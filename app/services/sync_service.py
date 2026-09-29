"""
Sync offline — push/pull (Fase 8).
Ola 1: comentarios, delays, fotos (meta), status, reprogramaciones.
Conflictos: last-write-wins por clientUpdatedAt vs updated_at/created_at del server.
"""
from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from typing import Any, Dict, List, Optional

from sqlalchemy.orm import Session, joinedload

from app.models import (
    Task,
    TaskComment,
    TaskDelayEvent,
    TaskPhoto,
    TaskReschedule,
    TaskStatusHistory,
    User,
)
from app.schemas import (
    TaskCommentAdd,
    TaskCommentUpdate,
    TaskDelayEventAdd,
    TaskRescheduleAdd,
    TaskStatusChange,
    SyncOperation,
    SyncPushRequest,
)
from app.schemas.sync.sync_schema import SYNC_ENTITIES, SYNC_OPS
from app.services import task_service as tasks

STATUS_APPLIED = "applied"
STATUS_IDEMPOTENT = "idempotent"
STATUS_CONFLICT = "conflict"
STATUS_NEEDS_UPLOAD = "needs_upload"
STATUS_ERROR = "error"


class SyncError(Exception):
    pass


class SyncValidationError(SyncError):
    pass


def _parse_date(value: Any) -> Optional[date]:
    if value is None or value == "":
        return None
    if isinstance(value, date) and not isinstance(value, datetime):
        return value
    if isinstance(value, datetime):
        return value.date()
    s = str(value)[:10]
    return date.fromisoformat(s)


def _parse_decimal(value: Any) -> Optional[Decimal]:
    if value is None or value == "":
        return None
    return Decimal(str(value))


def _as_camel_payload(payload: Dict[str, Any]) -> Dict[str, Any]:
    """Acepta camelCase o snake_case en payload."""
    out = dict(payload or {})
    # aliases comunes
    aliases = {
        "taskUuid": "task_uuid",
        "taskId": "task_id",
        "toStatus": "to_status",
        "delayReasonId": "delay_reason_id",
        "startDate": "start_date",
        "endDate": "end_date",
        "daysLost": "days_lost",
        "newStartDate": "new_start_date",
        "newEndDate": "new_end_date",
        "reasonId": "reason_id",
        "fileUrl": "file_url",
        "takenAt": "taken_at",
        "parentTaskId": "parent_task_id",
    }
    for camel, snake in aliases.items():
        if camel in out and snake not in out:
            out[snake] = out[camel]
    return out


def _resolve_task(
    db: Session, payload: Dict[str, Any]
) -> Task:
    task_uuid = payload.get("task_uuid")
    task_id = payload.get("task_id")
    if task_uuid:
        row = db.query(Task).filter(Task.uuid == str(task_uuid)).first()
        if row:
            return row
    if task_id is not None:
        row = db.query(Task).filter(Task.id == int(task_id)).first()
        if row:
            return row
    raise SyncValidationError("payload requiere taskUuid o taskId válido")


def _server_ts(row: Any) -> Optional[datetime]:
    for attr in ("updated_at", "created_at", "rescheduled_at", "changed_at"):
        val = getattr(row, attr, None)
        if val is not None:
            return val
    return None


def _is_conflict(
    server_ts: Optional[datetime], client_ts: Optional[datetime]
) -> bool:
    """Conflicto si el server es más nuevo que el cliente."""
    if server_ts is None or client_ts is None:
        return False
    # naive compare
    s = server_ts.replace(tzinfo=None) if getattr(server_ts, "tzinfo", None) else server_ts
    c = client_ts.replace(tzinfo=None) if getattr(client_ts, "tzinfo", None) else client_ts
    return s > c


def _result(
    op: SyncOperation,
    *,
    status: str,
    server_id: Optional[int] = None,
    message: Optional[str] = None,
    server_record: Optional[Dict[str, Any]] = None,
    upload_hint: Optional[str] = None,
) -> Dict[str, Any]:
    return {
        "op_id": op.op_id,
        "entity": op.entity,
        "uuid": op.uuid,
        "status": status,
        "server_id": server_id,
        "message": message,
        "server_record": server_record,
        "upload_hint": upload_hint,
    }


