from datetime import datetime
from decimal import Decimal
from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class TaskTemplateVersionCreate(BaseCreateSchema):
    task_template_id: int
    version_number: int
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    status: str = Field(..., max_length=30)
    base_quantity: Optional[Decimal] = None
    base_duration_days: Optional[Decimal] = None

class TaskTemplateVersionUpdate(BaseUpdateSchema):
    name: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    base_quantity: Optional[Decimal] = None
    base_duration_days: Optional[Decimal] = None

class TaskTemplateVersionResponse(BaseResponseSchema):
    task_template_id: int
    version_number: int
    name: str
    description: Optional[str] = None
    status: str
    base_quantity: Optional[Decimal] = None
    base_duration_days: Optional[Decimal] = None
    published_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
