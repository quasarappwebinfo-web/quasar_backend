from typing import Any, Dict, Optional

from sqlalchemy import or_
from sqlalchemy.orm import Session

from app.models import Person
from app.schemas import PersonCreate, PersonUpdate


def person_to_dict(person: Person) -> Dict[str, Any]:
    return {
        "id": person.id,
        "document_number": person.document_number,
        "name": person.name,
        "phone": person.phone,
        "photo_url": person.photo_url,
        "birth_date": person.birth_date,
        "created_at": person.created_at,
    }


class PersonAlreadyExistsError(Exception):
    """La cédula / documento ya está registrado."""

    def __init__(self, message: str, existing: Optional[Person] = None):
        super().__init__(message)
        self.existing = existing


class PersonNotFoundError(Exception):
    pass


async def create_person(db: Session, data: PersonCreate) -> Person:
    existing = (
        db.query(Person)
        .filter(Person.document_number == data.document_number)
        .first()
    )
    if existing:
        raise PersonAlreadyExistsError(
            f"Ya existe una persona con documento '{data.document_number}'",
            existing=existing,
        )

    person = Person(
        document_number=data.document_number,
        name=data.name,
        phone=data.phone,
        photo_url=data.photo_url,
        birth_date=data.birth_date,
    )
    db.add(person)
    try:
        db.commit()
        db.refresh(person)
        return person
    except Exception:
        db.rollback()
        raise


async def get_person(db: Session, person_id: int) -> Person:
    person = db.query(Person).filter(Person.id == person_id).first()
    if not person:
        raise PersonNotFoundError(f"Persona con ID {person_id} no encontrada")
    return person


async def list_persons(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
) -> Dict[str, Any]:
    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    base_query = db.query(Person)
    if search:
        term = f"%{search.strip()}%"
        base_query = base_query.filter(
            or_(
                Person.name.ilike(term),
                Person.document_number.ilike(term),
            )
        )

    total_items = base_query.count()
    persons = (
        base_query.order_by(Person.name.asc())
        .offset(offset)
        .limit(limit_per_page)
        .all()
    )

    return {
        "persons": [person_to_dict(p) for p in persons],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def update_person(
    db: Session, person_id: int, data: PersonUpdate
) -> Person:
    person = await get_person(db, person_id)
    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(person, field, value)

    try:
        db.commit()
        db.refresh(person)
        return person
    except Exception:
        db.rollback()
        raise
