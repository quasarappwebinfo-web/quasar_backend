"""
Clientes de obra y documentos.
"""
import uuid as uuid_lib
from datetime import date
from typing import Any, Dict, List, Optional, Tuple

from sqlalchemy.orm import Session, joinedload

from app.models import Document, DocumentType, Obra, ObraClient, Person
from app.schemas import DocumentCreate, DocumentUpdate, ObraClientCreate, ObraClientUpdate
from app.schemas.obras.obra_schema import OBRA_CLIENT_ROLES
from app.services.s3_service import resolve_media_url

MAX_OBRA_DOCUMENTS = 10
MAX_DOCUMENT_BYTES = 25 * 1024 * 1024
_IMAGE_EXTENSIONS = {"jpg", "jpeg", "png", "webp", "heic", "heif", "gif", "bmp"}


class ObraClientNotFoundError(Exception):
    pass


class ObraClientValidationError(Exception):
    pass


class ObraClientConflictError(Exception):
    pass


class DocumentNotFoundError(Exception):
    pass


class DocumentValidationError(Exception):
    pass


class DocumentConflictError(Exception):
    pass


def client_to_dict(row: ObraClient) -> Dict[str, Any]:
    return {
        "id": row.id,
        "obra_id": row.obra_id,
        "person_id": row.person_id,
        "role": row.role,
        "is_primary": row.is_primary,
        "start_date": row.start_date,
        "end_date": row.end_date,
        "person_name": row.person.name if row.person else None,
        "document_number": row.person.document_number if row.person else None,
        "created_at": row.created_at,
    }


def document_to_dict(row: Document) -> Dict[str, Any]:
    return {
        "id": row.id,
        "uuid": row.uuid,
        "obra_id": row.obra_id,
        "document_type_id": row.document_type_id,
        "document_type_name": row.document_type.name if row.document_type else None,
        "name": row.name,
        "description": row.description,
        "file_url": _public_file_url(row.file_url),
        "is_visible_to_client": row.is_visible_to_client,
        "uploaded_by": row.uploaded_by,
        "created_at": row.created_at,
    }


def _load_client(db: Session, client_id: int) -> Optional[ObraClient]:
    return (
        db.query(ObraClient)
        .options(joinedload(ObraClient.person))
        .filter(ObraClient.id == client_id)
        .first()
    )


def _load_document(db: Session, document_id: int) -> Optional[Document]:
    return (
        db.query(Document)
        .options(joinedload(Document.document_type))
        .filter(Document.id == document_id)
        .first()
    )


def _ensure_obra(db: Session, obra_id: int) -> Obra:
    obra = db.query(Obra).filter(Obra.id == obra_id).first()
    if not obra:
        raise ObraClientValidationError(f"No existe obra con ID {obra_id}")
    return obra


def _clear_other_primaries(db: Session, obra_id: int, except_id: Optional[int] = None) -> None:
    q = db.query(ObraClient).filter(
        ObraClient.obra_id == obra_id,
        ObraClient.is_primary == 1,
        ObraClient.end_date.is_(None),
    )
    if except_id is not None:
        q = q.filter(ObraClient.id != except_id)
    for row in q.all():
        row.is_primary = 0


async def add_obra_client(db: Session, data: ObraClientCreate) -> ObraClient:
    _ensure_obra(db, data.obra_id)

    if data.role not in OBRA_CLIENT_ROLES:
        raise ObraClientValidationError(
            f"role inválido '{data.role}'. Valores: {', '.join(OBRA_CLIENT_ROLES)}"
        )

    person = db.query(Person).filter(Person.id == data.person_id).first()
    if not person:
        raise ObraClientValidationError(f"No existe persona con ID {data.person_id}")

    active_same = (
        db.query(ObraClient)
        .filter(
            ObraClient.obra_id == data.obra_id,
            ObraClient.person_id == data.person_id,
            ObraClient.end_date.is_(None),
        )
        .first()
    )
    if active_same:
        raise ObraClientConflictError(
            "Esa persona ya es cliente vigente de esta obra"
        )

    if data.is_primary not in (0, 1):
        raise ObraClientValidationError("is_primary debe ser 0 o 1")

    if data.is_primary == 1:
        _clear_other_primaries(db, data.obra_id)

    row = ObraClient(
        obra_id=data.obra_id,
        person_id=data.person_id,
        role=data.role,
        is_primary=data.is_primary,
        start_date=data.start_date or date.today(),
        end_date=data.end_date,
    )
    db.add(row)
    try:
        db.commit()
        db.refresh(row)
        return _load_client(db, row.id)
    except Exception:
        db.rollback()
        raise


