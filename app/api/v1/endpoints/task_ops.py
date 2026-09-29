"""
Endpoints operación — tareas en obra /api/v1/operacion/tareas
"""
from datetime import date
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

from app.core.permissions import PERMISSION_TAREAS
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import (
    TaskActivityItem,
    TaskAssignmentAdd,
    TaskAssignmentResponse,
    TaskCommentAdd,
    TaskCommentResponse,
    TaskCommentUpdate,
    TaskCreateFromTemplate,
    TaskCreateManual,
    TaskCrewAssignmentAdd,
    TaskCrewAssignmentResponse,
    TaskDelayEventAdd,
    TaskDelayEventResponse,
    TaskDependencyAdd,
    TaskDependencyOverrideAdd,
    TaskDependencyOverrideResponse,
    TaskDependencyResponse,
    TaskDocumentResponse,
    TaskMarkDelayedRequest,
    TaskPhotoResponse,
    TaskRescheduleAdd,
    TaskRescheduleResponse,
    TaskResponse,
    TaskStatusChange,
    TaskStatusChangeResult,
    TaskStatusHistoryResponse,
    TaskUpdate,
)
from app.services import task_service as svc

router = APIRouter(prefix="/api/v1/operacion/tareas", tags=["tareas"])


def _err(exc: Exception):
    if isinstance(exc, svc.TaskOpNotFoundError):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc))
    if isinstance(exc, svc.TaskOpConflictError):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc))
    if isinstance(exc, svc.TaskOpBlockedError):
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail={
                "message": str(exc),
                "blocked": True,
                "blockingDependencies": exc.blocking,
            },
        )
    if isinstance(exc, svc.TaskOpValidationError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))
    raise exc


def _task(d: dict) -> dict:
    return TaskResponse(**d).model_dump(by_alias=True)


# ---------- Listados / board ----------


