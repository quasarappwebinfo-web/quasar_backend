"""
Endpoints planificación — /api/v1/planificacion/planes
"""
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_PLANIFICACION
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import (
    WorkPlanCompareResponse,
    WorkPlanCreate,
    WorkPlanNewVersionRequest,
    WorkPlanResponse,
    WorkPlanSignatureEventResponse,
    WorkPlanSignerResponse,
    WorkPlanTaskAdd,
    WorkPlanTaskResponse,
    WorkPlanUpdate,
    WorkPlanVersionResponse,
)
from app.schemas.planificacion.work_plan_schema import UnfinishedPlanActivity
from app.services import work_plan_service as svc

router = APIRouter(prefix="/api/v1/planificacion/planes", tags=["planificacion"])


def _err(exc: Exception):
    if isinstance(exc, svc.WorkPlanNotFoundError):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc))
    if isinstance(exc, svc.WorkPlanConflictError):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc))
    if isinstance(exc, svc.WorkPlanValidationError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))
    raise exc


def _plan(d: dict) -> dict:
    return WorkPlanResponse(**d).model_dump(by_alias=True)


@router.get("", summary="Listar planificaciones")
async def list_plans(
    page: int = Query(1, ge=1),
    obra_id: Optional[int] = Query(None, alias="obraId"),
    status_filter: Optional[str] = Query(None, alias="status"),
    search: Optional[str] = None,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    _ = user_auth
    try:
        result = await svc.list_plans(
            db,
            page=page,
            obra_id=obra_id,
            status=status_filter,
            search=search,
        )
        return {
            "workPlans": [_plan(p) for p in result["workPlans"]],
            "pagination": result["pagination"],
        }
    except svc.WorkPlanError as e:
        _err(e)


@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
    summary="Crear planificación + versión 1 con snapshots",
)
async def create_plan(
    data: WorkPlanCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        row = await svc.create_plan(db, data, requested_by=user_auth.id)
        return _plan(svc.plan_to_dict(row))
    except svc.WorkPlanError as e:
        _err(e)


@router.get(
    "/pendientes",
    summary="Actividades de periodos anteriores que no se completaron",
)
async def list_unfinished(
    obra_id: int = Query(..., alias="obraId"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    _ = user_auth
    try:
        rows = await svc.list_unfinished_activities(db, obra_id)
        return {
            "tasks": [
                UnfinishedPlanActivity(**row).model_dump(by_alias=True) for row in rows
            ]
        }
    except svc.WorkPlanError as e:
        _err(e)


@router.get("/{plan_id}", summary="Detalle: versiones, snapshots y eventos")
async def get_detail(
    plan_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    _ = user_auth
    try:
        detail = await svc.get_plan_detail(db, plan_id)
        out = {
            "workPlan": _plan(detail["workPlan"]),
            "versions": [
                WorkPlanVersionResponse(**v).model_dump(by_alias=True)
                for v in detail["versions"]
            ],
            "currentVersion": None,
        }
        cv = detail["currentVersion"]
        if cv:
            out["currentVersion"] = {
                "version": WorkPlanVersionResponse(**cv["version"]).model_dump(
                    by_alias=True
                ),
                "tasks": [
                    WorkPlanTaskResponse(**t).model_dump(by_alias=True)
                    for t in cv["tasks"]
                ],
                "signers": [
                    WorkPlanSignerResponse(**s).model_dump(by_alias=True)
                    for s in cv["signers"]
                ],
                "events": [
                    WorkPlanSignatureEventResponse(**e).model_dump(by_alias=True)
                    for e in cv["events"]
                ],
            }
        return out
    except svc.WorkPlanError as e:
        _err(e)


@router.put("/{plan_id}", summary="Actualizar cabecera (solo draft)")
async def update_plan(
    plan_id: int,
    data: WorkPlanUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        row = await svc.update_plan(
            db, plan_id, data, edited_by=user_auth.id
        )
        return _plan(svc.plan_to_dict(row))
    except svc.WorkPlanError as e:
        _err(e)


@router.get(
    "/{plan_id}/comparar",
    summary="Planificado (snapshot) vs actual (tarea) vs delays",
)
async def compare(
    plan_id: int,
    version_id: Optional[int] = Query(None, alias="versionId"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    _ = user_auth
    try:
        result = await svc.compare_version(db, plan_id, version_id)
        return WorkPlanCompareResponse(**result).model_dump(by_alias=True)
    except svc.WorkPlanError as e:
        _err(e)


@router.post(
    "/{plan_id}/vista",
    summary="Compatibilidad: ya no registra vistas en el historial",
)
async def mark_viewed(
    plan_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        await svc.mark_viewed(db, plan_id, user_id=user_auth.id)
        return {"ok": True}
    except svc.WorkPlanError as e:
        _err(e)


@router.post(
    "/{plan_id}/nueva-version",
    status_code=status.HTTP_201_CREATED,
    summary="Desde signed/rejected → nuevo draft (snapshot fresco)",
)
async def new_version(
    plan_id: int,
    data: WorkPlanNewVersionRequest,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        row = await svc.create_new_version(
            db, plan_id, data, created_by=user_auth.id
        )
        return _plan(svc.plan_to_dict(row))
    except svc.WorkPlanError as e:
        _err(e)


# --- Versión: tareas ---


@router.post(
    "/versiones/{version_id}/tareas",
    status_code=status.HTTP_201_CREATED,
    summary="Agregar tarea al snapshot (draft)",
)
async def add_task(
    version_id: int,
    data: WorkPlanTaskAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        row = await svc.add_task_to_version(
            db, version_id, data, edited_by=user_auth.id
        )
        return WorkPlanTaskResponse(**svc.snapshot_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.WorkPlanError as e:
        _err(e)


@router.delete(
    "/snapshots/{snapshot_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar tarea del snapshot (draft)",
)
async def remove_task(
    snapshot_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        await svc.remove_task_from_version(
            db, snapshot_id, edited_by=user_auth.id
        )
    except svc.WorkPlanError as e:
        _err(e)

