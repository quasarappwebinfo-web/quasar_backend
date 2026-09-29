"""
Operación — tareas en obra (Fase 6).
Plantilla recomienda; supervisor aprueba. Deps bloqueantes no se silencian.
"""
from __future__ import annotations

import uuid as uuid_lib
from datetime import date, datetime
from decimal import Decimal, ROUND_HALF_UP
from typing import Any, Dict, List, Optional, Tuple

from sqlalchemy.orm import Session, joinedload

from app.models import (
    Crew,
    DelayReason,
    MeasurementUnit,
    Obra,
    Task,
    TaskAssignment,
    TaskComment,
    TaskCrewAssignment,
    TaskDailyAssignment,
    TaskDelayEvent,
    TaskDependency,
    TaskDependencyOverride,
    TaskDocument,
    TaskPhoto,
    TaskReschedule,
    TaskStatusHistory,
    TaskTemplate,
    TaskTemplateDependency,
    TaskTemplateMeasurement,
    TaskTemplateSubtask,
    TaskTemplateVersion,
    User,
    Worker,
)
from app.schemas import (
    TaskAssignmentAdd,
    TaskCommentAdd,
    TaskCommentUpdate,
    TaskCreateFromTemplate,
    TaskCreateManual,
    TaskCrewAssignmentAdd,
    TaskDelayEventAdd,
    TaskDependencyAdd,
    TaskDependencyOverrideAdd,
    TaskRescheduleAdd,
    TaskStatusChange,
    TaskUpdate,
)
from app.schemas.operacion.task_schema import (
    COMMENT_TYPES,
    DEPENDENCY_TYPES,
    OVERRIDE_TYPES,
    TASK_STATUSES,
)
from app.services.s3_service import resolve_media_url

STATUS_SCHEDULED = "scheduled"
STATUS_IN_PROGRESS = "in_progress"
STATUS_COMPLETED = "completed"
STATUS_VERIFIED = "verified"
STATUS_RESCHEDULED = "rescheduled"

# Transiciones permitidas (grafo)
ALLOWED_TRANSITIONS: Dict[str, set] = {
    STATUS_SCHEDULED: {STATUS_IN_PROGRESS, STATUS_RESCHEDULED},
    STATUS_IN_PROGRESS: {STATUS_COMPLETED, STATUS_RESCHEDULED, STATUS_SCHEDULED},
    STATUS_COMPLETED: {STATUS_VERIFIED, STATUS_IN_PROGRESS},
    STATUS_VERIFIED: set(),
    STATUS_RESCHEDULED: {STATUS_SCHEDULED, STATUS_IN_PROGRESS},
}

# Dep cumplida si el prerequisito llegó al menos a completed
DEP_SATISFIED_STATUSES = {STATUS_COMPLETED, STATUS_VERIFIED}


class TaskOpError(Exception):
    pass


class TaskOpNotFoundError(TaskOpError):
    pass


class TaskOpConflictError(TaskOpError):
    pass


class TaskOpValidationError(TaskOpError):
    pass


class TaskOpBlockedError(TaskOpError):
    """Inicio bloqueado por dependencias. Contiene lista en .blocking"""

    def __init__(self, message: str, blocking: List[Dict[str, Any]]):
        super().__init__(message)
        self.blocking = blocking


def _new_uuid(value: Optional[str] = None) -> str:
    if value:
        return value.strip()
    return str(uuid_lib.uuid4())


def _dec(value) -> Decimal:
    return Decimal(str(value))


def _pagination(total: int, page: int, limit: int = 50) -> Dict[str, Any]:
    return {
        "totalItems": total,
        "itemsPerPage": limit,
        "currentPage": page,
    }


def _initials(name: Optional[str]) -> Optional[str]:
    if not name:
        return None
    parts = [p for p in name.strip().split() if p]
    if not parts:
        return None
    if len(parts) == 1:
        return parts[0][:2].upper()
    return (parts[0][0] + parts[-1][0]).upper()


def _person_name(worker: Optional[Worker]) -> Optional[str]:
    if worker and worker.person:
        return worker.person.name
    return None


def _user_display(user: Optional[User]) -> Optional[str]:
    if not user:
        return None
    if user.person and user.person.name:
        return user.person.name
    return user.username


# ---------- serializers ----------


def task_to_dict(row: Task, *, enrich: bool = True) -> Dict[str, Any]:
    tpl = None
    category_id = None
    category_name = None
    zone_id = None
    zone_name = None
    budget_activity_id = None
    budget_activity_name = None
    template_code = None
    template_name = None
    if row.source_template_version:
        tpl = row.source_template_version.task_template
        if tpl:
            template_code = tpl.code
            template_name = tpl.name
            if tpl.category:
                category_id = tpl.category.id
                category_name = tpl.category.name
            if tpl.zone:
                zone_id = tpl.zone.id
                zone_name = tpl.zone.name
            if tpl.budget_activity:
                budget_activity_id = tpl.budget_activity.id
                budget_activity_name = tpl.budget_activity.name

    data: Dict[str, Any] = {
        "id": row.id,
        "uuid": row.uuid,
        "obra_id": row.obra_id,
        "obra_name": row.obra.name if row.obra else None,
        "source_template_version_id": row.source_template_version_id,
        "template_code": template_code,
        "template_name": template_name,
        "category_id": category_id,
        "category_name": category_name,
        "zone_id": zone_id,
        "zone_name": zone_name,
        "budget_activity_id": budget_activity_id,
        "budget_activity_name": budget_activity_name,
        "parent_task_id": row.parent_task_id,
        "name": row.name,
        "description": row.description,
        "weight_percent": row.weight_percent,
        "budget_weight_percent": row.budget_weight_percent,
        "unit_id": row.unit_id,
        "unit_name": row.unit.name if row.unit else None,
        "unit_symbol": row.unit.symbol if row.unit else None,
        "planned_quantity": row.planned_quantity,
        "template_base_quantity": row.template_base_quantity,
        "template_base_duration_days": row.template_base_duration_days,
        "estimated_duration_days": row.estimated_duration_days,
        "approved_duration_days": row.approved_duration_days,
        "planned_start_date": row.planned_start_date,
        "planned_end_date": row.planned_end_date,
        "actual_start_date": row.actual_start_date,
        "actual_end_date": row.actual_end_date,
        "status": row.status,
        "progress_percent": None,
        "photo_count": 0,
        "document_count": 0,
        "attachment_count": 0,
        "subtask_count": 0,
        "subtasks_done": 0,
        "is_delayed": False,
        "primary_assignee": None,
        "created_by": row.created_by,
        "created_by_name": _user_display(getattr(row, "created_by_user", None)),
        "created_at": row.created_at,
        "updated_by": getattr(row, "updated_by", None),
        "updated_by_name": _user_display(getattr(row, "updated_by_user", None)),
        "updated_at": row.updated_at,
    }

    if not enrich:
        return data

    # Subtareas / progreso ponderado por weight_percent
    children = list(row.subtasks) if row.subtasks is not None else []
    data["subtask_count"] = len(children)
    done = sum(
        1 for c in children if c.status in (STATUS_COMPLETED, STATUS_VERIFIED)
    )
    data["subtasks_done"] = done
    if children:
        weights = []
        for c in children:
            w = c.weight_percent
            if w is None:
                weights.append(Decimal("0"))
            else:
                weights.append(Decimal(str(w)))
        total_w = sum(weights)
        if total_w > 0:
            done_w = sum(
                w
                for c, w in zip(children, weights)
                if c.status in (STATUS_COMPLETED, STATUS_VERIFIED)
            )
            pct = (done_w / total_w * 100).quantize(
                Decimal("1"), rounding=ROUND_HALF_UP
            )
        else:
            # Sin pesos: fallback 1/N
            pct = (Decimal(done) / Decimal(len(children)) * 100).quantize(
                Decimal("1"), rounding=ROUND_HALF_UP
            )
        data["progress_percent"] = pct
    elif row.status == STATUS_IN_PROGRESS:
        data["progress_percent"] = Decimal("0")
    elif row.status in (STATUS_COMPLETED, STATUS_VERIFIED):
        data["progress_percent"] = Decimal("100")

    photos = list(row.photos) if row.photos is not None else []
    data["photo_count"] = len(photos)
    docs = list(getattr(row, "documents", None) or [])
    data["document_count"] = len(docs)
    data["attachment_count"] = data["photo_count"] + data["document_count"]
    delays = list(row.delay_events) if row.delay_events is not None else []
    data["is_delayed"] = any(d.end_date is None for d in delays)

    # Asignado principal: gente de HOY en la tarea; si no, asignación larga duración
    today = date.today()
    daily_today = [
        a
        for a in (row.daily_assignments or [])
        if a.removed_at is None and a.work_date == today
    ]
    if daily_today:
        w = daily_today[0].worker
        name = _person_name(w)
        data["primary_assignee"] = {
            "worker_id": daily_today[0].worker_id,
            "worker_name": name,
            "initials": _initials(name),
            "position_name": (
                w.worker_position.name if w and w.worker_position else None
            ),
            "crew_id": None,
            "crew_name": None,
        }
    else:
        active_asg = [
            a for a in (row.assignments or []) if a.removed_at is None
        ]
        if active_asg:
            w = active_asg[0].worker
            name = _person_name(w)
            data["primary_assignee"] = {
                "worker_id": active_asg[0].worker_id,
                "worker_name": name,
                "initials": _initials(name),
                "position_name": (
                    w.worker_position.name if w and w.worker_position else None
                ),
                "crew_id": None,
                "crew_name": None,
            }
        else:
            active_crews = [
                c for c in (row.crew_assignments or []) if c.removed_at is None
            ]
            if active_crews:
                crew = active_crews[0].crew
                data["primary_assignee"] = {
                    "worker_id": None,
                    "worker_name": None,
                    "initials": _initials(crew.name if crew else None),
                    "position_name": "Cuadrilla",
                    "crew_id": active_crews[0].crew_id,
                    "crew_name": crew.name if crew else None,
                }

    return data


