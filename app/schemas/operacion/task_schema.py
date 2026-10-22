"""Schemas de tareas en obra (Fase 6 — operación)."""
from datetime import date, datetime
from decimal import Decimal
from typing import List, Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseSchema, BaseUpdateSchema

TASK_STATUSES = (
    "scheduled",
    "in_progress",
    "completed",
    "verified",
    "rescheduled",
)

DEPENDENCY_TYPES = (
    "finish_to_start",
    "start_to_start",
    "finish_to_finish",
    "start_to_finish",
)

OVERRIDE_TYPES = ("waive", "relax")
COMMENT_TYPES = ("comment", "instruction")


class TaskCreateFromTemplate(BaseCreateSchema):
    """Crear tarea desde una actividad registrada.

    `template_id` basta para dejarla en un periodo, sin versión ni rendimiento.
    `source_template_version_id` sigue disponible cuando hay una versión published
    y se quiere copiar cantidad, subtareas y dependencias.
    """

    uuid: Optional[str] = Field(None, max_length=36)
    obra_id: int
    template_id: Optional[int] = Field(
        None,
        description="Actividad registrada. Sin versión no hay rendimiento ni sugerencia.",
    )
    source_template_version_id: Optional[int] = None
    planned_quantity: Optional[Decimal] = Field(
        None,
        gt=0,
        description="Opcional. Solo se usa si la versión tiene cantidad y duración base.",
    )
    approved_duration_days: Optional[Decimal] = Field(
        None, description="Si se omite, se usa la duración recomendada"
    )
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    name: Optional[str] = Field(
        None, max_length=255, description="Override del nombre de plantilla"
    )
    description: Optional[str] = None
    copy_subtasks: bool = True
    instantiate_dependencies: bool = True


class TaskAddToPeriod(BaseCreateSchema):
    """Agrega una actividad al periodo vigente y pide de nuevo la firma."""

    obra_id: int
    template_id: Optional[int] = Field(
        None,
        description="Actividad del pool. Sin versión ni rendimiento.",
    )
    name: Optional[str] = Field(
        None,
        max_length=255,
        description="Obligatorio si no hay templateId. Actividad única de la obra.",
    )
    description: Optional[str] = None
    justification: str = Field(..., min_length=8, max_length=2000)


class TaskCreateManual(BaseCreateSchema):
    """Tarea manual (sin plantilla) o subtarea."""

    uuid: Optional[str] = Field(None, max_length=36)
    obra_id: int
    parent_task_id: Optional[int] = None
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    unit_id: Optional[int] = None
    planned_quantity: Optional[Decimal] = None
    estimated_duration_days: Optional[Decimal] = None
    approved_duration_days: Optional[Decimal] = None
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    weight_percent: Optional[Decimal] = Field(
        None,
        ge=0,
        le=100,
        description="Opcional. % hacia el 100% de la actividad padre",
    )


# Alias histórico / genérico
class TaskCreate(TaskCreateManual):
    source_template_version_id: Optional[int] = None
    template_base_quantity: Optional[Decimal] = None
    template_base_duration_days: Optional[Decimal] = None
    status: Optional[str] = None


class TaskUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    unit_id: Optional[int] = None
    planned_quantity: Optional[Decimal] = None
    estimated_duration_days: Optional[Decimal] = None
    approved_duration_days: Optional[Decimal] = None
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    actual_start_date: Optional[date] = None
    actual_end_date: Optional[date] = None
    weight_percent: Optional[Decimal] = Field(None, ge=0, le=100)
    budget_weight_percent: Optional[Decimal] = Field(None, ge=0, le=100)


class TaskStatusChange(BaseSchema):
    to_status: str = Field(..., description="scheduled|in_progress|completed|verified|rescheduled")
    reason: Optional[str] = None
    force: bool = Field(
        False,
        description="Si true, permite iniciar con deps bloqueantes (queda en historial)",
    )


