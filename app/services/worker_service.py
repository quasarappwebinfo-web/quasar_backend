from datetime import date
from typing import Any, Dict, Optional

from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload

from app.models import (
    Obra,
    Person,
    Specialty,
    User,
    Worker,
    WorkerAssignment,
    WorkerPosition,
)
from app.schemas import WorkerAssignmentCreate, WorkerAssignmentUpdate, WorkerCreate, WorkerStatusUpdate, WorkerUpdate


class WorkerAlreadyExistsError(Exception):
    pass


class WorkerNotFoundError(Exception):
    pass


class WorkerValidationError(Exception):
    pass


class AssignmentNotFoundError(Exception):
    pass


class AssignmentConflictError(Exception):
    pass


def worker_to_dict(worker: Worker) -> Dict[str, Any]:
    return {
        "id": worker.id,
        "person_id": worker.person_id,
        "worker_position_id": worker.worker_position_id,
        "specialty_id": worker.specialty_id,
        "linked_user_id": worker.linked_user_id,
        "is_active": worker.is_active,
        "deactivation_reason": worker.deactivation_reason,
        "person_name": worker.person.name if worker.person else None,
        "document_number": worker.person.document_number if worker.person else None,
        "position_name": (
            worker.worker_position.name if worker.worker_position else None
        ),
        "specialty_name": worker.specialty.name if worker.specialty else None,
        "linked_username": worker.linked_user.username if worker.linked_user else None,
        "daily_rate": (
            float(worker.daily_rate) if worker.daily_rate is not None else None
        ),
        "bank_account": worker.bank_account,
        "created_at": worker.created_at,
    }


def assignment_to_dict(row: WorkerAssignment) -> Dict[str, Any]:
    person_name = None
    if row.worker and row.worker.person:
        person_name = row.worker.person.name
    return {
        "id": row.id,
        "worker_id": row.worker_id,
        "obra_id": row.obra_id,
        "start_date": row.start_date,
        "end_date": row.end_date,
        "assigned_by": row.assigned_by,
        "person_name": person_name,
        "obra_name": row.obra.name if row.obra else None,
        "created_at": row.created_at,
    }


def _load_worker(db: Session, worker_id: int) -> Optional[Worker]:
    return (
        db.query(Worker)
        .options(
            joinedload(Worker.person),
            joinedload(Worker.worker_position),
            joinedload(Worker.specialty),
            joinedload(Worker.linked_user),
        )
        .filter(Worker.id == worker_id)
        .first()
    )


def _validate_position_specialty_user(
    db: Session,
    *,
    person_id: Optional[int] = None,
    worker_position_id: Optional[int] = None,
    specialty_id: Optional[int] = None,
    linked_user_id: Optional[int] = None,
    check_position: bool = False,
    check_specialty: bool = False,
    check_user: bool = False,
) -> None:
    if check_position and worker_position_id is not None:
        pos = (
            db.query(WorkerPosition)
            .filter(WorkerPosition.id == worker_position_id)
            .first()
        )
        if not pos:
            raise WorkerValidationError(
                f"No existe cargo con ID {worker_position_id}"
            )
        if pos.is_active != 1:
            raise WorkerValidationError(
                f"El cargo con ID {worker_position_id} está inactivo"
            )

    specialty = None
    if check_specialty and specialty_id is not None:
        specialty = db.query(Specialty).filter(Specialty.id == specialty_id).first()
        if not specialty:
            raise WorkerValidationError(
                f"No existe especialidad con ID {specialty_id}"
            )
        if specialty.is_active != 1:
            raise WorkerValidationError(
                f"La especialidad con ID {specialty_id} está inactiva"
            )

    # Si ambos vienen, la especialidad debe encajar con el cargo (si está ligada)
    effective_position_id = worker_position_id
    if specialty is not None and specialty.worker_position_id is not None:
        if (
            effective_position_id is not None
            and specialty.worker_position_id != effective_position_id
        ):
            raise WorkerValidationError(
                "La especialidad no pertenece al cargo seleccionado"
            )

    if check_user and linked_user_id is not None:
        user = db.query(User).filter(User.id == linked_user_id).first()
        if not user:
            raise WorkerValidationError(f"No existe usuario con ID {linked_user_id}")
        if person_id is not None and user.person_id != person_id:
            raise WorkerValidationError(
                "El usuario vinculado debe pertenecer a la misma persona"
            )