def assignment_to_dict(row: TaskAssignment) -> Dict[str, Any]:
    w = row.worker
    return {
        "id": row.id,
        "task_id": row.task_id,
        "worker_id": row.worker_id,
        "worker_name": _person_name(w),
        "position_name": (
            w.worker_position.name if w and w.worker_position else None
        ),
        "start_date": row.start_date,
        "end_date": row.end_date,
        "assigned_at": row.assigned_at,
        "assigned_by": row.assigned_by,
        "removed_at": row.removed_at,
        "removed_by": row.removed_by,
    }


def crew_assignment_to_dict(row: TaskCrewAssignment) -> Dict[str, Any]:
    return {
        "id": row.id,
        "task_id": row.task_id,
        "crew_id": row.crew_id,
        "crew_name": row.crew.name if row.crew else None,
        "start_date": row.start_date,
        "end_date": row.end_date,
        "assigned_at": row.assigned_at,
        "assigned_by": row.assigned_by,
        "removed_at": row.removed_at,
        "removed_by": row.removed_by,
    }


def dependency_to_dict(row: TaskDependency) -> Dict[str, Any]:
    dep = row.depends_on_task
    return {
        "id": row.id,
        "task_id": row.task_id,
        "depends_on_task_id": row.depends_on_task_id,
        "depends_on_task_name": dep.name if dep else None,
        "depends_on_status": dep.status if dep else None,
        "dependency_type": row.dependency_type,
        "is_required": row.is_required,
        "blocks_start": row.blocks_start,
        "created_at": row.created_at,
    }


def override_to_dict(row: TaskDependencyOverride) -> Dict[str, Any]:
    return {
        "id": row.id,
        "task_id": row.task_id,
        "template_dependency_id": row.template_dependency_id,
        "override_type": row.override_type,
        "reason": row.reason,
        "created_by": row.created_by,
        "created_at": row.created_at,
    }


def history_to_dict(row: TaskStatusHistory) -> Dict[str, Any]:
    return {
        "id": row.id,
        "task_id": row.task_id,
        "from_status": row.from_status,
        "to_status": row.to_status,
        "reason": row.reason,
        "changed_by": row.changed_by,
        "changed_at": row.changed_at,
    }


def reschedule_to_dict(row: TaskReschedule) -> Dict[str, Any]:
    return {
        "id": row.id,
        "uuid": row.uuid,
        "task_id": row.task_id,
        "previous_start_date": row.previous_start_date,
        "previous_end_date": row.previous_end_date,
        "new_start_date": row.new_start_date,
        "new_end_date": row.new_end_date,
        "reason_id": row.reason_id,
        "reason_name": row.reason_ref.name if row.reason_ref else None,
        "reason": row.reason,
        "rescheduled_by": row.rescheduled_by,
        "rescheduled_at": row.rescheduled_at,
    }


def delay_to_dict(row: TaskDelayEvent) -> Dict[str, Any]:
    return {
        "id": row.id,
        "uuid": row.uuid,
        "task_id": row.task_id,
        "delay_reason_id": row.delay_reason_id,
        "delay_reason_name": row.delay_reason.name if row.delay_reason else None,
        "start_date": row.start_date,
        "end_date": row.end_date,
        "days_lost": row.days_lost,
        "description": row.description,
        "created_by": row.created_by,
        "created_at": row.created_at,
    }


def comment_to_dict(row: TaskComment) -> Dict[str, Any]:
    uname = None
    if row.user and row.user.person:
        uname = row.user.person.name
    elif row.user:
        uname = row.user.username
    return {
        "id": row.id,
        "uuid": row.uuid,
        "task_id": row.task_id,
        "user_id": row.user_id,
        "user_name": uname,
        "type": row.type,
        "content": row.content,
        "created_at": row.created_at,
        "updated_at": row.updated_at,
    }


def photo_to_dict(row: TaskPhoto) -> Dict[str, Any]:
    url = row.file_url
    if url and not url.startswith("http"):
        url = resolve_media_url(url) or url
    return {
        "id": row.id,
        "uuid": row.uuid,
        "task_id": row.task_id,
        "file_url": url,
        "description": row.description,
        "taken_at": row.taken_at,
        "uploaded_by": row.uploaded_by,
        "uploaded_by_name": _user_display(getattr(row, "uploaded_by_user", None)),
        "created_at": row.created_at,
    }


def document_to_dict(row: TaskDocument) -> Dict[str, Any]:
    url = row.file_url
    if url and not url.startswith("http"):
        url = resolve_media_url(url) or url
    return {
        "id": row.id,
        "uuid": row.uuid,
        "task_id": row.task_id,
        "name": row.name,
        "description": row.description,
        "file_url": url,
        "content_type": row.content_type,
        "file_size_bytes": row.file_size_bytes,
        "uploaded_by": row.uploaded_by,
        "uploaded_by_name": _user_display(getattr(row, "uploaded_by_user", None)),
        "created_at": row.created_at,
    }


