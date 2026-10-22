"""
Servicios de catálogos Fase 2 (RRHH, operación, catálogo, obras).
"""
from typing import Any, Dict, Optional

from sqlalchemy.orm import Session

from app.models import (
    DelayReason,
    DocumentType,
    MeasurementUnit,
    ObraSaleType,
    ObraStage,
    Specialty,
    WorkerPosition,
)
from app.schemas import (
    DelayReasonCreate,
    DelayReasonUpdate,
    DocumentTypeCreate,
    DocumentTypeUpdate,
    MeasurementUnitCreate,
    MeasurementUnitUpdate,
    ObraSaleTypeCreate,
    ObraSaleTypeUpdate,
    ObraStageCreate,
    ObraStageUpdate,
    SpecialtyCreate,
    SpecialtyUpdate,
    WorkerPositionCreate,
    WorkerPositionUpdate,
)
from app.services.catalog_crud import (
    CatalogAlreadyExistsError,
    CatalogNotFoundError,
    CatalogValidationError,
    catalog_to_dict,
    create_catalog_item,
    get_catalog_item,
    list_catalog_items,
    update_catalog_item,
)

# Reexport para endpoints
__all_errors__ = (
    CatalogAlreadyExistsError,
    CatalogNotFoundError,
    CatalogValidationError,
)

POSITION_FIELDS = ("name", "is_active")
SPECIALTY_FIELDS = ("name", "worker_position_id", "is_active")
DELAY_FIELDS = ("name", "description", "is_active")
UNIT_FIELDS = ("name", "symbol", "is_active")
DOC_TYPE_FIELDS = ("name", "description", "is_active")
SALE_TYPE_FIELDS = ("name", "is_active")
STAGE_FIELDS = (
    "name",
    "description",
    "display_order",
    "weight_percent",
    "is_active",
)


def _ensure_worker_position(db: Session, payload: Dict[str, Any]) -> None:
    position_id = payload.get("worker_position_id")
    if position_id is None:
        return
    if not db.query(WorkerPosition).filter(WorkerPosition.id == position_id).first():
        raise CatalogValidationError(
            f"No existe cargo (worker_position) con ID {position_id}"
        )


def _ensure_worker_position_on_update(
    db: Session, _row: Any, update_data: Dict[str, Any]
) -> None:
    if "worker_position_id" in update_data:
        _ensure_worker_position(db, update_data)


# --- Cargos ---


async def create_worker_position(db: Session, data: WorkerPositionCreate):
    return create_catalog_item(
        db,
        model=WorkerPosition,
        data=data,
        fields=POSITION_FIELDS,
        label="cargo",
    )


async def get_worker_position(db: Session, item_id: int):
    return get_catalog_item(
        db, model=WorkerPosition, item_id=item_id, label="cargo"
    )


async def list_worker_positions(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
):
    return list_catalog_items(
        db,
        model=WorkerPosition,
        fields=POSITION_FIELDS,
        collection_key="positions",
        page=page,
        search=search,
        active_only=active_only,
    )


async def update_worker_position(
    db: Session, item_id: int, data: WorkerPositionUpdate
):
    return update_catalog_item(
        db,
        model=WorkerPosition,
        item_id=item_id,
        data=data,
        fields=POSITION_FIELDS,
        label="cargo",
    )


def worker_position_to_dict(row) -> Dict[str, Any]:
    return catalog_to_dict(row, POSITION_FIELDS)


# --- Especialidades ---


async def create_specialty(db: Session, data: SpecialtyCreate):
    return create_catalog_item(
        db,
        model=Specialty,
        data=data,
        fields=SPECIALTY_FIELDS,
        label="especialidad",
        before_create=_ensure_worker_position,
    )


async def get_specialty(db: Session, item_id: int):
    return get_catalog_item(
        db, model=Specialty, item_id=item_id, label="especialidad"
    )


async def list_specialties(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
    worker_position_id: Optional[int] = None,
):
    def extra(query):
        if worker_position_id is not None:
            return query.filter(Specialty.worker_position_id == worker_position_id)
        return query

    return list_catalog_items(
        db,
        model=Specialty,
        fields=SPECIALTY_FIELDS,
        collection_key="specialties",
        page=page,
        search=search,
        active_only=active_only,
        extra_filters=extra,
    )


async def update_specialty(db: Session, item_id: int, data: SpecialtyUpdate):
    return update_catalog_item(
        db,
        model=Specialty,
        item_id=item_id,
        data=data,
        fields=SPECIALTY_FIELDS,
        label="especialidad",
        before_update=_ensure_worker_position_on_update,
    )


def specialty_to_dict(row) -> Dict[str, Any]:
    return catalog_to_dict(row, SPECIALTY_FIELDS)


# --- Motivos de retraso ---


async def create_delay_reason(db: Session, data: DelayReasonCreate):
    return create_catalog_item(
        db, model=DelayReason, data=data, fields=DELAY_FIELDS, label="motivo de retraso"
    )


async def get_delay_reason(db: Session, item_id: int):
    return get_catalog_item(
        db, model=DelayReason, item_id=item_id, label="motivo de retraso"
    )


