from datetime import datetime
from typing import List, Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseSchema, BaseUpdateSchema


class UserCreate(BaseCreateSchema):
    person_id: int
    username: str = Field(..., min_length=1, max_length=255)
    password: str = Field(..., min_length=1)
    email: Optional[str] = Field(None, max_length=255)
    role_id: Optional[int] = None
    permissions: Optional[List[str]] = Field(
        None,
        description="Códigos de módulo (solo si el rol no es admin/super_admin)",
    )


class UserUpdate(BaseUpdateSchema):
    email: Optional[str] = Field(None, max_length=255)
    role_id: Optional[int] = None
    username: Optional[str] = Field(None, min_length=1, max_length=255)
    permissions: Optional[List[str]] = Field(
        None,
        description="Reemplaza la lista de permisos (omitir = no tocar)",
    )


class UserStatusUpdate(BaseSchema):
    """Activar (1) o desactivar (2) un usuario."""

    is_active: int = Field(..., description="1=activo, 2=inactivo")
    deactivation_reason: Optional[str] = Field(
        None,
        max_length=255,
        description="Obligatorio al desactivar (isActive=2)",
    )


class ChangePasswordRequest(BaseSchema):
    new_password: str = Field(..., min_length=1)
    current_password: Optional[str] = Field(
        None,
        description="Requerido cuando el usuario cambia su propia contraseña",
    )


class UserResponse(BaseResponseSchema):
    person_id: int
    username: str
    email: Optional[str] = None
    role_id: Optional[int] = None
    is_super: int
    is_active: int
    deactivation_reason: Optional[str] = None
    person_name: str = Field(..., description="Nombre desde persons.name")
    role_name: str = Field("", description="Nombre del rol")
    permissions: List[str] = Field(default_factory=list)
    has_full_access: bool = False
    created_at: Optional[datetime] = None


class UserInDB(UserResponse):
    pass


class PermissionCatalogItem(BaseSchema):
    code: str
    label: str
    description: str = ""
