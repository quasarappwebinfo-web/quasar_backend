from datetime import date, datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class PersonBase(BaseCreateSchema):
    document_number: str = Field(..., min_length=1, max_length=20)
    name: str = Field(..., min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=255)
    photo_url: Optional[str] = Field(None, max_length=255)
    birth_date: Optional[date] = None


class PersonCreate(PersonBase):
    pass


class PersonUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    phone: Optional[str] = Field(None, max_length=255)
    photo_url: Optional[str] = Field(None, max_length=255)
    birth_date: Optional[date] = None


class PersonResponse(BaseResponseSchema):
    document_number: str
    name: str
    phone: Optional[str] = None
    photo_url: Optional[str] = None
    birth_date: Optional[date] = None
    created_at: Optional[datetime] = None
