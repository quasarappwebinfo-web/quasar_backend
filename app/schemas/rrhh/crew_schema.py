from datetime import datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class CrewCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=255)
    leader_worker_id: Optional[int] = None
    obra_id: Optional[int] = None


class CrewUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    leader_worker_id: Optional[int] = None
    obra_id: Optional[int] = None
    is_active: Optional[int] = None


class CrewResponse(BaseResponseSchema):
    name: str
    leader_worker_id: Optional[int] = None
    obra_id: Optional[int] = None
    is_active: int
    created_at: Optional[datetime] = None
