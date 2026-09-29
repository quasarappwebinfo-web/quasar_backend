from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_IDENTIDAD
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import UserRoleCreate, UserRoleResponse, UserRoleUpdate
from app.services.role_service import (
    RoleAlreadyExistsError,
    RoleNotFoundError,
    RoleProtectedError,
    create_role,
    get_role,
    list_roles,
    role_to_dict,
    update_role,
)

router = APIRouter(prefix="/api/v1/identidad/roles", tags=["identidad-roles"])


@router.get(
    "",
    summary="Listar roles",
    description="Lista paginada de roles. Filtro opcional solo activos.",
)
async def list_roles_endpoint(
    page: int = Query(1, ge=1),
    search: Optional[str] = Query(None, description="Buscar por nombre de rol"),
    active_only: bool = Query(False, description="Si true, solo roles activos"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    result = await list_roles(
        db=db, page=page, search=search, active_only=active_only
    )
    roles_serialized = [
        UserRoleResponse(**r).model_dump(by_alias=True) for r in result["roles"]
    ]
    return {"roles": roles_serialized, "pagination": result["pagination"]}


@router.post(
    "",
    response_model=UserRoleResponse,
    summary="Crear rol",
    status_code=status.HTTP_201_CREATED,
)
async def create_role_endpoint(
    data: UserRoleCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    try:
        role = await create_role(db=db, data=data)
        return UserRoleResponse(**role_to_dict(role)).model_dump(by_alias=True)
    except RoleAlreadyExistsError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except RoleProtectedError as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))


@router.get(
    "/{role_id}",
    response_model=UserRoleResponse,
    summary="Obtener rol por ID",
)
async def get_role_endpoint(
    role_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    try:
        role = await get_role(db=db, role_id=role_id)
        return UserRoleResponse(**role_to_dict(role)).model_dump(by_alias=True)
    except RoleNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.put(
    "/{role_id}",
    response_model=UserRoleResponse,
    summary="Actualizar rol",
    description="Actualiza nombre y/o isActive (1=activo, 2=inactivo).",
)
async def update_role_endpoint(
    role_id: int,
    data: UserRoleUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    try:
        role = await update_role(db=db, role_id=role_id, data=data)
        return UserRoleResponse(**role_to_dict(role)).model_dump(by_alias=True)
    except RoleNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except RoleAlreadyExistsError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except RoleProtectedError as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
