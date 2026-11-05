"""Planificación de obra. Las firmas quedaron fuera de uso."""
from __future__ import annotations

import uuid as uuid_lib
from datetime import date, datetime
from decimal import Decimal
from typing import Any, Dict, List, Optional

from sqlalchemy import func, or_
from sqlalchemy.orm import Session, joinedload

from app.models import (
    Obra,
    Task,
    TaskDelayEvent,
    TaskTemplateVersion,
    User,
    WorkPlan,
    WorkPlanSignatureEvent,
    WorkPlanSigner,
    WorkPlanTask,
    WorkPlanVersion,
)
from app.schemas.operacion.task_schema import TaskAddToPeriod, TaskCreateFromTemplate
from app.services.task_service import (
    _period_plan,
    add_task_from_catalog,
    add_unique_obra_task,
    get_task,
    task_to_dict,
)
from app.schemas import (
    WorkPlanCreate,
    WorkPlanNewVersionRequest,
    WorkPlanTaskAdd,
    WorkPlanUpdate,
)
from app.schemas.planificacion.work_plan_schema import (
    SIGNATURE_EVENT_TYPES,
    WORK_PLAN_STATUSES,
)

STATUS_DRAFT = "draft"
STATUS_PENDING = "pending_signature"
STATUS_SIGNED = "signed"
STATUS_REJECTED = "rejected"

SIGNER_SIGNED = "signed"


class WorkPlanError(Exception):
    pass


class WorkPlanNotFoundError(WorkPlanError):
    pass


class WorkPlanConflictError(WorkPlanError):
    pass


class WorkPlanValidationError(WorkPlanError):
    pass


def _new_uuid(value: Optional[str] = None) -> str:
    return value.strip() if value else str(uuid_lib.uuid4())


def _pagination(total: int, page: int, limit: int = 15) -> Dict[str, Any]:
    return {
        "totalItems": total,
        "itemsPerPage": limit,
        "currentPage": page,
    }


def _user_display(user: Optional[User]) -> Optional[str]:
    if not user:
        return None
    if user.person and user.person.name:
        return user.person.name
    return user.username


def _assert_no_secrets(signature_data: Optional[str]) -> None:
    from app.core.signature_data import SignatureDataError, assert_no_secrets

    try:
        assert_no_secrets(signature_data)
    except SignatureDataError as e:
        raise WorkPlanValidationError(str(e)) from e


# ---------- serializers ----------


def plan_to_dict(row: WorkPlan) -> Dict[str, Any]:
    version_number = None
    if row.current_version_id and row.versions:
        for v in row.versions:
            if v.id == row.current_version_id:
                version_number = v.version_number
                break
    return {
        "id": row.id,
        "uuid": row.uuid,
        "obra_id": row.obra_id,
        "obra_name": row.obra.name if row.obra else None,
        "name": row.name,
        "start_date": row.start_date,
        "end_date": row.end_date,
        "status": row.status,
        "current_version_id": row.current_version_id,
        "current_version_number": version_number,
        "requested_by": row.requested_by,
        "requested_by_name": _user_display(row.requested_by_user),
        "created_at": row.created_at,
        "updated_at": row.updated_at,
    }


def version_to_dict(
    row: WorkPlanVersion, *, plan_status: Optional[str] = None
) -> Dict[str, Any]:
    immutable = False
    tasks = list(row.tasks) if row.tasks is not None else []
    signers = list(row.signers) if row.signers is not None else []
    return {
        "id": row.id,
        "work_plan_id": row.work_plan_id,
        "version_number": row.version_number,
        "created_by": row.created_by,
        "created_by_name": _user_display(row.created_by_user),
        "created_at": row.created_at,
        "signed_at": row.signed_at,
        "is_immutable": bool(immutable),
        "task_count": len(tasks),
        "signer_count": len(signers),
        "signed_count": sum(1 for s in signers if s.status == SIGNER_SIGNED),
    }