async def list_delay_reasons(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
):
    return list_catalog_items(
        db,
        model=DelayReason,
        fields=DELAY_FIELDS,
        collection_key="delayReasons",
        page=page,
        search=search,
        active_only=active_only,
        search_fields=("name", "description"),
    )


async def update_delay_reason(db: Session, item_id: int, data: DelayReasonUpdate):
    return update_catalog_item(
        db,
        model=DelayReason,
        item_id=item_id,
        data=data,
        fields=DELAY_FIELDS,
        label="motivo de retraso",
    )


def delay_reason_to_dict(row) -> Dict[str, Any]:
    return catalog_to_dict(row, DELAY_FIELDS)


# --- Unidades de medida ---


async def create_measurement_unit(db: Session, data: MeasurementUnitCreate):
    return create_catalog_item(
        db,
        model=MeasurementUnit,
        data=data,
        fields=UNIT_FIELDS,
        unique_fields=("name", "symbol"),
        label="unidad de medida",
    )


async def get_measurement_unit(db: Session, item_id: int):
    return get_catalog_item(
        db, model=MeasurementUnit, item_id=item_id, label="unidad de medida"
    )


async def list_measurement_units(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
):
    return list_catalog_items(
        db,
        model=MeasurementUnit,
        fields=UNIT_FIELDS,
        collection_key="measurementUnits",
        page=page,
        search=search,
        active_only=active_only,
        search_fields=("name", "symbol"),
    )


async def update_measurement_unit(
    db: Session, item_id: int, data: MeasurementUnitUpdate
):
    return update_catalog_item(
        db,
        model=MeasurementUnit,
        item_id=item_id,
        data=data,
        fields=UNIT_FIELDS,
        unique_fields=("name", "symbol"),
        label="unidad de medida",
    )


def measurement_unit_to_dict(row) -> Dict[str, Any]:
    return catalog_to_dict(row, UNIT_FIELDS)


# --- Tipos de documento ---


async def create_document_type(db: Session, data: DocumentTypeCreate):
    return create_catalog_item(
        db,
        model=DocumentType,
        data=data,
        fields=DOC_TYPE_FIELDS,
        label="tipo de documento",
    )


async def get_document_type(db: Session, item_id: int):
    return get_catalog_item(
        db, model=DocumentType, item_id=item_id, label="tipo de documento"
    )


async def list_document_types(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
):
    return list_catalog_items(
        db,
        model=DocumentType,
        fields=DOC_TYPE_FIELDS,
        collection_key="documentTypes",
        page=page,
        search=search,
        active_only=active_only,
        search_fields=("name", "description"),
    )


async def update_document_type(db: Session, item_id: int, data: DocumentTypeUpdate):
    return update_catalog_item(
        db,
        model=DocumentType,
        item_id=item_id,
        data=data,
        fields=DOC_TYPE_FIELDS,
        label="tipo de documento",
    )


def document_type_to_dict(row) -> Dict[str, Any]:
    return catalog_to_dict(row, DOC_TYPE_FIELDS)


# --- Tipos de venta de obra ---


async def create_obra_sale_type(db: Session, data: ObraSaleTypeCreate):
    return create_catalog_item(
        db,
        model=ObraSaleType,
        data=data,
        fields=SALE_TYPE_FIELDS,
        label="tipo de venta",
    )


async def get_obra_sale_type(db: Session, item_id: int):
    return get_catalog_item(
        db, model=ObraSaleType, item_id=item_id, label="tipo de venta"
    )


async def list_obra_sale_types(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
):
    return list_catalog_items(
        db,
        model=ObraSaleType,
        fields=SALE_TYPE_FIELDS,
        collection_key="saleTypes",
        page=page,
        search=search,
        active_only=active_only,
    )


async def update_obra_sale_type(db: Session, item_id: int, data: ObraSaleTypeUpdate):
    return update_catalog_item(
        db,
        model=ObraSaleType,
        item_id=item_id,
        data=data,
        fields=SALE_TYPE_FIELDS,
        label="tipo de venta",
    )


def obra_sale_type_to_dict(row) -> Dict[str, Any]:
    return catalog_to_dict(row, SALE_TYPE_FIELDS)


# --- Etapas de obra ---


async def create_obra_stage(db: Session, data: ObraStageCreate):
    return create_catalog_item(
        db, model=ObraStage, data=data, fields=STAGE_FIELDS, label="etapa de obra"
    )


async def get_obra_stage(db: Session, item_id: int):
    return get_catalog_item(
        db, model=ObraStage, item_id=item_id, label="etapa de obra"
    )


async def list_obra_stages(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
):
    return list_catalog_items(
        db,
        model=ObraStage,
        fields=STAGE_FIELDS,
        collection_key="stages",
        page=page,
        search=search,
        active_only=active_only,
        order_by="display_order",
        search_fields=("name", "description"),
    )


async def update_obra_stage(db: Session, item_id: int, data: ObraStageUpdate):
    return update_catalog_item(
        db,
        model=ObraStage,
        item_id=item_id,
        data=data,
        fields=STAGE_FIELDS,
        label="etapa de obra",
    )


def obra_stage_to_dict(row) -> Dict[str, Any]:
    return catalog_to_dict(row, STAGE_FIELDS)
