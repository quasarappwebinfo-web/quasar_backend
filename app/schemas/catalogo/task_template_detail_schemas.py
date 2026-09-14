from datetime import datetime
from decimal import Decimal
from typing import Optional
from pydantic import Field
from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseUpdateSchema

class TaskTemplateMeasurementCreate(BaseCreateSchema):
    template_version_id: int
    unit_id: int
    is_primary: int = 0

class TaskTemplateMeasurementResponse(BaseResponseSchema):
    template_version_id: int
    unit_id: int
    is_primary: int
    created_at: Optional[datetime] = None

class TaskTemplatePositionCreate(BaseCreateSchema):
    template_version_id: int
    worker_position_id: int
    quantity: Decimal
    is_required: int = 1

class TaskTemplatePositionResponse(BaseResponseSchema):
    template_version_id: int
    worker_position_id: int
    quantity: Decimal
    is_required: int
    created_at: Optional[datetime] = None

class TaskTemplateCrewCreate(BaseCreateSchema):
    template_version_id: int
    crew_id: int
    is_preferred: int = 0

class TaskTemplateCrewResponse(BaseResponseSchema):
    template_version_id: int
    crew_id: int
    is_preferred: int
    created_at: Optional[datetime] = None

class TaskTemplateSubtaskCreate(BaseCreateSchema):
    template_version_id: int
    name: str = Field(..., min_length=1, max_length=255)
    description: Optional[str] = None
    display_order: int
    is_required: int = 1

class TaskTemplateSubtaskUpdate(BaseUpdateSchema):
    name: Optional[str] = None
    description: Optional[str] = None
    display_order: Optional[int] = None
    is_required: Optional[int] = None

class TaskTemplateSubtaskResponse(BaseResponseSchema):
    template_version_id: int
    name: str
    description: Optional[str] = None
    display_order: int
    is_required: int
    created_at: Optional[datetime] = None

class TaskTemplateDependencyCreate(BaseCreateSchema):
    template_version_id: int
    depends_on_template_id: int
    dependency_type: str = Field(..., max_length=30)
    is_required: int = 1
    blocks_start: int = 1
    description: Optional[str] = None

class TaskTemplateDependencyResponse(BaseResponseSchema):
    template_version_id: int
    depends_on_template_id: int
    dependency_type: str
    is_required: int
    blocks_start: int
    description: Optional[str] = None
    created_at: Optional[datetime] = None