def _task_load_options():
    return [
        joinedload(Task.obra),
        joinedload(Task.unit),
        joinedload(Task.created_by_user).joinedload(User.person),
        joinedload(Task.updated_by_user).joinedload(User.person),
        joinedload(Task.source_template_version)
        .joinedload(TaskTemplateVersion.task_template)
        .options(
            joinedload(TaskTemplate.category),
            joinedload(TaskTemplate.zone),
            joinedload(TaskTemplate.budget_activity),
        ),
        joinedload(Task.assignments).joinedload(TaskAssignment.worker).joinedload(
            Worker.person
        ),
        joinedload(Task.assignments)
        .joinedload(TaskAssignment.worker)
        .joinedload(Worker.worker_position),
        joinedload(Task.crew_assignments).joinedload(TaskCrewAssignment.crew),
        joinedload(Task.daily_assignments).joinedload(
            TaskDailyAssignment.worker
        ).joinedload(Worker.person),
        joinedload(Task.daily_assignments)
        .joinedload(TaskDailyAssignment.worker)
        .joinedload(Worker.worker_position),
        joinedload(Task.photos).joinedload(TaskPhoto.uploaded_by_user).joinedload(
            User.person
        ),
        joinedload(Task.documents).joinedload(TaskDocument.uploaded_by_user).joinedload(
            User.person
        ),
        joinedload(Task.delay_events),
        joinedload(Task.subtasks),
    ]


def _load_task(db: Session, task_id: int) -> Optional[Task]:
    return (
        db.query(Task)
        .options(*_task_load_options())
        .filter(Task.id == task_id)
        .first()
    )


def _append_history(
    db: Session,
    *,
    task_id: int,
    from_status: Optional[str],
    to_status: str,
    changed_by: int,
    reason: Optional[str] = None,
) -> None:
    db.add(
        TaskStatusHistory(
            task_id=task_id,
            from_status=from_status,
            to_status=to_status,
            reason=reason,
            changed_by=changed_by,
        )
    )


def _assert_uuid_free(db: Session, model, value: str, label: str) -> None:
    exists = db.query(model).filter(model.uuid == value).first()
    if exists:
        raise TaskOpConflictError(f"{label} con uuid={value} ya existe")


# ---------- CRUD tareas ----------


async def get_task(db: Session, task_id: int) -> Task:
    row = _load_task(db, task_id)
    if not row:
        raise TaskOpNotFoundError(f"Tarea {task_id} no encontrada")
    return row


async def list_tasks(
    db: Session,
    *,
    page: int = 1,
    obra_id: Optional[int] = None,
    status: Optional[str] = None,
    category_id: Optional[int] = None,
    search: Optional[str] = None,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    parent_only: bool = True,
    parent_task_id: Optional[int] = None,
    limit: int = 50,
) -> Dict[str, Any]:
    q = db.query(Task).options(*_task_load_options())

    if obra_id is not None:
        q = q.filter(Task.obra_id == obra_id)
    if status:
        if status not in TASK_STATUSES:
            raise TaskOpValidationError(
                f"status inválido. Valores: {', '.join(TASK_STATUSES)}"
            )
        q = q.filter(Task.status == status)
    if parent_task_id is not None:
        q = q.filter(Task.parent_task_id == parent_task_id)
    elif parent_only:
        q = q.filter(Task.parent_task_id.is_(None))
    if search:
        like = f"%{search.strip()}%"
        q = q.filter(Task.name.ilike(like))
    if date_from is not None:
        q = q.filter(
            (Task.planned_end_date.is_(None))
            | (Task.planned_end_date >= date_from)
        )
    if date_to is not None:
        q = q.filter(
            (Task.planned_start_date.is_(None))
            | (Task.planned_start_date <= date_to)
        )
    if category_id is not None:
        q = (
            q.join(Task.source_template_version)
            .join(TaskTemplateVersion.task_template)
            .filter(TaskTemplate.category_id == category_id)
            .distinct()
        )

    total = q.count()
    rows = (
        q.order_by(Task.planned_start_date.asc(), Task.id.desc())
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )
    return {
        "tasks": [task_to_dict(r) for r in rows],
        "pagination": _pagination(total, page, limit),
    }


async def list_board(
    db: Session,
    *,
    obra_id: int,
    category_id: Optional[int] = None,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
) -> Dict[str, Any]:
    """Kanban: tareas padre agrupadas por status."""
    result = await list_tasks(
        db,
        page=1,
        obra_id=obra_id,
        category_id=category_id,
        date_from=date_from,
        date_to=date_to,
        parent_only=True,
        limit=500,
    )
    columns: Dict[str, List[Dict[str, Any]]] = {s: [] for s in TASK_STATUSES}
    for t in result["tasks"]:
        st = t["status"]
        if st in columns:
            columns[st].append(t)
    return {
        "obraId": obra_id,
        "columns": {
            "scheduled": columns[STATUS_SCHEDULED],
            "inProgress": columns[STATUS_IN_PROGRESS],
            "completed": columns[STATUS_COMPLETED],
            "verified": columns[STATUS_VERIFIED],
            "rescheduled": columns[STATUS_RESCHEDULED],
        },
        "counts": {
            "scheduled": len(columns[STATUS_SCHEDULED]),
            "inProgress": len(columns[STATUS_IN_PROGRESS]),
            "completed": len(columns[STATUS_COMPLETED]),
            "verified": len(columns[STATUS_VERIFIED]),
            "rescheduled": len(columns[STATUS_RESCHEDULED]),
        },
    }


def _primary_unit_id(db: Session, version_id: int) -> Optional[int]:
    primary = (
        db.query(TaskTemplateMeasurement)
        .filter(
            TaskTemplateMeasurement.template_version_id == version_id,
            TaskTemplateMeasurement.is_primary == 1,
        )
        .first()
    )
    if primary:
        return primary.unit_id
    any_m = (
        db.query(TaskTemplateMeasurement)
        .filter(TaskTemplateMeasurement.template_version_id == version_id)
        .first()
    )
    return any_m.unit_id if any_m else None


def _estimate_duration(
    base_qty: Decimal, base_days: Decimal, obra_qty: Decimal
) -> Decimal:
    factor = (obra_qty / base_qty).quantize(
        Decimal("0.0001"), rounding=ROUND_HALF_UP
    )
    return (base_days * factor).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)


async def create_task_from_template(
    db: Session,
    data: TaskCreateFromTemplate,
    *,
    created_by: int,
) -> Task:
    obra = db.query(Obra).filter(Obra.id == data.obra_id).first()
    if not obra:
        raise TaskOpValidationError(f"Obra {data.obra_id} no existe")

    version = (
        db.query(TaskTemplateVersion)
        .options(
            joinedload(TaskTemplateVersion.task_template),
            joinedload(TaskTemplateVersion.subtasks),
            joinedload(TaskTemplateVersion.dependencies),
            joinedload(TaskTemplateVersion.measurements),
        )
        .filter(TaskTemplateVersion.id == data.source_template_version_id)
        .first()
    )
    if not version:
        raise TaskOpValidationError(
            f"Versión {data.source_template_version_id} no existe"
        )
    if version.status != "published":
        raise TaskOpValidationError(
            f"Solo se crea desde versión published (actual: {version.status})"
        )
    if not version.base_quantity or _dec(version.base_quantity) <= 0:
        raise TaskOpValidationError("La versión no tiene baseQuantity válida")
    if not version.base_duration_days or _dec(version.base_duration_days) <= 0:
        raise TaskOpValidationError(
            "La versión no tiene baseDurationDays válida"
        )

    uid = _new_uuid(data.uuid)
    _assert_uuid_free(db, Task, uid, "Tarea")

    base_q = _dec(version.base_quantity)
    base_d = _dec(version.base_duration_days)
    estimated = _estimate_duration(base_q, base_d, data.planned_quantity)
    approved = (
        data.approved_duration_days
        if data.approved_duration_days is not None
        else estimated
    )
    tpl = version.task_template
    name = data.name or (tpl.name if tpl else version.name)
    unit_id = _primary_unit_id(db, version.id)

    task = Task(
        uuid=uid,
        obra_id=data.obra_id,
        source_template_version_id=version.id,
        parent_task_id=None,
        name=name,
        description=data.description or version.description,
        unit_id=unit_id,
        planned_quantity=data.planned_quantity,
        template_base_quantity=base_q,
        template_base_duration_days=base_d,
        estimated_duration_days=estimated,
        approved_duration_days=approved,
        planned_start_date=data.planned_start_date,
        planned_end_date=data.planned_end_date,
        status=STATUS_SCHEDULED,
        budget_weight_percent=tpl.budget_weight_percent if tpl else None,
        created_by=created_by,
    )
    db.add(task)
    db.flush()

    _append_history(
        db,
        task_id=task.id,
        from_status=None,
        to_status=STATUS_SCHEDULED,
        changed_by=created_by,
        reason="Creada desde plantilla",
    )

    if data.copy_subtasks:
        for st in sorted(version.subtasks or [], key=lambda s: s.display_order):
            child_uuid = str(uuid_lib.uuid4())
            child = Task(
                uuid=child_uuid,
                obra_id=data.obra_id,
                source_template_version_id=None,
                parent_task_id=task.id,
                name=st.name,
                description=st.description,
                status=STATUS_SCHEDULED,
                weight_percent=st.weight_percent,
                created_by=created_by,
            )
            db.add(child)
            db.flush()
            _append_history(
                db,
                task_id=child.id,
                from_status=None,
                to_status=STATUS_SCHEDULED,
                changed_by=created_by,
                reason="Subtarea desde plantilla",
            )

    if data.instantiate_dependencies:
        _instantiate_template_deps(db, task, version, created_by=created_by)

    db.commit()
    return await get_task(db, task.id)


