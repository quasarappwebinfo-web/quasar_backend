from datetime import date, datetime
from decimal import Decimal
from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class TaskCreate(BaseCreateSchema):
    uuid: Optional[str] = Field(None, max_length=36)
    obra_id: int
    source_template_version_id: Optional[int] = None
    parent_task_id: Optional[int] = None
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    unit_id: Optional[int] = None
    planned_quantity: Optional[Decimal] = None
    template_base_quantity: Optional[Decimal] = None
    template_base_duration_days: Optional[Decimal] = None
    estimated_duration_days: Optional[Decimal] = None
    approved_duration_days: Optional[Decimal] = None
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    status: str = Field(..., max_length=30)

class TaskUpdate(BaseUpdateSchema):
    name: Optional[str] = None
    description: Optional[str] = None
    unit_id: Optional[int] = None
    planned_quantity: Optional[Decimal] = None
    estimated_duration_days: Optional[Decimal] = None
    approved_duration_days: Optional[Decimal] = None
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    actual_start_date: Optional[date] = None
    actual_end_date: Optional[date] = None
    status: Optional[str] = None

class TaskResponse(BaseResponseSchema):
    uuid: str
    obra_id: int
    source_template_version_id: Optional[int] = None
    parent_task_id: Optional[int] = None
    name: str
    description: Optional[str] = None
    unit_id: Optional[int] = None
    planned_quantity: Optional[Decimal] = None
    template_base_quantity: Optional[Decimal] = None
    template_base_duration_days: Optional[Decimal] = None
    estimated_duration_days: Optional[Decimal] = None
    approved_duration_days: Optional[Decimal] = None
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    actual_start_date: Optional[date] = None
    actual_end_date: Optional[date] = None
    status: str
    created_by: int
    created_at: Optional[datetime] = None
