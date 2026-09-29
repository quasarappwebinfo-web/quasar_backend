from datetime import datetime
from decimal import Decimal
from typing import List, Optional

from pydantic import Field

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseSchema, BaseUpdateSchema

VERSION_STATUSES = ("draft", "published", "archived")
DEPENDENCY_TYPES = (
    "finish_to_start",
    "start_to_start",
    "finish_to_finish",
    "start_to_finish",
)


class TaskTemplateVersionCreate(BaseCreateSchema):
    task_template_id: int
    version_number: Optional[int] = None
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    base_quantity: Optional[Decimal] = None
    base_duration_days: Optional[Decimal] = None
    copy_from_version_id: Optional[int] = None


class TaskTemplateVersionUpdate(BaseUpdateSchema):
    name: Optional[str] = Field(None, min_length=1, max_length=255)
    description: Optional[str] = None
    base_quantity: Optional[Decimal] = None
    base_duration_days: Optional[Decimal] = None


class TaskTemplateVersionResponse(BaseResponseSchema):
    task_template_id: int
    template_code: Optional[str] = None
    template_name: Optional[str] = None
    version_number: int
    name: str
    description: Optional[str] = None
    status: str
    base_quantity: Optional[Decimal] = None
    base_duration_days: Optional[Decimal] = None
    published_at: Optional[datetime] = None
    created_at: Optional[datetime] = None


class TaskTemplateRecommendRequest(BaseSchema):
    """Cantidad de obra (+ días objetivo opcionales) para escalar la versión."""

    obra_quantity: Decimal = Field(..., gt=0)
    target_duration_days: Optional[Decimal] = Field(
        None,
        gt=0,
        description=(
            "Días que se quiere gastar en la obra. "
            "Si se envía, la duración recomendada es ese valor y los cargos "
            "se ajustan por intensidad (más gente si hay menos días)."
        ),
    )


class TaskTemplateRecommendPosition(BaseSchema):
    worker_position_id: int
    position_name: Optional[str] = None
    specialty_id: Optional[int] = None
    specialty_name: Optional[str] = None
    base_quantity: Decimal
    recommended_quantity: Decimal
    is_required: int


class TaskTemplateRecommendResponse(BaseSchema):
    """Solo recomendación — el supervisor aprueba después en la tarea."""

    template_version_id: int
    template_code: Optional[str] = None
    version_number: int
    status: str
    unit_id: Optional[int] = None
    unit_name: Optional[str] = None
    unit_symbol: Optional[str] = None
    base_quantity: Optional[Decimal] = None
    base_duration_days: Optional[Decimal] = None
    obra_quantity: Decimal
    target_duration_days: Optional[Decimal] = None
    scale_factor: Decimal
    crew_scale_factor: Optional[Decimal] = None
    recommended_duration_days: Optional[Decimal] = None
    recommended_positions: List[TaskTemplateRecommendPosition] = []
    note: str = (
        "Valores RECOMENDADOS por el sistema. "
        "No son aprobados ni asignados; el responsable de obra decide."
    )