async def _push_comment(
    db: Session, op: SyncOperation, *, user_id: int
) -> Dict[str, Any]:
    payload = _as_camel_payload(op.payload)
    existing = db.query(TaskComment).filter(TaskComment.uuid == op.uuid).first()

    if op.op == "create":
        if existing:
            return _result(
                op,
                status=STATUS_IDEMPOTENT,
                server_id=existing.id,
                server_record=tasks.comment_to_dict(existing),
                message="Comentario ya existía (uuid)",
            )
        task = _resolve_task(db, payload)
        content = payload.get("content")
        if not content:
            raise SyncValidationError("comment.content requerido")
        row = await tasks.add_comment(
            db,
            task.id,
            TaskCommentAdd(
                uuid=op.uuid,
                type=payload.get("type") or "comment",
                content=str(content),
            ),
            user_id=user_id,
        )
        return _result(
            op,
            status=STATUS_APPLIED,
            server_id=row.id,
            server_record=tasks.comment_to_dict(row),
        )

    if op.op == "update":
        if not existing:
            raise SyncValidationError(f"Comentario uuid={op.uuid} no existe")
        if _is_conflict(_server_ts(existing), op.client_updated_at):
            return _result(
                op,
                status=STATUS_CONFLICT,
                server_id=existing.id,
                message="Server más reciente (updatedAt)",
                server_record=tasks.comment_to_dict(existing),
            )
        patch: Dict[str, Any] = {}
        if "content" in payload:
            patch["content"] = payload["content"]
        if "type" in payload:
            patch["type"] = payload["type"]
        if not patch:
            raise SyncValidationError("update de comment sin campos")
        row = await tasks.update_comment(
            db, existing.id, TaskCommentUpdate(**patch)
        )
        return _result(
            op,
            status=STATUS_APPLIED,
            server_id=row.id,
            server_record=tasks.comment_to_dict(row),
        )

    raise SyncValidationError(f"op inválida para comment: {op.op}")


async def _push_delay(
    db: Session, op: SyncOperation, *, user_id: int
) -> Dict[str, Any]:
    payload = _as_camel_payload(op.payload)
    existing = (
        db.query(TaskDelayEvent).filter(TaskDelayEvent.uuid == op.uuid).first()
    )
    if existing:
        return _result(
            op,
            status=STATUS_IDEMPOTENT,
            server_id=existing.id,
            server_record=tasks.delay_to_dict(existing),
            message="Retraso ya existía (uuid)",
        )
    if op.op != "create":
        raise SyncValidationError("task_delay solo soporta create en ola 1")
    task = _resolve_task(db, payload)
    row = await tasks.add_delay_event(
        db,
        task.id,
        TaskDelayEventAdd(
            uuid=op.uuid,
            delay_reason_id=payload.get("delay_reason_id"),
            start_date=_parse_date(payload.get("start_date")),
            end_date=_parse_date(payload.get("end_date")),
            days_lost=_parse_decimal(payload.get("days_lost")),
            description=payload.get("description"),
        ),
        created_by=user_id,
    )
    return _result(
        op,
        status=STATUS_APPLIED,
        server_id=row.id,
        server_record=tasks.delay_to_dict(row),
    )


async def _push_photo(
    db: Session, op: SyncOperation, *, user_id: int
) -> Dict[str, Any]:
    """
    create con fileUrl (key ya subida) → aplica.
    create sin archivo → needs_upload (usar POST /sync/fotos).
    """
    payload = _as_camel_payload(op.payload)
    existing = db.query(TaskPhoto).filter(TaskPhoto.uuid == op.uuid).first()
    if existing:
        return _result(
            op,
            status=STATUS_IDEMPOTENT,
            server_id=existing.id,
            server_record=tasks.photo_to_dict(existing),
            message="Foto ya existía (uuid)",
        )
    if op.op != "create":
        raise SyncValidationError("task_photo solo soporta create")

    task = _resolve_task(db, payload)
    file_url = payload.get("file_url")
    if not file_url:
        return _result(
            op,
            status=STATUS_NEEDS_UPLOAD,
            message="Sube el archivo con POST /api/v1/sync/fotos",
            upload_hint="/api/v1/sync/fotos",
        )

    row = await tasks.add_photo_meta(
        db,
        task.id,
        file_url_or_key=str(file_url),
        description=payload.get("description"),
        taken_at=None,
        uploaded_by=user_id,
        uuid=op.uuid,
    )
    return _result(
        op,
        status=STATUS_APPLIED,
        server_id=row.id,
        server_record=tasks.photo_to_dict(row),
    )


