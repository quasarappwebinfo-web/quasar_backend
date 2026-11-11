from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class TaskZoneCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=150)
    description: Optional[str] = None
    display_order: int = 0
    weight_percent: Optional[Decimal] = Field(
        None,
        ge=0,
        le=100,
        description="% de esta zona sobre la obra. Vacío: la zona no suma al avance",
    )


class TaskZoneUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=150)
    description: Optional[str] = None
    display_order: Optional[int] = None
    weight_percent: Optional[Decimal] = Field(None, ge=0, le=100)
    is_active: Optional[int] = None


class TaskZoneResponse(BaseResponseSchema):
    name: str
    description: Optional[str] = None
    display_order: int
    weight_percent: Optional[Decimal] = None
    is_active: int
    created_at: Optional[datetime] = None
