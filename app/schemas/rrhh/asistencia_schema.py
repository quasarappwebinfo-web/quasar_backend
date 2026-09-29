from datetime import date, datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseSchema


class ObraDailyAttendanceCreate(BaseCreateSchema):
    obra_id: int
    work_date: date
    worker_id: int
    signature_type: str = Field(
        "acknowledgment",
        max_length=30,
        description=(
            "acknowledgment = admin registra llegada (sin firma del trabajador). "
            "electronic = firma canvas (legacy)."
        ),
    )
    signature_data: Optional[str] = Field(
        None,
        max_length=500_000,
        description=(
            "Opcional. Con electronic: data:image/png;base64,... "
            "Con acknowledgment: nota corta o vacío."
        ),
    )


class ObraDailyAttendanceResponse(BaseResponseSchema):
    obra_id: int
    obra_name: Optional[str] = None
    work_date: date
    worker_id: int
    worker_name: Optional[str] = None
    document_number: Optional[str] = None
    position_name: Optional[str] = None
    signed_at: datetime
    signature_type: str
    signature_data: Optional[str] = None
    recorded_by: int
    recorded_by_name: Optional[str] = None
    created_at: Optional[datetime] = None
    removed_at: Optional[datetime] = None


class TaskDailyAssignmentCreate(BaseCreateSchema):
    worker_id: int
    work_date: date


class TaskDailyAssignmentResponse(BaseResponseSchema):
    task_id: int
    task_name: Optional[str] = None
    work_date: date
    worker_id: int
    worker_name: Optional[str] = None
    document_number: Optional[str] = None
    position_name: Optional[str] = None
    assigned_at: Optional[datetime] = None
    assigned_by: int
    assigned_by_name: Optional[str] = None
    removed_at: Optional[datetime] = None
