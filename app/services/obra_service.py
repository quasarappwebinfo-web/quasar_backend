"""
Servicio de obras: CRUD, cambio de etapa + historial.
"""
from typing import Any, Dict, Optional

from sqlalchemy.orm import Session, joinedload

from app.models import Obra, ObraSaleType, ObraStage, ObraStageHistory
from app.schemas import ObraCreate, ObraStageChange, ObraUpdate
from app.schemas.obras.obra_schema import OBRA_STATUSES


class ObraAlreadyExistsError(Exception):
    pass


class ObraNotFoundError(Exception):
    pass


class ObraValidationError(Exception):
    pass


from app.services.s3_service import resolve_media_url


def obra_to_dict(obra: Obra) -> Dict[str, Any]:
    return {
        "id": obra.id,
        "name": obra.name,
        "code": obra.code,
        "sale_type_id": obra.sale_type_id,
        "sale_type_name": obra.sale_type.name if obra.sale_type else None,
        "address": obra.address,
        "city": obra.city,
        "neighborhood": obra.neighborhood,
        "start_date": obra.start_date,
        "estimated_end_date": obra.estimated_end_date,
        "actual_end_date": obra.actual_end_date,
        "current_stage_id": obra.current_stage_id,
        "current_stage_name": obra.current_stage.name if obra.current_stage else None,
        "status": obra.status,
        "cover_image_url": resolve_media_url(obra.cover_image_key),
        "is_active": obra.is_active,
        "created_at": obra.created_at,
    }


def stage_history_to_dict(row: ObraStageHistory) -> Dict[str, Any]:
    return {
        "id": row.id,
        "obra_id": row.obra_id,
        "stage_id": row.stage_id,
        "stage_name": row.stage.name if row.stage else None,
        "planned_start_date": row.planned_start_date,
        "planned_end_date": row.planned_end_date,
        "actual_start_date": row.actual_start_date,
        "actual_end_date": row.actual_end_date,
        "created_at": row.created_at,
    }


def _load_obra(db: Session, obra_id: int) -> Optional[Obra]:
    return (
        db.query(Obra)
        .options(joinedload(Obra.sale_type), joinedload(Obra.current_stage))
        .filter(Obra.id == obra_id)
        .first()
    )


def _validate_status(status: str) -> None:
    if status not in OBRA_STATUSES:
        raise ObraValidationError(
            f"status inválido '{status}'. Valores: {', '.join(OBRA_STATUSES)}"
        )


def _ensure_sale_type(db: Session, sale_type_id: int) -> None:
    st = db.query(ObraSaleType).filter(ObraSaleType.id == sale_type_id).first()
    if not st:
        raise ObraValidationError(f"No existe tipo de venta con ID {sale_type_id}")
    if st.is_active != 1:
        raise ObraValidationError(f"El tipo de venta {sale_type_id} está inactivo")


def _ensure_stage(db: Session, stage_id: int) -> ObraStage:
    stage = db.query(ObraStage).filter(ObraStage.id == stage_id).first()
    if not stage:
        raise ObraValidationError(f"No existe etapa con ID {stage_id}")
    if stage.is_active != 1:
        raise ObraValidationError(f"La etapa {stage_id} está inactiva")
    return stage


def _append_stage_history(
    db: Session,
    *,
    obra_id: int,
    stage_id: int,
    planned_start_date=None,
    planned_end_date=None,
    actual_start_date=None,
    actual_end_date=None,
) -> ObraStageHistory:
    row = ObraStageHistory(
        obra_id=obra_id,
        stage_id=stage_id,
        planned_start_date=planned_start_date,
        planned_end_date=planned_end_date,
        actual_start_date=actual_start_date,
        actual_end_date=actual_end_date,
    )
    db.add(row)
    return row


async def create_obra(db: Session, data: ObraCreate) -> Obra:
    _validate_status(data.status)
    _ensure_sale_type(db, data.sale_type_id)

    if data.code:
        exists = db.query(Obra).filter(Obra.code == data.code).first()
        if exists:
            raise ObraAlreadyExistsError(f"Ya existe una obra con code='{data.code}'")

    if data.current_stage_id is not None:
        _ensure_stage(db, data.current_stage_id)

    obra = Obra(
        name=data.name,
        code=data.code,
        sale_type_id=data.sale_type_id,
        address=data.address,
        city=data.city,
        neighborhood=data.neighborhood,
        start_date=data.start_date,
        estimated_end_date=data.estimated_end_date,
        current_stage_id=data.current_stage_id,
        status=data.status,
        is_active=1,
    )
    db.add(obra)
    try:
        db.flush()
        if data.current_stage_id is not None:
            _append_stage_history(
                db, obra_id=obra.id, stage_id=data.current_stage_id
            )
        db.commit()
        db.refresh(obra)
        return _load_obra(db, obra.id)
    except Exception:
        db.rollback()
        raise


async def get_obra(db: Session, obra_id: int) -> Obra:
    obra = _load_obra(db, obra_id)
    if not obra:
        raise ObraNotFoundError(f"Obra con ID {obra_id} no encontrada")
    return obra