def snapshot_to_dict(row: WorkPlanTask) -> Dict[str, Any]:
    return {
        "id": row.id,
        "work_plan_version_id": row.work_plan_version_id,
        "task_id": row.task_id,
        "task_name_snapshot": row.task_name_snapshot,
        "task_description_snapshot": row.task_description_snapshot,
        "quantity_snapshot": row.quantity_snapshot,
        "unit_snapshot": row.unit_snapshot,
        "planned_start_date": row.planned_start_date,
        "planned_end_date": row.planned_end_date,
        "estimated_duration_days_snapshot": row.estimated_duration_days_snapshot,
        "approved_duration_days_snapshot": row.approved_duration_days_snapshot,
        "created_at": row.created_at,
    }


def signer_to_dict(row: WorkPlanSigner) -> Dict[str, Any]:
    latest_sig = None
    if row.signatures:
        latest_sig = max(row.signatures, key=lambda s: s.signed_at or s.id)
    return {
        "id": row.id,
        "work_plan_version_id": row.work_plan_version_id,
        "user_id": row.user_id,
        "user_name": _user_display(row.user),
        "signature_order": row.signature_order,
        "status": row.status,
        "requested_at": row.requested_at,
        "signed_at": row.signed_at,
        "rejected_at": row.rejected_at,
        "rejection_reason": row.rejection_reason,
        "signature_type": latest_sig.signature_type if latest_sig else None,
        "signature_data": latest_sig.signature_data if latest_sig else None,
    }


def event_to_dict(row: WorkPlanSignatureEvent) -> Dict[str, Any]:
    return {
        "id": row.id,
        "work_plan_version_id": row.work_plan_version_id,
        "user_id": row.user_id,
        "user_name": _user_display(row.user),
        "event_type": row.event_type,
        "event_at": row.event_at,
        "details": row.details,
    }


def _plan_options():
    return [
        joinedload(WorkPlan.obra),
        joinedload(WorkPlan.requested_by_user).joinedload(User.person),
        joinedload(WorkPlan.versions),
    ]


def _version_options():
    return [
        joinedload(WorkPlanVersion.created_by_user).joinedload(User.person),
        joinedload(WorkPlanVersion.tasks),
        joinedload(WorkPlanVersion.signers).joinedload(WorkPlanSigner.user).joinedload(
            User.person
        ),
        joinedload(WorkPlanVersion.signers).joinedload(WorkPlanSigner.signatures),
        joinedload(WorkPlanVersion.signature_events)
        .joinedload(WorkPlanSignatureEvent.user)
        .joinedload(User.person),
    ]


def _load_plan(db: Session, plan_id: int) -> Optional[WorkPlan]:
    return (
        db.query(WorkPlan)
        .options(*_plan_options())
        .filter(WorkPlan.id == plan_id)
        .first()
    )


def _load_version(db: Session, version_id: int) -> Optional[WorkPlanVersion]:
    return (
        db.query(WorkPlanVersion)
        .options(*_version_options())
        .filter(WorkPlanVersion.id == version_id)
        .first()
    )


def _append_event(
    db: Session,
    *,
    version_id: int,
    event_type: str,
    user_id: Optional[int],
    details: Optional[str] = None,
) -> None:
    if event_type not in SIGNATURE_EVENT_TYPES:
        raise WorkPlanValidationError(
            f"eventType inválido. Valores: {', '.join(SIGNATURE_EVENT_TYPES)}"
        )
    db.add(
        WorkPlanSignatureEvent(
            work_plan_version_id=version_id,
            user_id=user_id,
            event_type=event_type,
            details=details,
        )
    )


def _snapshot_from_task(
    db: Session,
    *,
    version_id: int,
    task: Task,
    planned_start: Optional[date] = None,
    planned_end: Optional[date] = None,
) -> WorkPlanTask:
    start = planned_start or task.planned_start_date
    end = planned_end or task.planned_end_date
    if not start or not end:
        raise WorkPlanValidationError(
            f"La tarea {task.id} («{task.name}») necesita "
            "plannedStartDate y plannedEndDate para el snapshot"
        )
    unit_snap = None
    if task.unit:
        unit_snap = task.unit.symbol or task.unit.name
    return WorkPlanTask(
        work_plan_version_id=version_id,
        task_id=task.id,
        task_name_snapshot=task.name,
        task_description_snapshot=task.description,
        quantity_snapshot=task.planned_quantity,
        unit_snapshot=unit_snap,
        planned_start_date=start,
        planned_end_date=end,
        estimated_duration_days_snapshot=task.estimated_duration_days,
        approved_duration_days_snapshot=task.approved_duration_days,
    )