async def _push_status(
    db: Session, op: SyncOperation, *, user_id: int
) -> Dict[str, Any]:
    payload = _as_camel_payload(op.payload)
    # uuid de la operación = uuid de la tarea
    task = db.query(Task).filter(Task.uuid == op.uuid).first()
    if not task:
        # fallback taskUuid en payload
        task = _resolve_task(db, {**payload, "task_uuid": payload.get("task_uuid") or op.uuid})

    if op.op not in ("create", "update"):
        raise SyncValidationError("task_status usa op=update")

    if _is_conflict(task.updated_at or task.created_at, op.client_updated_at):
        return _result(
            op,
            status=STATUS_CONFLICT,
            server_id=task.id,
            message="Tarea modificada en servidor después del cliente",
            server_record=tasks.task_to_dict(await tasks.get_task(db, task.id)),
        )

    to_status = payload.get("to_status") or payload.get("status")
    if not to_status:
        raise SyncValidationError("toStatus requerido")

    result = await tasks.change_task_status(
        db,
        task.id,
        TaskStatusChange(
            to_status=str(to_status),
            reason=payload.get("reason"),
            force=bool(payload.get("force") or False),
        ),
        changed_by=user_id,
    )
    return _result(
        op,
        status=STATUS_APPLIED,
        server_id=task.id,
        server_record=result["task"],
    )


async def _push_reschedule(
    db: Session, op: SyncOperation, *, user_id: int
) -> Dict[str, Any]:
    payload = _as_camel_payload(op.payload)
    existing = (
        db.query(TaskReschedule).filter(TaskReschedule.uuid == op.uuid).first()
    )
    if existing:
        return _result(
            op,
            status=STATUS_IDEMPOTENT,
            server_id=existing.id,
            server_record=tasks.reschedule_to_dict(existing),
            message="Reprogramación ya existía (uuid)",
        )
    if op.op != "create":
        raise SyncValidationError("task_reschedule solo soporta create")

    task = _resolve_task(db, payload)
    task_row, entry = await tasks.reschedule_task(
        db,
        task.id,
        TaskRescheduleAdd(
            uuid=op.uuid,
            new_start_date=_parse_date(payload.get("new_start_date")),
            new_end_date=_parse_date(payload.get("new_end_date")),
            reason_id=payload.get("reason_id"),
            reason=payload.get("reason"),
        ),
        rescheduled_by=user_id,
    )
    entry = (
        db.query(TaskReschedule)
        .options(joinedload(TaskReschedule.reason_ref))
        .filter(TaskReschedule.id == entry.id)
        .first()
    )
    return _result(
        op,
        status=STATUS_APPLIED,
        server_id=entry.id,
        server_record={
            "task": tasks.task_to_dict(task_row),
            "reschedule": tasks.reschedule_to_dict(entry),
        },
    )


async def apply_operation(
    db: Session, op: SyncOperation, *, user_id: int
) -> Dict[str, Any]:
    if op.entity not in SYNC_ENTITIES:
        return _result(
            op,
            status=STATUS_ERROR,
            message=f"entity no soportada en ola 1: {op.entity}",
        )
    if op.op not in SYNC_OPS:
        return _result(
            op,
            status=STATUS_ERROR,
            message=f"op inválida: {op.op}",
        )
    try:
        if op.entity == "task_comment":
            return await _push_comment(db, op, user_id=user_id)
        if op.entity == "task_delay":
            return await _push_delay(db, op, user_id=user_id)
        if op.entity == "task_photo":
            return await _push_photo(db, op, user_id=user_id)
        if op.entity == "task_status":
            return await _push_status(db, op, user_id=user_id)
        if op.entity == "task_reschedule":
            return await _push_reschedule(db, op, user_id=user_id)
        return _result(op, status=STATUS_ERROR, message="entity no implementada")
    except tasks.TaskOpBlockedError as e:
        return _result(
            op,
            status=STATUS_ERROR,
            message=str(e),
            server_record={"blockingDependencies": e.blocking},
        )
    except (SyncValidationError, tasks.TaskOpError) as e:
        return _result(op, status=STATUS_ERROR, message=str(e))
    except Exception as e:
        return _result(op, status=STATUS_ERROR, message=f"Error interno: {e}")


async def push_batch(
    db: Session, data: SyncPushRequest, *, user_id: int
) -> Dict[str, Any]:
    results: List[Dict[str, Any]] = []
    for op in data.operations:
        results.append(await apply_operation(db, op, user_id=user_id))

    applied = sum(1 for r in results if r["status"] in (STATUS_APPLIED, STATUS_IDEMPOTENT))
    conflicts = sum(1 for r in results if r["status"] == STATUS_CONFLICT)
    errors = sum(1 for r in results if r["status"] == STATUS_ERROR)
    needs_upload = sum(1 for r in results if r["status"] == STATUS_NEEDS_UPLOAD)

    return {
        "results": results,
        "applied": applied,
        "conflicts": conflicts,
        "errors": errors,
        "needs_upload": needs_upload,
        "server_time": datetime.utcnow(),
    }