async def list_obra_clients(
    db: Session,
    obra_id: int,
    *,
    current_only: bool = True,
    page: int = 1,
) -> Dict[str, Any]:
    _ensure_obra(db, obra_id)

    limit_per_page = 15
    offset = (page - 1) * limit_per_page
    query = (
        db.query(ObraClient)
        .options(joinedload(ObraClient.person))
        .filter(ObraClient.obra_id == obra_id)
    )
    if current_only:
        query = query.filter(ObraClient.end_date.is_(None))

    total_items = query.count()
    rows = (
        query.order_by(ObraClient.is_primary.desc(), ObraClient.id.desc())
        .offset(offset)
        .limit(limit_per_page)
        .all()
    )
    return {
        "clients": [client_to_dict(c) for c in rows],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def update_obra_client(
    db: Session, client_id: int, data: ObraClientUpdate
) -> ObraClient:
    row = db.query(ObraClient).filter(ObraClient.id == client_id).first()
    if not row:
        raise ObraClientNotFoundError(f"Cliente de obra ID {client_id} no encontrado")

    update_data = data.model_dump(exclude_unset=True)
    if "role" in update_data and update_data["role"] is not None:
        if update_data["role"] not in OBRA_CLIENT_ROLES:
            raise ObraClientValidationError(
                f"role inválido '{update_data['role']}'. "
                f"Valores: {', '.join(OBRA_CLIENT_ROLES)}"
            )
    if "is_primary" in update_data:
        if update_data["is_primary"] not in (0, 1):
            raise ObraClientValidationError("is_primary debe ser 0 o 1")
        if update_data["is_primary"] == 1:
            _clear_other_primaries(db, row.obra_id, except_id=row.id)

    for field, value in update_data.items():
        setattr(row, field, value)

    try:
        db.commit()
        db.refresh(row)
        return _load_client(db, row.id)
    except Exception:
        db.rollback()
        raise


async def close_obra_client(
    db: Session, client_id: int, *, end_date: Optional[date] = None
) -> ObraClient:
    row = db.query(ObraClient).filter(ObraClient.id == client_id).first()
    if not row:
        raise ObraClientNotFoundError(f"Cliente de obra ID {client_id} no encontrado")
    if row.end_date is not None:
        raise ObraClientConflictError("El vínculo de cliente ya está cerrado")

    row.end_date = end_date or date.today()
    row.is_primary = 0
    try:
        db.commit()
        db.refresh(row)
        return _load_client(db, row.id)
    except Exception:
        db.rollback()
        raise


# --- Documentos ---


async def create_document(
    db: Session, data: DocumentCreate, *, uploaded_by: int
) -> Document:
    if not db.query(Obra).filter(Obra.id == data.obra_id).first():
        raise DocumentValidationError(f"No existe obra con ID {data.obra_id}")

    if data.document_type_id is not None:
        doc_type = (
            db.query(DocumentType)
            .filter(DocumentType.id == data.document_type_id)
            .first()
        )
        if not doc_type:
            raise DocumentValidationError(
                f"No existe tipo de documento con ID {data.document_type_id}"
            )
        if doc_type.is_active != 1:
            raise DocumentValidationError("El tipo de documento está inactivo")

    if data.is_visible_to_client not in (0, 1):
        raise DocumentValidationError("is_visible_to_client debe ser 0 o 1")

    doc_uuid = (data.uuid or "").strip() or str(uuid_lib.uuid4())
    if db.query(Document).filter(Document.uuid == doc_uuid).first():
        raise DocumentConflictError(f"Ya existe un documento con uuid='{doc_uuid}'")

    row = Document(
        uuid=doc_uuid,
        obra_id=data.obra_id,
        document_type_id=data.document_type_id,
        name=data.name,
        description=data.description,
        file_url=data.file_url,
        is_visible_to_client=data.is_visible_to_client,
        uploaded_by=uploaded_by,
    )
    db.add(row)
    try:
        db.commit()
        db.refresh(row)
        return _load_document(db, row.id)
    except Exception:
        db.rollback()
        raise


async def get_document(db: Session, document_id: int) -> Document:
    row = _load_document(db, document_id)
    if not row:
        raise DocumentNotFoundError(f"Documento con ID {document_id} no encontrado")
    return row


async def list_documents(
    db: Session,
    *,
    obra_id: Optional[int] = None,
    visible_to_client: Optional[bool] = None,
    page: int = 1,
    search: Optional[str] = None,
) -> Dict[str, Any]:
    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    query = db.query(Document).options(joinedload(Document.document_type))
    if obra_id is not None:
        query = query.filter(Document.obra_id == obra_id)
    if visible_to_client is True:
        query = query.filter(Document.is_visible_to_client == 1)
    elif visible_to_client is False:
        query = query.filter(Document.is_visible_to_client == 0)
    if search:
        query = query.filter(Document.name.ilike(f"%{search.strip()}%"))

    total_items = query.count()
    rows = (
        query.order_by(Document.created_at.desc())
        .offset(offset)
        .limit(limit_per_page)
        .all()
    )
    return {
        "documents": [document_to_dict(d) for d in rows],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def update_document(
    db: Session, document_id: int, data: DocumentUpdate
) -> Document:
    row = db.query(Document).filter(Document.id == document_id).first()
    if not row:
        raise DocumentNotFoundError(f"Documento con ID {document_id} no encontrado")

    update_data = data.model_dump(exclude_unset=True)
    if "is_visible_to_client" in update_data and update_data[
        "is_visible_to_client"
    ] not in (0, 1):
        raise DocumentValidationError("is_visible_to_client debe ser 0 o 1")

    for field, value in update_data.items():
        setattr(row, field, value)

    try:
        db.commit()
        db.refresh(row)
        return _load_document(db, row.id)
    except Exception:
        db.rollback()
        raise


def _public_file_url(stored: Optional[str]) -> Optional[str]:
    if not stored:
        return stored
    if stored.startswith("http"):
        return stored
    return resolve_media_url(stored) or stored


def _file_extension(filename: str) -> str:
    if "." not in filename:
        return ""
    ext = filename.rsplit(".", 1)[-1].lower().strip()
    return ext if 0 < len(ext) <= 10 else ""


def _is_image(filename: str, content_type: Optional[str]) -> bool:
    mime = (content_type or "").split(";", 1)[0].strip().lower()
    if mime.startswith("image/"):
        return True
    return _file_extension(filename) in _IMAGE_EXTENSIONS


def prepare_document_bytes(
    raw: bytes,
    *,
    filename: str,
    content_type: Optional[str],
) -> Tuple[bytes, str, str]:
    """Comprime imágenes al máximo usable. El resto se guarda tal cual."""
    if not raw:
        raise DocumentValidationError("Hay un archivo vacío")
    if len(raw) > MAX_DOCUMENT_BYTES:
        raise DocumentValidationError("Cada archivo puede pesar hasta 25 MB")

    if _is_image(filename, content_type):
        from app.core.images import ImageProcessingError, compress_image_for_upload

        try:
            return compress_image_for_upload(
                raw,
                content_type=content_type,
                max_side=2200,
                target_max_bytes=350_000,
            )
        except ImageProcessingError as exc:
            raise DocumentValidationError(str(exc)) from exc

    mime = (content_type or "").split(";", 1)[0].strip().lower() or "application/octet-stream"
    ext = _file_extension(filename) or "bin"
    return raw, mime, ext


async def upload_obra_documents(
    db: Session,
    *,
    obra_id: int,
    items: List[Tuple[bytes, str, Optional[str], str, Optional[str], int]],
    uploaded_by: int,
) -> List[Dict[str, Any]]:
    """items: (bytes, filename, content_type, name, description, visible)."""
    from app.services.s3_service import (
        S3ConfigError,
        S3UploadError,
        build_object_key,
        delete_object,
        upload_bytes,
    )

    if not db.query(Obra).filter(Obra.id == obra_id).first():
        raise DocumentValidationError(f"No existe obra con ID {obra_id}")
    if not items:
        raise DocumentValidationError("Elige al menos un archivo")
    if len(items) > MAX_OBRA_DOCUMENTS:
        raise DocumentValidationError(
            "Puedes subir hasta 10 archivos, de 25 MB cada uno"
        )

    prepared: List[Tuple[bytes, str, str, str, Optional[str], int]] = []
    for raw, filename, content_type, name, description, visible in items:
        clean_name = (name or "").strip()
        if not clean_name:
            raise DocumentValidationError("Cada archivo necesita un nombre")
        if visible not in (0, 1):
            raise DocumentValidationError("La visibilidad debe ser 0 o 1")
        data, mime, ext = prepare_document_bytes(
            raw, filename=filename or clean_name, content_type=content_type
        )
        text = (description or "").strip() or None
        prepared.append((data, mime, ext, clean_name[:255], text, visible))

    keys: List[str] = []
    try:
        rows: List[Document] = []
        for data, mime, ext, name, description, visible in prepared:
            key = build_object_key(
                "obras",
                str(obra_id),
                "documentos",
                f"{uuid_lib.uuid4().hex}.{ext}",
            )
            try:
                upload_bytes(key=key, data=data, content_type=mime)
            except (S3ConfigError, S3UploadError) as exc:
                raise DocumentValidationError(str(exc)) from exc
            keys.append(key)
            rows.append(
                Document(
                    uuid=str(uuid_lib.uuid4()),
                    obra_id=obra_id,
                    document_type_id=None,
                    name=name,
                    description=description,
                    file_url=key,
                    is_visible_to_client=visible,
                    uploaded_by=uploaded_by,
                )
            )
        db.add_all(rows)
        db.commit()
        loaded = [_load_document(db, row.id) for row in rows]
        return [document_to_dict(row) for row in loaded if row]
    except Exception:
        db.rollback()
        for key in keys:
            delete_object(key)
        raise