def _require_draft_plan(plan: WorkPlan) -> None:
    _ = plan


def _require_editable_version(db: Session, version: WorkPlanVersion) -> WorkPlan:
    plan = db.query(WorkPlan).filter(WorkPlan.id == version.work_plan_id).first()
    if not plan:
        raise WorkPlanNotFoundError("Plan no encontrado")
    return plan


# ---------- CRUD plan ----------


async def get_plan(db: Session, plan_id: int) -> WorkPlan:
    row = _load_plan(db, plan_id)
    if not row:
        raise WorkPlanNotFoundError(f"Planificación {plan_id} no encontrada")
    return row


async def list_plans(
    db: Session,
    *,
    page: int = 1,
    obra_id: Optional[int] = None,
    status: Optional[str] = None,
    search: Optional[str] = None,
) -> Dict[str, Any]:
    limit = 15
    q = db.query(WorkPlan).options(*_plan_options())
    if obra_id is not None:
        q = q.filter(WorkPlan.obra_id == obra_id)
    if status:
        if status not in WORK_PLAN_STATUSES:
            raise WorkPlanValidationError(
                f"status inválido. Valores: {', '.join(WORK_PLAN_STATUSES)}"
            )
        q = q.filter(WorkPlan.status == status)
    if search:
        q = q.filter(WorkPlan.name.ilike(f"%{search.strip()}%"))
    total = q.count()
    rows = (
        q.order_by(WorkPlan.start_date.desc(), WorkPlan.id.desc())
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )
    return {
        "workPlans": [plan_to_dict(r) for r in rows],
        "pagination": _pagination(total, page, limit),
    }


async def list_unfinished_activities(
    db: Session, obra_id: int
) -> List[Dict[str, Any]]:
    """Actividades de periodos anteriores que no se completaron ni verificaron."""
    obra = db.query(Obra).filter(Obra.id == obra_id).first()
    if not obra:
        raise WorkPlanValidationError(f"Obra {obra_id} no existe")

    rows = (
        db.query(Task)
        .options(
            joinedload(Task.source_template),
            joinedload(Task.source_template_version).joinedload(
                TaskTemplateVersion.task_template
            ),
            joinedload(Task.work_plan_tasks)
            .joinedload(WorkPlanTask.work_plan_version)
            .joinedload(WorkPlanVersion.work_plan),
        )
        .filter(
            Task.obra_id == obra_id,
            Task.parent_task_id.is_(None),
            Task.status.in_(("scheduled", "in_progress", "rescheduled")),
        )
        .all()
    )
    items: List[Dict[str, Any]] = []
    for task in rows:
        plans = []
        for snap in task.work_plan_tasks or []:
            version = snap.work_plan_version
            plan = version.work_plan if version else None
            if plan and plan.obra_id == obra_id:
                plans.append(plan)
        if not plans:
            continue
        latest = max(plans, key=lambda plan: (plan.end_date, plan.id))
        template = task.source_template
        if template is None and task.source_template_version:
            template = task.source_template_version.task_template
        chapter = template.chapter if template else None
        items.append(
            {
                "id": task.id,
                "name": task.name,
                "status": task.status,
                "planned_start_date": task.planned_start_date,
                "planned_end_date": task.planned_end_date,
                "template_id": template.id if template else task.source_template_id,
                "template_code": template.code if template else None,
                "chapter_name": chapter.name if chapter else None,
                "source_plan_id": latest.id,
                "source_plan_name": latest.name,
                "source_plan_start_date": latest.start_date,
                "source_plan_end_date": latest.end_date,
            }
        )
    items.sort(
        key=lambda item: (
            item["source_plan_end_date"] or date.min,
            item["name"],
        ),
        reverse=True,
    )
    return items


