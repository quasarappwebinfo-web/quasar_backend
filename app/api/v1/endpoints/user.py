from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app.api.deps import get_db, require_role
from app.models import User
from app.schemas import UserCreate, UserResponse, UserUpdate
from app.services.user_service import (
    UserAlreadyExistsError,
    UserNotFoundError,
    create_user,
    list_active_roles,
    list_users,
    update_status_user,
    update_user,
    user_to_dict,
)

router = APIRouter(prefix="/api/v1/user", tags=["user"])


@router.get(
    "/users",
    summary="Listar Usuarios",
    description="Lista paginada con filtros opcionales por estado y búsqueda",
)
async def list_users_endpoint(
    status_id: Optional[int] = Query(None, description="Filtrar por estado (2=Inactivo, 1=Activo)"),
    page: int = Query(1, ge=1, description="Número de página"),
    search: Optional[str] = Query(None, description="Buscar por nombre o username"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_role(["admin"])),
):
    _ = user_auth
    result = await list_users(db=db, status_id=status_id, page=page, search=search)
    users_serialized = [
        UserResponse(**user_dict).model_dump(by_alias=True) for user_dict in result["users"]
    ]
    return {"users": users_serialized, "pagination": result["pagination"]}


@router.post(
    "/users",
    response_model=UserResponse,
    summary="Crear Usuario",
)
async def create_user_endpoint(
    user: UserCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_role(["admin"])),
):
    _ = user_auth
    try:
        db_user = await create_user(db=db, user=user)
        user_dict = user_to_dict(db_user)
        return UserResponse(**user_dict).model_dump(by_alias=True)
    except UserAlreadyExistsError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="El usuario ya existe",
        )


@router.put(
    "/users/{user_id}",
    response_model=UserResponse,
    summary="Actualizar Usuario",
)
async def update_user_endpoint(
    user_id: int,
    user_update: UserUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_role(["admin"])),
):
    _ = user_auth
    try:
        db_user = await update_user(db=db, user_id=user_id, user_update=user_update)
        user_dict = user_to_dict(db_user)
        return UserResponse(**user_dict).model_dump(by_alias=True)
    except UserNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except UserAlreadyExistsError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.put(
    "/users/{user_id}/update-status",
    summary="Cambiar Estado de Usuario",
)
async def update_status_user_endpoint(
    user_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_role(["admin"])),
):
    _ = user_auth
    try:
        updated_user = update_status_user(db=db, user_id=user_id)
        return JSONResponse(
            status_code=status.HTTP_200_OK,
            content={
                "message": "Usuario Modificado Con Éxito",
                "userId": updated_user.id,
                "username": updated_user.username,
                "name": updated_user.person.name if updated_user.person else "",
                "is_active": updated_user.is_active,
            },
        )
    except HTTPException as http_error:
        raise http_error
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error inesperado: {str(e)}",
        )


@router.get(
    "/roles/active",
    summary="Listar Roles Activos",
)
async def list_active_roles_endpoint(
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_role(["admin"])),
):
    _ = user_auth
    roles = await list_active_roles(db=db)
    return {"roles": roles}
