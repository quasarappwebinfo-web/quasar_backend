from datetime import datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class UserCreate(BaseCreateSchema):
    person_id: int
    username: str = Field(..., min_length=1, max_length=255)
    password: str = Field(..., min_length=1)
    email: Optional[str] = Field(None, max_length=255)
    role_id: Optional[int] = None
    is_super: int = 0


class UserUpdate(BaseUpdateSchema):
    email: Optional[str] = Field(None, max_length=255)
    role_id: Optional[int] = None
    is_super: Optional[int] = None
    username: Optional[str] = Field(None, min_length=1, max_length=255)


class UserResponse(BaseResponseSchema):
    person_id: int
    username: str
    email: Optional[str] = None
    role_id: Optional[int] = None
    is_super: int
    is_active: int
    person_name: str = Field(..., description="Nombre desde persons.name")
    role_name: str = Field("", description="Nombre del rol")
    created_at: Optional[datetime] = None


class UserInDB(UserResponse):
    pass
