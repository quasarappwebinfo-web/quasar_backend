from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class TaskTemplateCreate(BaseCreateSchema):
    category_id: int
    zone_id: int
    budget_activity_id: int
    name: str = Field(..., min_length=1, max_length=255)
    code: str = Field(..., min_length=1, max_length=100)
    description: Optional[str] = None
    budget_weight_percent: Optional[Decimal] = Field(
        None,
        ge=0,
        le=100,
        description="% que esta actividad aporta a su actividad presupuestal",
    )


class TaskTemplateUpdate(BaseUpdateSchema):
    category_id: Optional[int] = None
    zone_id: Optional[int] = None
    budget_activity_id: Optional[int] = None
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    budget_weight_percent: Optional[Decimal] = Field(None, ge=0, le=100)
    is_active: Optional[int] = None


class TaskTemplateResponse(BaseResponseSchema):
    category_id: int
    category_name: Optional[str] = None
    zone_id: Optional[int] = None
    zone_name: Optional[str] = None
    budget_activity_id: Optional[int] = None
    budget_activity_name: Optional[str] = None
    name: str
    code: str
    description: Optional[str] = None
    budget_weight_percent: Optional[Decimal] = None
    is_active: int
    created_at: Optional[datetime] = None
