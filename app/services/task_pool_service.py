"""
Task Pool — catálogo reutilizable (no son tareas de obra).
Publicadas = inmutables. El sistema recomienda; nadie auto-aprueba.
"""
from __future__ import annotations

from datetime import datetime
from decimal import Decimal, ROUND_HALF_UP
from typing import Any, Dict, List, Optional

from sqlalchemy import func
from sqlalchemy.orm import Session, joinedload

from app.models import (
    Crew,
    MeasurementUnit,
    ObraStage,
    Specialty,
    TaskBudgetActivity,
    TaskChapter,
    TaskTemplate,
    TaskTemplateCrew,
    TaskTemplateDependency,
    TaskTemplateMeasurement,
    TaskTemplatePosition,
    TaskTemplateSubtask,
    TaskTemplateVersion,
    TaskZone,
    WorkerPosition,
)
from app.schemas import (
    TaskBudgetActivityCreate,
    TaskBudgetActivityUpdate,
    TaskChapterCreate,
    TaskChapterUpdate,
    TaskTemplateCreate,
    TaskTemplateDependencyAdd,
    TaskTemplateMeasurementAdd,
    TaskTemplatePositionAdd,
    TaskTemplatePositionUpdate,
    TaskTemplateSubtaskAdd,
    TaskTemplateSubtaskUpdate,
    TaskTemplateUpdate,
    TaskTemplateVersionCreate,
    TaskTemplateVersionUpdate,
    TaskZoneCreate,
    TaskZoneUpdate,
)
from app.schemas.catalogo.task_template_version_schema import (
    DEPENDENCY_TYPES,
    VERSION_STATUSES,
)

STATUS_DRAFT = "draft"
STATUS_PUBLISHED = "published"
STATUS_ARCHIVED = "archived"


class TaskPoolError(Exception):
    pass


class TaskPoolNotFoundError(TaskPoolError):
    pass


class TaskPoolConflictError(TaskPoolError):
    pass


class TaskPoolValidationError(TaskPoolError):
    pass


# ---------- helpers dict ----------


def chapter_to_dict(row: TaskChapter) -> Dict[str, Any]:
    return {
        "id": row.id,
        "name": row.name,
        "stage_id": row.stage_id,
        "stage_name": row.stage.name if row.stage else None,
        "description": row.description,
        "display_order": row.display_order,
        "weight_percent": row.weight_percent,
        "is_active": row.is_active,
        "created_at": row.created_at,
    }


def _active_stage(db: Session, stage_id: int) -> ObraStage:
    stage = db.query(ObraStage).filter(ObraStage.id == stage_id).first()
    if not stage or stage.is_active != 1:
        raise TaskPoolValidationError("La etapa no existe o está inactiva.")
    return stage


def zone_to_dict(row: TaskZone) -> Dict[str, Any]:
    return {
        "id": row.id,
        "name": row.name,
        "description": row.description,
        "display_order": row.display_order,
        "is_active": row.is_active,
        "created_at": row.created_at,
    }


def budget_activity_to_dict(row: TaskBudgetActivity) -> Dict[str, Any]:
    return {
        "id": row.id,
        "chapter_id": row.chapter_id,
        "chapter_name": row.chapter.name if row.chapter else None,
        "zone_id": row.zone_id,
        "zone_name": row.zone.name if row.zone else None,
        "name": row.name,
        "description": row.description,
        "display_order": row.display_order,
        "chapter_weight_percent": row.chapter_weight_percent,
        "zone_weight_percent": row.zone_weight_percent,
        "is_active": row.is_active,
        "created_at": row.created_at,
    }


def template_to_dict(row: TaskTemplate) -> Dict[str, Any]:
    return {
        "id": row.id,
        "chapter_id": row.chapter_id,
        "chapter_name": row.chapter.name if row.chapter else None,
        "zone_id": row.zone_id,
        "zone_name": row.zone.name if row.zone else None,
        "budget_activity_id": row.budget_activity_id,
        "budget_activity_name": (
            row.budget_activity.name if row.budget_activity else None
        ),
        "name": row.name,
        "code": row.code,
        "description": row.description,
        "budget_weight_percent": row.budget_weight_percent,
        "is_active": row.is_active,
        "created_at": row.created_at,
    }


def version_to_dict(row: TaskTemplateVersion) -> Dict[str, Any]:
    tpl = row.task_template
    return {
        "id": row.id,
        "task_template_id": row.task_template_id,
        "template_code": tpl.code if tpl else None,
        "template_name": tpl.name if tpl else None,
        "version_number": row.version_number,
        "name": row.name,
        "description": row.description,
        "status": row.status,
        "base_quantity": row.base_quantity,
        "base_duration_days": row.base_duration_days,
        "published_at": row.published_at,
        "created_at": row.created_at,
    }


def measurement_to_dict(row: TaskTemplateMeasurement) -> Dict[str, Any]:
    return {
        "id": row.id,
        "template_version_id": row.template_version_id,
        "unit_id": row.unit_id,
        "unit_name": row.unit.name if row.unit else None,
        "unit_symbol": row.unit.symbol if row.unit else None,
        "is_primary": row.is_primary,
        "created_at": row.created_at,
    }


def position_to_dict(row: TaskTemplatePosition) -> Dict[str, Any]:
    return {
        "id": row.id,
        "template_version_id": row.template_version_id,
        "worker_position_id": row.worker_position_id,
        "position_name": row.worker_position.name if row.worker_position else None,
        "specialty_id": row.specialty_id,
        "specialty_name": row.specialty.name if row.specialty else None,
        "quantity": row.quantity,
        "is_required": row.is_required,
        "created_at": row.created_at,
    }