async def create_plan(
    db: Session,
    data: WorkPlanCreate,
    *,
    requested_by: int,
) -> WorkPlan:
    if data.end_date < data.start_date:
        raise WorkPlanValidationError("endDate debe ser >= startDate")
    obra = db.query(Obra).filter(Obra.id == data.obra_id).first()
    if not obra:
        raise WorkPlanValidationError(f"Obra {data.obra_id} no existe")

    uid = _new_uuid(data.uuid)
    exists = db.query(WorkPlan).filter(WorkPlan.uuid == uid).first()
    if exists:
        raise WorkPlanConflictError(f"Plan con uuid={uid} ya existe")

    task_ids = list(dict.fromkeys(data.task_ids or []))
    template_ids = list(dict.fromkeys(data.template_ids or []))
    if not task_ids and not template_ids:
        raise WorkPlanValidationError(
            "Selecciona al menos una actividad para el periodo."
        )

    tasks: List[Task] = []
    if task_ids:
        tasks = (
            db.query(Task)
            .options(joinedload(Task.unit))
            .filter(Task.id.in_(task_ids), Task.obra_id == data.obra_id)
            .all()
        )
        found_ids = {t.id for t in tasks}
        missing = [i for i in task_ids if i not in found_ids]
        if missing:
            raise WorkPlanValidationError(
                f"Tareas no encontradas en la obra: {missing}"
            )
        open_statuses = {"scheduled", "in_progress", "rescheduled"}
        for task in tasks:
            if task.parent_task_id is not None:
                raise WorkPlanValidationError(
                    f"«{task.name}» es una subtarea. El periodo incluye la actividad."
                )
            if task.status in open_statuses:
                task.planned_start_date = data.start_date
                task.planned_end_date = data.end_date

    for template_id in template_ids:
        tasks.append(
            add_task_from_catalog(
                db,
                TaskCreateFromTemplate(
                    obra_id=data.obra_id,
                    template_id=template_id,
                    planned_start_date=data.start_date,
                    planned_end_date=data.end_date,
                    copy_subtasks=False,
                    instantiate_dependencies=False,
                ),
                created_by=requested_by,
            )
        )

    plan = WorkPlan(
        uuid=uid,
        obra_id=data.obra_id,
        name=data.name,
        start_date=data.start_date,
        end_date=data.end_date,
        status=STATUS_DRAFT,
        requested_by=requested_by,
    )
    db.add(plan)
    db.flush()

    version = WorkPlanVersion(
        work_plan_id=plan.id,
        version_number=1,
        created_by=requested_by,
    )
    db.add(version)
    db.flush()

    for task in tasks:
        db.add(_snapshot_from_task(db, version_id=version.id, task=task))

    plan.current_version_id = version.id
    _append_event(
        db,
        version_id=version.id,
        event_type="created",
        user_id=requested_by,
        details=f"Plan creado con {len(tasks)} tarea(s)",
    )
    db.commit()
    return await get_plan(db, plan.id)


async def update_plan(
    db: Session,
    plan_id: int,
    data: WorkPlanUpdate,
    *,
    edited_by: int,
) -> WorkPlan:
    plan = db.query(WorkPlan).filter(WorkPlan.id == plan_id).first()
    if not plan:
        raise WorkPlanNotFoundError(f"Planificación {plan_id} no encontrada")
    _require_draft_plan(plan)
    payload = data.model_dump(exclude_unset=True)
    start = payload.get("start_date", plan.start_date)
    end = payload.get("end_date", plan.end_date)
    if end < start:
        raise WorkPlanValidationError("endDate debe ser >= startDate")
    if not payload:
        return await get_plan(db, plan_id)

    changes: List[str] = []
    if "name" in payload and payload["name"] != plan.name:
        changes.append("nombre")
    if "start_date" in payload and payload["start_date"] != plan.start_date:
        changes.append("fecha inicio")
    if "end_date" in payload and payload["end_date"] != plan.end_date:
        changes.append("fecha fin")

    for k, v in payload.items():
        setattr(plan, k, v)

    if plan.current_version_id and changes:
        _append_event(
            db,
            version_id=plan.current_version_id,
            event_type="edited",
            user_id=edited_by,
            details=f"Cabecera: {', '.join(changes)}",
        )
    db.commit()
    return await get_plan(db, plan_id)


