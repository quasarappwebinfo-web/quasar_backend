from datetime import date, datetime
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class ObraClientCreate(BaseCreateSchema):
    obra_id: int
    person_id: int
    role: str = Field(..., max_length=30)
    is_primary: int = 0
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class ObraClientAdd(BaseCreateSchema):
    """Body para POST /obras/{id}/clientes (obraId viene de la URL)."""

    person_id: int
    role: str = Field(..., max_length=30)
    is_primary: int = 0
    start_date: Optional[date] = None


class ObraClientUpdate(BaseUpdateSchema):
    role: Optional[str] = Field(None, max_length=30)
    is_primary: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class ObraClientResponse(BaseResponseSchema):
    obra_id: int
    person_id: int
    role: str
    is_primary: int
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    person_name: Optional[str] = None
    document_number: Optional[str] = None
    created_at: Optional[datetime] = None
