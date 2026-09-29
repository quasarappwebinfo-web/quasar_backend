from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_RRHH
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import (
    CrewCreate,
    CrewMemberAdd,
    CrewMemberCreate,
    CrewMemberResponse,
    CrewResponse,
    CrewUpdate,
)
from app.services.crew_service import (
    CrewMemberConflictError,
    CrewMemberNotFoundError,
    CrewNotFoundError,
    CrewValidationError,
    add_crew_member,
    create_crew,
    crew_member_to_dict,
    crew_to_dict,
    get_crew,
    list_crew_members,
    list_crews,
    remove_crew_member,
    update_crew,
)

router = APIRouter(
    prefix="/api/v1/rrhh/cuadrillas",
    tags=["rrhh-cuadrillas"],
)
# DEPRECATED: alta rotación diaria — preferir asistencia + gente-día.
# Se mantiene por compatibilidad; el front ya no lo expone.


@router.get("", summary="Listar cuadrillas")
async def list_crews_endpoint(
    page: int = Query(1, ge=1),
    search: Optional[str] = Query(None),
    active_only: bool = Query(False),
    obra_id: Optional[int] = Query(None),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    result = await list_crews(
        db=db,
        page=page,
        search=search,
        active_only=active_only,
        obra_id=obra_id,
    )
    return {
        "crews": [
            CrewResponse(**c).model_dump(by_alias=True) for c in result["crews"]
        ],
        "pagination": result["pagination"],
    }


@router.post(
    "",
    summary="Crear cuadrilla",
    status_code=status.HTTP_201_CREATED,
)
async def create_crew_endpoint(
    data: CrewCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        crew = await create_crew(db=db, data=data)
        return CrewResponse(**crew_to_dict(crew)).model_dump(by_alias=True)
    except CrewValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get("/{crew_id}", summary="Obtener cuadrilla")
async def get_crew_endpoint(
    crew_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        crew = await get_crew(db=db, crew_id=crew_id)
        return CrewResponse(**crew_to_dict(crew)).model_dump(by_alias=True)
    except CrewNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.put("/{crew_id}", summary="Actualizar cuadrilla")
async def update_crew_endpoint(
    crew_id: int,
    data: CrewUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        crew = await update_crew(db=db, crew_id=crew_id, data=data)
        return CrewResponse(**crew_to_dict(crew)).model_dump(by_alias=True)
    except CrewNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except CrewValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get(
    "/{crew_id}/miembros",
    summary="Listar miembros de cuadrilla",
    description="Por defecto solo vigentes (leftAt null).",
)
async def list_members_endpoint(
    crew_id: int,
    page: int = Query(1, ge=1),
    current_only: bool = Query(True),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        result = await list_crew_members(
            db=db, crew_id=crew_id, current_only=current_only, page=page
        )
        return {
            "members": [
                CrewMemberResponse(**m).model_dump(by_alias=True)
                for m in result["members"]
            ],
            "pagination": result["pagination"],
        }
    except CrewNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.post(
    "/{crew_id}/miembros",
    summary="Agregar miembro a cuadrilla",
    status_code=status.HTTP_201_CREATED,
)
async def add_member_endpoint(
    crew_id: int,
    data: CrewMemberAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    payload = CrewMemberCreate(crew_id=crew_id, worker_id=data.worker_id)
    try:
        row = await add_crew_member(db=db, data=payload)
        return CrewMemberResponse(**crew_member_to_dict(row)).model_dump(by_alias=True)
    except CrewNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except CrewMemberConflictError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except CrewValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.put(
    "/miembros/{membership_id}/sacar",
    summary="Sacar miembro de cuadrilla",
    description="Pone leftAt (historial). No borra el registro.",
)
async def remove_member_endpoint(
    membership_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        row = await remove_crew_member(db=db, membership_id=membership_id)
        return CrewMemberResponse(**crew_member_to_dict(row)).model_dump(by_alias=True)
    except CrewMemberNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except CrewMemberConflictError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
