"""Fotos sueltas de una obra: no requieren actividad."""
from __future__ import annotations

import uuid as uuid_lib
from typing import Any, Dict, List, Optional, Tuple

from sqlalchemy.orm import Session, joinedload

from app.models import Obra, ObraPhoto, User
from app.services.s3_service import (
    S3ConfigError,
    S3UploadError,
    build_object_key,
    delete_object,
    resolve_media_url,
    upload_bytes,
)
from app.services.task_service import (
    TaskOpNotFoundError,
    TaskOpValidationError,
    _user_display,
)

MAX_OBRA_PHOTOS = 15
MAX_DESCRIPTION = 500


def _clean_description(value: str) -> str:
    text = (value or "").strip()
    if not text:
        raise TaskOpValidationError("Cada foto necesita una descripción")
    if len(text) > MAX_DESCRIPTION:
        raise TaskOpValidationError(
            f"La descripción no puede pasar de {MAX_DESCRIPTION} caracteres"
        )
    return text


def _to_gallery_item(row: ObraPhoto) -> Dict[str, Any]:
    url = row.file_url
    if url and not url.startswith("http"):
        url = resolve_media_url(url) or url
    return {
        "id": row.id,
        "file_url": url,
        "description": row.description,
        "taken_at": None,
        "created_at": row.created_at,
        "uploaded_by_name": _user_display(row.uploaded_by_user),
        "task_id": None,
        "task_name": "Foto de la obra",
        "subtask_name": None,
        "chapter_id": None,
        "chapter_name": None,
        "budget_activity_id": None,
        "budget_activity_name": None,
        "kind": "obra",
    }


def list_gallery_items(db: Session, obra_id: int) -> List[Dict[str, Any]]:
    rows = (
        db.query(ObraPhoto)
        .options(joinedload(ObraPhoto.uploaded_by_user).joinedload(User.person))
        .filter(ObraPhoto.obra_id == obra_id)
        .order_by(ObraPhoto.created_at.desc(), ObraPhoto.id.desc())
        .all()
    )
    return [_to_gallery_item(row) for row in rows]


async def upload_obra_photos(
    db: Session,
    *,
    obra_id: int,
    files: List[Tuple[bytes, Optional[str], str]],
    uploaded_by: int,
) -> List[Dict[str, Any]]:
    from app.core.images import ImageProcessingError, compress_image_for_upload

    obra = db.query(Obra).filter(Obra.id == obra_id).first()
    if not obra:
        raise TaskOpNotFoundError(f"Obra {obra_id} no encontrada")
    if not files:
        raise TaskOpValidationError("Agrega al menos una foto")
    if len(files) > MAX_OBRA_PHOTOS:
        raise TaskOpValidationError(
            f"Puedes subir hasta {MAX_OBRA_PHOTOS} fotos a la vez"
        )

    prepared: List[Tuple[bytes, str, str, str]] = []
    for raw, content_type, description in files:
        text = _clean_description(description)
        try:
            compressed, mime, ext = compress_image_for_upload(
                raw, content_type=content_type
            )
        except ImageProcessingError as e:
            raise TaskOpValidationError(str(e)) from e
        prepared.append((compressed, mime, ext, text))

    keys: List[str] = []
    try:
        rows: List[ObraPhoto] = []
        for data, mime, ext, description in prepared:
            key = build_object_key(
                "obras",
                str(obra_id),
                "fotos",
                f"{uuid_lib.uuid4().hex}.{ext}",
            )
            try:
                upload_bytes(key=key, data=data, content_type=mime)
            except (S3ConfigError, S3UploadError) as e:
                raise TaskOpValidationError(str(e)) from e
            keys.append(key)
            rows.append(
                ObraPhoto(
                    uuid=str(uuid_lib.uuid4()),
                    obra_id=obra_id,
                    file_url=key,
                    description=description,
                    uploaded_by=uploaded_by,
                )
            )
        db.add_all(rows)
        db.commit()
    except Exception:
        db.rollback()
        for key in keys:
            delete_object(key)
        raise

    created_ids = [row.id for row in rows]
    fresh = (
        db.query(ObraPhoto)
        .options(joinedload(ObraPhoto.uploaded_by_user).joinedload(User.person))
        .filter(ObraPhoto.id.in_(created_ids))
        .all()
    )
    by_id = {row.id: row for row in fresh}
    return [_to_gallery_item(by_id[i]) for i in created_ids if i in by_id]
