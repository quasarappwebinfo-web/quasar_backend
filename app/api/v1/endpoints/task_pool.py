"""
Endpoints Task Pool — /api/v1/catalogo/...
"""
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_TASK_POOL
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import (
    TaskBudgetActivityCreate,
    TaskBudgetActivityResponse,
    TaskBudgetActivityUpdate,
    TaskCategoryCreate,
    TaskCategoryResponse,
    TaskCategoryUpdate,
    TaskTemplateCreate,
    TaskTemplateCrewResponse,
    TaskTemplateDependencyAdd,
    TaskTemplateDependencyResponse,
    TaskTemplateMeasurementAdd,
    TaskTemplateMeasurementResponse,
    TaskTemplatePositionAdd,
    TaskTemplatePositionUpdate,
    TaskTemplatePositionResponse,
    TaskTemplateRecommendRequest,
    TaskTemplateRecommendResponse,
    TaskTemplateResponse,
    TaskTemplateSubtaskAdd,
    TaskTemplateSubtaskResponse,
    TaskTemplateSubtaskUpdate,
    TaskTemplateUpdate,
    TaskTemplateVersionCreate,
    TaskTemplateVersionResponse,
    TaskTemplateVersionUpdate,
    TaskZoneCreate,
    TaskZoneResponse,
    TaskZoneUpdate,
)
from app.services import task_pool_service as svc

router = APIRouter(prefix="/api/v1/catalogo", tags=["task-pool"])


def _err(exc: Exception):
    if isinstance(exc, svc.TaskPoolNotFoundError):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(exc))
    if isinstance(exc, svc.TaskPoolConflictError):
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(exc))
    if isinstance(exc, svc.TaskPoolValidationError):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(exc))
    raise exc


# ---------- Categorías ----------


