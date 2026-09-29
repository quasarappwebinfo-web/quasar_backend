from datetime import datetime
from typing import Any, Dict, Optional

from sqlalchemy.orm import Session, joinedload

from app.models import Crew, CrewMember, Obra, Worker
from app.schemas import CrewCreate, CrewMemberCreate, CrewUpdate


class CrewNotFoundError(Exception):
    pass


class CrewValidationError(Exception):
    pass


class CrewMemberNotFoundError(Exception):
    pass


class CrewMemberConflictError(Exception):
    pass


def crew_to_dict(crew: Crew) -> Dict[str, Any]:
    leader_name = None
    if crew.leader and crew.leader.person:
        leader_name = crew.leader.person.name
    return {
        "id": crew.id,
        "name": crew.name,
        "leader_worker_id": crew.leader_worker_id,
        "obra_id": crew.obra_id,
        "is_active": crew.is_active,
        "leader_name": leader_name,
        "obra_name": crew.obra.name if crew.obra else None,
        "created_at": crew.created_at,
    }


def crew_member_to_dict(row: CrewMember) -> Dict[str, Any]:
    person_name = None
    document_number = None
    if row.worker and row.worker.person:
        person_name = row.worker.person.name
        document_number = row.worker.person.document_number
    return {
        "id": row.id,
        "crew_id": row.crew_id,
        "worker_id": row.worker_id,
        "joined_at": row.joined_at,
        "left_at": row.left_at,
        "person_name": person_name,
        "document_number": document_number,
    }


def _load_crew(db: Session, crew_id: int) -> Optional[Crew]:
    return (
        db.query(Crew)
        .options(
            joinedload(Crew.leader).joinedload(Worker.person),
            joinedload(Crew.obra),
        )
        .filter(Crew.id == crew_id)
        .first()
    )


def _ensure_worker_active(db: Session, worker_id: int, label: str = "trabajador") -> Worker:
    worker = db.query(Worker).filter(Worker.id == worker_id).first()
    if not worker:
        raise CrewValidationError(f"No existe {label} con ID {worker_id}")
    if worker.is_active != 1:
        raise CrewValidationError(f"El {label} con ID {worker_id} está inactivo")
    return worker


def _ensure_obra(db: Session, obra_id: Optional[int]) -> None:
    if obra_id is None:
        return
    if not db.query(Obra).filter(Obra.id == obra_id).first():
        raise CrewValidationError(f"No existe obra con ID {obra_id}")


async def create_crew(db: Session, data: CrewCreate) -> Crew:
    if data.leader_worker_id is not None:
        _ensure_worker_active(db, data.leader_worker_id, label="líder")
    _ensure_obra(db, data.obra_id)

    crew = Crew(
        name=data.name,
        leader_worker_id=data.leader_worker_id,
        obra_id=data.obra_id,
        is_active=1,
    )
    db.add(crew)
    try:
        db.commit()
        db.refresh(crew)
        # Si hay líder, agregarlo como miembro vigente
        if data.leader_worker_id is not None:
            member = CrewMember(
                crew_id=crew.id,
                worker_id=data.leader_worker_id,
            )
            db.add(member)
            db.commit()
        return _load_crew(db, crew.id)
    except Exception:
        db.rollback()
        raise


async def get_crew(db: Session, crew_id: int) -> Crew:
    crew = _load_crew(db, crew_id)
    if not crew:
        raise CrewNotFoundError(f"Cuadrilla con ID {crew_id} no encontrada")
    return crew


