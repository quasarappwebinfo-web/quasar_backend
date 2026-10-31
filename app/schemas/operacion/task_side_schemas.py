"""Schemas laterales de tareas (asignaciones, deps, evidencias)."""
from datetime import date, datetime
from decimal import Decimal
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


class DelayReasonCreate(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=150)
    description: Optional[str] = None


class DelayReasonUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=150)
    description: Optional[str] = None
    is_active: Optional[int] = None


class DelayReasonResponse(BaseResponseSchema):
    name: str
    description: Optional[str] = None
    is_active: int


# --- Assignments ---


class TaskAssignmentAdd(BaseCreateSchema):
    worker_id: int
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class TaskAssignmentCreate(TaskAssignmentAdd):
    task_id: int


class TaskAssignmentResponse(BaseResponseSchema):
    task_id: int
    worker_id: int
    worker_name: Optional[str] = None
    position_name: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    assigned_at: Optional[datetime] = None
    assigned_by: int
    removed_at: Optional[datetime] = None
    removed_by: Optional[int] = None


class TaskCrewAssignmentAdd(BaseCreateSchema):
    crew_id: int
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class TaskCrewAssignmentCreate(TaskCrewAssignmentAdd):
    task_id: int


class TaskCrewAssignmentResponse(BaseResponseSchema):
    task_id: int
    crew_id: int
    crew_name: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    assigned_at: Optional[datetime] = None
    assigned_by: int
    removed_at: Optional[datetime] = None
    removed_by: Optional[int] = None


# --- Dependencies ---


class TaskDependencyAdd(BaseCreateSchema):
    depends_on_task_id: int
    dependency_type: str = Field("finish_to_start", max_length=30)
    is_required: int = 1
    blocks_start: int = 1


class TaskDependencyCreate(TaskDependencyAdd):
    task_id: int


class TaskDependencyResponse(BaseResponseSchema):
    task_id: int
    depends_on_task_id: int
    depends_on_task_name: Optional[str] = None
    depends_on_status: Optional[str] = None
    dependency_type: str
    is_required: int
    blocks_start: int
    created_at: Optional[datetime] = None


class TaskDependencyOverrideAdd(BaseCreateSchema):
    template_dependency_id: int
    override_type: str = Field(
        ...,
        description="waive = no aplica; relax = no bloquea inicio",
        max_length=30,
    )
    reason: str = Field(..., min_length=1)


class TaskDependencyOverrideCreate(TaskDependencyOverrideAdd):
    task_id: int


class TaskDependencyOverrideResponse(BaseResponseSchema):
    task_id: int
    template_dependency_id: int
    override_type: str
    reason: Optional[str] = None
    created_by: int
    created_at: Optional[datetime] = None


# --- History / reschedule / delay ---


class TaskStatusHistoryResponse(BaseResponseSchema):
    task_id: int
    from_status: Optional[str] = None
    to_status: str
    reason: Optional[str] = None
    changed_by: int
    changed_at: Optional[datetime] = None


class TaskRescheduleAdd(BaseCreateSchema):
    uuid: Optional[str] = Field(None, max_length=36)
    new_start_date: Optional[date] = None
    new_end_date: Optional[date] = None
    reason_id: Optional[int] = None
    reason: Optional[str] = None


class TaskRescheduleCreate(TaskRescheduleAdd):
    task_id: int
    previous_start_date: Optional[date] = None
    previous_end_date: Optional[date] = None


class TaskRescheduleResponse(BaseResponseSchema):
    uuid: str
    task_id: int
    previous_start_date: Optional[date] = None
    previous_end_date: Optional[date] = None
    new_start_date: Optional[date] = None
    new_end_date: Optional[date] = None
    reason_id: Optional[int] = None
    reason_name: Optional[str] = None
    reason: Optional[str] = None
    rescheduled_by: int
    rescheduled_at: Optional[datetime] = None


class TaskDelayEventAdd(BaseCreateSchema):
    uuid: Optional[str] = Field(None, max_length=36)
    delay_reason_id: Optional[int] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    days_lost: Optional[Decimal] = None
    description: Optional[str] = None


class TaskDelayEventCreate(TaskDelayEventAdd):
    task_id: int


class TaskDelayEventResponse(BaseResponseSchema):
    uuid: str
    task_id: int
    delay_reason_id: Optional[int] = None
    delay_reason_name: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    days_lost: Optional[Decimal] = None
    description: Optional[str] = None
    created_by: int
    created_at: Optional[datetime] = None


# --- Comments / photos ---


class TaskCommentAdd(BaseCreateSchema):
    uuid: Optional[str] = Field(None, max_length=36)
    type: str = Field("comment", max_length=30)
    content: str = Field(..., min_length=1)


class TaskCommentCreate(TaskCommentAdd):
    task_id: int


class TaskCommentUpdate(BaseUpdateSchema):
    content: Optional[str] = Field(None, min_length=1)
    type: Optional[str] = Field(None, max_length=30)


class TaskCommentResponse(BaseResponseSchema):
    uuid: str
    task_id: int
    user_id: int
    user_name: Optional[str] = None
    type: str
    content: str
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class TaskPhotoAdd(BaseCreateSchema):
    """Metadatos si ya tienes URL (sin upload). Preferir multipart upload."""

    uuid: Optional[str] = Field(None, max_length=36)
    file_url: str = Field(..., max_length=500)
    description: Optional[str] = None
    taken_at: Optional[datetime] = None


class TaskPhotoCreate(TaskPhotoAdd):
    task_id: int


class TaskPhotoResponse(BaseResponseSchema):
    uuid: str
    task_id: int
    file_url: str
    description: Optional[str] = None
    taken_at: Optional[datetime] = None
    uploaded_by: int
    uploaded_by_name: Optional[str] = None
    created_at: Optional[datetime] = None


class TaskPhotoGalleryItem(BaseResponseSchema):
    file_url: str
    description: Optional[str] = None
    taken_at: Optional[datetime] = None
    created_at: Optional[datetime] = None
    uploaded_by_name: Optional[str] = None
    task_id: Optional[int] = None
    task_name: str
    kind: str = "task"
    subtask_name: Optional[str] = None
    chapter_id: Optional[int] = None
    chapter_name: Optional[str] = None
    budget_activity_id: Optional[int] = None
    budget_activity_name: Optional[str] = None


# --- Documents ---


class TaskDocumentResponse(BaseResponseSchema):
    uuid: str
    task_id: int
    name: str
    description: Optional[str] = None
    file_url: str
    content_type: Optional[str] = None
    file_size_bytes: Optional[int] = None
    uploaded_by: int
    uploaded_by_name: Optional[str] = None
    created_at: Optional[datetime] = None
