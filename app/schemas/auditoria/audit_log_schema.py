from datetime import datetime
from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema

class AuditLogCreate(BaseCreateSchema):
    entity_type: str = Field(..., max_length=50)
    entity_id: int
    action: str = Field(..., max_length=50)
    field_changed: Optional[str] = None
    old_value: Optional[str] = None
    new_value: Optional[str] = None
    reason: Optional[str] = None

class AuditLogResponse(BaseResponseSchema):
    entity_type: str
    entity_id: int
    action: str
    field_changed: Optional[str] = None
    old_value: Optional[str] = None
    new_value: Optional[str] = None
    reason: Optional[str] = None
    changed_by: int
    changed_at: datetime