def _instantiate_template_deps(
    db: Session,
    task: Task,
    version: TaskTemplateVersion,
    *,
    created_by: int,
) -> None:
    """
    Busca en la misma obra una tarea cuyo template_id coincida con
    depends_on_template_id. Si existe, crea TaskDependency.
    """
    _ = created_by
    for dep in version.dependencies or []:
        # Override waive en esta tarea (aún no suele haber) — skip si waive
        waived = (
            db.query(TaskDependencyOverride)
            .filter(
                TaskDependencyOverride.task_id == task.id,
                TaskDependencyOverride.template_dependency_id == dep.id,
                TaskDependencyOverride.override_type == "waive",
            )
            .first()
        )
        if waived:
            continue

        # Tarea prerequisito en la obra: plantilla origen = depends_on_template_id
        prerequisite = (
            db.query(Task)
            .join(
                TaskTemplateVersion,
                Task.source_template_version_id == TaskTemplateVersion.id,
            )
            .filter(
                Task.obra_id == task.obra_id,
                Task.parent_task_id.is_(None),
                TaskTemplateVersion.task_template_id == dep.depends_on_template_id,
                Task.id != task.id,
            )
            .order_by(Task.id.desc())
            .first()
        )
        if not prerequisite:
            continue

        blocks = dep.blocks_start
        relaxed = (
            db.query(TaskDependencyOverride)
            .filter(
                TaskDependencyOverride.task_id == task.id,
                TaskDependencyOverride.template_dependency_id == dep.id,
                TaskDependencyOverride.override_type == "relax",
            )
            .first()
        )
        if relaxed:
            blocks = 0

        db.add(
            TaskDependency(
                task_id=task.id,
                depends_on_task_id=prerequisite.id,
                dependency_type=dep.dependency_type,
                is_required=dep.is_required,
                blocks_start=blocks,
            )
        )


async def create_task_manual(
    db: Session,
    data: TaskCreateManual,
    *,
    created_by: int,
) -> Task:
    obra = db.query(Obra).filter(Obra.id == data.obra_id).first()
    if not obra:
        raise TaskOpValidationError(f"Obra {data.obra_id} no existe")

    if data.parent_task_id is not None:
        parent = db.query(Task).filter(Task.id == data.parent_task_id).first()
        if not parent:
            raise TaskOpValidationError(
                f"Tarea padre {data.parent_task_id} no existe"
            )
        if parent.obra_id != data.obra_id:
            raise TaskOpValidationError(
                "La subtarea debe pertenecer a la misma obra que el padre"
            )
        if data.weight_percent is None:
            raise TaskOpValidationError(
                "Las subtareas requieren weightPercent (% hacia el 100% de la actividad)"
            )

    if data.unit_id is not None:
        unit = (
            db.query(MeasurementUnit)
            .filter(MeasurementUnit.id == data.unit_id)
            .first()
        )
        if not unit:
            raise TaskOpValidationError(f"Unidad {data.unit_id} no existe")

    uid = _new_uuid(data.uuid)
    _assert_uuid_free(db, Task, uid, "Tarea")

    task = Task(
        uuid=uid,
        obra_id=data.obra_id,
        parent_task_id=data.parent_task_id,
        name=data.name,
        description=data.description,
        unit_id=data.unit_id,
        planned_quantity=data.planned_quantity,
        estimated_duration_days=data.estimated_duration_days,
        approved_duration_days=data.approved_duration_days,
        planned_start_date=data.planned_start_date,
        planned_end_date=data.planned_end_date,
        status=STATUS_SCHEDULED,
        weight_percent=data.weight_percent,
        created_by=created_by,
    )
    db.add(task)
    db.flush()
    _append_history(
        db,
        task_id=task.id,
        from_status=None,
        to_status=STATUS_SCHEDULED,
        changed_by=created_by,
        reason="Creada manualmente",
    )
    db.commit()
    return await get_task(db, task.id)


async def update_task(
    db: Session,
    task_id: int,
    data: TaskUpdate,
    *,
    updated_by: Optional[int] = None,
) -> Task:
    row = db.query(Task).filter(Task.id == task_id).first()
    if not row:
        raise TaskOpNotFoundError(f"Tarea {task_id} no encontrada")
    if row.status == STATUS_VERIFIED:
        raise TaskOpValidationError(
            "Una tarea verified no se edita. Crea otra o reabre vía status."
        )
    payload = data.model_dump(exclude_unset=True)
    if "unit_id" in payload and payload["unit_id"] is not None:
        unit = (
            db.query(MeasurementUnit)
            .filter(MeasurementUnit.id == payload["unit_id"])
            .first()
        )
        if not unit:
            raise TaskOpValidationError(f"Unidad {payload['unit_id']} no existe")
    for k, v in payload.items():
        setattr(row, k, v)
    if updated_by is not None:
        row.updated_by = updated_by
        row.updated_at = datetime.utcnow()
    db.commit()
    return await get_task(db, task_id)


# ---------- Ciclo de vida ----------


def _blocking_dependencies(
    db: Session, task: Task
) -> List[Dict[str, Any]]:
    deps = (
        db.query(TaskDependency)
        .options(joinedload(TaskDependency.depends_on_task))
        .filter(TaskDependency.task_id == task.id)
        .all()
    )
    blocking: List[Dict[str, Any]] = []
    for d in deps:
        if not d.blocks_start:
            continue
        dep_task = d.depends_on_task
        if not dep_task:
            continue
        if dep_task.status in DEP_SATISFIED_STATUSES:
            continue
        blocking.append(
            {
                "dependency_id": d.id,
                "depends_on_task_id": dep_task.id,
                "depends_on_task_name": dep_task.name,
                "depends_on_status": dep_task.status,
                "dependency_type": d.dependency_type,
                "blocks_start": d.blocks_start,
                "message": (
                    f"«{dep_task.name}» está en status={dep_task.status}. "
                    "Debe estar completed o verified antes de iniciar."
                ),
            }
        )
    return blocking


