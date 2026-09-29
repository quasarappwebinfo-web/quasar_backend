"""
Endpoints planificación — /api/v1/planificacion/planes
"""
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_PLANIFICACION
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import (
    WorkPlanCompareResponse,
    WorkPlanCreate,
    WorkPlanNewVersionRequest,
    WorkPlanRejectRequest,
    WorkPlanResponse,
    WorkPlanSignatureEventResponse,
    WorkPlanSignerAdd,
    WorkPlanSignerResponse,
    WorkPlanSignRequest,
    WorkPlanTaskAdd,
    WorkPlanTaskResponse,
    WorkPlanUpdate,
    WorkPlanVersionResponse,
)
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


@router.get("/{plan_id}", summary="Detalle: versiones, snapshots, firmantes, eventos")
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
    "/{plan_id}/solicitar-firma",
    summary="draft/rejected → pending_signature",
)
async def request_signature(
    plan_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        row = await svc.request_signatures(
            db, plan_id, requested_by=user_auth.id
        )
        return _plan(svc.plan_to_dict(row))
    except svc.WorkPlanError as e:
        _err(e)


@router.post(
    "/{plan_id}/cancelar-firma",
    summary="pending_signature → draft",
)
async def cancel_signature(
    plan_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        row = await svc.cancel_signature_request(
            db, plan_id, cancelled_by=user_auth.id
        )
        return _plan(svc.plan_to_dict(row))
    except svc.WorkPlanError as e:
        _err(e)


@router.post("/{plan_id}/vista", summary="Registrar evento viewed")
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


@router.post("/{plan_id}/firmar", summary="Firmar versión actual (firmante)")
async def sign(
    plan_id: int,
    data: WorkPlanSignRequest,
    request: Request,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        ip = request.client.host if request.client else None
        ua = request.headers.get("user-agent")
        result = await svc.sign_plan(
            db,
            plan_id,
            data,
            user_id=user_auth.id,
            ip_address=ip,
            user_agent=ua,
        )
        return {
            "workPlan": _plan(result["workPlan"]),
            "signer": WorkPlanSignerResponse(**result["signer"]).model_dump(
                by_alias=True
            ),
            "fullySigned": result["fullySigned"],
        }
    except svc.WorkPlanError as e:
        _err(e)


@router.post("/{plan_id}/rechazar", summary="Rechazar (firmante) → rejected")
async def reject(
    plan_id: int,
    data: WorkPlanRejectRequest,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        result = await svc.reject_plan(
            db, plan_id, data, user_id=user_auth.id
        )
        return {
            "workPlan": _plan(result["workPlan"]),
            "signer": WorkPlanSignerResponse(**result["signer"]).model_dump(
                by_alias=True
            ),
        }
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


# --- Versión: tareas / firmantes ---


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


@router.post(
    "/versiones/{version_id}/firmantes",
    status_code=status.HTTP_201_CREATED,
    summary="Agregar firmante (draft)",
)
async def add_signer(
    version_id: int,
    data: WorkPlanSignerAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        row = await svc.add_signer(
            db, version_id, data, edited_by=user_auth.id
        )
        return WorkPlanSignerResponse(**svc.signer_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.WorkPlanError as e:
        _err(e)


@router.delete(
    "/firmantes/{signer_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar firmante (draft)",
)
async def remove_signer(
    signer_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_PLANIFICACION)),
):
    try:
        await svc.remove_signer(db, signer_id, edited_by=user_auth.id)
    except svc.WorkPlanError as e:
        _err(e)