async def create_worker(db: Session, data: WorkerCreate) -> Worker:
    person = db.query(Person).filter(Person.id == data.person_id).first()
    if not person:
        raise WorkerValidationError(f"No existe persona con ID {data.person_id}")

    existing = db.query(Worker).filter(Worker.person_id == data.person_id).first()
    if existing:
        raise WorkerAlreadyExistsError(
            f"La persona con ID {data.person_id} ya es trabajador (id={existing.id})"
        )

    _validate_position_specialty_user(
        db,
        person_id=data.person_id,
        worker_position_id=data.worker_position_id,
        specialty_id=data.specialty_id,
        linked_user_id=data.linked_user_id,
        check_position=True,
        check_specialty=True,
        check_user=True,
    )

    worker = Worker(
        person_id=data.person_id,
        worker_position_id=data.worker_position_id,
        specialty_id=data.specialty_id,
        linked_user_id=data.linked_user_id,
        daily_rate=data.daily_rate,
        bank_account=data.bank_account,
        is_active=1,
    )
    db.add(worker)
    try:
        db.commit()
        db.refresh(worker)
        return _load_worker(db, worker.id)
    except Exception:
        db.rollback()
        raise


async def get_worker(db: Session, worker_id: int) -> Worker:
    worker = _load_worker(db, worker_id)
    if not worker:
        raise WorkerNotFoundError(f"Trabajador con ID {worker_id} no encontrado")
    return worker