async def change_task_status(
    db: Session,
    task_id: int,
    data: TaskStatusChange,
    *,
    changed_by: int,
) -> Dict[str, Any]:
    row = db.query(Task).filter(Task.id == task_id).first()
    if not row:
        raise TaskOpNotFoundError(f"Tarea {task_id} no encontrada")

    to_status = data.to_status
    if to_status not in TASK_STATUSES:
        raise TaskOpValidationError(
            f"toStatus inválido. Valores: {', '.join(TASK_STATUSES)}"
        )
    if to_status == STATUS_RESCHEDULED:
        raise TaskOpValidationError(
            "Usa POST .../reprogramar para pasar a rescheduled "
            "(guarda historial de fechas)."
        )

    allowed = ALLOWED_TRANSITIONS.get(row.status, set())
    if to_status not in allowed:
        raise TaskOpValidationError(
            f"Transición no permitida: {row.status} → {to_status}. "
            f"Permitidas: {', '.join(sorted(allowed)) or '(ninguna)'}"
        )

    forced = False
    blocking: List[Dict[str, Any]] = []
    if to_status == STATUS_IN_PROGRESS:
        blocking = _blocking_dependencies(db, row)
        if blocking and not data.force:
            raise TaskOpBlockedError(
                "No se puede iniciar: hay dependencias bloqueantes",
                blocking,
            )
        if blocking and data.force:
            forced = True

    from_status = row.status
    row.status = to_status
    today = date.today()
    if to_status == STATUS_IN_PROGRESS and not row.actual_start_date:
        row.actual_start_date = today
    if to_status == STATUS_COMPLETED and not row.actual_end_date:
        row.actual_end_date = today

    reason = data.reason
    if forced:
        reason = (
            (reason or "")
            + " [FORZADO: deps bloqueantes omitidas]"
        ).strip()

    _append_history(
        db,
        task_id=row.id,
        from_status=from_status,
        to_status=to_status,
        changed_by=changed_by,
        reason=reason,
    )
    db.commit()
    loaded = await get_task(db, task_id)
    return {
        "task": task_to_dict(loaded),
        "blocked": False,
        "blocking_dependencies": blocking if forced else [],
        "forced": forced,
    }


async def reschedule_task(
    db: Session,
    task_id: int,
    data: TaskRescheduleAdd,
    *,
    rescheduled_by: int,
) -> Tuple[Task, TaskReschedule]:
    row = db.query(Task).filter(Task.id == task_id).first()
    if not row:
        raise TaskOpNotFoundError(f"Tarea {task_id} no encontrada")
    if row.status == STATUS_VERIFIED:
        raise TaskOpValidationError("No se reprograma una tarea verified")
    if data.new_start_date is None and data.new_end_date is None:
        raise TaskOpValidationError(
            "Indica newStartDate y/o newEndDate"
        )
    if not data.reason_id and not (data.reason and data.reason.strip()):
        raise TaskOpValidationError(
            "Indica reasonId (motivo catálogo) o reason (texto)"
        )
    if data.reason_id is not None:
        reason_row = (
            db.query(DelayReason)
            .filter(DelayReason.id == data.reason_id, DelayReason.is_active == 1)
            .first()
        )
        if not reason_row:
            raise TaskOpValidationError(
                f"Motivo {data.reason_id} inválido o inactivo"
            )

    uid = _new_uuid(data.uuid)
    _assert_uuid_free(db, TaskReschedule, uid, "Reprogramación")

    prev_start = row.planned_start_date
    prev_end = row.planned_end_date
    entry = TaskReschedule(
        uuid=uid,
        task_id=row.id,
        previous_start_date=prev_start,
        previous_end_date=prev_end,
        new_start_date=data.new_start_date,
        new_end_date=data.new_end_date,
        reason_id=data.reason_id,
        reason=data.reason,
        rescheduled_by=rescheduled_by,
    )
    db.add(entry)

    if data.new_start_date is not None:
        row.planned_start_date = data.new_start_date
    if data.new_end_date is not None:
        row.planned_end_date = data.new_end_date

    from_status = row.status
    if row.status != STATUS_RESCHEDULED:
        row.status = STATUS_RESCHEDULED
        _append_history(
            db,
            task_id=row.id,
            from_status=from_status,
            to_status=STATUS_RESCHEDULED,
            changed_by=rescheduled_by,
            reason=data.reason or f"reasonId={data.reason_id}",
        )

    db.commit()
    return await get_task(db, task_id), entry


# ---------- Dependencias ----------


async def add_dependency(
    db: Session, task_id: int, data: TaskDependencyAdd
) -> TaskDependency:
    task = await get_task(db, task_id)
    if data.depends_on_task_id == task_id:
        raise TaskOpValidationError("Una tarea no puede depender de sí misma")
    other = db.query(Task).filter(Task.id == data.depends_on_task_id).first()
    if not other:
        raise TaskOpValidationError(
            f"Tarea {data.depends_on_task_id} no existe"
        )
    if other.obra_id != task.obra_id:
        raise TaskOpValidationError(
            "Las dependencias deben ser de la misma obra"
        )
    if data.dependency_type not in DEPENDENCY_TYPES:
        raise TaskOpValidationError(
            f"dependencyType inválido. Valores: {', '.join(DEPENDENCY_TYPES)}"
        )
    exists = (
        db.query(TaskDependency)
        .filter(
            TaskDependency.task_id == task_id,
            TaskDependency.depends_on_task_id == data.depends_on_task_id,
        )
        .first()
    )
    if exists:
        raise TaskOpConflictError("Ya existe esa dependencia")

    row = TaskDependency(
        task_id=task_id,
        depends_on_task_id=data.depends_on_task_id,
        dependency_type=data.dependency_type,
        is_required=data.is_required,
        blocks_start=data.blocks_start,
    )
    db.add(row)
    db.commit()
    return (
        db.query(TaskDependency)
        .options(joinedload(TaskDependency.depends_on_task))
        .filter(TaskDependency.id == row.id)
        .first()
    )


async def delete_dependency(db: Session, item_id: int) -> None:
    row = db.query(TaskDependency).filter(TaskDependency.id == item_id).first()
    if not row:
        raise TaskOpNotFoundError(f"Dependencia {item_id} no encontrada")
    db.delete(row)
    db.commit()


async def list_dependencies(db: Session, task_id: int) -> List[Dict[str, Any]]:
    await get_task(db, task_id)
    rows = (
        db.query(TaskDependency)
        .options(joinedload(TaskDependency.depends_on_task))
        .filter(TaskDependency.task_id == task_id)
        .all()
    )
    return [dependency_to_dict(r) for r in rows]


async def add_dependency_override(
    db: Session,
    task_id: int,
    data: TaskDependencyOverrideAdd,
    *,
    created_by: int,
) -> TaskDependencyOverride:
    task = await get_task(db, task_id)
    if data.override_type not in OVERRIDE_TYPES:
        raise TaskOpValidationError(
            f"overrideType inválido. Valores: {', '.join(OVERRIDE_TYPES)}"
        )
    if not data.reason or not data.reason.strip():
        raise TaskOpValidationError("reason es obligatorio en overrides")

    tpl_dep = (
        db.query(TaskTemplateDependency)
        .filter(TaskTemplateDependency.id == data.template_dependency_id)
        .first()
    )
    if not tpl_dep:
        raise TaskOpValidationError(
            f"Dependencia de plantilla {data.template_dependency_id} no existe"
        )

    row = TaskDependencyOverride(
        task_id=task_id,
        template_dependency_id=data.template_dependency_id,
        override_type=data.override_type,
        reason=data.reason.strip(),
        created_by=created_by,
    )
    db.add(row)

    prereq_ids = [
        t.id
        for t in db.query(Task)
        .join(
            TaskTemplateVersion,
            Task.source_template_version_id == TaskTemplateVersion.id,
        )
        .filter(
            Task.obra_id == task.obra_id,
            TaskTemplateVersion.task_template_id == tpl_dep.depends_on_template_id,
        )
        .all()
    ]

    if prereq_ids:
        if data.override_type == "waive":
            db.query(TaskDependency).filter(
                TaskDependency.task_id == task_id,
                TaskDependency.depends_on_task_id.in_(prereq_ids),
            ).delete(synchronize_session=False)
        elif data.override_type == "relax":
            db.query(TaskDependency).filter(
                TaskDependency.task_id == task_id,
                TaskDependency.depends_on_task_id.in_(prereq_ids),
            ).update({"blocks_start": 0}, synchronize_session=False)

    db.commit()
    return (
        db.query(TaskDependencyOverride)
        .filter(TaskDependencyOverride.id == row.id)
        .first()
    )


