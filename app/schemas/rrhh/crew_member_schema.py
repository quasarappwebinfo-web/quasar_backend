from datetime import datetime
from typing import Optional

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class CrewMemberCreate(BaseCreateSchema):
    crew_id: int
    worker_id: int


class CrewMemberAdd(BaseCreateSchema):
    """Body para POST /cuadrillas/{id}/miembros (crewId viene de la URL)."""

    worker_id: int


class CrewMemberUpdate(BaseUpdateSchema):
    left_at: Optional[datetime] = None


class CrewMemberResponse(BaseResponseSchema):
    crew_id: int
    worker_id: int
    joined_at: datetime
    left_at: Optional[datetime] = None
    person_name: Optional[str] = None
    document_number: Optional[str] = None
