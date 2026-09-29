from datetime import datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseSchema, BaseUpdateSchema


class WorkerCreate(BaseCreateSchema):
    person_id: int
    worker_position_id: Optional[int] = None
    specialty_id: Optional[int] = None
    linked_user_id: Optional[int] = None


class WorkerUpdate(BaseUpdateSchema):
    worker_position_id: Optional[int] = None
    specialty_id: Optional[int] = None
    linked_user_id: Optional[int] = None


class WorkerStatusUpdate(BaseSchema):
    """Baja definitiva del trabajador (≠ salida de obra)."""

    is_active: int = Field(..., description="1=activo, 2=inactivo")
    deactivation_reason: Optional[str] = Field(
        None,
        max_length=255,
        description="Obligatorio al desactivar (isActive=2)",
    )


class WorkerResponse(BaseResponseSchema):
    person_id: int
    worker_position_id: Optional[int] = None
    specialty_id: Optional[int] = None
    linked_user_id: Optional[int] = None
    is_active: int
    deactivation_reason: Optional[str] = None
    person_name: Optional[str] = None
    document_number: Optional[str] = None
    position_name: Optional[str] = None
    specialty_name: Optional[str] = None
    linked_username: Optional[str] = None
    created_at: Optional[datetime] = None
