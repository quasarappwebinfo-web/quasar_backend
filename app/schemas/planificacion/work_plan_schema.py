from datetime import date, datetime
from decimal import Decimal
from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class WorkPlanCreate(BaseCreateSchema):
    uuid: Optional[str] = None
    obra_id: int
    name: str = Field(..., min_length=1, max_length=255)
    start_date: date
    end_date: date
    status: str = Field(..., max_length=30)

class WorkPlanUpdate(BaseUpdateSchema):
    name: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    status: Optional[str] = None
    current_version_id: Optional[int] = None

class WorkPlanResponse(BaseResponseSchema):
    uuid: str
    obra_id: int
    name: str
    start_date: date
    end_date: date
    status: str
    current_version_id: Optional[int] = None
    requested_by: int
    created_at: Optional[datetime] = None

class WorkPlanVersionCreate(BaseCreateSchema):
    work_plan_id: int
    version_number: int

class WorkPlanVersionResponse(BaseResponseSchema):
    work_plan_id: int
    version_number: int
    created_by: int
    created_at: Optional[datetime] = None
    signed_at: Optional[datetime] = None

class WorkPlanTaskCreate(BaseCreateSchema):
    work_plan_version_id: int
    task_id: int
    task_name_snapshot: str
    task_description_snapshot: Optional[str] = None
    quantity_snapshot: Optional[Decimal] = None
    unit_snapshot: Optional[str] = None
    planned_start_date: date
    planned_end_date: date
    estimated_duration_days_snapshot: Optional[Decimal] = None
    approved_duration_days_snapshot: Optional[Decimal] = None

class WorkPlanTaskResponse(BaseResponseSchema):
    work_plan_version_id: int
    task_id: int
    task_name_snapshot: str
    task_description_snapshot: Optional[str] = None
    quantity_snapshot: Optional[Decimal] = None
    unit_snapshot: Optional[str] = None
    planned_start_date: date
    planned_end_date: date
    estimated_duration_days_snapshot: Optional[Decimal] = None
    approved_duration_days_snapshot: Optional[Decimal] = None
    created_at: Optional[datetime] = None

class WorkPlanSignerCreate(BaseCreateSchema):
    work_plan_version_id: int
    user_id: int
    signature_order: Optional[int] = None
    status: str = "pending"

class WorkPlanSignerResponse(BaseResponseSchema):
    work_plan_version_id: int
    user_id: int
    signature_order: Optional[int] = None
    status: str
    requested_at: datetime
    signed_at: Optional[datetime] = None
    rejected_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None

class WorkPlanSignatureCreate(BaseCreateSchema):
    work_plan_signer_id: int
    signature_type: str
    signature_data: Optional[str] = None

class WorkPlanSignatureResponse(BaseResponseSchema):
    work_plan_signer_id: int
    user_id: int
    signature_type: str
    signature_data: Optional[str] = None
    signed_at: datetime
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None

class WorkPlanSignatureEventResponse(BaseResponseSchema):
    work_plan_version_id: int
    user_id: Optional[int] = None
    event_type: str
    event_at: datetime
    details: Optional[str] = None
