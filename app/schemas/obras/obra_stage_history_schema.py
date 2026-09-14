from datetime import date, datetime
from typing import Optional
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class ObraStageHistoryCreate(BaseCreateSchema):
    obra_id: int
    stage_id: int
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    actual_start_date: Optional[date] = None
    actual_end_date: Optional[date] = None

class ObraStageHistoryUpdate(BaseUpdateSchema):
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    actual_start_date: Optional[date] = None
    actual_end_date: Optional[date] = None

class ObraStageHistoryResponse(BaseResponseSchema):
    obra_id: int
    stage_id: int
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    actual_start_date: Optional[date] = None
    actual_end_date: Optional[date] = None
    created_at: Optional[datetime] = None
