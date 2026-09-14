from datetime import datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class WorkerCreate(BaseCreateSchema):
    person_id: int
    worker_position_id: Optional[int] = None
    specialty_id: Optional[int] = None
    linked_user_id: Optional[int] = None


class WorkerUpdate(BaseUpdateSchema):
    worker_position_id: Optional[int] = None
    specialty_id: Optional[int] = None
    linked_user_id: Optional[int] = None
    is_active: Optional[int] = None
    deactivation_reason: Optional[str] = Field(None, max_length=255)


class WorkerResponse(BaseResponseSchema):
    person_id: int
    worker_position_id: Optional[int] = None
    specialty_id: Optional[int] = None
    linked_user_id: Optional[int] = None
    is_active: int
    deactivation_reason: Optional[str] = None
    person_name: Optional[str] = None
    created_at: Optional[datetime] = None
