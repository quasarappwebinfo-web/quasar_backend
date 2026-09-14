from datetime import date, datetime
from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class ObraCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=255)
    code: Optional[str] = Field(None, max_length=100)
    sale_type_id: int
    address: Optional[str] = None
    city: Optional[str] = None
    neighborhood: Optional[str] = None
    start_date: Optional[date] = None
    estimated_end_date: Optional[date] = None
    current_stage_id: Optional[int] = None
    status: str = Field(..., max_length=30)

class ObraUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    code: Optional[str] = None
    sale_type_id: Optional[int] = None
    address: Optional[str] = None
    city: Optional[str] = None
    neighborhood: Optional[str] = None
    start_date: Optional[date] = None
    estimated_end_date: Optional[date] = None
    actual_end_date: Optional[date] = None
    current_stage_id: Optional[int] = None
    status: Optional[str] = None
    is_active: Optional[int] = None

class ObraResponse(BaseResponseSchema):
    name: str
    code: Optional[str] = None
    sale_type_id: int
    address: Optional[str] = None
    city: Optional[str] = None
    neighborhood: Optional[str] = None
    start_date: Optional[date] = None
    estimated_end_date: Optional[date] = None
    actual_end_date: Optional[date] = None
    current_stage_id: Optional[int] = None
    status: str
    is_active: int
    created_at: Optional[datetime] = None