async def list_obras(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    status: Optional[str] = None,
    city: Optional[str] = None,
    current_stage_id: Optional[int] = None,
    active_only: bool = False,
) -> Dict[str, Any]:
    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    query = db.query(Obra).options(
        joinedload(Obra.sale_type), joinedload(Obra.current_stage)
    )
    if active_only:
        query = query.filter(Obra.is_active == 1)
    if status:
        query = query.filter(Obra.status == status)
    if city:
        query = query.filter(Obra.city.ilike(f"%{city.strip()}%"))
    if current_stage_id is not None:
        query = query.filter(Obra.current_stage_id == current_stage_id)
    if search:
        term = f"%{search.strip()}%"
        from sqlalchemy import or_

        query = query.filter(or_(Obra.name.ilike(term), Obra.code.ilike(term)))

    total_items = query.count()
    rows = query.order_by(Obra.id.desc()).offset(offset).limit(limit_per_page).all()
    return {
        "obras": [obra_to_dict(o) for o in rows],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def update_obra(db: Session, obra_id: int, data: ObraUpdate) -> Obra:
    obra = db.query(Obra).filter(Obra.id == obra_id).first()
    if not obra:
        raise ObraNotFoundError(f"Obra con ID {obra_id} no encontrada")

    update_data = data.model_dump(exclude_unset=True)

    if "status" in update_data and update_data["status"] is not None:
        _validate_status(update_data["status"])
    if "is_active" in update_data and update_data["is_active"] not in (1, 2):
        raise ObraValidationError("is_active debe ser 1 o 2")
    if "sale_type_id" in update_data and update_data["sale_type_id"] is not None:
        _ensure_sale_type(db, update_data["sale_type_id"])
    if "code" in update_data and update_data["code"]:
        conflict = (
            db.query(Obra)
            .filter(Obra.code == update_data["code"], Obra.id != obra_id)
            .first()
        )
        if conflict:
            raise ObraAlreadyExistsError(
                f"Ya existe una obra con code='{update_data['code']}'"
            )

    # current_stage_id no va por update genérico: usar change_obra_stage
    update_data.pop("current_stage_id", None)

    for field, value in update_data.items():
        setattr(obra, field, value)

    try:
        db.commit()
        db.refresh(obra)
        return _load_obra(db, obra.id)
    except Exception:
        db.rollback()
        raise


async def change_obra_stage(
    db: Session, obra_id: int, data: ObraStageChange
) -> Obra:
    obra = db.query(Obra).filter(Obra.id == obra_id).first()
    if not obra:
        raise ObraNotFoundError(f"Obra con ID {obra_id} no encontrada")

    _ensure_stage(db, data.stage_id)

    if obra.current_stage_id == data.stage_id:
        raise ObraValidationError("La obra ya está en esa etapa")

    obra.current_stage_id = data.stage_id
    _append_stage_history(
        db,
        obra_id=obra.id,
        stage_id=data.stage_id,
        planned_start_date=data.planned_start_date,
        planned_end_date=data.planned_end_date,
        actual_start_date=data.actual_start_date,
        actual_end_date=data.actual_end_date,
    )
    try:
        db.commit()
        db.refresh(obra)
        return _load_obra(db, obra.id)
    except Exception:
        db.rollback()
        raise


async def list_obra_stage_history(
    db: Session, obra_id: int, page: int = 1
) -> Dict[str, Any]:
    if not db.query(Obra).filter(Obra.id == obra_id).first():
        raise ObraNotFoundError(f"Obra con ID {obra_id} no encontrada")

    limit_per_page = 15
    offset = (page - 1) * limit_per_page
    query = (
        db.query(ObraStageHistory)
        .options(joinedload(ObraStageHistory.stage))
        .filter(ObraStageHistory.obra_id == obra_id)
    )
    total_items = query.count()
    rows = (
        query.order_by(ObraStageHistory.created_at.desc())
        .offset(offset)
        .limit(limit_per_page)
        .all()
    )
    return {
        "history": [stage_history_to_dict(r) for r in rows],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def set_obra_cover_image(
    db: Session,
    obra_id: int,
    *,
    raw_bytes: bytes,
    content_type: Optional[str],
) -> Obra:
    """Comprime la imagen, la sube a S3 y actualiza cover_image_key."""
    from app.core.images import ImageProcessingError, compress_image_for_upload
    from app.services.s3_service import (
        S3ConfigError,
        S3UploadError,
        delete_object,
        obra_cover_key,
        upload_bytes,
    )

    obra = db.query(Obra).filter(Obra.id == obra_id).first()
    if not obra:
        raise ObraNotFoundError(f"Obra con ID {obra_id} no encontrada")

    try:
        compressed, mime, ext = compress_image_for_upload(
            raw_bytes, content_type=content_type
        )
    except ImageProcessingError as e:
        raise ObraValidationError(str(e)) from e

    new_key = obra_cover_key(obra_id, extension=ext)
    try:
        upload_bytes(key=new_key, data=compressed, content_type=mime)
    except (S3ConfigError, S3UploadError) as e:
        raise ObraValidationError(str(e)) from e

    old_key = obra.cover_image_key
    obra.cover_image_key = new_key
    try:
        db.commit()
        db.refresh(obra)
    except Exception:
        db.rollback()
        delete_object(new_key)
        raise

    if old_key and old_key != new_key:
        delete_object(old_key)

    return _load_obra(db, obra.id)


async def delete_obra_cover_image(db: Session, obra_id: int) -> Obra:
    from app.services.s3_service import delete_object

    obra = db.query(Obra).filter(Obra.id == obra_id).first()
    if not obra:
        raise ObraNotFoundError(f"Obra con ID {obra_id} no encontrada")

    old_key = obra.cover_image_key
    obra.cover_image_key = None
    try:
        db.commit()
        db.refresh(obra)
    except Exception:
        db.rollback()
        raise

    delete_object(old_key)
    return _load_obra(db, obra.id)
