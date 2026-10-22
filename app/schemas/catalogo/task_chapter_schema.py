from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class TaskChapterCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=150)
    stage_id: int = Field(..., description="Etapa de la obra a la que pertenece")
    description: Optional[str] = None
    display_order: int = 0
    weight_percent: Optional[Decimal] = Field(
        None,
        ge=0,
        le=100,
        description="% de cumplimiento: cuánto aporta este capítulo al 100% de su etapa",
    )


class TaskChapterUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=150)
    stage_id: Optional[int] = None
    description: Optional[str] = None
    display_order: Optional[int] = None
    weight_percent: Optional[Decimal] = Field(None, ge=0, le=100)
    is_active: Optional[int] = None


class TaskChapterResponse(BaseResponseSchema):
    name: str
    stage_id: Optional[int] = None
    stage_name: Optional[str] = None
    description: Optional[str] = None
    display_order: int
    weight_percent: Optional[Decimal] = None
    is_active: int
    created_at: Optional[datetime] = None
