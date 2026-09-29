from datetime import date, datetime
from typing import Optional

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class WorkerAssignmentCreate(BaseCreateSchema):
    worker_id: int
    obra_id: int
    start_date: date
    end_date: Optional[date] = None


class WorkerAssignmentUpdate(BaseUpdateSchema):
    end_date: Optional[date] = None


class WorkerAssignmentResponse(BaseResponseSchema):
    worker_id: int
    obra_id: int
    start_date: date
    end_date: Optional[date] = None
    assigned_by: int
    person_name: Optional[str] = None
    obra_name: Optional[str] = None
    created_at: Optional[datetime] = None
