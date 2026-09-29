from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_IDENTIDAD
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import PersonCreate, PersonResponse, PersonUpdate
from app.services.person_service import (
    PersonAlreadyExistsError,
    PersonNotFoundError,
    create_person,
    get_person,
    list_persons,
    person_to_dict,
    update_person,
)

router = APIRouter(prefix="/api/v1/identidad/personas", tags=["identidad-personas"])


@router.get(
    "",
    summary="Listar personas",
    description="Lista paginada. Búsqueda por nombre o número de documento.",
)
async def list_persons_endpoint(
    page: int = Query(1, ge=1, description="Número de página"),
    search: Optional[str] = Query(
        None, description="Buscar por nombre o documento (cédula)"
    ),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    result = await list_persons(db=db, page=page, search=search)
    persons_serialized = [
        PersonResponse(**p).model_dump(by_alias=True) for p in result["persons"]
    ]
    return {"persons": persons_serialized, "pagination": result["pagination"]}


@router.post(
    "",
    response_model=PersonResponse,
    summary="Crear persona",
    description=(
        "Crea una persona. Si el documentNumber ya existe, responde 409 "
        "sin crear duplicado."
    ),
    status_code=status.HTTP_201_CREATED,
)
async def create_person_endpoint(
    data: PersonCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    try:
        person = await create_person(db=db, data=data)
        return PersonResponse(**person_to_dict(person)).model_dump(by_alias=True)
    except PersonAlreadyExistsError as e:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=str(e),
        )


@router.get(
    "/{person_id}",
    response_model=PersonResponse,
    summary="Obtener persona por ID",
)
async def get_person_endpoint(
    person_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    try:
        person = await get_person(db=db, person_id=person_id)
        return PersonResponse(**person_to_dict(person)).model_dump(by_alias=True)
    except PersonNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.put(
    "/{person_id}",
    response_model=PersonResponse,
    summary="Actualizar persona",
    description="Actualiza nombre, teléfono, foto o fecha de nacimiento. "
    "El documento (cédula) no se puede cambiar.",
)
async def update_person_endpoint(
    person_id: int,
    data: PersonUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_IDENTIDAD)),
):
    _ = user_auth
    try:
        person = await update_person(db=db, person_id=person_id, data=data)
        return PersonResponse(**person_to_dict(person)).model_dump(by_alias=True)
    except PersonNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
