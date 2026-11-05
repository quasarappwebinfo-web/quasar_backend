from datetime import datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class PersonBase(BaseCreateSchema):
    document_number: str = Field(..., min_length=1, max_length=20)
    name: str = Field(..., min_length=1, max_length=255)
    photo_url: Optional[str] = Field(None, max_length=255)


class PersonCreate(PersonBase):
    pass


class PersonUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    photo_url: Optional[str] = Field(None, max_length=255)


class PersonResponse(BaseResponseSchema):
    document_number: str
    name: str
    photo_url: Optional[str] = None
    created_at: Optional[datetime] = None
    is_user: bool = False
    is_worker: bool = False