@router.get("", summary="Listar tareas")
async def list_tasks(
    page: int = Query(1, ge=1),
    obra_id: Optional[int] = Query(None, alias="obraId"),
    status_filter: Optional[str] = Query(None, alias="status"),
    category_id: Optional[int] = Query(None, alias="categoryId"),
    search: Optional[str] = None,
    date_from: Optional[date] = Query(None, alias="dateFrom"),
    date_to: Optional[date] = Query(None, alias="dateTo"),
    parent_only: bool = Query(True, alias="parentOnly"),
    parent_task_id: Optional[int] = Query(None, alias="parentTaskId"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        result = await svc.list_tasks(
            db,
            page=page,
            obra_id=obra_id,
            status=status_filter,
            category_id=category_id,
            search=search,
            date_from=date_from,
            date_to=date_to,
            parent_only=parent_only,
            parent_task_id=parent_task_id,
        )
        return {
            "tasks": [_task(t) for t in result["tasks"]],
            "pagination": result["pagination"],
        }
    except svc.TaskOpError as e:
        _err(e)


@router.get("/tablero", summary="Kanban por obra (columnas de status)")
async def board(
    obra_id: int = Query(..., alias="obraId"),
    category_id: Optional[int] = Query(None, alias="categoryId"),
    date_from: Optional[date] = Query(None, alias="dateFrom"),
    date_to: Optional[date] = Query(None, alias="dateTo"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        result = await svc.list_board(
            db,
            obra_id=obra_id,
            category_id=category_id,
            date_from=date_from,
            date_to=date_to,
        )
        return {
            "obraId": result["obraId"],
            "counts": result["counts"],
            "columns": {
                "scheduled": [_task(t) for t in result["columns"]["scheduled"]],
                "inProgress": [_task(t) for t in result["columns"]["inProgress"]],
                "completed": [_task(t) for t in result["columns"]["completed"]],
                "verified": [_task(t) for t in result["columns"]["verified"]],
                "rescheduled": [_task(t) for t in result["columns"]["rescheduled"]],
            },
        }
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/desde-plantilla",
    status_code=status.HTTP_201_CREATED,
    summary="Crear tarea desde versión published del Task Pool",
)
async def create_from_template(
    data: TaskCreateFromTemplate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        row = await svc.create_task_from_template(
            db, data, created_by=user_auth.id
        )
        return _task(svc.task_to_dict(row))
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "",
    status_code=status.HTTP_201_CREATED,
    summary="Crear tarea manual o subtarea",
)
async def create_manual(
    data: TaskCreateManual,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        row = await svc.create_task_manual(db, data, created_by=user_auth.id)
        return _task(svc.task_to_dict(row))
    except svc.TaskOpError as e:
        _err(e)


@router.get("/{task_id}", summary="Detalle completo de tarea")
async def get_task_detail(
    task_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        detail = await svc.get_task_detail(db, task_id)
        return {
            "task": _task(detail["task"]),
            "subtasks": [_task(t) for t in detail["subtasks"]],
            "dependencies": [
                TaskDependencyResponse(**d).model_dump(by_alias=True)
                for d in detail["dependencies"]
            ],
            "overrides": [
                TaskDependencyOverrideResponse(**o).model_dump(by_alias=True)
                for o in detail["overrides"]
            ],
            "assignments": {
                "workers": [
                    TaskAssignmentResponse(**w).model_dump(by_alias=True)
                    for w in detail["assignments"]["workers"]
                ],
                "crews": [
                    TaskCrewAssignmentResponse(**c).model_dump(by_alias=True)
                    for c in detail["assignments"]["crews"]
                ],
            },
            "statusHistory": [
                TaskStatusHistoryResponse(**h).model_dump(by_alias=True)
                for h in detail["statusHistory"]
            ],
            "reschedules": [
                TaskRescheduleResponse(**r).model_dump(by_alias=True)
                for r in detail["reschedules"]
            ],
            "delays": [
                TaskDelayEventResponse(**d).model_dump(by_alias=True)
                for d in detail["delays"]
            ],
            "comments": [
                TaskCommentResponse(**c).model_dump(by_alias=True)
                for c in detail["comments"]
            ],
            "photos": [
                TaskPhotoResponse(**p).model_dump(by_alias=True)
                for p in detail["photos"]
            ],
            "documents": [
                TaskDocumentResponse(**d).model_dump(by_alias=True)
                for d in detail["documents"]
            ],
            "activity": [
                TaskActivityItem(**a).model_dump(by_alias=True)
                for a in detail["activity"]
            ],
        }
    except svc.TaskOpError as e:
        _err(e)


@router.put("/{task_id}", summary="Actualizar cabecera de tarea")
async def update_task(
    task_id: int,
    data: TaskUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        row = await svc.update_task(
            db, task_id, data, updated_by=user_auth.id
        )
        return _task(svc.task_to_dict(row))
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/estado",
    summary="Cambiar status (con chequeo de deps al iniciar)",
)
async def change_status(
    task_id: int,
    data: TaskStatusChange,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        result = await svc.change_task_status(
            db, task_id, data, changed_by=user_auth.id
        )
        return TaskStatusChangeResult(
            task=TaskResponse(**result["task"]),
            blocked=result["blocked"],
            blocking_dependencies=result["blocking_dependencies"],
            forced=result["forced"],
        ).model_dump(by_alias=True)
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/reprogramar",
    summary="Reprogramar fechas (historial + status rescheduled)",
)
async def reschedule(
    task_id: int,
    data: TaskRescheduleAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        from sqlalchemy.orm import joinedload

        from app.models import TaskReschedule

        task, entry = await svc.reschedule_task(
            db, task_id, data, rescheduled_by=user_auth.id
        )
        entry = (
            db.query(TaskReschedule)
            .options(joinedload(TaskReschedule.reason_ref))
            .filter(TaskReschedule.id == entry.id)
            .first()
        )
        return {
            "task": _task(svc.task_to_dict(task)),
            "reschedule": TaskRescheduleResponse(
                **svc.reschedule_to_dict(entry)
            ).model_dump(by_alias=True),
        }
    except svc.TaskOpError as e:
        _err(e)


# ---------- Dependencias ----------


@router.get("/{task_id}/dependencias", summary="Listar dependencias")
async def list_deps(
    task_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        rows = await svc.list_dependencies(db, task_id)
        return {
            "dependencies": [
                TaskDependencyResponse(**d).model_dump(by_alias=True) for d in rows
            ]
        }
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/dependencias",
    status_code=status.HTTP_201_CREATED,
    summary="Agregar dependencia manual",
)
async def add_dep(
    task_id: int,
    data: TaskDependencyAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        row = await svc.add_dependency(db, task_id, data)
        return TaskDependencyResponse(**svc.dependency_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskOpError as e:
        _err(e)


@router.delete(
    "/dependencias/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar dependencia",
)
async def delete_dep(
    item_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        await svc.delete_dependency(db, item_id)
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/overrides-dependencia",
    status_code=status.HTTP_201_CREATED,
    summary="Override local de dependencia de plantilla (waive|relax)",
)
async def add_override(
    task_id: int,
    data: TaskDependencyOverrideAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        row = await svc.add_dependency_override(
            db, task_id, data, created_by=user_auth.id
        )
        return TaskDependencyOverrideResponse(**svc.override_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskOpError as e:
        _err(e)


# ---------- Asignaciones ----------


@router.get("/{task_id}/asignaciones", summary="Trabajadores y cuadrillas asignados")
async def list_asg(
    task_id: int,
    current_only: bool = Query(True, alias="currentOnly"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        result = await svc.list_assignments(
            db, task_id, current_only=current_only
        )
        return {
            "workers": [
                TaskAssignmentResponse(**w).model_dump(by_alias=True)
                for w in result["workers"]
            ],
            "crews": [
                TaskCrewAssignmentResponse(**c).model_dump(by_alias=True)
                for c in result["crews"]
            ],
        }
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/asignaciones/trabajadores",
    status_code=status.HTTP_201_CREATED,
    summary="Asignar trabajador",
)
async def assign_worker(
    task_id: int,
    data: TaskAssignmentAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        row = await svc.assign_worker(
            db, task_id, data, assigned_by=user_auth.id
        )
        return TaskAssignmentResponse(**svc.assignment_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskOpError as e:
        _err(e)


@router.delete(
    "/asignaciones/trabajadores/{assignment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar trabajador (soft)",
)
async def remove_worker(
    assignment_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        await svc.remove_worker_assignment(
            db, assignment_id, removed_by=user_auth.id
        )
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/asignaciones/cuadrillas",
    status_code=status.HTTP_201_CREATED,
    summary="[DEPRECATED] Asignar cuadrilla — preferir gente-día",
    deprecated=True,
)
async def assign_crew(
    task_id: int,
    data: TaskCrewAssignmentAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        row = await svc.assign_crew(
            db, task_id, data, assigned_by=user_auth.id
        )
        return TaskCrewAssignmentResponse(
            **svc.crew_assignment_to_dict(row)
        ).model_dump(by_alias=True)
    except svc.TaskOpError as e:
        _err(e)


@router.delete(
    "/asignaciones/cuadrillas/{assignment_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar cuadrilla (soft)",
)
async def remove_crew(
    assignment_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        await svc.remove_crew_assignment(
            db, assignment_id, removed_by=user_auth.id
        )
    except svc.TaskOpError as e:
        _err(e)


# ---------- Retrasos / evidencias ----------


@router.post(
    "/{task_id}/retrasos",
    status_code=status.HTTP_201_CREATED,
    summary="Registrar retraso",
)
async def add_delay(
    task_id: int,
    data: TaskDelayEventAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        row = await svc.add_delay_event(
            db, task_id, data, created_by=user_auth.id
        )
        return TaskDelayEventResponse(**svc.delay_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/comentarios",
    status_code=status.HTTP_201_CREATED,
    summary="Agregar comentario o instrucción",
)
async def add_comment(
    task_id: int,
    data: TaskCommentAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        row = await svc.add_comment(db, task_id, data, user_id=user_auth.id)
        return TaskCommentResponse(**svc.comment_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskOpError as e:
        _err(e)


@router.put(
    "/comentarios/{comment_id}",
    summary="Editar comentario",
)
async def update_comment(
    comment_id: int,
    data: TaskCommentUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        row = await svc.update_comment(db, comment_id, data)
        return TaskCommentResponse(**svc.comment_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/fotos",
    status_code=status.HTTP_201_CREATED,
    summary="Subir foto de evidencia (multipart)",
)
async def upload_photo(
    task_id: int,
    file: UploadFile = File(...),
    description: Optional[str] = Form(None),
    uuid: Optional[str] = Form(None),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        raw = await file.read()
        row = await svc.upload_task_photo(
            db,
            task_id,
            raw_bytes=raw,
            content_type=file.content_type,
            description=description,
            taken_at=None,
            uploaded_by=user_auth.id,
            uuid=uuid,
        )
        return TaskPhotoResponse(**svc.photo_to_dict(row)).model_dump(by_alias=True)
    except svc.TaskOpError as e:
        _err(e)


@router.delete(
    "/fotos/{photo_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Eliminar foto",
)
async def delete_photo(
    photo_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        await svc.delete_photo(db, photo_id)
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/documentos",
    status_code=status.HTTP_201_CREATED,
    summary="Subir documento/adjunto (PDF, plano, etc.)",
)
async def upload_document(
    task_id: int,
    file: UploadFile = File(...),
    description: Optional[str] = Form(None),
    uuid: Optional[str] = Form(None),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        raw = await file.read()
        row = await svc.upload_task_document(
            db,
            task_id,
            raw_bytes=raw,
            filename=file.filename or "documento",
            content_type=file.content_type,
            description=description,
            uploaded_by=user_auth.id,
            uuid=uuid,
        )
        return TaskDocumentResponse(**svc.document_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskOpError as e:
        _err(e)


@router.delete(
    "/documentos/{document_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Eliminar documento",
)
async def delete_document(
    document_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        await svc.delete_document(db, document_id)
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/subtareas/{subtask_id}/toggle",
    summary="Checkbox subtarea (completed ↔ scheduled)",
)
async def toggle_subtask(
    task_id: int,
    subtask_id: int,
    completed: bool = Query(True),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        row = await svc.toggle_subtask(
            db,
            task_id,
            subtask_id,
            completed=completed,
            changed_by=user_auth.id,
        )
        return _task(svc.task_to_dict(row))
    except svc.TaskOpError as e:
        _err(e)


@router.post(
    "/{task_id}/marcar-retraso",
    summary="Toggle «Marcar como retrasada» (Figma drawer)",
)
async def mark_delayed(
    task_id: int,
    data: TaskMarkDelayedRequest,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    try:
        result = await svc.mark_delayed(
            db,
            task_id,
            delayed=data.delayed,
            delay_reason_id=data.delay_reason_id,
            description=data.description,
            days_lost=data.days_lost,
            created_by=user_auth.id,
        )
        return {
            "task": _task(result["task"]),
            "delays": [
                TaskDelayEventResponse(**d).model_dump(by_alias=True)
                for d in result["delays"]
            ],
        }
    except svc.TaskOpError as e:
        _err(e)


@router.get(
    "/{task_id}/actividad",
    summary="Trazabilidad unificada (quién / cuándo / qué)",
)
async def activity(
    task_id: int,
    limit: int = Query(50, ge=1, le=200),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TAREAS)),
):
    _ = user_auth
    try:
        items = await svc.list_activity(db, task_id, limit=limit)
        return {
            "activity": [
                TaskActivityItem(**a).model_dump(by_alias=True) for a in items
            ]
        }
    except svc.TaskOpError as e:
        _err(e)