async def list_crews(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
    obra_id: Optional[int] = None,
) -> Dict[str, Any]:
    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    query = db.query(Crew).options(
        joinedload(Crew.leader).joinedload(Worker.person),
        joinedload(Crew.obra),
    )
    if active_only:
        query = query.filter(Crew.is_active == 1)
    if obra_id is not None:
        query = query.filter(Crew.obra_id == obra_id)
    if search:
        query = query.filter(Crew.name.ilike(f"%{search.strip()}%"))

    total_items = query.count()
    rows = query.order_by(Crew.name.asc()).offset(offset).limit(limit_per_page).all()
    return {
        "crews": [crew_to_dict(c) for c in rows],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def update_crew(db: Session, crew_id: int, data: CrewUpdate) -> Crew:
    crew = db.query(Crew).filter(Crew.id == crew_id).first()
    if not crew:
        raise CrewNotFoundError(f"Cuadrilla con ID {crew_id} no encontrada")

    update_data = data.model_dump(exclude_unset=True)
    if "is_active" in update_data and update_data["is_active"] not in (1, 2):
        raise CrewValidationError("is_active debe ser 1 (activo) o 2 (inactivo)")

    if "leader_worker_id" in update_data and update_data["leader_worker_id"] is not None:
        _ensure_worker_active(db, update_data["leader_worker_id"], label="líder")
    if "obra_id" in update_data:
        _ensure_obra(db, update_data["obra_id"])

    for field, value in update_data.items():
        setattr(crew, field, value)

    try:
        db.commit()
        db.refresh(crew)
        return _load_crew(db, crew.id)
    except Exception:
        db.rollback()
        raise


async def add_crew_member(db: Session, data: CrewMemberCreate) -> CrewMember:
    crew = db.query(Crew).filter(Crew.id == data.crew_id).first()
    if not crew:
        raise CrewNotFoundError(f"Cuadrilla con ID {data.crew_id} no encontrada")
    if crew.is_active != 1:
        raise CrewValidationError("No se pueden agregar miembros a una cuadrilla inactiva")

    _ensure_worker_active(db, data.worker_id)

    active = (
        db.query(CrewMember)
        .filter(
            CrewMember.crew_id == data.crew_id,
            CrewMember.worker_id == data.worker_id,
            CrewMember.left_at.is_(None),
        )
        .first()
    )
    if active:
        raise CrewMemberConflictError(
            "El trabajador ya es miembro vigente de esta cuadrilla"
        )

    row = CrewMember(crew_id=data.crew_id, worker_id=data.worker_id)
    db.add(row)
    try:
        db.commit()
        db.refresh(row)
        return (
            db.query(CrewMember)
            .options(joinedload(CrewMember.worker).joinedload(Worker.person))
            .filter(CrewMember.id == row.id)
            .first()
        )
    except Exception:
        db.rollback()
        raise


async def list_crew_members(
    db: Session,
    crew_id: int,
    *,
    current_only: bool = True,
    page: int = 1,
) -> Dict[str, Any]:
    crew = db.query(Crew).filter(Crew.id == crew_id).first()
    if not crew:
        raise CrewNotFoundError(f"Cuadrilla con ID {crew_id} no encontrada")

    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    query = (
        db.query(CrewMember)
        .options(joinedload(CrewMember.worker).joinedload(Worker.person))
        .filter(CrewMember.crew_id == crew_id)
    )
    if current_only:
        query = query.filter(CrewMember.left_at.is_(None))

    total_items = query.count()
    rows = (
        query.order_by(CrewMember.joined_at.desc())
        .offset(offset)
        .limit(limit_per_page)
        .all()
    )
    return {
        "members": [crew_member_to_dict(m) for m in rows],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def remove_crew_member(
    db: Session,
    membership_id: int,
    *,
    left_at: Optional[datetime] = None,
) -> CrewMember:
    row = (
        db.query(CrewMember)
        .options(joinedload(CrewMember.worker).joinedload(Worker.person))
        .filter(CrewMember.id == membership_id)
        .first()
    )
    if not row:
        raise CrewMemberNotFoundError(
            f"Membresía con ID {membership_id} no encontrada"
        )
    if row.left_at is not None:
        raise CrewMemberConflictError("El miembro ya salió de la cuadrilla")

    row.left_at = left_at or datetime.utcnow()
    try:
        db.commit()
        db.refresh(row)
        return row
    except Exception:
        db.rollback()
        raise
