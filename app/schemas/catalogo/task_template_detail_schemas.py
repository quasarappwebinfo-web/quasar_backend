from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema


# --- Measurements ---


class TaskTemplateMeasurementCreate(BaseCreateSchema):
    template_version_id: int
    unit_id: int
    is_primary: int = 0


class TaskTemplateMeasurementAdd(BaseCreateSchema):
    unit_id: int
    is_primary: int = 0


class TaskTemplateMeasurementResponse(BaseResponseSchema):
    template_version_id: int
    unit_id: int
    unit_name: Optional[str] = None
    unit_symbol: Optional[str] = None
    is_primary: int
    created_at: Optional[datetime] = None


# --- Positions ---


class TaskTemplatePositionCreate(BaseCreateSchema):
    template_version_id: int
    worker_position_id: int
    specialty_id: Optional[int] = None
    quantity: Decimal
    is_required: int = 1


class TaskTemplatePositionAdd(BaseCreateSchema):
    worker_position_id: int
    specialty_id: Optional[int] = None
    quantity: Decimal
    is_required: int = 1


class TaskTemplatePositionUpdate(BaseUpdateSchema):
    quantity: Optional[Decimal] = None
    is_required: Optional[int] = None


class TaskTemplatePositionResponse(BaseResponseSchema):
    template_version_id: int
    worker_position_id: int
    position_name: Optional[str] = None
    specialty_id: Optional[int] = None
    specialty_name: Optional[str] = None
    quantity: Decimal
    is_required: int
    created_at: Optional[datetime] = None


# --- Crews (opcional en Fase 5; expuesto por completitud) ---


class TaskTemplateCrewCreate(BaseCreateSchema):
    template_version_id: int
    crew_id: int
    is_preferred: int = 0


class TaskTemplateCrewAdd(BaseCreateSchema):
    crew_id: int
    is_preferred: int = 0


class TaskTemplateCrewResponse(BaseResponseSchema):
    template_version_id: int
    crew_id: int
    crew_name: Optional[str] = None
    is_preferred: int
    created_at: Optional[datetime] = None


# --- Subtasks ---


class TaskTemplateSubtaskCreate(BaseCreateSchema):
    template_version_id: int
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    display_order: int = 0
    is_required: int = 1
    weight_percent: Optional[Decimal] = Field(
        None,
        ge=0,
        le=100,
        description="% que aporta al 100% de la actividad. Opcional.",
    )


class TaskTemplateSubtaskAdd(BaseCreateSchema):
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    display_order: int = 0
    is_required: int = 1
    weight_percent: Optional[Decimal] = Field(
        None,
        ge=0,
        le=100,
        description="% que aporta al 100% de la actividad. Opcional.",
    )


class TaskTemplateSubtaskUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    display_order: Optional[int] = None
    is_required: Optional[int] = None
    weight_percent: Optional[Decimal] = Field(None, ge=0, le=100)


class TaskTemplateSubtaskResponse(BaseResponseSchema):
    template_version_id: int
    name: str
    description: Optional[str] = None
    display_order: int
    is_required: int
    weight_percent: Decimal
    created_at: Optional[datetime] = None


# --- Dependencies ---


class TaskTemplateDependencyCreate(BaseCreateSchema):
    template_version_id: int
    depends_on_template_id: int
    dependency_type: str = Field("finish_to_start", max_length=30)
    is_required: int = 1
    blocks_start: int = 1
    description: Optional[str] = None


class TaskTemplateDependencyAdd(BaseCreateSchema):
    depends_on_template_id: int
    dependency_type: str = Field("finish_to_start", max_length=30)
    is_required: int = 1
    blocks_start: int = 1
    description: Optional[str] = None


class TaskTemplateDependencyResponse(BaseResponseSchema):
    template_version_id: int
    depends_on_template_id: int
    depends_on_template_code: Optional[str] = None
    depends_on_template_name: Optional[str] = None
    dependency_type: str
    is_required: int
    blocks_start: int
    description: Optional[str] = None
    created_at: Optional[datetime] = None