async def list_overrides(db: Session, task_id: int) -> List[Dict[str, Any]]:
    await get_task(db, task_id)
    rows = (
        db.query(TaskDependencyOverride)
        .filter(TaskDependencyOverride.task_id == task_id)
        .all()
    )
    return [override_to_dict(r) for r in rows]


# ---------- Asignaciones ----------


async def assign_worker(
    db: Session,
    task_id: int,
    data: TaskAssignmentAdd,
    *,
    assigned_by: int,
) -> TaskAssignment:
    await get_task(db, task_id)
    worker = (
        db.query(Worker)
        .options(joinedload(Worker.person), joinedload(Worker.worker_position))
        .filter(Worker.id == data.worker_id)
        .first()
    )
    if not worker or worker.is_active != 1:
        raise TaskOpValidationError(
            f"Trabajador {data.worker_id} inválido o inactivo"
        )
    active = (
        db.query(TaskAssignment)
        .filter(
            TaskAssignment.task_id == task_id,
            TaskAssignment.worker_id == data.worker_id,
            TaskAssignment.removed_at.is_(None),
        )
        .first()
    )
    if active:
        raise TaskOpConflictError("El trabajador ya está asignado a esta tarea")

    row = TaskAssignment(
        task_id=task_id,
        worker_id=data.worker_id,
        start_date=data.start_date,
        end_date=data.end_date,
        assigned_by=assigned_by,
    )
    db.add(row)
    db.commit()
    return (
        db.query(TaskAssignment)
        .options(
            joinedload(TaskAssignment.worker).joinedload(Worker.person),
            joinedload(TaskAssignment.worker).joinedload(Worker.worker_position),
        )
        .filter(TaskAssignment.id == row.id)
        .first()
    )


async def remove_worker_assignment(
    db: Session, assignment_id: int, *, removed_by: int
) -> None:
    row = (
        db.query(TaskAssignment)
        .filter(TaskAssignment.id == assignment_id)
        .first()
    )
    if not row:
        raise TaskOpNotFoundError(f"Asignación {assignment_id} no encontrada")
    if row.removed_at:
        raise TaskOpValidationError("La asignación ya fue removida")
    row.removed_at = datetime.utcnow()
    row.removed_by = removed_by
    db.commit()


async def assign_crew(
    db: Session,
    task_id: int,
    data: TaskCrewAssignmentAdd,
    *,
    assigned_by: int,
) -> TaskCrewAssignment:
    await get_task(db, task_id)
    crew = db.query(Crew).filter(Crew.id == data.crew_id).first()
    if not crew or getattr(crew, "is_active", 1) != 1:
        raise TaskOpValidationError(
            f"Cuadrilla {data.crew_id} inválida o inactiva"
        )
    active = (
        db.query(TaskCrewAssignment)
        .filter(
            TaskCrewAssignment.task_id == task_id,
            TaskCrewAssignment.crew_id == data.crew_id,
            TaskCrewAssignment.removed_at.is_(None),
        )
        .first()
    )
    if active:
        raise TaskOpConflictError("La cuadrilla ya está asignada a esta tarea")

    row = TaskCrewAssignment(
        task_id=task_id,
        crew_id=data.crew_id,
        start_date=data.start_date,
        end_date=data.end_date,
        assigned_by=assigned_by,
    )
    db.add(row)
    db.commit()
    return (
        db.query(TaskCrewAssignment)
        .options(joinedload(TaskCrewAssignment.crew))
        .filter(TaskCrewAssignment.id == row.id)
        .first()
    )


async def remove_crew_assignment(
    db: Session, assignment_id: int, *, removed_by: int
) -> None:
    row = (
        db.query(TaskCrewAssignment)
        .filter(TaskCrewAssignment.id == assignment_id)
        .first()
    )
    if not row:
        raise TaskOpNotFoundError(f"Asignación {assignment_id} no encontrada")
    if row.removed_at:
        raise TaskOpValidationError("La asignación ya fue removida")
    row.removed_at = datetime.utcnow()
    row.removed_by = removed_by
    db.commit()


async def list_assignments(
    db: Session, task_id: int, *, current_only: bool = True
) -> Dict[str, Any]:
    await get_task(db, task_id)
    wq = (
        db.query(TaskAssignment)
        .options(
            joinedload(TaskAssignment.worker).joinedload(Worker.person),
            joinedload(TaskAssignment.worker).joinedload(Worker.worker_position),
        )
        .filter(TaskAssignment.task_id == task_id)
    )
    cq = (
        db.query(TaskCrewAssignment)
        .options(joinedload(TaskCrewAssignment.crew))
        .filter(TaskCrewAssignment.task_id == task_id)
    )
    if current_only:
        wq = wq.filter(TaskAssignment.removed_at.is_(None))
        cq = cq.filter(TaskCrewAssignment.removed_at.is_(None))
    return {
        "workers": [assignment_to_dict(r) for r in wq.all()],
        "crews": [crew_assignment_to_dict(r) for r in cq.all()],
    }


# ---------- Retrasos / historial ----------


async def add_delay_event(
    db: Session,
    task_id: int,
    data: TaskDelayEventAdd,
    *,
    created_by: int,
) -> TaskDelayEvent:
    await get_task(db, task_id)
    if data.delay_reason_id is not None:
        reason = (
            db.query(DelayReason)
            .filter(
                DelayReason.id == data.delay_reason_id,
                DelayReason.is_active == 1,
            )
            .first()
        )
        if not reason:
            raise TaskOpValidationError(
                f"Motivo {data.delay_reason_id} inválido o inactivo"
            )
    uid = _new_uuid(data.uuid)
    _assert_uuid_free(db, TaskDelayEvent, uid, "Retraso")
    row = TaskDelayEvent(
        uuid=uid,
        task_id=task_id,
        delay_reason_id=data.delay_reason_id,
        start_date=data.start_date,
        end_date=data.end_date,
        days_lost=data.days_lost,
        description=data.description,
        created_by=created_by,
    )
    db.add(row)
    db.commit()
    return (
        db.query(TaskDelayEvent)
        .options(joinedload(TaskDelayEvent.delay_reason))
        .filter(TaskDelayEvent.id == row.id)
        .first()
    )


async def list_delay_events(db: Session, task_id: int) -> List[Dict[str, Any]]:
    await get_task(db, task_id)
    rows = (
        db.query(TaskDelayEvent)
        .options(joinedload(TaskDelayEvent.delay_reason))
        .filter(TaskDelayEvent.task_id == task_id)
        .order_by(TaskDelayEvent.created_at.desc())
        .all()
    )
    return [delay_to_dict(r) for r in rows]


async def list_status_history(
    db: Session, task_id: int
) -> List[Dict[str, Any]]:
    await get_task(db, task_id)
    rows = (
        db.query(TaskStatusHistory)
        .filter(TaskStatusHistory.task_id == task_id)
        .order_by(TaskStatusHistory.changed_at.asc())
        .all()
    )
    return [history_to_dict(r) for r in rows]


