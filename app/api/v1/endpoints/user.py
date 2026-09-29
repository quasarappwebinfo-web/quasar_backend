from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db, require_permission
from app.core.permissions import (
    PERMISSION_IDENTIDAD,
    catalog_as_list,
)
from app.models import User
from app.schemas import (
    ChangePasswordRequest,
    PermissionCatalogItem,
    UserCreate,
    UserResponse,
    UserStatusUpdate,
    UserUpdate,
)
from app.services.role_service import list_active_roles
from app.services.user_service import (
    InvalidPasswordError,
    MasterUserProtectedError,
    PersonAlreadyHasUserError,
    PersonNotFoundForUserError,
    RoleNotFoundForUserError,
    UserAlreadyExistsError,
    UserNotFoundError,
    UserPermissionError,
    change_password,
    create_user,
    get_user,
    list_users,
    update_status_user,
    update_user,
    user_to_dict,
)

router = APIRouter(prefix="/api/v1/user", tags=["user"])


def _user_err(exc: Exception):
    if isinstance(exc, UserNotFoundError):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc))
    if isinstance(exc, PersonNotFoundForUserError):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc))
    if isinstance(exc, PersonAlreadyHasUserError):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc))
    if isinstance(exc, UserAlreadyExistsError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))
    if isinstance(exc, RoleNotFoundForUserError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))
    if isinstance(exc, MasterUserProtectedError):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(exc))
    if isinstance(exc, UserPermissionError):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(exc))
    if isinstance(exc, InvalidPasswordError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))
    if isinstance(exc, PermissionError):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(exc))
    if isinstance(exc, ValueError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))
    raise exc


@router.get(
    "/permissions/catalog",
    summary="Catálogo de permisos de módulo",
    description="Checklist para asignar a usuarios que no son admin/super_admin.",
)
async def permissions_catalog(
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    items = [
        PermissionCatalogItem(**p).model_dump(by_alias=True)
        for p in catalog_as_list()
    ]
    return {"permissions": items}


@router.get(
    "/users",
    summary="Listar Usuarios",
    description="Lista paginada con filtros opcionales por estado y búsqueda",
)
async def list_users_endpoint(
    status_id: Optional[int] = Query(
        None, description="Filtrar por estado (2=Inactivo, 1=Activo)"
    ),
    page: int = Query(1, ge=1, description="Número de página"),
    search: Optional[str] = Query(None, description="Buscar por nombre o username"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    result = await list_users(db=db, status_id=status_id, page=page, search=search)
    users_serialized = [
        UserResponse(**user_dict).model_dump(by_alias=True)
        for user_dict in result["users"]
    ]
    return {"users": users_serialized, "pagination": result["pagination"]}


@router.get(
    "/users/{user_id}",
    response_model=UserResponse,
    summary="Obtener usuario por ID",
)
async def get_user_endpoint(
    user_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    try:
        db_user = await get_user(db=db, user_id=user_id)
        return UserResponse(**user_to_dict(db_user)).model_dump(by_alias=True)
    except Exception as e:
        _user_err(e)


@router.post(
    "/users",
    response_model=UserResponse,
    summary="Crear Usuario",
    description=(
        "Crea usuario ligado a personId + username + password + roleId. "
        "Si el rol no es admin/super_admin, enviar permissions[] del catálogo."
    ),
    status_code=status.HTTP_201_CREATED,
)
async def create_user_endpoint(
    user: UserCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    try:
        db_user = await create_user(db=db, user=user, actor=user_auth)
        return UserResponse(**user_to_dict(db_user)).model_dump(by_alias=True)
    except Exception as e:
        _user_err(e)


@router.put(
    "/users/{user_id}",
    response_model=UserResponse,
    summary="Actualizar Usuario",
)
async def update_user_endpoint(
    user_id: int,
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    try:
        db_user = await update_user(
            db=db, user_id=user_id, user_update=user_update, actor=user_auth
        )
        return UserResponse(**user_to_dict(db_user)).model_dump(by_alias=True)
    except Exception as e:
        _user_err(e)


@router.put(
    "/users/{user_id}/update-status",
    summary="Activar / desactivar usuario",
    description=(
        "Body: isActive (1|2) y deactivationReason (obligatorio al desactivar). "
        "Al reactivar se limpia el motivo. Super admin intocable."
    ),
)
async def update_status_user_endpoint(
    user_id: int,
    body: UserStatusUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    try:
        updated_user = await update_status_user(
            db=db, user_id=user_id, data=body, actor=user_auth
        )
        return JSONResponse(
            status_code=status.HTTP_200_OK,
            content={
                "message": "Usuario modificado con éxito",
                "userId": updated_user.id,
                "username": updated_user.username,
                "name": updated_user.person.name if updated_user.person else "",
                "isActive": updated_user.is_active,
                "deactivationReason": updated_user.deactivation_reason,
            },
        )
    except Exception as e:
        _user_err(e)


@router.put(
    "/users/{user_id}/password",
    summary="Cambiar contraseña (admin)",
    description=(
        "Admin/super puede cambiar contraseña de operativos. "
        "Solo super admin cambia la de un admin. Super admin: no."
    ),
)
async def change_password_admin_endpoint(
    user_id: int,
    body: ChangePasswordRequest,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    try:
        await change_password(
            db=db,
            user_id=user_id,
            data=body,
            actor=user_auth,
            require_current=False,
        )
        return {"message": "Contraseña actualizada"}
    except Exception as e:
        _user_err(e)


@router.put(
    "/me/password",
    summary="Cambiar mi contraseña",
    description="El usuario autenticado cambia su propia contraseña (exige currentPassword).",
)
async def change_own_password_endpoint(
    body: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    try:
        await change_password(
            db=db,
            user_id=current_user.id,
            data=body,
            actor=current_user,
            require_current=True,
        )
        return {"message": "Contraseña actualizada"}
    except Exception as e:
        _user_err(e)


@router.get(
    "/roles/active",
    summary="Listar Roles Activos",
    description="Atajo para selects. Preferir GET /api/v1/identidad/roles?activeOnly=true",
)
async def list_active_roles_endpoint(
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    roles = await list_active_roles(db=db)
    # No ofrecer super_admin en selects de alta
    roles = [r for r in roles if r["name"] != "super_admin"]
    return {"roles": roles}
