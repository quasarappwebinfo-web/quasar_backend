from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class SpecialtyCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=255)
    worker_position_id: Optional[int] = None


class SpecialtyUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    worker_position_id: Optional[int] = None
    is_active: Optional[int] = None


class SpecialtyResponse(BaseResponseSchema):
    name: str
    worker_position_id: Optional[int] = None
    is_active: int
