from datetime import date, datetime
from decimal import Decimal
from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class DelayReasonCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=150)
    description: Optional[str] = None

class DelayReasonUpdate(BaseUpdateSchema):
    name: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[int] = None

class DelayReasonResponse(BaseResponseSchema):
    name: str
    description: Optional[str] = None
    is_active: int

class TaskAssignmentCreate(BaseCreateSchema):
    task_id: int
    worker_id: int
    start_date: Optional[date] = None
    end_date: Optional[date] = None

class TaskAssignmentResponse(BaseResponseSchema):
    task_id: int
    worker_id: int
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    assigned_at: datetime
    assigned_by: int
    removed_at: Optional[datetime] = None
    removed_by: Optional[int] = None

class TaskCrewAssignmentCreate(BaseCreateSchema):
    task_id: int
    crew_id: int
    start_date: Optional[date] = None
    end_date: Optional[date] = None

class TaskCrewAssignmentResponse(BaseResponseSchema):
    task_id: int
    crew_id: int
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    assigned_at: datetime
    assigned_by: int
    removed_at: Optional[datetime] = None
    removed_by: Optional[int] = None

class TaskDependencyCreate(BaseCreateSchema):
    task_id: int
    depends_on_task_id: int
    dependency_type: str
    is_required: int = 1
    blocks_start: int = 1

class TaskDependencyResponse(BaseResponseSchema):
    task_id: int
    depends_on_task_id: int
    dependency_type: str
    is_required: int
    blocks_start: int
    created_at: Optional[datetime] = None

class TaskDependencyOverrideCreate(BaseCreateSchema):
    task_id: int
    template_dependency_id: int
    override_type: str
    reason: Optional[str] = None

class TaskDependencyOverrideResponse(BaseResponseSchema):
    task_id: int
    template_dependency_id: int
    override_type: str
    reason: Optional[str] = None
    created_by: int
    created_at: Optional[datetime] = None

class TaskStatusHistoryResponse(BaseResponseSchema):
    task_id: int
    from_status: Optional[str] = None
    to_status: str
    reason: Optional[str] = None
    changed_by: int
    changed_at: datetime

class TaskRescheduleCreate(BaseCreateSchema):
    uuid: Optional[str] = None
    task_id: int
    previous_start_date: Optional[date] = None
    previous_end_date: Optional[date] = None
    new_start_date: Optional[date] = None
    new_end_date: Optional[date] = None
    reason_id: Optional[int] = None
    reason: Optional[str] = None

class TaskRescheduleResponse(BaseResponseSchema):
    uuid: str
    task_id: int
    previous_start_date: Optional[date] = None
    previous_end_date: Optional[date] = None
    new_start_date: Optional[date] = None
    new_end_date: Optional[date] = None
    reason_id: Optional[int] = None
    reason: Optional[str] = None
    rescheduled_by: int
    rescheduled_at: datetime

class TaskDelayEventCreate(BaseCreateSchema):
    uuid: Optional[str] = None
    task_id: int
    delay_reason_id: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    days_lost: Optional[Decimal] = None
    description: Optional[str] = None

class TaskDelayEventResponse(BaseResponseSchema):
    uuid: str
    task_id: int
    delay_reason_id: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    days_lost: Optional[Decimal] = None
    description: Optional[str] = None
    created_by: int
    created_at: Optional[datetime] = None

class TaskCommentCreate(BaseCreateSchema):
    uuid: Optional[str] = None
    task_id: int
    type: str = Field(..., max_length=30)
    content: str

class TaskCommentUpdate(BaseUpdateSchema):
    content: Optional[str] = None
    type: Optional[str] = None

class TaskCommentResponse(BaseResponseSchema):
    uuid: str
    task_id: int
    user_id: int
    type: str
    content: str
    created_at: Optional[datetime] = None

class TaskPhotoCreate(BaseCreateSchema):
    uuid: Optional[str] = None
    task_id: int
    file_url: str
    description: Optional[str] = None
    taken_at: Optional[datetime] = None

class TaskPhotoResponse(BaseResponseSchema):
    uuid: str
    task_id: int
    file_url: str
    description: Optional[str] = None
    taken_at: Optional[datetime] = None
    uploaded_by: int
    created_at: Optional[datetime] = None
