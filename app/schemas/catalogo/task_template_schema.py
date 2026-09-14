from datetime import datetime
from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class TaskTemplateCreate(BaseCreateSchema):
    category_id: int
    name: str = Field(..., min_length=1, max_length=255)
    code: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None

class TaskTemplateUpdate(BaseUpdateSchema):
    category_id: Optional[int] = None
    name: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[int] = None

class TaskTemplateResponse(BaseResponseSchema):
    category_id: int
    name: str
    code: str
    description: Optional[str] = None
    is_active: int
    created_at: Optional[datetime] = None
