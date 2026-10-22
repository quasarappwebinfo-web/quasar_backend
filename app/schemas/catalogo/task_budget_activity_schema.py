from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class TaskBudgetActivityCreate(BaseCreateSchema):
    chapter_id: int
    zone_id: Optional[int] = None
    name: str = Field(..., min_length=1, max_length=150)
    description: Optional[str] = None
    display_order: int = 0
    chapter_weight_percent: Optional[Decimal] = Field(
        None,
        ge=0,
        le=100,
        description=(
            "% de cumplimiento: cuánto aporta esta actividad presupuestal "
            "al 100% de su capítulo"
        ),
    )
    zone_weight_percent: Optional[Decimal] = Field(
        None, ge=0, le=100, description="% hacia el 100% de la zona"
    )


class TaskBudgetActivityUpdate(BaseUpdateSchema):
    chapter_id: Optional[int] = None
    zone_id: Optional[int] = None
    name: Optional[str] = Field(None, min_length=1, max_length=150)
    description: Optional[str] = None
    display_order: Optional[int] = None
    chapter_weight_percent: Optional[Decimal] = Field(None, ge=0, le=100)
    zone_weight_percent: Optional[Decimal] = Field(None, ge=0, le=100)
    is_active: Optional[int] = None


class TaskBudgetActivityResponse(BaseResponseSchema):
    chapter_id: Optional[int] = None
    chapter_name: Optional[str] = None
    zone_id: Optional[int] = None
    zone_name: Optional[str] = None
    name: str
    description: Optional[str] = None
    display_order: int
    chapter_weight_percent: Optional[Decimal] = None
    zone_weight_percent: Optional[Decimal] = None
    is_active: int
    created_at: Optional[datetime] = None