async def list_reschedules(
    db: Session, task_id: int
) -> List[Dict[str, Any]]:
    await get_task(db, task_id)
    rows = (
        db.query(TaskReschedule)
        .options(joinedload(TaskReschedule.reason_ref))
        .filter(TaskReschedule.task_id == task_id)
        .order_by(TaskReschedule.rescheduled_at.desc())
        .all()
    )
    return [reschedule_to_dict(r) for r in rows]


# ---------- Comentarios / fotos ----------


async def add_comment(
    db: Session,
    task_id: int,
    data: TaskCommentAdd,
    *,
    user_id: int,
) -> TaskComment:
    await get_task(db, task_id)
    if data.type not in COMMENT_TYPES:
        raise TaskOpValidationError(
            f"type inválido. Valores: {', '.join(COMMENT_TYPES)}"
        )
    uid = _new_uuid(data.uuid)
    _assert_uuid_free(db, TaskComment, uid, "Comentario")
    row = TaskComment(
        uuid=uid,
        task_id=task_id,
        user_id=user_id,
        type=data.type,
        content=data.content,
    )
    db.add(row)
    db.commit()
    return (
        db.query(TaskComment)
        .options(joinedload(TaskComment.user).joinedload(User.person))
        .filter(TaskComment.id == row.id)
        .first()
    )


async def update_comment(
    db: Session, comment_id: int, data: TaskCommentUpdate
) -> TaskComment:
    row = db.query(TaskComment).filter(TaskComment.id == comment_id).first()
    if not row:
        raise TaskOpNotFoundError(f"Comentario {comment_id} no encontrado")
    payload = data.model_dump(exclude_unset=True)
    if "type" in payload and payload["type"] not in COMMENT_TYPES:
        raise TaskOpValidationError(
            f"type inválido. Valores: {', '.join(COMMENT_TYPES)}"
        )
    for k, v in payload.items():
        setattr(row, k, v)
    db.commit()
    return (
        db.query(TaskComment)
        .options(joinedload(TaskComment.user).joinedload(User.person))
        .filter(TaskComment.id == comment_id)
        .first()
    )


async def list_comments(db: Session, task_id: int) -> List[Dict[str, Any]]:
    await get_task(db, task_id)
    rows = (
        db.query(TaskComment)
        .options(joinedload(TaskComment.user).joinedload(User.person))
        .filter(TaskComment.task_id == task_id)
        .order_by(TaskComment.created_at.asc())
        .all()
    )
    return [comment_to_dict(r) for r in rows]


async def add_photo_meta(
    db: Session,
    task_id: int,
    *,
    file_url_or_key: str,
    description: Optional[str],
    taken_at: Optional[datetime],
    uploaded_by: int,
    uuid: Optional[str] = None,
) -> TaskPhoto:
    await get_task(db, task_id)
    uid = _new_uuid(uuid)
    _assert_uuid_free(db, TaskPhoto, uid, "Foto")
    row = TaskPhoto(
        uuid=uid,
        task_id=task_id,
        file_url=file_url_or_key,
        description=description,
        taken_at=taken_at,
        uploaded_by=uploaded_by,
    )
    db.add(row)
    db.commit()
    return db.query(TaskPhoto).filter(TaskPhoto.id == row.id).first()


async def upload_task_photo(
    db: Session,
    task_id: int,
    *,
    raw_bytes: bytes,
    content_type: Optional[str],
    description: Optional[str],
    taken_at: Optional[datetime],
    uploaded_by: int,
    uuid: Optional[str] = None,
) -> TaskPhoto:
    from app.core.images import ImageProcessingError, compress_image_for_upload
    from app.services.s3_service import (
        S3ConfigError,
        S3UploadError,
        build_object_key,
        delete_object,
        upload_bytes,
    )

    task = await get_task(db, task_id)
    try:
        compressed, mime, ext = compress_image_for_upload(
            raw_bytes, content_type=content_type
        )
    except ImageProcessingError as e:
        raise TaskOpValidationError(str(e)) from e

    key = build_object_key(
        "obras",
        str(task.obra_id),
        "tareas",
        str(task_id),
        "fotos",
        f"{uuid_lib.uuid4().hex}.{ext}",
    )
    try:
        upload_bytes(key=key, data=compressed, content_type=mime)
    except (S3ConfigError, S3UploadError) as e:
        raise TaskOpValidationError(str(e)) from e

    try:
        return await add_photo_meta(
            db,
            task_id,
            file_url_or_key=key,
            description=description,
            taken_at=taken_at,
            uploaded_by=uploaded_by,
            uuid=uuid,
        )
    except Exception:
        delete_object(key)
        raise


async def list_photos(db: Session, task_id: int) -> List[Dict[str, Any]]:
    await get_task(db, task_id)
    rows = (
        db.query(TaskPhoto)
        .options(joinedload(TaskPhoto.uploaded_by_user).joinedload(User.person))
        .filter(TaskPhoto.task_id == task_id)
        .order_by(TaskPhoto.created_at.desc())
        .all()
    )
    return [photo_to_dict(r) for r in rows]


async def delete_photo(db: Session, photo_id: int) -> None:
    from app.services.s3_service import delete_object

    row = db.query(TaskPhoto).filter(TaskPhoto.id == photo_id).first()
    if not row:
        raise TaskOpNotFoundError(f"Foto {photo_id} no encontrada")
    key = row.file_url if row.file_url and not row.file_url.startswith("http") else None
    db.delete(row)
    db.commit()
    if key:
        delete_object(key)


async def upload_task_document(
    db: Session,
    task_id: int,
    *,
    raw_bytes: bytes,
    filename: str,
    content_type: Optional[str],
    description: Optional[str],
    uploaded_by: int,
    uuid: Optional[str] = None,
) -> TaskDocument:
    from app.services.s3_service import (
        S3ConfigError,
        S3UploadError,
        build_object_key,
        delete_object,
        upload_bytes,
    )

    task = await get_task(db, task_id)
    if not raw_bytes:
        raise TaskOpValidationError("Archivo vacío")
    if len(raw_bytes) > 25 * 1024 * 1024:
        raise TaskOpValidationError("Documento máximo 25 MB")

    safe_name = (filename or "documento").strip() or "documento"
    ext = safe_name.rsplit(".", 1)[-1].lower() if "." in safe_name else "bin"
    if len(ext) > 10:
        ext = "bin"
    key = build_object_key(
        "obras",
        str(task.obra_id),
        "tareas",
        str(task_id),
        "docs",
        f"{uuid_lib.uuid4().hex}.{ext}",
    )
    mime = content_type or "application/octet-stream"
    try:
        upload_bytes(key=key, data=raw_bytes, content_type=mime)
    except (S3ConfigError, S3UploadError) as e:
        raise TaskOpValidationError(str(e)) from e

    uid = _new_uuid(uuid)
    _assert_uuid_free(db, TaskDocument, uid, "Documento")
    row = TaskDocument(
        uuid=uid,
        task_id=task_id,
        name=safe_name[:255],
        description=description,
        file_url=key,
        content_type=mime,
        file_size_bytes=len(raw_bytes),
        uploaded_by=uploaded_by,
    )
    try:
        db.add(row)
        db.commit()
    except Exception:
        db.rollback()
        delete_object(key)
        raise
    return (
        db.query(TaskDocument)
        .options(joinedload(TaskDocument.uploaded_by_user).joinedload(User.person))
        .filter(TaskDocument.id == row.id)
        .first()
    )


async def list_documents(db: Session, task_id: int) -> List[Dict[str, Any]]:
    await get_task(db, task_id)
    rows = (
        db.query(TaskDocument)
        .options(joinedload(TaskDocument.uploaded_by_user).joinedload(User.person))
        .filter(TaskDocument.task_id == task_id)
        .order_by(TaskDocument.created_at.desc())
        .all()
    )
    return [document_to_dict(r) for r in rows]


