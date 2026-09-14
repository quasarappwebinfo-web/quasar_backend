from datetime import datetime
from typing import Optional

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class CrewMemberCreate(BaseCreateSchema):
    crew_id: int
    worker_id: int


class CrewMemberUpdate(BaseUpdateSchema):
    left_at: Optional[datetime] = None


class CrewMemberResponse(BaseResponseSchema):
    crew_id: int
    worker_id: int
    joined_at: datetime
    left_at: Optional[datetime] = None