def subtask_to_dict(row: TaskTemplateSubtask) -> Dict[str, Any]:
    return {
        "id": row.id,
        "template_version_id": row.template_version_id,
        "name": row.name,
        "description": row.description,
        "display_order": row.display_order,
        "is_required": row.is_required,
        "weight_percent": row.weight_percent,
        "created_at": row.created_at,
    }


def dependency_to_dict(row: TaskTemplateDependency) -> Dict[str, Any]:
    dep = row.depends_on_template
    return {
        "id": row.id,
        "template_version_id": row.template_version_id,
        "depends_on_template_id": row.depends_on_template_id,
        "depends_on_template_code": dep.code if dep else None,
        "depends_on_template_name": dep.name if dep else None,
        "dependency_type": row.dependency_type,
        "is_required": row.is_required,
        "blocks_start": row.blocks_start,
        "description": row.description,
        "created_at": row.created_at,
    }


def crew_pref_to_dict(row: TaskTemplateCrew) -> Dict[str, Any]:
    return {
        "id": row.id,
        "template_version_id": row.template_version_id,
        "crew_id": row.crew_id,
        "crew_name": row.crew.name if row.crew else None,
        "is_preferred": row.is_preferred,
        "created_at": row.created_at,
    }


def _pagination(total: int, page: int, limit: int = 15) -> Dict[str, Any]:
    return {
        "totalItems": total,
        "itemsPerPage": limit,
        "currentPage": page,
    }


def _load_version(db: Session, version_id: int) -> Optional[TaskTemplateVersion]:
    return (
        db.query(TaskTemplateVersion)
        .options(joinedload(TaskTemplateVersion.task_template))
        .filter(TaskTemplateVersion.id == version_id)
        .first()
    )


def _require_draft(version: TaskTemplateVersion) -> None:
    if version.status != STATUS_DRAFT:
        raise TaskPoolValidationError(
            f"La versión está en status='{version.status}'. "
            "Solo se puede editar una versión en draft. "
            "Para cambios: crea una nueva versión."
        )


# ---------- Capítulos ----------


