from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class ObraSaleTypeCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=100)

class ObraSaleTypeUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=100)
    is_active: Optional[int] = None

class ObraSaleTypeResponse(BaseResponseSchema):
    name: str
    is_active: int
