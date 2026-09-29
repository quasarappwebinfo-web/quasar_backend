from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_RRHH
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import (
    WorkerAssignmentCreate,
    WorkerAssignmentResponse,
    WorkerAssignmentUpdate,
    WorkerCreate,
    WorkerResponse,
    WorkerStatusUpdate,
    WorkerUpdate,
)
from app.services.worker_service import (
    AssignmentConflictError,
    AssignmentNotFoundError,
    WorkerAlreadyExistsError,
    WorkerNotFoundError,
    WorkerValidationError,
    assignment_to_dict,
    close_assignment,
    create_assignment,
    create_worker,
    get_assignment,
    get_worker,
    list_assignments,
    list_workers,
    update_worker,
    update_worker_status,
    worker_to_dict,
)

router = APIRouter(prefix="/api/v1/rrhh", tags=["rrhh-trabajadores"])


@router.get(
    "/trabajadores",
    summary="Listar trabajadores",
)
async def list_workers_endpoint(
    page: int = Query(1, ge=1),
    search: Optional[str] = Query(None, description="Nombre o cédula"),
    active_only: bool = Query(False, description="Solo activos (isActive=1)"),
    worker_position_id: Optional[int] = Query(None, description="Filtrar por cargo"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    result = await list_workers(
        db=db,
        page=page,
        search=search,
        active_only=active_only,
        worker_position_id=worker_position_id,
    )
    return {
        "workers": [
            WorkerResponse(**w).model_dump(by_alias=True) for w in result["workers"]
        ],
        "pagination": result["pagination"],
    }


@router.post(
    "/trabajadores",
    summary="Crear trabajador",
    description=(
        "Requiere personId (crear persona antes si no existe). "
        "Una persona solo puede ser un trabajador. "
        "linkedUserId opcional debe ser el usuario de la misma persona."
    ),
    status_code=status.HTTP_201_CREATED,
)
async def create_worker_endpoint(
    data: WorkerCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        worker = await create_worker(db=db, data=data)
        return WorkerResponse(**worker_to_dict(worker)).model_dump(by_alias=True)
    except WorkerAlreadyExistsError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except WorkerValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get(
    "/trabajadores/{worker_id}",
    summary="Obtener trabajador",
)
async def get_worker_endpoint(
    worker_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        worker = await get_worker(db=db, worker_id=worker_id)
        return WorkerResponse(**worker_to_dict(worker)).model_dump(by_alias=True)
    except WorkerNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.put(
    "/trabajadores/{worker_id}",
    summary="Actualizar trabajador",
    description="Cargo, especialidad y usuario vinculado. No cambia personId.",
)
async def update_worker_endpoint(
    worker_id: int,
    data: WorkerUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        worker = await update_worker(db=db, worker_id=worker_id, data=data)
        return WorkerResponse(**worker_to_dict(worker)).model_dump(by_alias=True)
    except WorkerNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except WorkerValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.put(
    "/trabajadores/{worker_id}/status",
    summary="Alta / baja definitiva del trabajador",
    description=(
        "isActive=2 requiere deactivationReason. "
        "Esto NO es sacar al trabajador de una obra (usa asignaciones)."
    ),
)
async def update_worker_status_endpoint(
    worker_id: int,
    data: WorkerStatusUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        worker = await update_worker_status(db=db, worker_id=worker_id, data=data)
        return WorkerResponse(**worker_to_dict(worker)).model_dump(by_alias=True)
    except WorkerNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except WorkerValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


# --- Asignaciones a obras ---


@router.get(
    "/asignaciones",
    summary="Listar asignaciones trabajador↔obra",
    tags=["rrhh-asignaciones"],
)
async def list_assignments_endpoint(
    page: int = Query(1, ge=1),
    worker_id: Optional[int] = Query(None),
    obra_id: Optional[int] = Query(None),
    current_only: bool = Query(
        False, description="Solo vigentes (endDate null)"
    ),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    result = await list_assignments(
        db=db,
        page=page,
        worker_id=worker_id,
        obra_id=obra_id,
        current_only=current_only,
    )
    return {
        "assignments": [
            WorkerAssignmentResponse(**a).model_dump(by_alias=True)
            for a in result["assignments"]
        ],
        "pagination": result["pagination"],
    }


@router.post(
    "/asignaciones",
    summary="Asignar trabajador a obra",
    tags=["rrhh-asignaciones"],
    status_code=status.HTTP_201_CREATED,
)
async def create_assignment_endpoint(
    data: WorkerAssignmentCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    try:
        row = await create_assignment(db=db, data=data, assigned_by=user_auth.id)
        return WorkerAssignmentResponse(**assignment_to_dict(row)).model_dump(
            by_alias=True
        )
    except AssignmentConflictError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except WorkerValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get(
    "/asignaciones/{assignment_id}",
    summary="Obtener asignación",
    tags=["rrhh-asignaciones"],
)
async def get_assignment_endpoint(
    assignment_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        row = await get_assignment(db=db, assignment_id=assignment_id)
        return WorkerAssignmentResponse(**assignment_to_dict(row)).model_dump(
            by_alias=True
        )
    except AssignmentNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.put(
    "/asignaciones/{assignment_id}/cerrar",
    summary="Cerrar asignación (poner endDate)",
    description="Historial: no se borra. Si no envías endDate, usa hoy.",
    tags=["rrhh-asignaciones"],
)
async def close_assignment_endpoint(
    assignment_id: int,
    data: WorkerAssignmentUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_RRHH)),
):
    _ = user_auth
    try:
        row = await close_assignment(db=db, assignment_id=assignment_id, data=data)
        return WorkerAssignmentResponse(**assignment_to_dict(row)).model_dump(
            by_alias=True
        )
    except AssignmentNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except AssignmentConflictError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except WorkerValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