async def pull_changes(
    db: Session,
    *,
    since: datetime,
    obra_id: Optional[int] = None,
    limit_per_entity: int = 200,
) -> Dict[str, Any]:
    since_naive = since.replace(tzinfo=None) if since.tzinfo else since

    task_q = db.query(Task).options(*tasks._task_load_options())
    if obra_id is not None:
        task_q = task_q.filter(Task.obra_id == obra_id)
    # updated_at o created_at >= since
    from sqlalchemy import or_

    task_q = task_q.filter(
        or_(
            Task.updated_at >= since_naive,
            Task.created_at >= since_naive,
        )
    )
    task_rows = task_q.order_by(Task.id.asc()).limit(limit_per_entity).all()

    # Scope comments/delays/photos/reschedules a obras si se filtró
    task_ids_in_obra: Optional[List[int]] = None
    if obra_id is not None:
        task_ids_in_obra = [
            t.id
            for t in db.query(Task.id).filter(Task.obra_id == obra_id).all()
        ]

    def _scope(q, model_task_id_col):
        if task_ids_in_obra is not None:
            if not task_ids_in_obra:
                return q.filter(False)
            return q.filter(model_task_id_col.in_(task_ids_in_obra))
        return q

    comments = (
        _scope(
            db.query(TaskComment).options(
                joinedload(TaskComment.user).joinedload(User.person)
            ),
            TaskComment.task_id,
        )
        .filter(
            or_(
                TaskComment.updated_at >= since_naive,
                TaskComment.created_at >= since_naive,
            )
        )
        .order_by(TaskComment.id.asc())
        .limit(limit_per_entity)
        .all()
    )

    delays = (
        _scope(
            db.query(TaskDelayEvent).options(
                joinedload(TaskDelayEvent.delay_reason)
            ),
            TaskDelayEvent.task_id,
        )
        .filter(TaskDelayEvent.created_at >= since_naive)
        .order_by(TaskDelayEvent.id.asc())
        .limit(limit_per_entity)
        .all()
    )

    photos = (
        _scope(db.query(TaskPhoto), TaskPhoto.task_id)
        .filter(TaskPhoto.created_at >= since_naive)
        .order_by(TaskPhoto.id.asc())
        .limit(limit_per_entity)
        .all()
    )

    reschedules = (
        _scope(
            db.query(TaskReschedule).options(
                joinedload(TaskReschedule.reason_ref)
            ),
            TaskReschedule.task_id,
        )
        .filter(TaskReschedule.rescheduled_at >= since_naive)
        .order_by(TaskReschedule.id.asc())
        .limit(limit_per_entity)
        .all()
    )

    history_q = db.query(TaskStatusHistory).filter(
        TaskStatusHistory.changed_at >= since_naive
    )
    if task_ids_in_obra is not None:
        if task_ids_in_obra:
            history_q = history_q.filter(
                TaskStatusHistory.task_id.in_(task_ids_in_obra)
            )
        else:
            history_q = history_q.filter(False)
    history = (
        history_q.order_by(TaskStatusHistory.id.asc())
        .limit(limit_per_entity)
        .all()
    )

    return {
        "since": since_naive,
        "server_time": datetime.utcnow(),
        "tasks": [tasks.task_to_dict(t) for t in task_rows],
        "comments": [tasks.comment_to_dict(c) for c in comments],
        "delays": [tasks.delay_to_dict(d) for d in delays],
        "photos": [tasks.photo_to_dict(p) for p in photos],
        "reschedules": [tasks.reschedule_to_dict(r) for r in reschedules],
        "status_history": [tasks.history_to_dict(h) for h in history],
    }


async def sync_upload_photo(
    db: Session,
    *,
    task_uuid: str,
    photo_uuid: str,
    raw_bytes: bytes,
    content_type: Optional[str],
    description: Optional[str],
    uploaded_by: int,
) -> Dict[str, Any]:
    """Cola de fotos offline: sube archivo respetando uuid del cliente."""
    task = db.query(Task).filter(Task.uuid == task_uuid).first()
    if not task:
        raise SyncValidationError(f"Tarea uuid={task_uuid} no encontrada")

    existing = db.query(TaskPhoto).filter(TaskPhoto.uuid == photo_uuid).first()
    if existing:
        return {
            "status": STATUS_IDEMPOTENT,
            "photo": tasks.photo_to_dict(existing),
        }

    row = await tasks.upload_task_photo(
        db,
        task.id,
        raw_bytes=raw_bytes,
        content_type=content_type,
        description=description,
        taken_at=None,
        uploaded_by=uploaded_by,
        uuid=photo_uuid,
    )
    return {
        "status": STATUS_APPLIED,
        "photo": tasks.photo_to_dict(row),
    }