async def get_plan_detail(db: Session, plan_id: int) -> Dict[str, Any]:
    plan = await get_plan(db, plan_id)
    versions = (
        db.query(WorkPlanVersion)
        .options(*_version_options())
        .filter(WorkPlanVersion.work_plan_id == plan_id)
        .order_by(WorkPlanVersion.version_number.desc())
        .all()
    )
    current = None
    if plan.current_version_id:
        current = _load_version(db, plan.current_version_id)

    detail: Dict[str, Any] = {
        "workPlan": plan_to_dict(plan),
        "versions": [
            version_to_dict(v, plan_status=plan.status) for v in versions
        ],
        "currentVersion": None,
    }
    if current:
        events = [
            event_to_dict(e)
            for e in sorted(
                current.signature_events or [],
                key=lambda x: x.event_at or datetime.min,
            )
            if e.event_type in ("created", "edited")
        ]
        # Planes antiguos sin evento created: completar desde la versión
        if not any(e.get("event_type") == "created" for e in events):
            events.insert(
                0,
                {
                    "id": -(current.id or 0),
                    "work_plan_version_id": current.id,
                    "user_id": current.created_by,
                    "user_name": _user_display(current.created_by_user),
                    "event_type": "created",
                    "event_at": current.created_at,
                    "details": f"Versión {current.version_number}",
                },
            )
        events.sort(key=lambda e: e.get("event_at") or datetime.min)
        detail["currentVersion"] = {
            "version": version_to_dict(current, plan_status=plan.status),
            "tasks": [snapshot_to_dict(t) for t in current.tasks],
            "signers": [signer_to_dict(s) for s in current.signers],
            "events": events,
        }
    return detail


# ---------- Snapshot tasks ----------


async def add_task_to_version(
    db: Session,
    version_id: int,
    data: WorkPlanTaskAdd,
    *,
    edited_by: int,
) -> WorkPlanTask:
    version = _load_version(db, version_id)
    if not version:
        raise WorkPlanNotFoundError(f"Versión {version_id} no encontrada")
    plan = _require_editable_version(db, version)
    if plan.status != STATUS_DRAFT:
        _require_draft_plan(plan)

    task = (
        db.query(Task)
        .options(joinedload(Task.unit))
        .filter(Task.id == data.task_id, Task.obra_id == plan.obra_id)
        .first()
    )
    if not task:
        raise WorkPlanValidationError(
            f"Tarea {data.task_id} no pertenece a la obra del plan"
        )
    exists = (
        db.query(WorkPlanTask)
        .filter(
            WorkPlanTask.work_plan_version_id == version_id,
            WorkPlanTask.task_id == data.task_id,
        )
        .first()
    )
    if exists:
        raise WorkPlanConflictError("La tarea ya está en esta versión")

    snap = _snapshot_from_task(
        db,
        version_id=version_id,
        task=task,
        planned_start=data.planned_start_date,
        planned_end=data.planned_end_date,
    )
    db.add(snap)
    _append_event(
        db,
        version_id=version_id,
        event_type="edited",
        user_id=edited_by,
        details=f"Tarea agregada: {task.name}",
    )
    db.commit()
    return db.query(WorkPlanTask).filter(WorkPlanTask.id == snap.id).first()


async def remove_task_from_version(
    db: Session, snapshot_id: int, *, edited_by: int
) -> None:
    row = db.query(WorkPlanTask).filter(WorkPlanTask.id == snapshot_id).first()
    if not row:
        raise WorkPlanNotFoundError(f"Snapshot {snapshot_id} no encontrado")
    version = _load_version(db, row.work_plan_version_id)
    plan = _require_editable_version(db, version)
    _require_draft_plan(plan)
    task_name = row.task_name_snapshot or f"#{row.task_id}"
    version_id = row.work_plan_version_id
    db.delete(row)
    _append_event(
        db,
        version_id=version_id,
        event_type="edited",
        user_id=edited_by,
        details=f"Tarea quitada: {task_name}",
    )
    db.commit()



