from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class WorkerPositionCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=255)


class WorkerPositionUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    is_active: Optional[int] = None


class WorkerPositionResponse(BaseResponseSchema):
    name: str
    is_active: int
