"""
Endpoints sync offline — /api/v1/sync
"""
from datetime import datetime
from typing import Optional

from fastapi import (
    APIRouter,
    Depends,
    File,
    Form,
    HTTPException,
    Query,
    UploadFile,
    status,
)
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_SYNC
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import (
    SyncOpResult,
    SyncPullResponse,
    SyncPushRequest,
    SyncPushResponse,
)
from app.services import sync_service as svc

router = APIRouter(prefix="/api/v1/sync", tags=["sync"])


def _err(exc: Exception):
    if isinstance(exc, svc.SyncValidationError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))
    if isinstance(exc, svc.SyncError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))
    raise exc


def _push(d: dict) -> dict:
    return SyncPushResponse(
        results=[SyncOpResult(**r) for r in d["results"]],
        applied=d["applied"],
        conflicts=d["conflicts"],
        errors=d["errors"],
        needs_upload=d["needs_upload"],
        server_time=d["server_time"],
    ).model_dump(by_alias=True)


def _pull(d: dict) -> dict:
    return SyncPullResponse(**d).model_dump(by_alias=True)


@router.post("/push", summary="Push lote outbox (offline)")
async def sync_push(
    body: SyncPushRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(require_permission(PERMISSION_SYNC)),
):
    """
    Aplica un lote de operaciones de la outbox del cliente.
    Idempotente por `uuid`. Conflictos = server más reciente que `clientUpdatedAt`.
    """
    result = await svc.push_batch(db, body, user_id=current_user.id)
    return _push(result)


@router.get("/pull", summary="Pull cambios desde marca de tiempo")
async def sync_pull(
    since: datetime = Query(
        ...,
        description="ISO-8601; cambios con created/updated >= since",
    ),
    obra_id: Optional[int] = Query(None, alias="obraId"),
    limit_per_entity: int = Query(200, alias="limitPerEntity", ge=1, le=500),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_permission(PERMISSION_SYNC)),
):
    """
    Devuelve deltas de la ola 1: tasks, comments, delays, photos,
    reschedules, statusHistory.
    Guarda `serverTime` de la respuesta como próximo `since`.
    """
    _ = current_user
    result = await svc.pull_changes(
        db,
        since=since,
        obra_id=obra_id,
        limit_per_entity=limit_per_entity,
    )
    return _pull(result)


@router.post("/fotos", summary="Cola de fotos offline (multipart)")
async def sync_upload_foto(
    task_uuid: str = Form(..., alias="taskUuid"),
    photo_uuid: str = Form(..., alias="photoUuid"),
    description: Optional[str] = Form(None),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
    current_user: User = Depends(require_permission(PERMISSION_SYNC)),
):
    """
    Sube el binario de una foto pendiente (`needs_upload` en push).
    Comprime en servidor y guarda con el `photoUuid` del cliente.
    """
    try:
        raw = await file.read()
        result = await svc.sync_upload_photo(
            db,
            task_uuid=task_uuid,
            photo_uuid=photo_uuid,
            raw_bytes=raw,
            content_type=file.content_type,
            description=description,
            uploaded_by=current_user.id,
        )
        return {
            "status": result["status"],
            "photo": result["photo"],
        }
    except Exception as e:
        _err(e)