async def create_new_version(
    db: Session,
    plan_id: int,
    data: WorkPlanNewVersionRequest,
    *,
    created_by: int,
) -> WorkPlan:
    """Nueva versión draft desde signed/rejected (o draft vacío no aplica)."""
    plan = db.query(WorkPlan).filter(WorkPlan.id == plan_id).first()
    if not plan:
        raise WorkPlanNotFoundError(f"Planificación {plan_id} no encontrada")
    if plan.status == STATUS_PENDING:
        raise WorkPlanValidationError(
            "Este plan ya se puede editar. No hace falta otra versión."
        )
    if plan.status == STATUS_DRAFT and plan.current_version_id:
        # Permitir solo si queremos iterar desde rejected → ya es draft vía cancel
        # Para signed/rejected creamos nueva; si draft, error
        raise WorkPlanValidationError(
            "Ya hay un borrador. Edítalo directo."
        )
    if plan.status not in (STATUS_SIGNED, STATUS_REJECTED):
        raise WorkPlanValidationError(
            f"Nueva versión desde signed/rejected (actual: {plan.status})"
        )

    prev = _load_version(db, plan.current_version_id)
    max_num = (
        db.query(func.max(WorkPlanVersion.version_number))
        .filter(WorkPlanVersion.work_plan_id == plan_id)
        .scalar()
        or 0
    )

    if data.name:
        plan.name = data.name
    if data.start_date:
        plan.start_date = data.start_date
    if data.end_date:
        plan.end_date = data.end_date
    if plan.end_date < plan.start_date:
        raise WorkPlanValidationError("endDate debe ser >= startDate")

    version = WorkPlanVersion(
        work_plan_id=plan.id,
        version_number=max_num + 1,
        created_by=created_by,
    )
    db.add(version)
    db.flush()

    task_ids = data.task_ids
    if task_ids is None:
        task_ids = [t.task_id for t in prev.tasks]

    tasks = (
        db.query(Task)
        .options(joinedload(Task.unit))
        .filter(Task.id.in_(task_ids), Task.obra_id == plan.obra_id)
        .all()
    )
    found = {t.id for t in tasks}
    missing = [i for i in task_ids if i not in found]
    if missing:
        raise WorkPlanValidationError(
            f"Tareas no encontradas en la obra: {missing}"
        )
    for task in tasks:
        db.add(_snapshot_from_task(db, version_id=version.id, task=task))

    plan.current_version_id = version.id
    plan.status = STATUS_DRAFT
    _append_event(
        db,
        version_id=version.id,
        event_type="created",
        user_id=created_by,
        details=f"Nueva versión {version.version_number} con {len(tasks)} tarea(s)",
    )
    db.commit()
    return await get_plan(db, plan_id)


# ---------- Comparación 7.3 ----------


