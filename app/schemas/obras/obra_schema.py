from datetime import date, datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseSchema, BaseUpdateSchema

OBRA_STATUSES = ("planning", "in_progress", "on_hold", "completed", "cancelled")
OBRA_CLIENT_ROLES = ("comprador", "propietario", "contacto")


class ObraCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=255)
    code: Optional[str] = Field(None, max_length=100)
    sale_type_id: int
    address: Optional[str] = Field(None, max_length=255)
    city: Optional[str] = Field(None, max_length=150)
    neighborhood: Optional[str] = Field(None, max_length=150)
    start_date: Optional[date] = None
    estimated_end_date: Optional[date] = None
    current_stage_id: Optional[int] = None
    status: str = Field("planning", max_length=30)


class ObraUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    code: Optional[str] = Field(None, max_length=100)
    sale_type_id: Optional[int] = None
    address: Optional[str] = Field(None, max_length=255)
    city: Optional[str] = Field(None, max_length=150)
    neighborhood: Optional[str] = Field(None, max_length=150)
    start_date: Optional[date] = None
    estimated_end_date: Optional[date] = None
    actual_end_date: Optional[date] = None
    status: Optional[str] = Field(None, max_length=30)
    is_active: Optional[int] = None


class ObraStageChange(BaseSchema):
    """Cambiar etapa actual y registrar historial."""

    stage_id: int
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    actual_start_date: Optional[date] = None
    actual_end_date: Optional[date] = None


class ObraResponse(BaseResponseSchema):
    name: str
    code: Optional[str] = None
    sale_type_id: int
    sale_type_name: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    neighborhood: Optional[str] = None
    start_date: Optional[date] = None
    estimated_end_date: Optional[date] = None
    actual_end_date: Optional[date] = None
    current_stage_id: Optional[int] = None
    current_stage_name: Optional[str] = None
    status: str
    cover_image_url: Optional[str] = None
    is_active: int
    created_at: Optional[datetime] = None
