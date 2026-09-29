from datetime import date
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_ASISTENCIA
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas.rrhh.asistencia_schema import (
    ObraDailyAttendanceCreate,
    ObraDailyAttendanceResponse,
    TaskDailyAssignmentCreate,
    TaskDailyAssignmentResponse,
)
from app.services import asistencia_service as svc

router = APIRouter(prefix="/api/v1/rrhh", tags=["rrhh-asistencia"])


def _err(e: Exception) -> None:
    if isinstance(e, svc.AsistenciaNotFoundError):
        raise HTTPException(status_code=404, detail=str(e)) from e
    if isinstance(e, svc.AsistenciaConflictError):
        raise HTTPException(status_code=409, detail=str(e)) from e
    if isinstance(e, svc.AsistenciaValidationError):
        raise HTTPException(status_code=400, detail=str(e)) from e
    raise e


@router.get(
    "/asistencia",
    summary="Listar asistencia diaria de una obra",
)
async def list_attendance(
    obra_id: int = Query(..., alias="obraId"),
    work_date: date = Query(..., alias="date"),
    current_only: bool = Query(True, alias="currentOnly"),
    page: int = Query(1, ge=1),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_ASISTENCIA)),
):
    _ = user_auth
    result = await svc.list_attendance(
        db,
        obra_id=obra_id,
        work_date=work_date,
        current_only=current_only,
        page=page,
    )
    return {
        "attendance": [
            ObraDailyAttendanceResponse(**r).model_dump(by_alias=True)
            for r in result["attendance"]
        ],
        "pagination": result["pagination"],
    }


@router.post(
    "/asistencia",
    status_code=status.HTTP_201_CREATED,
    summary="Registrar llegada (firma canvas base64)",
)
async def check_in(
    data: ObraDailyAttendanceCreate,
    request: Request,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_ASISTENCIA)),
):
    try:
        ip = request.client.host if request.client else None
        ua = request.headers.get("user-agent")
        row = await svc.check_in(
            db,
            data,
            recorded_by=user_auth.id,
            ip_address=ip,
            user_agent=ua,
        )
        return ObraDailyAttendanceResponse(
            **svc.attendance_to_dict(row)
        ).model_dump(by_alias=True)
    except svc.AsistenciaError as e:
        _err(e)


@router.delete(
    "/asistencia/{attendance_id}",
    status_code=status.HTTP_400_BAD_REQUEST,
    summary="No permitido: la llegada firmada no se anula",
    deprecated=True,
)
async def remove_attendance(
    attendance_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_ASISTENCIA)),
):
    _ = attendance_id, db, user_auth
    raise HTTPException(
        status_code=400,
        detail="La llegada firmada no se puede anular. Queda como registro definitivo.",
    )

# --- gente del día en tarea (mismo router rrhh/operacion vía path operacion) ---

task_day_router = APIRouter(
    prefix="/api/v1/operacion/tareas",
    tags=["tareas-gente-dia"],
)


@task_day_router.get(
    "/{task_id}/gente-dia",
    summary="Quién trabaja en la tarea un día",
)
async def list_task_day_people(
    task_id: int,
    work_date: date = Query(..., alias="date"),
    current_only: bool = Query(True, alias="currentOnly"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_ASISTENCIA)),
):
    _ = user_auth
    try:
        rows = await svc.list_task_day_people(
            db,
            task_id=task_id,
            work_date=work_date,
            current_only=current_only,
        )
        return {
            "assignments": [
                TaskDailyAssignmentResponse(**r).model_dump(by_alias=True)
                for r in rows
            ]
        }
    except svc.AsistenciaError as e:
        _err(e)


@task_day_router.post(
    "/{task_id}/gente-dia",
    status_code=status.HTTP_201_CREATED,
    summary="Asignar trabajador a la tarea ese día (sin filtro de especialidad)",
)
async def assign_task_day(
    task_id: int,
    data: TaskDailyAssignmentCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_ASISTENCIA)),
):
    try:
        row = await svc.assign_task_day(
            db, task_id, data, assigned_by=user_auth.id
        )
        return TaskDailyAssignmentResponse(
            **svc.daily_assignment_to_dict(row)
        ).model_dump(by_alias=True)
    except svc.AsistenciaError as e:
        _err(e)


@task_day_router.delete(
    "/gente-dia/{assignment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar trabajador de la tarea ese día (soft)",
)
async def remove_task_day(
    assignment_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_ASISTENCIA)),
):
    try:
        await svc.remove_task_day(
            db, assignment_id, removed_by=user_auth.id
        )
    except svc.AsistenciaError as e:
        _err(e)
