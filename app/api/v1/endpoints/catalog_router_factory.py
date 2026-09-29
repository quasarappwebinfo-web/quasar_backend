"""
Factory de routers CRUD para catálogos admin (Fase 2).
"""
from typing import Any, Callable, Optional, Type

from fastapi import APIRouter, Depends, HTTPException, Query, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_CATALOGOS
from app.api.deps import get_db, require_permission
from app.models import User
from app.services.catalog_crud import (
    CatalogAlreadyExistsError,
    CatalogNotFoundError,
    CatalogValidationError,
)


def build_catalog_router(
    *,
    prefix: str,
    tags: list[str],
    response_model: Type[BaseModel],
    create_model: Type[BaseModel],
    update_model: Type[BaseModel],
    collection_key: str,
    create_fn: Callable,
    get_fn: Callable,
    list_fn: Callable,
    update_fn: Callable,
    to_dict_fn: Callable,
    entity_summary: str,
    supports_position_filter: bool = False,
) -> APIRouter:
    router = APIRouter(prefix=prefix, tags=tags)

    @router.get(
        "",
        summary=f"Listar {entity_summary}",
    )
    async def list_items(
        page: int = Query(1, ge=1),
        search: Optional[str] = Query(None, description="Búsqueda por texto"),
        active_only: bool = Query(False, description="Solo activos (isActive=1)"),
        worker_position_id: Optional[int] = Query(
            None,
            description="Filtrar por cargo (solo especialidades)",
        ),
        db: Session = Depends(get_db),
        user_auth: User = Depends(require_permission(PERMISSION_CATALOGOS)),
    ):
        _ = user_auth
        kwargs: dict[str, Any] = {
            "db": db,
            "page": page,
            "search": search,
            "active_only": active_only,
        }
        if supports_position_filter:
            kwargs["worker_position_id"] = worker_position_id
        result = await list_fn(**kwargs)
        items = [
            response_model(**item).model_dump(by_alias=True)
            for item in result[collection_key]
        ]
        return {collection_key: items, "pagination": result["pagination"]}

    @router.post(
        "",
        summary=f"Crear {entity_summary}",
        status_code=status.HTTP_201_CREATED,
    )
    async def create_item(
        data: create_model,  # type: ignore[valid-type]
        db: Session = Depends(get_db),
        user_auth: User = Depends(require_permission(PERMISSION_CATALOGOS)),
    ):
        _ = user_auth
        try:
            row = await create_fn(db=db, data=data)
            return response_model(**to_dict_fn(row)).model_dump(by_alias=True)
        except CatalogAlreadyExistsError as e:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
        except CatalogValidationError as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

    @router.get(
        "/{item_id}",
        summary=f"Obtener {entity_summary}",
    )
    async def get_item(
        item_id: int,
        db: Session = Depends(get_db),
        user_auth: User = Depends(require_permission(PERMISSION_CATALOGOS)),
    ):
        _ = user_auth
        try:
            row = await get_fn(db=db, item_id=item_id)
            return response_model(**to_dict_fn(row)).model_dump(by_alias=True)
        except CatalogNotFoundError as e:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))

    @router.put(
        "/{item_id}",
        summary=f"Actualizar {entity_summary}",
        description="Actualización parcial. isActive: 1=activo, 2=inactivo.",
    )
    async def update_item(
        item_id: int,
        data: update_model,  # type: ignore[valid-type]
        db: Session = Depends(get_db),
        user_auth: User = Depends(require_permission(PERMISSION_CATALOGOS)),
    ):
        _ = user_auth
        try:
            row = await update_fn(db=db, item_id=item_id, data=data)
            return response_model(**to_dict_fn(row)).model_dump(by_alias=True)
        except CatalogNotFoundError as e:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
        except CatalogAlreadyExistsError as e:
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
        except CatalogValidationError as e:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

    return router