async def delete_document(db: Session, document_id: int) -> None:
    from app.services.s3_service import delete_object

    row = db.query(TaskDocument).filter(TaskDocument.id == document_id).first()
    if not row:
        raise TaskOpNotFoundError(f"Documento {document_id} no encontrado")
    key = row.file_url if row.file_url and not row.file_url.startswith("http") else None
    db.delete(row)
    db.commit()
    if key:
        delete_object(key)


async def toggle_subtask(
    db: Session,
    parent_task_id: int,
    subtask_id: int,
    *,
    completed: bool,
    changed_by: int,
) -> Task:
    parent = await get_task(db, parent_task_id)
    child = db.query(Task).filter(Task.id == subtask_id).first()
    if not child or child.parent_task_id != parent.id:
        raise TaskOpNotFoundError(
            f"Subtarea {subtask_id} no pertenece a la tarea {parent_task_id}"
        )
    target = STATUS_COMPLETED if completed else STATUS_SCHEDULED
    if child.status == target:
        return await get_task(db, subtask_id)
    from_status = child.status
    child.status = target
    if completed and not child.actual_end_date:
        child.actual_end_date = date.today()
    if not completed:
        child.actual_end_date = None
    child.updated_by = changed_by
    child.updated_at = datetime.utcnow()
    _append_history(
        db,
        task_id=child.id,
        from_status=from_status,
        to_status=target,
        changed_by=changed_by,
        reason="Checkbox subtarea (drawer)",
    )
    db.commit()
    return await get_task(db, subtask_id)


async def mark_delayed(
    db: Session,
    task_id: int,
    *,
    delayed: bool,
    delay_reason_id: Optional[int],
    description: Optional[str],
    days_lost: Optional[Decimal],
    created_by: int,
) -> Dict[str, Any]:
    """Toggle Figma «Marcar como retrasada»."""
    task = await get_task(db, task_id)
    if delayed:
        if description is not None and len(description) > 250:
            raise TaskOpValidationError("Motivo máximo 250 caracteres")
        open_delay = (
            db.query(TaskDelayEvent)
            .filter(
                TaskDelayEvent.task_id == task_id,
                TaskDelayEvent.end_date.is_(None),
            )
            .first()
        )
        if open_delay:
            if description:
                open_delay.description = description
            if delay_reason_id is not None:
                open_delay.delay_reason_id = delay_reason_id
            if days_lost is not None:
                open_delay.days_lost = days_lost
            db.commit()
        else:
            await add_delay_event(
                db,
                task_id,
                TaskDelayEventAdd(
                    delay_reason_id=delay_reason_id,
                    start_date=date.today(),
                    end_date=None,
                    days_lost=days_lost,
                    description=description,
                ),
                created_by=created_by,
            )
    else:
        opens = (
            db.query(TaskDelayEvent)
            .filter(
                TaskDelayEvent.task_id == task_id,
                TaskDelayEvent.end_date.is_(None),
            )
            .all()
        )
        for d in opens:
            d.end_date = date.today()
        db.commit()

    loaded = await get_task(db, task_id)
    return {
        "task": task_to_dict(loaded),
        "delays": await list_delay_events(db, task_id),
    }


async def list_activity(
    db: Session, task_id: int, *, limit: int = 50
) -> List[Dict[str, Any]]:
    """Trazabilidad unificada: creación, status, notas, fotos, docs, delays, reschedules."""
    task = await get_task(db, task_id)
    items: List[Dict[str, Any]] = []

    items.append(
        {
            "event_type": "created",
            "at": task.created_at or datetime.utcnow(),
            "user_id": task.created_by,
            "user_name": _user_display(task.created_by_user),
            "summary": "Tarea creada",
            "detail": task.name,
            "ref_id": task.id,
        }
    )
    if task.updated_at and task.updated_by:
        items.append(
            {
                "event_type": "updated",
                "at": task.updated_at,
                "user_id": task.updated_by,
                "user_name": _user_display(task.updated_by_user),
                "summary": "Tarea modificada",
                "detail": None,
                "ref_id": task.id,
            }
        )

    for h in await list_status_history(db, task_id):
        user = db.query(User).options(joinedload(User.person)).filter(
            User.id == h["changed_by"]
        ).first()
        items.append(
            {
                "event_type": "status_change",
                "at": h["changed_at"] or datetime.utcnow(),
                "user_id": h["changed_by"],
                "user_name": _user_display(user),
                "summary": f"Status {h.get('from_status') or '—'} → {h['to_status']}",
                "detail": h.get("reason"),
                "ref_id": h["id"],
            }
        )

    for c in await list_comments(db, task_id):
        items.append(
            {
                "event_type": "note" if c["type"] == "comment" else "instruction",
                "at": c["created_at"] or datetime.utcnow(),
                "user_id": c["user_id"],
                "user_name": c.get("user_name"),
                "summary": "Nota" if c["type"] == "comment" else "Instrucción",
                "detail": c["content"],
                "ref_id": c["id"],
            }
        )

    for p in await list_photos(db, task_id):
        items.append(
            {
                "event_type": "photo",
                "at": p["created_at"] or datetime.utcnow(),
                "user_id": p["uploaded_by"],
                "user_name": p.get("uploaded_by_name"),
                "summary": "Foto de evidencia",
                "detail": p.get("description"),
                "ref_id": p["id"],
            }
        )

    for d in await list_documents(db, task_id):
        items.append(
            {
                "event_type": "document",
                "at": d["created_at"] or datetime.utcnow(),
                "user_id": d["uploaded_by"],
                "user_name": d.get("uploaded_by_name"),
                "summary": f"Documento: {d['name']}",
                "detail": d.get("description"),
                "ref_id": d["id"],
            }
        )

    for delay in await list_delay_events(db, task_id):
        user = db.query(User).options(joinedload(User.person)).filter(
            User.id == delay["created_by"]
        ).first()
        items.append(
            {
                "event_type": "delay",
                "at": delay["created_at"] or datetime.utcnow(),
                "user_id": delay["created_by"],
                "user_name": _user_display(user),
                "summary": "Retraso marcado",
                "detail": delay.get("description")
                or delay.get("delay_reason_name"),
                "ref_id": delay["id"],
            }
        )

    for r in await list_reschedules(db, task_id):
        user = db.query(User).options(joinedload(User.person)).filter(
            User.id == r["rescheduled_by"]
        ).first()
        items.append(
            {
                "event_type": "reschedule",
                "at": r["rescheduled_at"] or datetime.utcnow(),
                "user_id": r["rescheduled_by"],
                "user_name": _user_display(user),
                "summary": "Reprogramación",
                "detail": r.get("reason") or r.get("reason_name"),
                "ref_id": r["id"],
            }
        )

    items.sort(key=lambda x: x["at"] or datetime.min, reverse=True)
    return items[:limit]


async def get_task_detail(db: Session, task_id: int) -> Dict[str, Any]:
    task = await get_task(db, task_id)
    children = (
        db.query(Task)
        .options(*_task_load_options())
        .filter(Task.parent_task_id == task_id)
        .order_by(Task.id.asc())
        .all()
    )
    return {
        "task": task_to_dict(task),
        "subtasks": [task_to_dict(c) for c in children],
        "dependencies": await list_dependencies(db, task_id),
        "overrides": await list_overrides(db, task_id),
        "assignments": await list_assignments(db, task_id, current_only=True),
        "statusHistory": await list_status_history(db, task_id),
        "reschedules": await list_reschedules(db, task_id),
        "delays": await list_delay_events(db, task_id),
        "comments": await list_comments(db, task_id),
        "photos": await list_photos(db, task_id),
        "documents": await list_documents(db, task_id),
        "activity": await list_activity(db, task_id, limit=30),
    }
