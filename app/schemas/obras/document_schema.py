from datetime import datetime
from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class DocumentCreate(BaseCreateSchema):
    uuid: Optional[str] = Field(None, max_length=36)
    obra_id: int
    document_type_id: int
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    file_url: str = Field(..., max_length=500)
    is_visible_to_client: int = 0

class DocumentUpdate(BaseUpdateSchema):
    name: Optional[str] = None
    description: Optional[str] = None
    file_url: Optional[str] = None
    is_visible_to_client: Optional[int] = None

class DocumentResponse(BaseResponseSchema):
    uuid: str
    obra_id: int
    document_type_id: int
    name: str
    description: Optional[str] = None
    file_url: str
    is_visible_to_client: int
    uploaded_by: int
    created_at: Optional[datetime] = None