async def add_activity_to_period(
    db: Session,
    data: TaskAddToPeriod,
    *,
    created_by: int,
) -> Dict[str, Any]:
    justification = data.justification.strip()
    if len(justification) < 8:
        raise WorkPlanValidationError("Escribe la justificación de la actividad.")

    plan = _period_plan(db, data.obra_id)
    if not plan or not plan.current_version_id:
        raise WorkPlanValidationError(
            "Esta obra no tiene un periodo de planificación. "
            "Crea el plan antes de agregar actividades."
        )

    if data.template_id:
        task = add_task_from_catalog(
            db,
            TaskCreateFromTemplate(
                obra_id=data.obra_id,
                template_id=data.template_id,
                name=data.name,
                description=data.description,
                planned_start_date=plan.start_date,
                planned_end_date=plan.end_date,
                copy_subtasks=False,
                instantiate_dependencies=False,
            ),
            created_by=created_by,
        )
    else:
        if not data.name or not data.name.strip():
            raise WorkPlanValidationError("El nombre de la actividad es obligatorio.")
        if (
            data.chapter_id is None
            or data.budget_activity_id is None
            or data.zone_id is None
        ):
            raise WorkPlanValidationError(
                "Indica capítulo, actividad presupuestal y zona."
            )
        task = add_unique_obra_task(
            db,
            obra_id=data.obra_id,
            name=data.name,
            description=data.description,
            planned_start_date=plan.start_date,
            planned_end_date=plan.end_date,
            created_by=created_by,
            chapter_id=data.chapter_id,
            budget_activity_id=data.budget_activity_id,
            zone_id=data.zone_id,
        )

    version = _load_version(db, plan.current_version_id)
    if not version:
        raise WorkPlanValidationError("El plan no tiene versión para agregar la actividad")
    already = any(row.task_id == task.id for row in (version.tasks or []))
    if not already:
        loaded = (
            db.query(Task)
            .options(joinedload(Task.unit))
            .filter(Task.id == task.id)
            .first()
        )
        db.add(_snapshot_from_task(db, version_id=version.id, task=loaded or task))
    _append_event(
        db,
        version_id=version.id,
        event_type="edited",
        user_id=created_by,
        details=f"Se añadió «{task.name}». Justificación: {justification}",
    )
    db.commit()
    return {
        "task": task_to_dict(await get_task(db, task.id)),
        "work_plan": plan_to_dict(await get_plan(db, plan.id)),
        "justification": justification,
    }


async def compare_version(
    db: Session, plan_id: int, version_id: Optional[int] = None
) -> Dict[str, Any]:
    plan = await get_plan(db, plan_id)
    vid = version_id or plan.current_version_id
    if not vid:
        raise WorkPlanValidationError("Sin versión para comparar")
    version = _load_version(db, vid)
    if not version or version.work_plan_id != plan_id:
        raise WorkPlanNotFoundError(f"Versión {vid} no pertenece al plan")

    items: List[Dict[str, Any]] = []
    for snap in version.tasks:
        task = (
            db.query(Task)
            .options(joinedload(Task.unit))
            .filter(Task.id == snap.task_id)
            .first()
        )
        delays = (
            db.query(TaskDelayEvent)
            .filter(TaskDelayEvent.task_id == snap.task_id)
            .all()
        )
        days_lost = Decimal("0")
        for d in delays:
            if d.days_lost is not None:
                days_lost += Decimal(str(d.days_lost))

        notes: List[str] = []
        if task:
            if task.name != snap.task_name_snapshot:
                notes.append("nombre cambió")
            if task.status in ("rescheduled",):
                notes.append("reprogramada")
            if (
                snap.approved_duration_days_snapshot is not None
                and task.approved_duration_days is not None
                and Decimal(str(task.approved_duration_days))
                != Decimal(str(snap.approved_duration_days_snapshot))
            ):
                notes.append("duración aprobada distinta")
            if days_lost > 0:
                notes.append(f"{days_lost} días perdidos")

        items.append(
            {
                "task_id": snap.task_id,
                "task_name_snapshot": snap.task_name_snapshot,
                "quantity_snapshot": snap.quantity_snapshot,
                "unit_snapshot": snap.unit_snapshot,
                "planned_start_date": snap.planned_start_date,
                "planned_end_date": snap.planned_end_date,
                "estimated_duration_days_snapshot": snap.estimated_duration_days_snapshot,
                "approved_duration_days_snapshot": snap.approved_duration_days_snapshot,
                "current_name": task.name if task else None,
                "current_status": task.status if task else None,
                "current_planned_start": task.planned_start_date if task else None,
                "current_planned_end": task.planned_end_date if task else None,
                "current_actual_start": task.actual_start_date if task else None,
                "current_actual_end": task.actual_end_date if task else None,
                "current_estimated_duration_days": (
                    task.estimated_duration_days if task else None
                ),
                "current_approved_duration_days": (
                    task.approved_duration_days if task else None
                ),
                "days_lost_total": days_lost if delays else Decimal("0"),
                "delay_count": len(delays),
                "variance_note": "; ".join(notes) if notes else None,
            }
        )

    return {
        "work_plan_id": plan.id,
        "version_id": version.id,
        "version_number": version.version_number,
        "plan_status": plan.status,
        "items": items,
    }
