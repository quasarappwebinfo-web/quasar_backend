from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class DocumentTypeCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=150)
    description: Optional[str] = None

class DocumentTypeUpdate(BaseUpdateSchema):
    name: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[int] = None

class DocumentTypeResponse(BaseResponseSchema):
    name: str
    description: Optional[str] = None
    is_active: int