@router.get("/categorias-tarea", summary="Listar categorías del Task Pool")
async def list_categories(
    page: int = Query(1, ge=1),
    search: Optional[str] = None,
    active_only: bool = Query(False),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    result = await svc.list_categories(
        db, page=page, search=search, active_only=active_only
    )
    return {
        "categories": [
            TaskCategoryResponse(**c).model_dump(by_alias=True)
            for c in result["categories"]
        ],
        "pagination": result["pagination"],
    }


@router.post(
    "/categorias-tarea",
    status_code=status.HTTP_201_CREATED,
    summary="Crear categoría",
)
async def create_category(
    data: TaskCategoryCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.create_category(db, data)
        return TaskCategoryResponse(**svc.category_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.get("/categorias-tarea/{item_id}", summary="Obtener categoría")
async def get_category(
    item_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.get_category(db, item_id)
        return TaskCategoryResponse(**svc.category_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.put("/categorias-tarea/{item_id}", summary="Actualizar categoría")
async def update_category(
    item_id: int,
    data: TaskCategoryUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.update_category(db, item_id, data)
        return TaskCategoryResponse(**svc.category_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


# ---------- Zonas ----------


@router.get("/zonas-tarea", summary="Listar zonas del Task Pool")
async def list_zones(
    page: int = Query(1, ge=1),
    search: Optional[str] = None,
    active_only: bool = Query(False),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    result = await svc.list_zones(
        db, page=page, search=search, active_only=active_only
    )
    return {
        "zones": [
            TaskZoneResponse(**z).model_dump(by_alias=True)
            for z in result["zones"]
        ],
        "pagination": result["pagination"],
    }


@router.post(
    "/zonas-tarea",
    status_code=status.HTTP_201_CREATED,
    summary="Crear zona",
)
async def create_zone(
    data: TaskZoneCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.create_zone(db, data)
        return TaskZoneResponse(**svc.zone_to_dict(row)).model_dump(by_alias=True)
    except svc.TaskPoolError as e:
        _err(e)


@router.get("/zonas-tarea/{item_id}", summary="Obtener zona")
async def get_zone(
    item_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.get_zone(db, item_id)
        return TaskZoneResponse(**svc.zone_to_dict(row)).model_dump(by_alias=True)
    except svc.TaskPoolError as e:
        _err(e)


@router.put("/zonas-tarea/{item_id}", summary="Actualizar zona")
async def update_zone(
    item_id: int,
    data: TaskZoneUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.update_zone(db, item_id, data)
        return TaskZoneResponse(**svc.zone_to_dict(row)).model_dump(by_alias=True)
    except svc.TaskPoolError as e:
        _err(e)


# ---------- Actividades presupuestales ----------


@router.get(
    "/actividades-presupuestales",
    summary="Listar actividades presupuestales del Task Pool",
)
async def list_budget_activities(
    page: int = Query(1, ge=1),
    search: Optional[str] = None,
    category_id: Optional[int] = Query(None),
    active_only: bool = Query(False),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    result = await svc.list_budget_activities(
        db,
        page=page,
        search=search,
        category_id=category_id,
        active_only=active_only,
    )
    return {
        "budgetActivities": [
            TaskBudgetActivityResponse(**a).model_dump(by_alias=True)
            for a in result["budgetActivities"]
        ],
        "pagination": result["pagination"],
    }


@router.post(
    "/actividades-presupuestales",
    status_code=status.HTTP_201_CREATED,
    summary="Crear actividad presupuestal",
)
async def create_budget_activity(
    data: TaskBudgetActivityCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.create_budget_activity(db, data)
        return TaskBudgetActivityResponse(
            **svc.budget_activity_to_dict(row)
        ).model_dump(by_alias=True)
    except svc.TaskPoolError as e:
        _err(e)


@router.get(
    "/actividades-presupuestales/{item_id}",
    summary="Obtener actividad presupuestal",
)
async def get_budget_activity(
    item_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.get_budget_activity(db, item_id)
        return TaskBudgetActivityResponse(
            **svc.budget_activity_to_dict(row)
        ).model_dump(by_alias=True)
    except svc.TaskPoolError as e:
        _err(e)


@router.put(
    "/actividades-presupuestales/{item_id}",
    summary="Actualizar actividad presupuestal",
)
async def update_budget_activity(
    item_id: int,
    data: TaskBudgetActivityUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.update_budget_activity(db, item_id, data)
        return TaskBudgetActivityResponse(
            **svc.budget_activity_to_dict(row)
        ).model_dump(by_alias=True)
    except svc.TaskPoolError as e:
        _err(e)


# ---------- Plantillas ----------


@router.get("/plantillas", summary="Listar plantillas")
async def list_templates(
    page: int = Query(1, ge=1),
    search: Optional[str] = None,
    category_id: Optional[int] = Query(None),
    zone_id: Optional[int] = Query(None),
    budget_activity_id: Optional[int] = Query(None),
    active_only: bool = Query(False),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    result = await svc.list_templates(
        db,
        page=page,
        search=search,
        category_id=category_id,
        zone_id=zone_id,
        budget_activity_id=budget_activity_id,
        active_only=active_only,
    )
    return {
        "templates": [
            TaskTemplateResponse(**t).model_dump(by_alias=True)
            for t in result["templates"]
        ],
        "pagination": result["pagination"],
    }


@router.post(
    "/plantillas",
    status_code=status.HTTP_201_CREATED,
    summary="Crear plantilla",
)
async def create_template(
    data: TaskTemplateCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.create_template(db, data)
        return TaskTemplateResponse(**svc.template_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.get("/plantillas/{item_id}", summary="Obtener plantilla")
async def get_template(
    item_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.get_template(db, item_id)
        return TaskTemplateResponse(**svc.template_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.put("/plantillas/{item_id}", summary="Actualizar plantilla")
async def update_template(
    item_id: int,
    data: TaskTemplateUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.update_template(db, item_id, data)
        return TaskTemplateResponse(**svc.template_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


# ---------- Versiones ----------


@router.get("/plantillas-versiones", summary="Listar versiones")
async def list_versions(
    page: int = Query(1, ge=1),
    template_id: Optional[int] = Query(None),
    status_filter: Optional[str] = Query(None, alias="status"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        result = await svc.list_versions(
            db, template_id=template_id, status=status_filter, page=page
        )
        return {
            "versions": [
                TaskTemplateVersionResponse(**v).model_dump(by_alias=True)
                for v in result["versions"]
            ],
            "pagination": result["pagination"],
        }
    except svc.TaskPoolError as e:
        _err(e)


@router.post(
    "/plantillas-versiones",
    status_code=status.HTTP_201_CREATED,
    summary="Crear versión draft",
    description="Siempre nace en draft. Opcional: copyFromVersionId para clonar detalle.",
)
async def create_version(
    data: TaskTemplateVersionCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.create_version(db, data)
        return TaskTemplateVersionResponse(**svc.version_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.get(
    "/plantillas-versiones/{version_id}",
    summary="Obtener versión + detalle completo",
)
async def get_version_detail(
    version_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        detail = await svc.list_version_detail(db, version_id)
        return {
            "version": TaskTemplateVersionResponse(**detail["version"]).model_dump(
                by_alias=True
            ),
            "measurements": [
                TaskTemplateMeasurementResponse(**m).model_dump(by_alias=True)
                for m in detail["measurements"]
            ],
            "positions": [
                TaskTemplatePositionResponse(**p).model_dump(by_alias=True)
                for p in detail["positions"]
            ],
            "subtasks": [
                TaskTemplateSubtaskResponse(**s).model_dump(by_alias=True)
                for s in detail["subtasks"]
            ],
            "dependencies": [
                TaskTemplateDependencyResponse(**d).model_dump(by_alias=True)
                for d in detail["dependencies"]
            ],
            "preferredCrews": [
                TaskTemplateCrewResponse(**c).model_dump(by_alias=True)
                for c in detail["preferredCrews"]
            ],
        }
    except svc.TaskPoolError as e:
        _err(e)


@router.put(
    "/plantillas-versiones/{version_id}",
    summary="Actualizar versión draft",
)
async def update_version(
    version_id: int,
    data: TaskTemplateVersionUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.update_version(db, version_id, data)
        return TaskTemplateVersionResponse(**svc.version_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.post(
    "/plantillas-versiones/{version_id}/publicar",
    summary="Publicar versión (queda inmutable)",
)
async def publish_version(
    version_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.publish_version(db, version_id)
        return TaskTemplateVersionResponse(**svc.version_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.post(
    "/plantillas-versiones/{version_id}/archivar",
    summary="Archivar versión publicada",
)
async def archive_version(
    version_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.archive_version(db, version_id)
        return TaskTemplateVersionResponse(**svc.version_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.post(
    "/plantillas-versiones/{version_id}/recomendar",
    summary="Calcular recomendación de duración y cargos",
    description=(
        "factor = obraQuantity / baseQuantity; "
        "duración por defecto = baseDurationDays × factor. "
        "Opcional targetDurationDays: fija la duración y ajusta cargos. "
        "Solo versiones published."
    ),
)
async def recommend(
    version_id: int,
    data: TaskTemplateRecommendRequest,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        result = await svc.recommend_from_version(
            db,
            version_id,
            obra_quantity=data.obra_quantity,
            target_duration_days=data.target_duration_days,
        )
        return TaskTemplateRecommendResponse(**result).model_dump(by_alias=True)
    except svc.TaskPoolError as e:
        _err(e)


# ---------- Detalle (solo draft) ----------


@router.post(
    "/plantillas-versiones/{version_id}/unidades",
    status_code=status.HTTP_201_CREATED,
    summary="Agregar unidad de medida a versión draft",
)
async def add_measurement(
    version_id: int,
    data: TaskTemplateMeasurementAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.add_measurement(db, version_id, data)
        return TaskTemplateMeasurementResponse(
            **svc.measurement_to_dict(row)
        ).model_dump(by_alias=True)
    except svc.TaskPoolError as e:
        _err(e)


@router.delete(
    "/plantillas-versiones/unidades/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar unidad de versión draft",
)
async def delete_measurement(
    item_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        await svc.delete_measurement(db, item_id)
    except svc.TaskPoolError as e:
        _err(e)


@router.post(
    "/plantillas-versiones/{version_id}/cargos",
    status_code=status.HTTP_201_CREATED,
    summary="Agregar cargo recomendado a versión draft",
)
async def add_position(
    version_id: int,
    data: TaskTemplatePositionAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.add_position(db, version_id, data)
        return TaskTemplatePositionResponse(**svc.position_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.put(
    "/plantillas-versiones/cargos/{item_id}",
    summary="Actualizar cantidad/requerido de cargo en versión draft",
)
async def update_position(
    item_id: int,
    data: TaskTemplatePositionUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.update_position(db, item_id, data)
        return TaskTemplatePositionResponse(**svc.position_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.delete(
    "/plantillas-versiones/cargos/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar cargo de versión draft",
)
async def delete_position(
    item_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        await svc.delete_position(db, item_id)
    except svc.TaskPoolError as e:
        _err(e)


@router.post(
    "/plantillas-versiones/{version_id}/subtareas",
    status_code=status.HTTP_201_CREATED,
    summary="Agregar subtarea estándar",
)
async def add_subtask(
    version_id: int,
    data: TaskTemplateSubtaskAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.add_subtask(db, version_id, data)
        return TaskTemplateSubtaskResponse(**svc.subtask_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.put(
    "/plantillas-versiones/subtareas/{item_id}",
    summary="Actualizar subtarea (draft)",
)
async def update_subtask(
    item_id: int,
    data: TaskTemplateSubtaskUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.update_subtask(db, item_id, data)
        return TaskTemplateSubtaskResponse(**svc.subtask_to_dict(row)).model_dump(
            by_alias=True
        )
    except svc.TaskPoolError as e:
        _err(e)


@router.delete(
    "/plantillas-versiones/subtareas/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar subtarea",
)
async def delete_subtask(
    item_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        await svc.delete_subtask(db, item_id)
    except svc.TaskPoolError as e:
        _err(e)


@router.post(
    "/plantillas-versiones/{version_id}/dependencias",
    status_code=status.HTTP_201_CREATED,
    summary="Agregar dependencia a otra plantilla",
)
async def add_dependency(
    version_id: int,
    data: TaskTemplateDependencyAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        row = await svc.add_dependency(db, version_id, data)
        return TaskTemplateDependencyResponse(
            **svc.dependency_to_dict(row)
        ).model_dump(by_alias=True)
    except svc.TaskPoolError as e:
        _err(e)


@router.delete(
    "/plantillas-versiones/dependencias/{item_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Quitar dependencia",
)
async def delete_dependency(
    item_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_TASK_POOL)),
):
    _ = user_auth
    try:
        await svc.delete_dependency(db, item_id)
    except svc.TaskPoolError as e:
        _err(e)
