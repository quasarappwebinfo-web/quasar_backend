"""
CRUD genérico para catálogos maestros (Fase 2).
"""
from __future__ import annotations

from typing import Any, Callable, Dict, List, Optional, Sequence, Type

from pydantic import BaseModel
from sqlalchemy.orm import Session


class CatalogAlreadyExistsError(Exception):
    pass


class CatalogNotFoundError(Exception):
    pass


class CatalogValidationError(Exception):
    pass


def _row_to_dict(row: Any, fields: Sequence[str]) -> Dict[str, Any]:
    data: Dict[str, Any] = {"id": row.id}
    for field in fields:
        data[field] = getattr(row, field)
    return data


def create_catalog_item(
    db: Session,
    *,
    model: Type[Any],
    data: BaseModel,
    fields: Sequence[str],
    unique_fields: Sequence[str] = ("name",),
    label: str = "registro",
    before_create: Optional[Callable[[Session, Dict[str, Any]], None]] = None,
) -> Any:
    payload = data.model_dump()
    for uf in unique_fields:
        value = payload.get(uf)
        if value is None:
            continue
        exists = db.query(model).filter(getattr(model, uf) == value).first()
        if exists:
            raise CatalogAlreadyExistsError(
                f"Ya existe un {label} con {uf}='{value}'"
            )

    if before_create:
        before_create(db, payload)

    row = model(**payload, is_active=1)
    db.add(row)
    try:
        db.commit()
        db.refresh(row)
        return row
    except Exception:
        db.rollback()
        raise


def get_catalog_item(
    db: Session,
    *,
    model: Type[Any],
    item_id: int,
    label: str = "registro",
) -> Any:
    row = db.query(model).filter(model.id == item_id).first()
    if not row:
        raise CatalogNotFoundError(f"{label.capitalize()} con ID {item_id} no encontrado")
    return row


def list_catalog_items(
    db: Session,
    *,
    model: Type[Any],
    fields: Sequence[str],
    collection_key: str,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
    search_fields: Sequence[str] = ("name",),
    order_by: str = "name",
    extra_filters: Optional[Callable[[Any], Any]] = None,
) -> Dict[str, Any]:
    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    query = db.query(model)
    if active_only and hasattr(model, "is_active"):
        query = query.filter(model.is_active == 1)
    if search:
        term = f"%{search.strip()}%"
        from sqlalchemy import or_

        clauses = [
            getattr(model, sf).ilike(term)
            for sf in search_fields
            if hasattr(model, sf)
        ]
        if clauses:
            query = query.filter(or_(*clauses))
    if extra_filters:
        query = extra_filters(query)

    total_items = query.count()
    order_col = getattr(model, order_by, getattr(model, "id"))
    rows = query.order_by(order_col.asc()).offset(offset).limit(limit_per_page).all()

    return {
        collection_key: [_row_to_dict(r, fields) for r in rows],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


def update_catalog_item(
    db: Session,
    *,
    model: Type[Any],
    item_id: int,
    data: BaseModel,
    fields: Sequence[str],
    unique_fields: Sequence[str] = ("name",),
    label: str = "registro",
    before_update: Optional[Callable[[Session, Any, Dict[str, Any]], None]] = None,
) -> Any:
    row = get_catalog_item(db, model=model, item_id=item_id, label=label)
    update_data = data.model_dump(exclude_unset=True)

    if "is_active" in update_data and update_data["is_active"] not in (1, 2):
        raise CatalogValidationError("is_active debe ser 1 (activo) o 2 (inactivo)")

    for uf in unique_fields:
        if uf in update_data and update_data[uf] is not None:
            new_val = update_data[uf]
            if getattr(row, uf) != new_val:
                conflict = (
                    db.query(model)
                    .filter(getattr(model, uf) == new_val, model.id != item_id)
                    .first()
                )
                if conflict:
                    raise CatalogAlreadyExistsError(
                        f"Ya existe un {label} con {uf}='{new_val}'"
                    )

    if before_update:
        before_update(db, row, update_data)

    for field, value in update_data.items():
        setattr(row, field, value)

    try:
        db.commit()
        db.refresh(row)
        return row
    except Exception:
        db.rollback()
        raise


def catalog_to_dict(row: Any, fields: Sequence[str]) -> Dict[str, Any]:
    return _row_to_dict(row, fields)


def list_active_options(
    db: Session,
    *,
    model: Type[Any],
    label_field: str = "name",
    extra_fields: Optional[Sequence[str]] = None,
    order_by: str = "name",
) -> List[Dict[str, Any]]:
    query = db.query(model).filter(model.is_active == 1)
    order_col = getattr(model, order_by, getattr(model, "id"))
    rows = query.order_by(order_col.asc()).all()
    result = []
    for row in rows:
        item = {"id": row.id, label_field: getattr(row, label_field)}
        if extra_fields:
            for ef in extra_fields:
                item[ef] = getattr(row, ef)
        result.append(item)
    return result
