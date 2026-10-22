"""Schemas planificación / firmas (Fase 7)."""
from datetime import date, datetime
from decimal import Decimal
from typing import List, Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseSchema, BaseUpdateSchema

WORK_PLAN_STATUSES = ("draft", "pending_signature", "signed", "rejected")
SIGNER_STATUSES = ("pending", "signed", "rejected")
SIGNATURE_TYPES = ("electronic", "acknowledgment")
SIGNATURE_EVENT_TYPES = (
    "created",
    "edited",
    "requested",
    "viewed",
    "signed",
    "rejected",
    "cancelled",
)


class WorkPlanCreate(BaseCreateSchema):
    """Crea plan + versión 1 + snapshots.

    `template_ids` registra actividades del catálogo en el periodo, sin versión.
    `task_ids` trae actividades ya existentes (las que faltaron en otro periodo).
    Hace falta al menos una de las dos listas.
    """

    uuid: Optional[str] = Field(None, max_length=36)
    obra_id: int
    name: str = Field(..., min_length=1, max_length=255)
    start_date: date
    end_date: date
    task_ids: List[int] = Field(default_factory=list)
    template_ids: List[int] = Field(default_factory=list)


class UnfinishedPlanActivity(BaseSchema):
    """Actividad de un periodo anterior que no quedó completed ni verified."""

    id: int
    name: str
    status: str
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None
    template_id: Optional[int] = None
    template_code: Optional[str] = None
    chapter_name: Optional[str] = None
    source_plan_id: Optional[int] = None
    source_plan_name: Optional[str] = None
    source_plan_start_date: Optional[date] = None
    source_plan_end_date: Optional[date] = None


class WorkPlanUpdate(BaseUpdateSchema):
    """Solo editable en draft (cabecera)."""

    name: Optional[str] = Field(None, min_length=1, max_length=255)
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class WorkPlanResponse(BaseResponseSchema):
    uuid: str
    obra_id: int
    obra_name: Optional[str] = None
    name: str
    start_date: date
    end_date: date
    status: str
    current_version_id: Optional[int] = None
    current_version_number: Optional[int] = None
    requested_by: int
    requested_by_name: Optional[str] = None
    created_at: Optional[datetime] = None
    updated_at: Optional[datetime] = None


class WorkPlanVersionResponse(BaseResponseSchema):
    work_plan_id: int
    version_number: int
    created_by: int
    created_by_name: Optional[str] = None
    created_at: Optional[datetime] = None
    signed_at: Optional[datetime] = None
    is_immutable: bool = False
    task_count: int = 0
    signer_count: int = 0
    signed_count: int = 0


class WorkPlanTaskAdd(BaseCreateSchema):
    """Agregar tarea al snapshot de una versión draft."""

    task_id: int
    planned_start_date: Optional[date] = None
    planned_end_date: Optional[date] = None


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


class WorkPlanSignerAdd(BaseCreateSchema):
    user_id: int
    signature_order: Optional[int] = None


class WorkPlanSignerCreate(WorkPlanSignerAdd):
    work_plan_version_id: int
    status: str = "pending"


class WorkPlanSignerResponse(BaseResponseSchema):
    work_plan_version_id: int
    user_id: int
    user_name: Optional[str] = None
    signature_order: Optional[int] = None
    status: str
    requested_at: Optional[datetime] = None
    signed_at: Optional[datetime] = None
    rejected_at: Optional[datetime] = None
    rejection_reason: Optional[str] = None
    signature_type: Optional[str] = None
    signature_data: Optional[str] = None


class WorkPlanSignRequest(BaseSchema):
    """Firmar como usuario autenticado (debe ser firmante pending)."""

    signature_type: str = Field("electronic", max_length=30)
    signature_data: Optional[str] = Field(
        None,
        max_length=500_000,
        description=(
            "Firma dibujada como data URL base64 (data:image/png;base64,...) "
            "o nota de acuse. NUNCA passwords ni tokens."
        ),
    )


class WorkPlanRejectRequest(BaseSchema):
    reason: str = Field(..., min_length=1)


class WorkPlanSignatureCreate(BaseCreateSchema):
    work_plan_signer_id: int
    signature_type: str
    signature_data: Optional[str] = None


class WorkPlanSignatureResponse(BaseResponseSchema):
    work_plan_signer_id: int
    user_id: int
    user_name: Optional[str] = None
    signature_type: str
    signature_data: Optional[str] = None
    signed_at: Optional[datetime] = None
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None


class WorkPlanSignatureEventResponse(BaseResponseSchema):
    work_plan_version_id: int
    user_id: Optional[int] = None
    user_name: Optional[str] = None
    event_type: str
    event_at: Optional[datetime] = None
    details: Optional[str] = None


class WorkPlanNewVersionRequest(BaseSchema):
    """Clonar versión (signed/rejected) a un nuevo draft editable."""

    task_ids: Optional[List[int]] = Field(
        None,
        description="Si se omite, clona los task_ids del snapshot anterior",
    )
    name: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class WorkPlanCompareItem(BaseSchema):
    task_id: int
    task_name_snapshot: str
    quantity_snapshot: Optional[Decimal] = None
    unit_snapshot: Optional[str] = None
    planned_start_date: date
    planned_end_date: date
    estimated_duration_days_snapshot: Optional[Decimal] = None
    approved_duration_days_snapshot: Optional[Decimal] = None
    # Actual (tarea viva)
    current_name: Optional[str] = None
    current_status: Optional[str] = None
    current_planned_start: Optional[date] = None
    current_planned_end: Optional[date] = None
    current_actual_start: Optional[date] = None
    current_actual_end: Optional[date] = None
    current_estimated_duration_days: Optional[Decimal] = None
    current_approved_duration_days: Optional[Decimal] = None
    days_lost_total: Optional[Decimal] = None
    delay_count: int = 0
    variance_note: Optional[str] = None


class WorkPlanCompareResponse(BaseSchema):
    work_plan_id: int
    version_id: int
    version_number: int
    plan_status: str
    items: List[WorkPlanCompareItem] = []


# Compat / legacy names
class WorkPlanVersionCreate(BaseCreateSchema):
    work_plan_id: int
    version_number: Optional[int] = None


class WorkPlanTaskCreate(WorkPlanTaskAdd):
    work_plan_version_id: int
    task_name_snapshot: Optional[str] = None
    task_description_snapshot: Optional[str] = None
    quantity_snapshot: Optional[Decimal] = None
    unit_snapshot: Optional[str] = None
    planned_start_date: date
    planned_end_date: date
    estimated_duration_days_snapshot: Optional[Decimal] = None
    approved_duration_days_snapshot: Optional[Decimal] = None