async def list_workers(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
    worker_position_id: Optional[int] = None,
) -> Dict[str, Any]:
    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    query = db.query(Worker).options(
        joinedload(Worker.person),
        joinedload(Worker.worker_position),
        joinedload(Worker.specialty),
        joinedload(Worker.linked_user),
    )
    if active_only:
        query = query.filter(Worker.is_active == 1)
    if worker_position_id is not None:
        query = query.filter(Worker.worker_position_id == worker_position_id)
    if search:
        term = f"%{search.strip()}%"
        query = query.join(Person).filter(
            or_(
                Person.name.ilike(term),
                Person.document_number.ilike(term),
            )
        )

    total_items = query.count()
    rows = (
        query.order_by(Worker.id.desc())
        .offset(offset)
        .limit(limit_per_page)
        .all()
    )
    return {
        "workers": [worker_to_dict(w) for w in rows],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def update_worker(
    db: Session, worker_id: int, data: WorkerUpdate
) -> Worker:
    worker = db.query(Worker).filter(Worker.id == worker_id).first()
    if not worker:
        raise WorkerNotFoundError(f"Trabajador con ID {worker_id} no encontrado")

    update_data = data.model_dump(exclude_unset=True)
    position_id = update_data.get(
        "worker_position_id", worker.worker_position_id
    )
    specialty_id = update_data.get("specialty_id", worker.specialty_id)
    linked_user_id = update_data.get("linked_user_id", worker.linked_user_id)

    _validate_position_specialty_user(
        db,
        person_id=worker.person_id,
        worker_position_id=position_id,
        specialty_id=specialty_id,
        linked_user_id=linked_user_id,
        check_position="worker_position_id" in update_data,
        check_specialty="specialty_id" in update_data
        or "worker_position_id" in update_data,
        check_user="linked_user_id" in update_data,
    )

    for field, value in update_data.items():
        setattr(worker, field, value)

    try:
        db.commit()
        db.refresh(worker)
        return _load_worker(db, worker.id)
    except Exception:
        db.rollback()
        raise


async def update_worker_status(
    db: Session, worker_id: int, data: WorkerStatusUpdate
) -> Worker:
    worker = db.query(Worker).filter(Worker.id == worker_id).first()
    if not worker:
        raise WorkerNotFoundError(f"Trabajador con ID {worker_id} no encontrado")

    if data.is_active not in (1, 2):
        raise WorkerValidationError("is_active debe ser 1 (activo) o 2 (inactivo)")

    if data.is_active == 2:
        reason = (data.deactivation_reason or "").strip()
        if not reason:
            raise WorkerValidationError(
                "deactivation_reason es obligatorio al dar de baja un trabajador"
            )
        worker.is_active = 2
        worker.deactivation_reason = reason
    else:
        worker.is_active = 1
        worker.deactivation_reason = None

    try:
        db.commit()
        db.refresh(worker)
        return _load_worker(db, worker.id)
    except Exception:
        db.rollback()
        raise


def _load_assignment(db: Session, assignment_id: int) -> Optional[WorkerAssignment]:
    return (
        db.query(WorkerAssignment)
        .options(
            joinedload(WorkerAssignment.worker).joinedload(Worker.person),
            joinedload(WorkerAssignment.obra),
        )
        .filter(WorkerAssignment.id == assignment_id)
        .first()
    )


async def create_assignment(
    db: Session,
    data: WorkerAssignmentCreate,
    *,
    assigned_by: int,
) -> WorkerAssignment:
    worker = db.query(Worker).filter(Worker.id == data.worker_id).first()
    if not worker:
        raise WorkerValidationError(f"No existe trabajador con ID {data.worker_id}")
    if worker.is_active != 1:
        raise WorkerValidationError("No se puede asignar un trabajador inactivo")

    obra = db.query(Obra).filter(Obra.id == data.obra_id).first()
    if not obra:
        raise WorkerValidationError(f"No existe obra con ID {data.obra_id}")

    if data.end_date is not None and data.end_date < data.start_date:
        raise WorkerValidationError("end_date no puede ser anterior a start_date")

    open_same = (
        db.query(WorkerAssignment)
        .filter(
            WorkerAssignment.worker_id == data.worker_id,
            WorkerAssignment.obra_id == data.obra_id,
            WorkerAssignment.end_date.is_(None),
        )
        .first()
    )
    if open_same:
        raise AssignmentConflictError(
            "El trabajador ya tiene una asignación vigente en esa obra"
        )

    row = WorkerAssignment(
        worker_id=data.worker_id,
        obra_id=data.obra_id,
        start_date=data.start_date,
        end_date=data.end_date,
        assigned_by=assigned_by,
    )
    db.add(row)
    try:
        db.commit()
        db.refresh(row)
        return _load_assignment(db, row.id)
    except Exception:
        db.rollback()
        raise


async def get_assignment(db: Session, assignment_id: int) -> WorkerAssignment:
    row = _load_assignment(db, assignment_id)
    if not row:
        raise AssignmentNotFoundError(
            f"Asignación con ID {assignment_id} no encontrada"
        )
    return row


async def list_assignments(
    db: Session,
    page: int = 1,
    worker_id: Optional[int] = None,
    obra_id: Optional[int] = None,
    current_only: bool = False,
) -> Dict[str, Any]:
    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    query = db.query(WorkerAssignment).options(
        joinedload(WorkerAssignment.worker).joinedload(Worker.person),
        joinedload(WorkerAssignment.obra),
    )
    if worker_id is not None:
        query = query.filter(WorkerAssignment.worker_id == worker_id)
    if obra_id is not None:
        query = query.filter(WorkerAssignment.obra_id == obra_id)
    if current_only:
        query = query.filter(WorkerAssignment.end_date.is_(None))

    total_items = query.count()
    rows = (
        query.order_by(WorkerAssignment.start_date.desc())
        .offset(offset)
        .limit(limit_per_page)
        .all()
    )
    return {
        "assignments": [assignment_to_dict(r) for r in rows],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def close_assignment(
    db: Session,
    assignment_id: int,
    data: WorkerAssignmentUpdate,
) -> WorkerAssignment:
    row = db.query(WorkerAssignment).filter(WorkerAssignment.id == assignment_id).first()
    if not row:
        raise AssignmentNotFoundError(
            f"Asignación con ID {assignment_id} no encontrada"
        )
    if row.end_date is not None:
        raise AssignmentConflictError("La asignación ya está cerrada")

    end_date = data.end_date or date.today()
    if end_date < row.start_date:
        raise WorkerValidationError("end_date no puede ser anterior a start_date")

    row.end_date = end_date
    try:
        db.commit()
        db.refresh(row)
        return _load_assignment(db, row.id)
    except Exception:
        db.rollback()
        raise
