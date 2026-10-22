"""
Planificación y firmas (Fase 7).
Versión firmada = inmutable. Firma = aprobación de una versión concreta.
"""
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
    UserNotification,
    UserRole,
    WorkPlan,
    WorkPlanSignature,
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
    WorkPlanRejectRequest,
    WorkPlanSignerAdd,
    WorkPlanSignRequest,
    WorkPlanTaskAdd,
    WorkPlanUpdate,
)
from app.schemas.planificacion.work_plan_schema import (
    SIGNATURE_EVENT_TYPES,
    SIGNATURE_TYPES,
    WORK_PLAN_STATUSES,
)

STATUS_DRAFT = "draft"
STATUS_PENDING = "pending_signature"
STATUS_SIGNED = "signed"
STATUS_REJECTED = "rejected"

SIGNER_PENDING = "pending"
SIGNER_SIGNED = "signed"
SIGNER_REJECTED = "rejected"


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
    immutable = plan_status == STATUS_SIGNED or (
        row.signed_at is not None
    )
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


def signature_to_dict(row: WorkPlanSignature) -> Dict[str, Any]:
    return {
        "id": row.id,
        "work_plan_signer_id": row.work_plan_signer_id,
        "user_id": row.user_id,
        "user_name": _user_display(row.user),
        "signature_type": row.signature_type,
        "signature_data": row.signature_data,
        "signed_at": row.signed_at,
        "ip_address": row.ip_address,
        "user_agent": row.user_agent,
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
    if plan.status != STATUS_DRAFT:
        raise WorkPlanValidationError(
            f"El plan está en status='{plan.status}'. "
            "Solo draft es editable. Firmado = nueva versión."
        )


def _require_editable_version(db: Session, version: WorkPlanVersion) -> WorkPlan:
    plan = db.query(WorkPlan).filter(WorkPlan.id == version.work_plan_id).first()
    if not plan:
        raise WorkPlanNotFoundError("Plan no encontrado")
    if plan.status == STATUS_SIGNED or version.signed_at:
        raise WorkPlanValidationError(
            "Versión firmada inmutable. Crea una nueva versión."
        )
    if plan.status not in (STATUS_DRAFT, STATUS_REJECTED):
        # pending_signature: no editar tareas/firmantes salvo cancelar
        if plan.status == STATUS_PENDING:
            raise WorkPlanValidationError(
                "Plan pendiente de firma. Cancela la solicitud para editar, "
                "o espera firmas."
            )
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
        # Firmas guardadas en firmante sin evento (datos legacy)
        signed_user_ids = {
            e.get("user_id")
            for e in events
            if e.get("event_type") == "signed" and e.get("user_id") is not None
        }
        for signer in current.signers or []:
            if (
                signer.status == SIGNER_SIGNED
                and signer.user_id not in signed_user_ids
                and signer.signed_at
            ):
                events.append(
                    {
                        "id": -(100000 + (signer.id or 0)),
                        "work_plan_version_id": current.id,
                        "user_id": signer.user_id,
                        "user_name": _user_display(signer.user),
                        "event_type": "signed",
                        "event_at": signer.signed_at,
                        "details": "Firma registrada",
                    }
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


# ---------- Signers / flow ----------


async def add_signer(
    db: Session,
    version_id: int,
    data: WorkPlanSignerAdd,
    *,
    edited_by: int,
) -> WorkPlanSigner:
    version = _load_version(db, version_id)
    if not version:
        raise WorkPlanNotFoundError(f"Versión {version_id} no encontrada")
    plan = _require_editable_version(db, version)
    _require_draft_plan(plan)

    user = (
        db.query(User)
        .options(joinedload(User.person))
        .filter(User.id == data.user_id, User.is_active == 1)
        .first()
    )
    if not user:
        raise WorkPlanValidationError(
            f"Usuario {data.user_id} inválido o inactivo"
        )
    exists = (
        db.query(WorkPlanSigner)
        .filter(
            WorkPlanSigner.work_plan_version_id == version_id,
            WorkPlanSigner.user_id == data.user_id,
        )
        .first()
    )
    if exists:
        raise WorkPlanConflictError("El usuario ya es firmante de esta versión")

    row = WorkPlanSigner(
        work_plan_version_id=version_id,
        user_id=data.user_id,
        signature_order=data.signature_order,
        status=SIGNER_PENDING,
    )
    db.add(row)
    _append_event(
        db,
        version_id=version_id,
        event_type="edited",
        user_id=edited_by,
        details=f"Firmante agregado: {_user_display(user) or user.username}",
    )
    db.commit()
    return (
        db.query(WorkPlanSigner)
        .options(joinedload(WorkPlanSigner.user).joinedload(User.person))
        .filter(WorkPlanSigner.id == row.id)
        .first()
    )


async def remove_signer(
    db: Session, signer_id: int, *, edited_by: int
) -> None:
    row = (
        db.query(WorkPlanSigner)
        .options(joinedload(WorkPlanSigner.user).joinedload(User.person))
        .filter(WorkPlanSigner.id == signer_id)
        .first()
    )
    if not row:
        raise WorkPlanNotFoundError(f"Firmante {signer_id} no encontrado")
    version = _load_version(db, row.work_plan_version_id)
    plan = _require_editable_version(db, version)
    _require_draft_plan(plan)
    name = _user_display(row.user) or f"#{row.user_id}"
    version_id = row.work_plan_version_id
    db.delete(row)
    _append_event(
        db,
        version_id=version_id,
        event_type="edited",
        user_id=edited_by,
        details=f"Firmante quitado: {name}",
    )
    db.commit()


def _admin_users(db: Session) -> List[User]:
    return (
        db.query(User)
        .options(joinedload(User.person), joinedload(User.role))
        .outerjoin(UserRole, User.role_id == UserRole.id)
        .filter(User.is_active == 1)
        .filter(or_(User.is_super == 1, UserRole.name.ilike("%admin%")))
        .all()
    )


def _add_signer_row(db: Session, version_id: int, user_id: int, order: int) -> None:
    exists = (
        db.query(WorkPlanSigner)
        .filter(
            WorkPlanSigner.work_plan_version_id == version_id,
            WorkPlanSigner.user_id == user_id,
        )
        .first()
    )
    if exists:
        if exists.status != SIGNER_PENDING:
            exists.status = SIGNER_PENDING
            exists.signed_at = None
            exists.rejected_at = None
            exists.rejection_reason = None
        return
    db.add(
        WorkPlanSigner(
            work_plan_version_id=version_id,
            user_id=user_id,
            signature_order=order,
            status=SIGNER_PENDING,
        )
    )


def _ensure_admin_signers(db: Session, version: WorkPlanVersion, admins: List[User]) -> None:
    order = len(version.signers or []) + 1
    for admin in admins:
        _add_signer_row(db, version.id, admin.id, order)
        order += 1
    db.flush()


def _version_with_added_task(
    db: Session,
    plan: WorkPlan,
    task: Task,
    *,
    created_by: int,
) -> WorkPlanVersion:
    """Deja un draft que incluye la actividad nueva. No hace commit."""
    if plan.status == STATUS_PENDING:
        plan.status = STATUS_DRAFT
        if plan.current_version_id:
            _append_event(
                db,
                version_id=plan.current_version_id,
                event_type="cancelled",
                user_id=created_by,
                details="Se reabre el plan para agregar una actividad",
            )

    if plan.status in (STATUS_SIGNED, STATUS_REJECTED):
        prev = _load_version(db, plan.current_version_id)
        max_num = (
            db.query(func.max(WorkPlanVersion.version_number))
            .filter(WorkPlanVersion.work_plan_id == plan.id)
            .scalar()
            or 0
        )
        version = WorkPlanVersion(
            work_plan_id=plan.id,
            version_number=max_num + 1,
            created_by=created_by,
        )
        db.add(version)
        db.flush()
        previous_ids = [row.task_id for row in (prev.tasks or [])]
        if task.id not in previous_ids:
            previous_ids.append(task.id)
        rows = (
            db.query(Task)
            .options(joinedload(Task.unit))
            .filter(Task.id.in_(previous_ids), Task.obra_id == plan.obra_id)
            .all()
        )
        by_id = {row.id: row for row in rows}
        for task_id in previous_ids:
            current = by_id.get(task_id)
            if not current:
                continue
            if current.id == task.id:
                current.planned_start_date = plan.start_date
                current.planned_end_date = plan.end_date
            db.add(_snapshot_from_task(db, version_id=version.id, task=current))
        order = 1
        for signer in prev.signers or []:
            _add_signer_row(db, version.id, signer.user_id, signer.signature_order or order)
            order += 1
        plan.current_version_id = version.id
        plan.status = STATUS_DRAFT
        _append_event(
            db,
            version_id=version.id,
            event_type="created",
            user_id=created_by,
            details=f"Nueva versión {version.version_number} por una actividad agregada",
        )
        db.flush()
        return _load_version(db, version.id)

    version = _load_version(db, plan.current_version_id)
    if not version:
        raise WorkPlanValidationError("El plan no tiene versión para agregar la actividad")
    already = any(row.task_id == task.id for row in (version.tasks or []))
    if not already:
        task.planned_start_date = plan.start_date
        task.planned_end_date = plan.end_date
        loaded = (
            db.query(Task)
            .options(joinedload(Task.unit))
            .filter(Task.id == task.id)
            .first()
        )
        db.add(_snapshot_from_task(db, version_id=version.id, task=loaded or task))
        db.flush()
    plan.status = STATUS_DRAFT
    return _load_version(db, version.id)


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
    if not plan:
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
        task = add_unique_obra_task(
            db,
            obra_id=data.obra_id,
            name=data.name or "",
            description=data.description,
            planned_start_date=plan.start_date,
            planned_end_date=plan.end_date,
            created_by=created_by,
        )

    admins = _admin_users(db)
    if not admins:
        raise WorkPlanValidationError(
            "No hay administradores activos para avisar y firmar."
        )

    version = _version_with_added_task(db, plan, task, created_by=created_by)
    _ensure_admin_signers(db, version, admins)
    version_id = version.id
    db.flush()
    db.expire(version)
    version = _load_version(db, version_id)
    if not version or not version.signers:
        raise WorkPlanValidationError("No quedó ningún firmante para el plan.")

    plan.status = STATUS_PENDING
    plan.requested_by = created_by
    detail = f"Se añadió «{task.name}». Justificación: {justification}"
    _append_event(
        db,
        version_id=version.id,
        event_type="requested",
        user_id=created_by,
        details=detail,
    )
    link = f"/dashboard/planes/{plan.id}"
    for admin in admins:
        db.add(
            UserNotification(
                user_id=admin.id,
                title=f"Firma pendiente · {plan.name}",
                body=detail,
                link=link,
            )
        )
    db.commit()
    return {
        "task": task_to_dict(await get_task(db, task.id)),
        "work_plan": plan_to_dict(await get_plan(db, plan.id)),
        "justification": justification,
    }


async def request_signatures(
    db: Session,
    plan_id: int,
    *,
    requested_by: int,
) -> WorkPlan:
    plan = db.query(WorkPlan).filter(WorkPlan.id == plan_id).first()
    if not plan:
        raise WorkPlanNotFoundError(f"Planificación {plan_id} no encontrada")
    if plan.status not in (STATUS_DRAFT, STATUS_REJECTED):
        raise WorkPlanValidationError(
            f"Solo draft/rejected pueden solicitar firma (actual: {plan.status})"
        )
    if not plan.current_version_id:
        raise WorkPlanValidationError("El plan no tiene versión actual")

    version = _load_version(db, plan.current_version_id)
    if not version.tasks:
        raise WorkPlanValidationError(
            "La versión no tiene tareas en el snapshot"
        )
    if not version.signers:
        raise WorkPlanValidationError(
            "Define al menos un firmante antes de solicitar firma"
        )

    # Reset rejected signers to pending if re-requesting
    for s in version.signers:
        if s.status == SIGNER_REJECTED:
            s.status = SIGNER_PENDING
            s.rejected_at = None
            s.rejection_reason = None

    plan.status = STATUS_PENDING
    plan.requested_by = requested_by
    _append_event(
        db,
        version_id=version.id,
        event_type="requested",
        user_id=requested_by,
        details=f"Solicitud de firma a {len(version.signers)} firmante(s)",
    )
    db.commit()
    return await get_plan(db, plan_id)


async def cancel_signature_request(
    db: Session,
    plan_id: int,
    *,
    cancelled_by: int,
) -> WorkPlan:
    plan = db.query(WorkPlan).filter(WorkPlan.id == plan_id).first()
    if not plan:
        raise WorkPlanNotFoundError(f"Planificación {plan_id} no encontrada")
    if plan.status != STATUS_PENDING:
        raise WorkPlanValidationError(
            "Solo se cancela un plan en pending_signature"
        )
    plan.status = STATUS_DRAFT
    if plan.current_version_id:
        _append_event(
            db,
            version_id=plan.current_version_id,
            event_type="cancelled",
            user_id=cancelled_by,
            details="Solicitud de firma cancelada; vuelve a draft",
        )
    db.commit()
    return await get_plan(db, plan_id)


async def mark_viewed(
    db: Session,
    plan_id: int,
    *,
    user_id: int,
) -> None:
    plan = await get_plan(db, plan_id)
    if not plan.current_version_id:
        return
    version = _load_version(db, plan.current_version_id)
    is_signer = any(s.user_id == user_id for s in version.signers)
    if not is_signer and plan.requested_by != user_id:
        raise WorkPlanValidationError(
            "Solo firmantes o el solicitante registran vista"
        )
    _append_event(
        db,
        version_id=version.id,
        event_type="viewed",
        user_id=user_id,
        details="Versión vista",
    )
    db.commit()


async def sign_plan(
    db: Session,
    plan_id: int,
    data: WorkPlanSignRequest,
    *,
    user_id: int,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> Dict[str, Any]:
    plan = db.query(WorkPlan).filter(WorkPlan.id == plan_id).first()
    if not plan:
        raise WorkPlanNotFoundError(f"Planificación {plan_id} no encontrada")
    if plan.status != STATUS_PENDING:
        raise WorkPlanValidationError(
            f"El plan debe estar pending_signature (actual: {plan.status})"
        )
    if data.signature_type not in SIGNATURE_TYPES:
        raise WorkPlanValidationError(
            f"signatureType inválido. Valores: {', '.join(SIGNATURE_TYPES)}"
        )
    _assert_no_secrets(data.signature_data)

    version = _load_version(db, plan.current_version_id)
    signer = next((s for s in version.signers if s.user_id == user_id), None)
    if not signer:
        raise WorkPlanValidationError("No eres firmante de esta versión")
    if signer.status == SIGNER_SIGNED:
        raise WorkPlanConflictError("Ya firmaste esta versión")
    if signer.status == SIGNER_REJECTED:
        raise WorkPlanValidationError(
            "Rechazaste esta versión; no puedes firmar"
        )

    now = datetime.utcnow()
    signer.status = SIGNER_SIGNED
    signer.signed_at = now

    sig = WorkPlanSignature(
        work_plan_signer_id=signer.id,
        user_id=user_id,
        signature_type=data.signature_type,
        signature_data=data.signature_data,
        signed_at=now,
        ip_address=ip_address,
        user_agent=(user_agent[:500] if user_agent else None),
    )
    db.add(sig)
    _append_event(
        db,
        version_id=version.id,
        event_type="signed",
        user_id=user_id,
        details=f"{_user_display(signer.user) or 'Firmante'} firmó ({data.signature_type})",
    )

    # ¿Todos firmaron?
    db.flush()
    version = _load_version(db, version.id)
    all_signed = all(s.status == SIGNER_SIGNED for s in version.signers)
    if all_signed:
        plan.status = STATUS_SIGNED
        version.signed_at = now

    db.commit()
    return {
        "workPlan": plan_to_dict(await get_plan(db, plan_id)),
        "signer": signer_to_dict(
            db.query(WorkPlanSigner)
            .options(joinedload(WorkPlanSigner.user).joinedload(User.person))
            .filter(WorkPlanSigner.id == signer.id)
            .first()
        ),
        "fullySigned": all_signed,
    }


async def reject_plan(
    db: Session,
    plan_id: int,
    data: WorkPlanRejectRequest,
    *,
    user_id: int,
) -> Dict[str, Any]:
    plan = db.query(WorkPlan).filter(WorkPlan.id == plan_id).first()
    if not plan:
        raise WorkPlanNotFoundError(f"Planificación {plan_id} no encontrada")
    if plan.status != STATUS_PENDING:
        raise WorkPlanValidationError(
            f"El plan debe estar pending_signature (actual: {plan.status})"
        )

    version = _load_version(db, plan.current_version_id)
    signer = next((s for s in version.signers if s.user_id == user_id), None)
    if not signer:
        raise WorkPlanValidationError("No eres firmante de esta versión")
    if signer.status != SIGNER_PENDING:
        raise WorkPlanValidationError(
            f"Firmante en status={signer.status}; no se puede rechazar"
        )

    now = datetime.utcnow()
    signer.status = SIGNER_REJECTED
    signer.rejected_at = now
    signer.rejection_reason = data.reason.strip()
    plan.status = STATUS_REJECTED

    _append_event(
        db,
        version_id=version.id,
        event_type="rejected",
        user_id=user_id,
        details=data.reason.strip(),
    )
    db.commit()
    return {
        "workPlan": plan_to_dict(await get_plan(db, plan_id)),
        "signer": signer_to_dict(
            db.query(WorkPlanSigner)
            .options(joinedload(WorkPlanSigner.user).joinedload(User.person))
            .filter(WorkPlanSigner.id == signer.id)
            .first()
        ),
    }


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
            "Cancela la solicitud de firma antes de crear nueva versión"
        )
    if plan.status == STATUS_DRAFT and plan.current_version_id:
        # Permitir solo si queremos iterar desde rejected → ya es draft vía cancel
        # Para signed/rejected creamos nueva; si draft, error
        raise WorkPlanValidationError(
            "Ya hay un draft. Edítalo o solicita firma."
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