async def create_chapter(db: Session, data: TaskChapterCreate) -> TaskChapter:
    exists = db.query(TaskChapter).filter(TaskChapter.name == data.name).first()
    if exists:
        raise TaskPoolConflictError(f"Ya existe capítulo '{data.name}'")
    _active_stage(db, data.stage_id)
    row = TaskChapter(
        name=data.name,
        stage_id=data.stage_id,
        description=data.description,
        display_order=data.display_order,
        weight_percent=data.weight_percent,
        is_active=1,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


async def get_chapter(db: Session, item_id: int) -> TaskChapter:
    row = db.query(TaskChapter).filter(TaskChapter.id == item_id).first()
    if not row:
        raise TaskPoolNotFoundError(f"Capítulo {item_id} no encontrado")
    return row


async def list_chapters(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
) -> Dict[str, Any]:
    limit = 15
    q = db.query(TaskChapter).options(joinedload(TaskChapter.stage))
    if active_only:
        q = q.filter(TaskChapter.is_active == 1)
    if search:
        q = q.filter(TaskChapter.name.ilike(f"%{search.strip()}%"))
    total = q.count()
    rows = (
        q.order_by(TaskChapter.display_order.asc(), TaskChapter.name.asc())
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )
    return {
        "chapters": [chapter_to_dict(r) for r in rows],
        "pagination": _pagination(total, page, limit),
    }


async def update_chapter(
    db: Session, item_id: int, data: TaskChapterUpdate
) -> TaskChapter:
    row = await get_chapter(db, item_id)
    payload = data.model_dump(exclude_unset=True)
    if "is_active" in payload and payload["is_active"] not in (1, 2):
        raise TaskPoolValidationError("is_active debe ser 1 o 2")
    if "stage_id" in payload and payload["stage_id"] is not None:
        _active_stage(db, payload["stage_id"])
    if "name" in payload and payload["name"] != row.name:
        conflict = (
            db.query(TaskChapter)
            .filter(TaskChapter.name == payload["name"], TaskChapter.id != item_id)
            .first()
        )
        if conflict:
            raise TaskPoolConflictError(f"Ya existe capítulo '{payload['name']}'")
    for k, v in payload.items():
        setattr(row, k, v)
    db.commit()
    db.refresh(row)
    return row


# ---------- Zonas ----------


async def create_zone(db: Session, data: TaskZoneCreate) -> TaskZone:
    exists = db.query(TaskZone).filter(TaskZone.name == data.name).first()
    if exists:
        raise TaskPoolConflictError(f"Ya existe zona '{data.name}'")
    row = TaskZone(
        name=data.name,
        description=data.description,
        display_order=data.display_order,
        is_active=1,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


async def get_zone(db: Session, item_id: int) -> TaskZone:
    row = db.query(TaskZone).filter(TaskZone.id == item_id).first()
    if not row:
        raise TaskPoolNotFoundError(f"Zona {item_id} no encontrada")
    return row


async def list_zones(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
) -> Dict[str, Any]:
    limit = 15
    q = db.query(TaskZone)
    if active_only:
        q = q.filter(TaskZone.is_active == 1)
    if search:
        q = q.filter(TaskZone.name.ilike(f"%{search.strip()}%"))
    total = q.count()
    rows = (
        q.order_by(TaskZone.display_order.asc(), TaskZone.name.asc())
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )
    return {
        "zones": [zone_to_dict(r) for r in rows],
        "pagination": _pagination(total, page, limit),
    }


async def update_zone(
    db: Session, item_id: int, data: TaskZoneUpdate
) -> TaskZone:
    row = await get_zone(db, item_id)
    payload = data.model_dump(exclude_unset=True)
    if "is_active" in payload and payload["is_active"] not in (1, 2):
        raise TaskPoolValidationError("is_active debe ser 1 o 2")
    if "name" in payload and payload["name"] != row.name:
        conflict = (
            db.query(TaskZone)
            .filter(TaskZone.name == payload["name"], TaskZone.id != item_id)
            .first()
        )
        if conflict:
            raise TaskPoolConflictError(f"Ya existe zona '{payload['name']}'")
    for k, v in payload.items():
        setattr(row, k, v)
    db.commit()
    db.refresh(row)
    return row


# ---------- Actividades presupuestales ----------


async def create_budget_activity(
    db: Session, data: TaskBudgetActivityCreate
) -> TaskBudgetActivity:
    cat = db.query(TaskChapter).filter(TaskChapter.id == data.chapter_id).first()
    _require_active_catalog(
        label="capítulo", row=cat, item_id=data.chapter_id, masculine=True
    )
    zone = None
    if data.zone_id is not None:
        zone = db.query(TaskZone).filter(TaskZone.id == data.zone_id).first()
        _require_active_catalog(label="zona", row=zone, item_id=data.zone_id)
    exists = (
        db.query(TaskBudgetActivity)
        .filter(
            TaskBudgetActivity.chapter_id == data.chapter_id,
            TaskBudgetActivity.name == data.name,
        )
        .first()
    )
    if exists:
        raise TaskPoolConflictError(
            f"Ya existe actividad presupuestal '{data.name}' en ese capítulo"
        )
    row = TaskBudgetActivity(
        chapter_id=data.chapter_id,
        zone_id=data.zone_id,
        name=data.name,
        description=data.description,
        display_order=data.display_order,
        chapter_weight_percent=data.chapter_weight_percent,
        zone_weight_percent=data.zone_weight_percent,
        is_active=1,
    )
    db.add(row)
    db.commit()
    return (
        db.query(TaskBudgetActivity)
        .options(
            joinedload(TaskBudgetActivity.chapter),
            joinedload(TaskBudgetActivity.zone),
        )
        .filter(TaskBudgetActivity.id == row.id)
        .first()
    )


async def get_budget_activity(db: Session, item_id: int) -> TaskBudgetActivity:
    row = (
        db.query(TaskBudgetActivity)
        .options(
            joinedload(TaskBudgetActivity.chapter),
            joinedload(TaskBudgetActivity.zone),
        )
        .filter(TaskBudgetActivity.id == item_id)
        .first()
    )
    if not row:
        raise TaskPoolNotFoundError(
            f"Actividad presupuestal {item_id} no encontrada"
        )
    return row


async def list_budget_activities(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    chapter_id: Optional[int] = None,
    active_only: bool = False,
) -> Dict[str, Any]:
    limit = 15
    q = db.query(TaskBudgetActivity).options(
        joinedload(TaskBudgetActivity.chapter),
        joinedload(TaskBudgetActivity.zone),
    )
    if active_only:
        q = q.filter(TaskBudgetActivity.is_active == 1)
    if chapter_id is not None:
        q = q.filter(TaskBudgetActivity.chapter_id == chapter_id)
    if search:
        q = q.filter(TaskBudgetActivity.name.ilike(f"%{search.strip()}%"))
    total = q.count()
    rows = (
        q.order_by(
            TaskBudgetActivity.display_order.asc(),
            TaskBudgetActivity.name.asc(),
        )
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )
    return {
        "budgetActivities": [budget_activity_to_dict(r) for r in rows],
        "pagination": _pagination(total, page, limit),
    }


async def update_budget_activity(
    db: Session, item_id: int, data: TaskBudgetActivityUpdate
) -> TaskBudgetActivity:
    row = await get_budget_activity(db, item_id)
    payload = data.model_dump(exclude_unset=True)
    if "is_active" in payload and payload["is_active"] not in (1, 2):
        raise TaskPoolValidationError("is_active debe ser 1 o 2")
    if "chapter_id" in payload:
        cat = (
            db.query(TaskChapter)
            .filter(TaskChapter.id == payload["chapter_id"])
            .first()
        )
        if not cat:
            raise TaskPoolValidationError(
                f"No existe capítulo {payload['chapter_id']}"
            )
    if "zone_id" in payload and payload["zone_id"] is not None:
        zone = (
            db.query(TaskZone)
            .filter(TaskZone.id == payload["zone_id"])
            .first()
        )
        if not zone:
            raise TaskPoolValidationError(
                f"No existe zona {payload['zone_id']}"
            )
    next_chapter_id = payload.get("chapter_id", row.chapter_id)
    next_name = payload.get("name", row.name)
    if next_name != row.name or next_chapter_id != row.chapter_id:
        conflict = (
            db.query(TaskBudgetActivity)
            .filter(
                TaskBudgetActivity.chapter_id == next_chapter_id,
                TaskBudgetActivity.name == next_name,
                TaskBudgetActivity.id != item_id,
            )
            .first()
        )
        if conflict:
            raise TaskPoolConflictError(
                f"Ya existe actividad presupuestal '{next_name}' en ese capítulo"
            )
    for k, v in payload.items():
        setattr(row, k, v)
    db.commit()
    return await get_budget_activity(db, item_id)

def _require_active_catalog(
    *,
    label: str,
    row: Any,
    item_id: int,
    masculine: bool = False,
) -> None:
    if not row:
        raise TaskPoolValidationError(f"No existe {label} {item_id}")
    if row.is_active != 1:
        article = "El" if masculine else "La"
        state = "inactivo" if masculine else "inactiva"
        raise TaskPoolValidationError(f"{article} {label} está {state}")


def _share_budget_weights(db: Session, budget_activity_id: Optional[int]) -> None:
    """Reparte el 100% de la actividad presupuestal en partes iguales.

    1 actividad → 100, 2 → 50, 3 → 33.33. Las inactivas quedan en 0.
    """
    if budget_activity_id is None:
        return
    rows = (
        db.query(TaskTemplate)
        .filter(TaskTemplate.budget_activity_id == budget_activity_id)
        .all()
    )
    active = [row for row in rows if row.is_active == 1]
    share = None
    if active:
        share = (Decimal("100") / Decimal(len(active))).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )
    for row in rows:
        row.budget_weight_percent = share if row.is_active == 1 else Decimal("0")


# ---------- Plantillas ----------


async def create_template(db: Session, data: TaskTemplateCreate) -> TaskTemplate:
    cat = db.query(TaskChapter).filter(TaskChapter.id == data.chapter_id).first()
    _require_active_catalog(
        label="capítulo", row=cat, item_id=data.chapter_id, masculine=True
    )
    if data.zone_id is not None:
        zone = db.query(TaskZone).filter(TaskZone.id == data.zone_id).first()
        _require_active_catalog(label="zona", row=zone, item_id=data.zone_id)
    activity = (
        db.query(TaskBudgetActivity)
        .filter(TaskBudgetActivity.id == data.budget_activity_id)
        .first()
    )
    _require_active_catalog(
        label="actividad presupuestal",
        row=activity,
        item_id=data.budget_activity_id,
    )
    if activity.chapter_id != data.chapter_id:
        raise TaskPoolValidationError(
            "La actividad presupuestal no pertenece al capítulo seleccionado"
        )
    code = data.code.strip()
    if db.query(TaskTemplate).filter(TaskTemplate.code == code).first():
        raise TaskPoolConflictError(f"Ya existe plantilla con code='{code}'")
    row = TaskTemplate(
        chapter_id=data.chapter_id,
        zone_id=data.zone_id,
        budget_activity_id=data.budget_activity_id,
        name=data.name,
        code=code,
        description=data.description,
        is_active=1,
    )
    db.add(row)
    db.flush()
    _share_budget_weights(db, data.budget_activity_id)
    db.commit()
    return (
        db.query(TaskTemplate)
        .options(
            joinedload(TaskTemplate.chapter),
            joinedload(TaskTemplate.zone),
            joinedload(TaskTemplate.budget_activity),
        )
        .filter(TaskTemplate.id == row.id)
        .first()
    )


async def get_template(db: Session, item_id: int) -> TaskTemplate:
    row = (
        db.query(TaskTemplate)
        .options(
            joinedload(TaskTemplate.chapter),
            joinedload(TaskTemplate.zone),
            joinedload(TaskTemplate.budget_activity),
        )
        .filter(TaskTemplate.id == item_id)
        .first()
    )
    if not row:
        raise TaskPoolNotFoundError(f"Plantilla {item_id} no encontrada")
    return row


async def list_templates(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    chapter_id: Optional[int] = None,
    zone_id: Optional[int] = None,
    budget_activity_id: Optional[int] = None,
    active_only: bool = False,
) -> Dict[str, Any]:
    limit = 15
    q = db.query(TaskTemplate).options(
        joinedload(TaskTemplate.chapter),
        joinedload(TaskTemplate.zone),
        joinedload(TaskTemplate.budget_activity),
    )
    if active_only:
        q = q.filter(TaskTemplate.is_active == 1)
    if chapter_id is not None:
        q = q.filter(TaskTemplate.chapter_id == chapter_id)
    if zone_id is not None:
        q = q.filter(TaskTemplate.zone_id == zone_id)
    if budget_activity_id is not None:
        q = q.filter(TaskTemplate.budget_activity_id == budget_activity_id)
    if search:
        term = f"%{search.strip()}%"
        q = q.filter(
            (TaskTemplate.name.ilike(term)) | (TaskTemplate.code.ilike(term))
        )
    total = q.count()
    rows = (
        q.order_by(TaskTemplate.code.asc())
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )
    return {
        "templates": [template_to_dict(r) for r in rows],
        "pagination": _pagination(total, page, limit),
    }


async def update_template(
    db: Session, item_id: int, data: TaskTemplateUpdate
) -> TaskTemplate:
    row = db.query(TaskTemplate).filter(TaskTemplate.id == item_id).first()
    if not row:
        raise TaskPoolNotFoundError(f"Plantilla {item_id} no encontrada")
    payload = data.model_dump(exclude_unset=True)
    payload.pop("budget_weight_percent", None)
    previous_activity_id = row.budget_activity_id
    if "is_active" in payload and payload["is_active"] not in (1, 2):
        raise TaskPoolValidationError("is_active debe ser 1 o 2")
    if "chapter_id" in payload:
        cat = (
            db.query(TaskChapter)
            .filter(TaskChapter.id == payload["chapter_id"])
            .first()
        )
        if not cat:
            raise TaskPoolValidationError(
                f"No existe capítulo {payload['chapter_id']}"
            )
    if "zone_id" in payload and payload["zone_id"] is not None:
        zone = (
            db.query(TaskZone)
            .filter(TaskZone.id == payload["zone_id"])
            .first()
        )
        if not zone:
            raise TaskPoolValidationError(
                f"No existe zona {payload['zone_id']}"
            )
    if "budget_activity_id" in payload and payload["budget_activity_id"] is not None:
        activity = (
            db.query(TaskBudgetActivity)
            .filter(TaskBudgetActivity.id == payload["budget_activity_id"])
            .first()
        )
        if not activity:
            raise TaskPoolValidationError(
                f"No existe actividad presupuestal {payload['budget_activity_id']}"
            )
    next_chapter_id = payload.get("chapter_id", row.chapter_id)
    next_activity_id = payload.get("budget_activity_id", row.budget_activity_id)
    if next_activity_id is not None:
        activity = (
            db.query(TaskBudgetActivity)
            .filter(TaskBudgetActivity.id == next_activity_id)
            .first()
        )
        if activity and activity.chapter_id != next_chapter_id:
            raise TaskPoolValidationError(
                "La actividad presupuestal no pertenece al capítulo seleccionado"
            )
    for k, v in payload.items():
        setattr(row, k, v)
    db.flush()
    _share_budget_weights(db, row.budget_activity_id)
    if previous_activity_id != row.budget_activity_id:
        _share_budget_weights(db, previous_activity_id)
    db.commit()
    return await get_template(db, item_id)


# ---------- Versiones ----------


def _next_version_number(db: Session, template_id: int) -> int:
    current = (
        db.query(func.max(TaskTemplateVersion.version_number))
        .filter(TaskTemplateVersion.task_template_id == template_id)
        .scalar()
    )
    return int(current or 0) + 1


def _clone_version_details(
    db: Session, source: TaskTemplateVersion, target_id: int
) -> None:
    for m in source.measurements:
        db.add(
            TaskTemplateMeasurement(
                template_version_id=target_id,
                unit_id=m.unit_id,
                is_primary=m.is_primary,
            )
        )
    for p in source.positions:
        db.add(
            TaskTemplatePosition(
                template_version_id=target_id,
                worker_position_id=p.worker_position_id,
                specialty_id=p.specialty_id,
                quantity=p.quantity,
                is_required=p.is_required,
            )
        )
    for s in source.subtasks:
        db.add(
            TaskTemplateSubtask(
                template_version_id=target_id,
                name=s.name,
                description=s.description,
                display_order=s.display_order,
                is_required=s.is_required,
                weight_percent=s.weight_percent if s.weight_percent is not None else 0,
            )
        )
    for d in source.dependencies:
        db.add(
            TaskTemplateDependency(
                template_version_id=target_id,
                depends_on_template_id=d.depends_on_template_id,
                dependency_type=d.dependency_type,
                is_required=d.is_required,
                blocks_start=d.blocks_start,
                description=d.description,
            )
        )
    for c in source.preferred_crews:
        db.add(
            TaskTemplateCrew(
                template_version_id=target_id,
                crew_id=c.crew_id,
                is_preferred=c.is_preferred,
            )
        )


async def create_version(
    db: Session, data: TaskTemplateVersionCreate
) -> TaskTemplateVersion:
    tpl = db.query(TaskTemplate).filter(TaskTemplate.id == data.task_template_id).first()
    if not tpl:
        raise TaskPoolValidationError(
            f"No existe plantilla {data.task_template_id}"
        )

    version_number = data.version_number or _next_version_number(
        db, data.task_template_id
    )
    conflict = (
        db.query(TaskTemplateVersion)
        .filter(
            TaskTemplateVersion.task_template_id == data.task_template_id,
            TaskTemplateVersion.version_number == version_number,
        )
        .first()
    )
    if conflict:
        raise TaskPoolConflictError(
            f"Ya existe la versión {version_number} para esta plantilla"
        )

    source = None
    if data.copy_from_version_id:
        source = (
            db.query(TaskTemplateVersion)
            .options(
                joinedload(TaskTemplateVersion.measurements),
                joinedload(TaskTemplateVersion.positions),
                joinedload(TaskTemplateVersion.subtasks),
                joinedload(TaskTemplateVersion.dependencies),
                joinedload(TaskTemplateVersion.preferred_crews),
            )
            .filter(TaskTemplateVersion.id == data.copy_from_version_id)
            .first()
        )
        if not source:
            raise TaskPoolValidationError(
                f"No existe versión origen {data.copy_from_version_id}"
            )
        if source.task_template_id != data.task_template_id:
            raise TaskPoolValidationError(
                "copyFromVersionId debe pertenecer a la misma plantilla"
            )

    row = TaskTemplateVersion(
        task_template_id=data.task_template_id,
        version_number=version_number,
        name=data.name,
        description=data.description,
        status=STATUS_DRAFT,
        base_quantity=data.base_quantity
        if data.base_quantity is not None
        else (source.base_quantity if source else None),
        base_duration_days=data.base_duration_days
        if data.base_duration_days is not None
        else (source.base_duration_days if source else None),
    )
    db.add(row)
    db.flush()
    if source:
        _clone_version_details(db, source, row.id)
    db.commit()
    return _load_version(db, row.id)


async def get_version(db: Session, version_id: int) -> TaskTemplateVersion:
    row = _load_version(db, version_id)
    if not row:
        raise TaskPoolNotFoundError(f"Versión {version_id} no encontrada")
    return row


async def list_versions(
    db: Session,
    *,
    template_id: Optional[int] = None,
    status: Optional[str] = None,
    page: int = 1,
) -> Dict[str, Any]:
    limit = 15
    q = db.query(TaskTemplateVersion).options(
        joinedload(TaskTemplateVersion.task_template)
    )
    if template_id is not None:
        q = q.filter(TaskTemplateVersion.task_template_id == template_id)
    if status:
        if status not in VERSION_STATUSES:
            raise TaskPoolValidationError(
                f"status inválido. Valores: {', '.join(VERSION_STATUSES)}"
            )
        q = q.filter(TaskTemplateVersion.status == status)
    total = q.count()
    rows = (
        q.order_by(
            TaskTemplateVersion.task_template_id.asc(),
            TaskTemplateVersion.version_number.desc(),
        )
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )
    return {
        "versions": [version_to_dict(r) for r in rows],
        "pagination": _pagination(total, page, limit),
    }


async def update_version(
    db: Session, version_id: int, data: TaskTemplateVersionUpdate
) -> TaskTemplateVersion:
    row = db.query(TaskTemplateVersion).filter(TaskTemplateVersion.id == version_id).first()
    if not row:
        raise TaskPoolNotFoundError(f"Versión {version_id} no encontrada")
    _require_draft(row)
    payload = data.model_dump(exclude_unset=True)
    for k, v in payload.items():
        setattr(row, k, v)
    db.commit()
    return _load_version(db, version_id)


async def publish_version(db: Session, version_id: int) -> TaskTemplateVersion:
    row = db.query(TaskTemplateVersion).filter(TaskTemplateVersion.id == version_id).first()
    if not row:
        raise TaskPoolNotFoundError(f"Versión {version_id} no encontrada")
    if row.status != STATUS_DRAFT:
        raise TaskPoolValidationError(
            f"Solo se puede publicar una versión draft (actual: {row.status})"
        )
    row.status = STATUS_PUBLISHED
    row.published_at = datetime.utcnow()
    db.commit()
    return _load_version(db, version_id)


async def archive_version(db: Session, version_id: int) -> TaskTemplateVersion:
    row = db.query(TaskTemplateVersion).filter(TaskTemplateVersion.id == version_id).first()
    if not row:
        raise TaskPoolNotFoundError(f"Versión {version_id} no encontrada")
    if row.status == STATUS_DRAFT:
        raise TaskPoolValidationError(
            "No archives un draft: elimínalo o publícalo. "
            "Archivar es para versiones publicadas antiguas."
        )
    if row.status == STATUS_ARCHIVED:
        raise TaskPoolValidationError("La versión ya está archivada")
    row.status = STATUS_ARCHIVED
    db.commit()
    return _load_version(db, version_id)


# ---------- Detalle de versión (solo draft) ----------


async def list_version_detail(db: Session, version_id: int) -> Dict[str, Any]:
    version = await get_version(db, version_id)
    measurements = (
        db.query(TaskTemplateMeasurement)
        .options(joinedload(TaskTemplateMeasurement.unit))
        .filter(TaskTemplateMeasurement.template_version_id == version_id)
        .all()
    )
    positions = (
        db.query(TaskTemplatePosition)
        .options(
            joinedload(TaskTemplatePosition.worker_position),
            joinedload(TaskTemplatePosition.specialty),
        )
        .filter(TaskTemplatePosition.template_version_id == version_id)
        .all()
    )
    subtasks = (
        db.query(TaskTemplateSubtask)
        .filter(TaskTemplateSubtask.template_version_id == version_id)
        .order_by(TaskTemplateSubtask.display_order.asc())
        .all()
    )
    deps = (
        db.query(TaskTemplateDependency)
        .options(joinedload(TaskTemplateDependency.depends_on_template))
        .filter(TaskTemplateDependency.template_version_id == version_id)
        .all()
    )
    crews = (
        db.query(TaskTemplateCrew)
        .options(joinedload(TaskTemplateCrew.crew))
        .filter(TaskTemplateCrew.template_version_id == version_id)
        .all()
    )
    return {
        "version": version_to_dict(version),
        "measurements": [measurement_to_dict(m) for m in measurements],
        "positions": [position_to_dict(p) for p in positions],
        "subtasks": [subtask_to_dict(s) for s in subtasks],
        "dependencies": [dependency_to_dict(d) for d in deps],
        "preferredCrews": [crew_pref_to_dict(c) for c in crews],
    }


async def add_measurement(
    db: Session, version_id: int, data: TaskTemplateMeasurementAdd
) -> TaskTemplateMeasurement:
    version = await get_version(db, version_id)
    _require_draft(version)
    unit = db.query(MeasurementUnit).filter(MeasurementUnit.id == data.unit_id).first()
    if not unit or unit.is_active != 1:
        raise TaskPoolValidationError(f"Unidad {data.unit_id} inválida o inactiva")
    if data.is_primary == 1:
        db.query(TaskTemplateMeasurement).filter(
            TaskTemplateMeasurement.template_version_id == version_id
        ).update({"is_primary": 0})
    row = TaskTemplateMeasurement(
        template_version_id=version_id,
        unit_id=data.unit_id,
        is_primary=data.is_primary,
    )
    db.add(row)
    db.commit()
    return (
        db.query(TaskTemplateMeasurement)
        .options(joinedload(TaskTemplateMeasurement.unit))
        .filter(TaskTemplateMeasurement.id == row.id)
        .first()
    )


async def delete_measurement(db: Session, item_id: int) -> None:
    row = (
        db.query(TaskTemplateMeasurement)
        .filter(TaskTemplateMeasurement.id == item_id)
        .first()
    )
    if not row:
        raise TaskPoolNotFoundError(f"Medición {item_id} no encontrada")
    version = await get_version(db, row.template_version_id)
    _require_draft(version)
    db.delete(row)
    db.commit()


async def add_position(
    db: Session, version_id: int, data: TaskTemplatePositionAdd
) -> TaskTemplatePosition:
    version = await get_version(db, version_id)
    _require_draft(version)
    pos = (
        db.query(WorkerPosition)
        .filter(WorkerPosition.id == data.worker_position_id)
        .first()
    )
    if not pos or pos.is_active != 1:
        raise TaskPoolValidationError(
            f"Cargo {data.worker_position_id} inválido o inactivo"
        )
    if Decimal(data.quantity) <= 0:
        raise TaskPoolValidationError("quantity debe ser > 0")

    specialty_id = data.specialty_id
    if specialty_id is not None:
        specialty = db.query(Specialty).filter(Specialty.id == specialty_id).first()
        if not specialty or specialty.is_active != 1:
            raise TaskPoolValidationError(
                f"Especialidad {specialty_id} inválida o inactiva"
            )
        if (
            specialty.worker_position_id is not None
            and specialty.worker_position_id != data.worker_position_id
        ):
            raise TaskPoolValidationError(
                "La especialidad no corresponde al cargo seleccionado"
            )

    existing_q = db.query(TaskTemplatePosition).filter(
        TaskTemplatePosition.template_version_id == version_id,
        TaskTemplatePosition.worker_position_id == data.worker_position_id,
    )
    if specialty_id is None:
        existing_q = existing_q.filter(TaskTemplatePosition.specialty_id.is_(None))
    else:
        existing_q = existing_q.filter(
            TaskTemplatePosition.specialty_id == specialty_id
        )
    if existing_q.first():
        raise TaskPoolConflictError(
            "Ese cargo ya está en la versión. Usa el campo cantidad de la fila existente."
        )

    row = TaskTemplatePosition(
        template_version_id=version_id,
        worker_position_id=data.worker_position_id,
        specialty_id=specialty_id,
        quantity=data.quantity,
        is_required=data.is_required,
    )
    db.add(row)
    db.commit()
    return (
        db.query(TaskTemplatePosition)
        .options(
            joinedload(TaskTemplatePosition.worker_position),
            joinedload(TaskTemplatePosition.specialty),
        )
        .filter(TaskTemplatePosition.id == row.id)
        .first()
    )


async def update_position(
    db: Session, item_id: int, data: TaskTemplatePositionUpdate
) -> TaskTemplatePosition:
    row = (
        db.query(TaskTemplatePosition)
        .options(
            joinedload(TaskTemplatePosition.worker_position),
            joinedload(TaskTemplatePosition.specialty),
        )
        .filter(TaskTemplatePosition.id == item_id)
        .first()
    )
    if not row:
        raise TaskPoolNotFoundError(f"Posición de plantilla {item_id} no encontrada")
    version = await get_version(db, row.template_version_id)
    _require_draft(version)

    payload = data.model_dump(exclude_unset=True)
    if "quantity" in payload:
        if Decimal(payload["quantity"]) <= 0:
            raise TaskPoolValidationError("quantity debe ser > 0")
        row.quantity = payload["quantity"]
    if "is_required" in payload and payload["is_required"] is not None:
        row.is_required = payload["is_required"]

    db.commit()
    db.refresh(row)
    return (
        db.query(TaskTemplatePosition)
        .options(
            joinedload(TaskTemplatePosition.worker_position),
            joinedload(TaskTemplatePosition.specialty),
        )
        .filter(TaskTemplatePosition.id == row.id)
        .first()
    )


async def delete_position(db: Session, item_id: int) -> None:
    row = (
        db.query(TaskTemplatePosition)
        .filter(TaskTemplatePosition.id == item_id)
        .first()
    )
    if not row:
        raise TaskPoolNotFoundError(f"Posición de plantilla {item_id} no encontrada")
    version = await get_version(db, row.template_version_id)
    _require_draft(version)
    db.delete(row)
    db.commit()


async def add_subtask(
    db: Session, version_id: int, data: TaskTemplateSubtaskAdd
) -> TaskTemplateSubtask:
    version = await get_version(db, version_id)
    _require_draft(version)
    row = TaskTemplateSubtask(
        template_version_id=version_id,
        name=data.name,
        description=data.description,
        display_order=data.display_order,
        is_required=data.is_required,
        weight_percent=data.weight_percent if data.weight_percent is not None else 0,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return row


async def update_subtask(
    db: Session, item_id: int, data: TaskTemplateSubtaskUpdate
) -> TaskTemplateSubtask:
    row = (
        db.query(TaskTemplateSubtask)
        .filter(TaskTemplateSubtask.id == item_id)
        .first()
    )
    if not row:
        raise TaskPoolNotFoundError(f"Subtarea {item_id} no encontrada")
    version = await get_version(db, row.template_version_id)
    _require_draft(version)
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(row, k, v)
    db.commit()
    db.refresh(row)
    return row


async def delete_subtask(db: Session, item_id: int) -> None:
    row = (
        db.query(TaskTemplateSubtask)
        .filter(TaskTemplateSubtask.id == item_id)
        .first()
    )
    if not row:
        raise TaskPoolNotFoundError(f"Subtarea {item_id} no encontrada")
    version = await get_version(db, row.template_version_id)
    _require_draft(version)
    db.delete(row)
    db.commit()


async def add_dependency(
    db: Session, version_id: int, data: TaskTemplateDependencyAdd
) -> TaskTemplateDependency:
    version = await get_version(db, version_id)
    _require_draft(version)
    if data.dependency_type not in DEPENDENCY_TYPES:
        raise TaskPoolValidationError(
            f"dependencyType inválido. Valores: {', '.join(DEPENDENCY_TYPES)}"
        )
    dep_tpl = (
        db.query(TaskTemplate)
        .filter(TaskTemplate.id == data.depends_on_template_id)
        .first()
    )
    if not dep_tpl:
        raise TaskPoolValidationError(
            f"No existe plantilla prerequisito {data.depends_on_template_id}"
        )
    if data.depends_on_template_id == version.task_template_id:
        raise TaskPoolValidationError(
            "Una plantilla no puede depender de sí misma"
        )
    row = TaskTemplateDependency(
        template_version_id=version_id,
        depends_on_template_id=data.depends_on_template_id,
        dependency_type=data.dependency_type,
        is_required=data.is_required,
        blocks_start=data.blocks_start,
        description=data.description,
    )
    db.add(row)
    db.commit()
    return (
        db.query(TaskTemplateDependency)
        .options(joinedload(TaskTemplateDependency.depends_on_template))
        .filter(TaskTemplateDependency.id == row.id)
        .first()
    )


async def delete_dependency(db: Session, item_id: int) -> None:
    row = (
        db.query(TaskTemplateDependency)
        .filter(TaskTemplateDependency.id == item_id)
        .first()
    )
    if not row:
        raise TaskPoolNotFoundError(f"Dependencia {item_id} no encontrada")
    version = await get_version(db, row.template_version_id)
    _require_draft(version)
    db.delete(row)
    db.commit()


# ---------- Recomendación ----------


def _dec(value) -> Decimal:
    return Decimal(str(value))


async def recommend_from_version(
    db: Session,
    version_id: int,
    *,
    obra_quantity: Decimal,
    target_duration_days: Optional[Decimal] = None,
) -> Dict[str, Any]:
    """
    factor_q = obra_quantity / base_quantity
    duración por defecto = base_duration_days × factor_q
    cargos por defecto = quantity × factor_q

    Si target_duration_days:
      duración = target_duration_days
      cargos = quantity × (base_duration_days × factor_q) / target_duration_days
    """
    if obra_quantity <= 0:
        raise TaskPoolValidationError("obraQuantity debe ser > 0")
    if target_duration_days is not None and target_duration_days <= 0:
        raise TaskPoolValidationError("targetDurationDays debe ser > 0")

    version = await get_version(db, version_id)
    if version.status != STATUS_PUBLISHED:
        raise TaskPoolValidationError(
            "Solo se recomienda desde una versión published "
            f"(actual: {version.status})"
        )
    if not version.base_quantity or _dec(version.base_quantity) <= 0:
        raise TaskPoolValidationError("La versión no tiene baseQuantity válida")
    if not version.base_duration_days or _dec(version.base_duration_days) <= 0:
        raise TaskPoolValidationError(
            "La versión no tiene baseDurationDays válida"
        )

    base_q = _dec(version.base_quantity)
    base_d = _dec(version.base_duration_days)
    factor = (obra_quantity / base_q).quantize(
        Decimal("0.0001"), rounding=ROUND_HALF_UP
    )
    duration_at_base_pace = (base_d * factor).quantize(
        Decimal("0.01"), rounding=ROUND_HALF_UP
    )

    if target_duration_days is not None:
        recommended_duration = target_duration_days.quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )
        crew_scale = (duration_at_base_pace / recommended_duration).quantize(
            Decimal("0.0001"), rounding=ROUND_HALF_UP
        )
    else:
        recommended_duration = duration_at_base_pace
        crew_scale = Decimal("1")

    positions = (
        db.query(TaskTemplatePosition)
        .options(
            joinedload(TaskTemplatePosition.worker_position),
            joinedload(TaskTemplatePosition.specialty),
        )
        .filter(TaskTemplatePosition.template_version_id == version_id)
        .all()
    )
    recommended_positions: List[Dict[str, Any]] = []
    for p in positions:
        base_pos = _dec(p.quantity)
        rec = (base_pos * factor * crew_scale).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )
        recommended_positions.append(
            {
                "worker_position_id": p.worker_position_id,
                "position_name": p.worker_position.name if p.worker_position else None,
                "specialty_id": p.specialty_id,
                "specialty_name": p.specialty.name if p.specialty else None,
                "base_quantity": base_pos,
                "recommended_quantity": rec,
                "is_required": p.is_required,
            }
        )

    primary = (
        db.query(TaskTemplateMeasurement)
        .options(joinedload(TaskTemplateMeasurement.unit))
        .filter(
            TaskTemplateMeasurement.template_version_id == version_id,
            TaskTemplateMeasurement.is_primary == 1,
        )
        .first()
    )
    if not primary:
        primary = (
            db.query(TaskTemplateMeasurement)
            .options(joinedload(TaskTemplateMeasurement.unit))
            .filter(TaskTemplateMeasurement.template_version_id == version_id)
            .first()
        )

    unit_id = primary.unit_id if primary else None
    unit_name = primary.unit.name if primary and primary.unit else None
    unit_symbol = primary.unit.symbol if primary and primary.unit else None

    tpl = version.task_template
    note = (
        "Valores RECOMENDADOS por el sistema. "
        "No son aprobados ni asignados; el responsable de obra decide."
    )
    if target_duration_days is not None:
        note = (
            f"Duración objetivo {recommended_duration} días "
            f"(a ritmo base serían {duration_at_base_pace} días). "
            f"Cargos ajustados por intensidad ×{crew_scale}. " + note
        )

    return {
        "template_version_id": version.id,
        "template_code": tpl.code if tpl else None,
        "version_number": version.version_number,
        "status": version.status,
        "unit_id": unit_id,
        "unit_name": unit_name,
        "unit_symbol": unit_symbol,
        "base_quantity": base_q,
        "base_duration_days": base_d,
        "obra_quantity": obra_quantity,
        "target_duration_days": target_duration_days,
        "scale_factor": factor,
        "crew_scale_factor": (
            crew_scale if target_duration_days is not None else None
        ),
        "recommended_duration_days": recommended_duration,
        "recommended_positions": recommended_positions,
        "note": note,
    }
