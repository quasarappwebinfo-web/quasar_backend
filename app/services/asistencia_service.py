"""Asistencia diaria en obra + gente del día en tarea."""
from __future__ import annotations

from datetime import date
from typing import Any, Dict, List, Optional

from sqlalchemy.orm import Session, joinedload

from app.core.db_timezone import get_colombia_now
from app.core.signature_data import SignatureDataError, assert_no_secrets, is_image_data_url
from app.models.obras.obra_model import Obra
from app.models.operacion.task_daily_assignment_model import TaskDailyAssignment
from app.models.operacion.task_model import Task
from app.models.rrhh.obra_daily_attendance_model import ObraDailyAttendance
from app.models.rrhh.worker_assignment_model import WorkerAssignment
from app.models.rrhh.worker_model import Worker
from app.models.identidad.user_model import User
from app.schemas.rrhh.asistencia_schema import (
    ObraDailyAttendanceCreate,
    TaskDailyAssignmentCreate,
)

SIGNATURE_TYPES = ("electronic", "acknowledgment")


class AsistenciaError(Exception):
    pass


class AsistenciaNotFoundError(AsistenciaError):
    pass


class AsistenciaConflictError(AsistenciaError):
    pass


class AsistenciaValidationError(AsistenciaError):
    pass


def _pagination(total: int, page: int, limit: int = 50) -> Dict[str, Any]:
    return {
        "totalItems": total,
        "itemsPerPage": limit,
        "currentPage": page,
    }


def _person_name(worker: Optional[Worker]) -> Optional[str]:
    if worker and worker.person:
        return worker.person.name
    return None


def _user_name(user: Optional[User]) -> Optional[str]:
    if not user:
        return None
    if user.person and user.person.name:
        return user.person.name
    return user.username


def _worker_options():
    return [
        joinedload(Worker.person),
        joinedload(Worker.worker_position),
    ]


def attendance_to_dict(row: ObraDailyAttendance) -> Dict[str, Any]:
    w = row.worker
    return {
        "id": row.id,
        "obra_id": row.obra_id,
        "obra_name": row.obra.name if row.obra else None,
        "work_date": row.work_date,
        "worker_id": row.worker_id,
        "worker_name": _person_name(w),
        "document_number": w.person.document_number if w and w.person else None,
        "position_name": (
            w.worker_position.name if w and w.worker_position else None
        ),
        "signed_at": row.signed_at,
        "signature_type": row.signature_type,
        "signature_data": row.signature_data,
        "recorded_by": row.recorded_by,
        "recorded_by_name": _user_name(row.recorded_by_user),
        "created_at": row.created_at,
        "removed_at": row.removed_at,
    }


def daily_assignment_to_dict(row: TaskDailyAssignment) -> Dict[str, Any]:
    w = row.worker
    return {
        "id": row.id,
        "task_id": row.task_id,
        "task_name": row.task.name if row.task else None,
        "work_date": row.work_date,
        "worker_id": row.worker_id,
        "worker_name": _person_name(w),
        "document_number": w.person.document_number if w and w.person else None,
        "position_name": (
            w.worker_position.name if w and w.worker_position else None
        ),
        "assigned_at": row.assigned_at,
        "assigned_by": row.assigned_by,
        "assigned_by_name": _user_name(row.assigned_by_user),
        "removed_at": row.removed_at,
    }


def _worker_on_obra(db: Session, worker_id: int, obra_id: int, on_date: date) -> bool:
    """Hay vínculo worker↔obra vigente que cubre on_date."""
    row = (
        db.query(WorkerAssignment)
        .filter(
            WorkerAssignment.worker_id == worker_id,
            WorkerAssignment.obra_id == obra_id,
            WorkerAssignment.start_date <= on_date,
        )
        .filter(
            (WorkerAssignment.end_date.is_(None))
            | (WorkerAssignment.end_date >= on_date)
        )
        .first()
    )
    return row is not None


def _has_attendance(
    db: Session, *, obra_id: int, worker_id: int, work_date: date
) -> bool:
    row = (
        db.query(ObraDailyAttendance)
        .filter(
            ObraDailyAttendance.obra_id == obra_id,
            ObraDailyAttendance.worker_id == worker_id,
            ObraDailyAttendance.work_date == work_date,
            ObraDailyAttendance.removed_at.is_(None),
        )
        .first()
    )
    return row is not None


