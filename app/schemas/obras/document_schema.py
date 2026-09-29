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


class DocumentAdd(BaseCreateSchema):
    """Body para POST /obras/{id}/documentos (obraId viene de la URL)."""

    uuid: Optional[str] = Field(None, max_length=36)
    document_type_id: int
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    file_url: str = Field(..., max_length=500)
    is_visible_to_client: int = 0


class DocumentUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    file_url: Optional[str] = Field(None, max_length=500)
    is_visible_to_client: Optional[int] = None


class DocumentResponse(BaseResponseSchema):
    uuid: str
    obra_id: int
    document_type_id: int
    document_type_name: Optional[str] = None
    name: str
    description: Optional[str] = None
    file_url: str
    is_visible_to_client: int
    uploaded_by: int
    created_at: Optional[datetime] = None
