from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class MeasurementUnitCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=100)
    symbol: str = Field(..., min_length=1, max_length=30)

class MeasurementUnitUpdate(BaseUpdateSchema):
    name: Optional[str] = None
    symbol: Optional[str] = None
    is_active: Optional[int] = None

class MeasurementUnitResponse(BaseResponseSchema):
    name: str
    symbol: str
    is_active: int