class TaskAssigneeSummary(BaseSchema):
    worker_id: Optional[int] = None
    worker_name: Optional[str] = None
    initials: Optional[str] = None
    position_name: Optional[str] = None
    crew_id: Optional[int] = None
    crew_name: Optional[str] = None


class TaskResponse(BaseResponseSchema):
    uuid: str
    obra_id: int
    obra_name: Optional[str] = None
    source_template_id: Optional[int] = None
    source_template_version_id: Optional[int] = None
    template_code: Optional[str] = None
    template_name: Optional[str] = None
    chapter_id: Optional[int] = None
    chapter_name: Optional[str] = None
    zone_id: Optional[int] = None
    zone_name: Optional[str] = None
    budget_activity_id: Optional[int] = None
    budget_activity_name: Optional[str] = None
    parent_task_id: Optional[int] = None
    name: str
    description: Optional[str] = None
    unit_id: Optional[int] = None
    unit_name: Optional[str] = None
    unit_symbol: Optional[str] = None
    planned_quantity: Optional[Decimal] = None
    template_base_quantity: Optional[Decimal] = None
    template_base_duration_days: Optional[Decimal] = None
    estimated_duration_days: Optional[Decimal] = None
    approved_duration_days: Optional[Decimal] = None
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    actual_start_date: Optional[date] = None
    actual_end_date: Optional[date] = None
    status: str
    progress_percent: Optional[Decimal] = None
    weight_percent: Optional[Decimal] = None
    budget_weight_percent: Optional[Decimal] = None
    photo_count: int = 0
    document_count: int = 0
    attachment_count: int = 0
    subtask_count: int = 0
    subtasks_done: int = 0
    is_delayed: bool = False
    primary_assignee: Optional[TaskAssigneeSummary] = None
    created_by: int
    created_by_name: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_by: Optional[int] = None
    updated_by_name: Optional[str] = None
    updated_at: Optional[datetime] = None


class TaskMarkDelayedRequest(BaseSchema):
    """Toggle Figma «Marcar como retrasada»."""

    delayed: bool = True
    delay_reason_id: Optional[int] = None
    description: Optional[str] = Field(None, max_length=250)
    days_lost: Optional[Decimal] = None


class TaskActivityItem(BaseSchema):
    """Entrada de trazabilidad del drawer."""

    event_type: str
    at: datetime
    user_id: Optional[int] = None
    user_name: Optional[str] = None
    summary: str
    detail: Optional[str] = None
    ref_id: Optional[int] = None


class TaskBlockingDependency(BaseSchema):
    dependency_id: int
    depends_on_task_id: int
    depends_on_task_name: Optional[str] = None
    depends_on_status: Optional[str] = None
    dependency_type: str
    blocks_start: int
    message: str


class TaskStatusChangeResult(BaseSchema):
    task: TaskResponse
    blocked: bool = False
    blocking_dependencies: List[TaskBlockingDependency] = []
    forced: bool = False


class BudgetActivityFulfillment(BaseSchema):
    budget_activity_id: Optional[int] = None
    budget_activity_name: Optional[str] = None
    weight_percent: Optional[Decimal] = None
    progress_percent: Decimal


class ChapterFulfillment(BaseSchema):
    chapter_id: Optional[int] = None
    chapter_name: Optional[str] = None
    weight_percent: Optional[Decimal] = None
    progress_percent: Decimal
    budget_activities: List[BudgetActivityFulfillment]


class ActivityStatusSummary(BaseSchema):
    completed: int = 0
    in_progress: int = 0
    pending: int = 0
    total: int = 0


class PeriodFulfillment(BaseSchema):
    plan_id: Optional[int] = None
    plan_name: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    progress_percent: Decimal


class ObraFulfillmentResponse(BaseSchema):
    obra_id: int
    progress_percent: Decimal
    chapters: List[ChapterFulfillment]
    period: Optional[PeriodFulfillment] = None
    activity_status: ActivityStatusSummary = Field(
        default_factory=ActivityStatusSummary
    )
