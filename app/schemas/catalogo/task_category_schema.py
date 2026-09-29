from datetime import datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class TaskCategoryCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=150)
    description: Optional[str] = None
    display_order: int = 0


class TaskCategoryUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=150)
    description: Optional[str] = None
    display_order: Optional[int] = None
    is_active: Optional[int] = None


class TaskCategoryResponse(BaseResponseSchema):
    name: str
    description: Optional[str] = None
    display_order: int
    is_active: int
    created_at: Optional[datetime] = None