async def list_attendance(
    db: Session,
    *,
    obra_id: int,
    work_date: date,
    current_only: bool = True,
    page: int = 1,
) -> Dict[str, Any]:
    limit = 100
    q = (
        db.query(ObraDailyAttendance)
        .options(
            joinedload(ObraDailyAttendance.obra),
            joinedload(ObraDailyAttendance.worker).joinedload(Worker.person),
            joinedload(ObraDailyAttendance.worker).joinedload(Worker.worker_position),
            joinedload(ObraDailyAttendance.recorded_by_user).joinedload(User.person),
        )
        .filter(
            ObraDailyAttendance.obra_id == obra_id,
            ObraDailyAttendance.work_date == work_date,
        )
    )
    if current_only:
        q = q.filter(ObraDailyAttendance.removed_at.is_(None))
    total = q.count()
    rows = (
        q.order_by(ObraDailyAttendance.signed_at.asc())
        .offset((page - 1) * limit)
        .limit(limit)
        .all()
    )
    return {
        "attendance": [attendance_to_dict(r) for r in rows],
        "pagination": _pagination(total, page, limit),
    }


async def check_in(
    db: Session,
    data: ObraDailyAttendanceCreate,
    *,
    recorded_by: int,
    ip_address: Optional[str] = None,
    user_agent: Optional[str] = None,
) -> ObraDailyAttendance:
    obra = db.query(Obra).filter(Obra.id == data.obra_id).first()
    if not obra:
        raise AsistenciaValidationError(f"No existe obra {data.obra_id}")

    worker = (
        db.query(Worker)
        .options(*_worker_options())
        .filter(Worker.id == data.worker_id)
        .first()
    )
    if not worker:
        raise AsistenciaValidationError(f"No existe trabajador {data.worker_id}")
    if worker.is_active != 1:
        raise AsistenciaValidationError("No se puede registrar un trabajador inactivo")

    # No exige vínculo previo RRHH: la asistencia del día es el registro en obra.

    if data.signature_type not in SIGNATURE_TYPES:
        raise AsistenciaValidationError(
            f"signatureType inválido. Valores: {', '.join(SIGNATURE_TYPES)}"
        )

    # electronic = firma dibujada del trabajador (legacy / opcional)
    # acknowledgment = el admin registra la llegada; auditoría en recorded_by
    signature_data = data.signature_data
    if data.signature_type == "electronic":
        if not signature_data or not is_image_data_url(signature_data):
            raise AsistenciaValidationError(
                "signatureData debe ser una firma dibujada "
                "(data:image/png;base64,...)."
            )
        try:
            assert_no_secrets(signature_data)
        except SignatureDataError as e:
            raise AsistenciaValidationError(str(e)) from e
    else:
        # acknowledgment: texto corto o vacío; no exige imagen
        if signature_data and is_image_data_url(signature_data):
            try:
                assert_no_secrets(signature_data)
            except SignatureDataError as e:
                raise AsistenciaValidationError(str(e)) from e
        elif signature_data:
            note = signature_data.strip()
            if len(note) > 500:
                raise AsistenciaValidationError(
                    "signatureData (acuse) no puede superar 500 caracteres"
                )
            signature_data = note or None
        else:
            signature_data = "Registrado por administrador en obra"

    existing = (
        db.query(ObraDailyAttendance)
        .filter(
            ObraDailyAttendance.obra_id == data.obra_id,
            ObraDailyAttendance.worker_id == data.worker_id,
            ObraDailyAttendance.work_date == data.work_date,
            ObraDailyAttendance.removed_at.is_(None),
        )
        .first()
    )
    if existing:
        raise AsistenciaConflictError(
            "Ese trabajador ya tiene asistencia registrada ese día"
        )

    row = ObraDailyAttendance(
        obra_id=data.obra_id,
        work_date=data.work_date,
        worker_id=data.worker_id,
        signed_at=get_colombia_now(),
        signature_type=data.signature_type,
        signature_data=signature_data,
        recorded_by=recorded_by,
        ip_address=ip_address,
        user_agent=(user_agent[:500] if user_agent else None),
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return (
        db.query(ObraDailyAttendance)
        .options(
            joinedload(ObraDailyAttendance.obra),
            joinedload(ObraDailyAttendance.worker).joinedload(Worker.person),
            joinedload(ObraDailyAttendance.worker).joinedload(Worker.worker_position),
            joinedload(ObraDailyAttendance.recorded_by_user).joinedload(User.person),
        )
        .filter(ObraDailyAttendance.id == row.id)
        .first()
    )


async def remove_attendance(
    db: Session, attendance_id: int, *, removed_by: int
) -> None:
    row = (
        db.query(ObraDailyAttendance)
        .filter(ObraDailyAttendance.id == attendance_id)
        .first()
    )
    if not row:
        raise AsistenciaNotFoundError(f"Asistencia {attendance_id} no encontrada")
    if row.removed_at is not None:
        raise AsistenciaValidationError("Ya estaba anulada")
    row.removed_at = get_colombia_now()
    row.removed_by = removed_by
    # Soft-remove también gente del día en tareas de esa obra
    task_ids = [
        tid
        for (tid,) in db.query(Task.id).filter(Task.obra_id == row.obra_id).all()
    ]
    if task_ids:
        (
            db.query(TaskDailyAssignment)
            .filter(
                TaskDailyAssignment.task_id.in_(task_ids),
                TaskDailyAssignment.worker_id == row.worker_id,
                TaskDailyAssignment.work_date == row.work_date,
                TaskDailyAssignment.removed_at.is_(None),
            )
            .update(
                {
                    TaskDailyAssignment.removed_at: get_colombia_now(),
                    TaskDailyAssignment.removed_by: removed_by,
                },
                synchronize_session=False,
            )
        )
    db.commit()


async def list_task_day_people(
    db: Session,
    *,
    task_id: int,
    work_date: date,
    current_only: bool = True,
) -> List[Dict[str, Any]]:
    q = (
        db.query(TaskDailyAssignment)
        .options(
            joinedload(TaskDailyAssignment.task),
            joinedload(TaskDailyAssignment.worker).joinedload(Worker.person),
            joinedload(TaskDailyAssignment.worker).joinedload(Worker.worker_position),
            joinedload(TaskDailyAssignment.assigned_by_user).joinedload(User.person),
        )
        .filter(
            TaskDailyAssignment.task_id == task_id,
            TaskDailyAssignment.work_date == work_date,
        )
    )
    if current_only:
        q = q.filter(TaskDailyAssignment.removed_at.is_(None))
    rows = q.order_by(TaskDailyAssignment.assigned_at.asc()).all()
    return [daily_assignment_to_dict(r) for r in rows]


async def assign_task_day(
    db: Session,
    task_id: int,
    data: TaskDailyAssignmentCreate,
    *,
    assigned_by: int,
) -> TaskDailyAssignment:
    task = db.query(Task).filter(Task.id == task_id).first()
    if not task:
        raise AsistenciaValidationError(f"No existe tarea {task_id}")

    worker = (
        db.query(Worker)
        .options(*_worker_options())
        .filter(Worker.id == data.worker_id)
        .first()
    )
    if not worker:
        raise AsistenciaValidationError(f"No existe trabajador {data.worker_id}")
    if worker.is_active != 1:
        raise AsistenciaValidationError("Trabajador inactivo")

    # No filtrar por especialidad: puede ir quien esté presente ese día
    if not _has_attendance(
        db, obra_id=task.obra_id, worker_id=data.worker_id, work_date=data.work_date
    ):
        raise AsistenciaValidationError(
            "El trabajador no tiene asistencia firmada en la obra ese día. "
            "Regístralo primero en asistencia diaria."
        )

    existing = (
        db.query(TaskDailyAssignment)
        .filter(
            TaskDailyAssignment.task_id == task_id,
            TaskDailyAssignment.worker_id == data.worker_id,
            TaskDailyAssignment.work_date == data.work_date,
            TaskDailyAssignment.removed_at.is_(None),
        )
        .first()
    )
    if existing:
        raise AsistenciaConflictError(
            "Ese trabajador ya está en la tarea ese día"
        )

    row = TaskDailyAssignment(
        task_id=task_id,
        work_date=data.work_date,
        worker_id=data.worker_id,
        assigned_by=assigned_by,
    )
    db.add(row)
    db.commit()
    db.refresh(row)
    return (
        db.query(TaskDailyAssignment)
        .options(
            joinedload(TaskDailyAssignment.task),
            joinedload(TaskDailyAssignment.worker).joinedload(Worker.person),
            joinedload(TaskDailyAssignment.worker).joinedload(Worker.worker_position),
            joinedload(TaskDailyAssignment.assigned_by_user).joinedload(User.person),
        )
        .filter(TaskDailyAssignment.id == row.id)
        .first()
    )


async def remove_task_day(
    db: Session, assignment_id: int, *, removed_by: int
) -> None:
    row = (
        db.query(TaskDailyAssignment)
        .filter(TaskDailyAssignment.id == assignment_id)
        .first()
    )
    if not row:
        raise AsistenciaNotFoundError(
            f"Asignación diaria {assignment_id} no encontrada"
        )
    if row.removed_at is not None:
        raise AsistenciaValidationError("Ya estaba quitada")
    row.removed_at = get_colombia_now()
    row.removed_by = removed_by
    db.commit()
