from datetime import date
from typing import List, Optional

from fastapi import APIRouter, Depends, File, Form, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session

from app.core.permissions import PERMISSION_OBRAS
from app.api.deps import get_db, require_permission
from app.models import User
from app.schemas import (
    DocumentAdd,
    DocumentCreate,
    DocumentResponse,
    DocumentUpdate,
    ObraClientAdd,
    ObraClientCreate,
    ObraClientResponse,
    ObraClientUpdate,
    ObraCreate,
    ObraResponse,
    ObraStageChange,
    ObraStageHistoryResponse,
    ObraUpdate,
)
from app.services.obra_client_document_service import (
    DocumentConflictError,
    DocumentNotFoundError,
    DocumentValidationError,
    ObraClientConflictError,
    ObraClientNotFoundError,
    ObraClientValidationError,
    add_obra_client,
    client_to_dict,
    close_obra_client,
    create_document,
    document_to_dict,
    upload_obra_documents,
    get_document,
    list_documents,
    list_obra_clients,
    update_document,
    update_obra_client,
)
from app.services.obra_service import (
    ObraAlreadyExistsError,
    ObraForbiddenError,
    ObraNotFoundError,
    ObraValidationError,
    change_obra_stage,
    create_obra,
    delete_obra_cover_image,
    get_obra,
    list_obra_stage_history,
    list_obras,
    obra_to_dict,
    set_obra_cover_image,
    update_obra,
)

router = APIRouter(prefix="/api/v1/obras", tags=["obras"])


# --- Colección ---


@router.get("", summary="Listar obras")
async def list_obras_endpoint(
    page: int = Query(1, ge=1),
    search: Optional[str] = Query(None, description="Nombre o código"),
    status_filter: Optional[str] = Query(
        None,
        alias="status",
        description="planning|in_progress|on_hold|completed|cancelled",
    ),
    city: Optional[str] = Query(None),
    current_stage_id: Optional[int] = Query(None),
    active_only: bool = Query(False),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    result = await list_obras(
        db=db,
        page=page,
        search=search,
        status=status_filter,
        city=city,
        current_stage_id=current_stage_id,
        active_only=active_only,
    )
    return {
        "obras": [ObraResponse(**o).model_dump(by_alias=True) for o in result["obras"]],
        "pagination": result["pagination"],
    }


@router.post(
    "",
    summary="Crear obra",
    description=(
        "Cliente no es obligatorio. status por defecto: planning. "
        "Copia a la obra las actividades del catálogo marcadas como fijas. "
        "El super admin puede marcar capítulos completados o a medias."
    ),
    status_code=status.HTTP_201_CREATED,
)
async def create_obra_endpoint(
    data: ObraCreate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    try:
        obra = await create_obra(db=db, data=data, created_by=user_auth.id, actor=user_auth)
        return ObraResponse(**obra_to_dict(obra)).model_dump(by_alias=True)
    except ObraAlreadyExistsError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except ObraForbiddenError as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))
    except ObraValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


# Rutas estáticas ANTES de /{obra_id}


@router.put(
    "/clientes/{client_id}",
    summary="Actualizar cliente de obra",
    tags=["obras-clientes"],
)
async def update_client_endpoint(
    client_id: int,
    data: ObraClientUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    try:
        row = await update_obra_client(db=db, client_id=client_id, data=data)
        return ObraClientResponse(**client_to_dict(row)).model_dump(by_alias=True)
    except ObraClientNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except ObraClientValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.put(
    "/clientes/{client_id}/cerrar",
    summary="Cerrar vínculo cliente (endDate)",
    tags=["obras-clientes"],
)
async def close_client_endpoint(
    client_id: int,
    end_date: Optional[date] = Query(None),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    try:
        row = await close_obra_client(db=db, client_id=client_id, end_date=end_date)
        return ObraClientResponse(**client_to_dict(row)).model_dump(by_alias=True)
    except ObraClientNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except ObraClientConflictError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))


@router.get(
    "/documentos/{document_id}",
    summary="Obtener documento",
    tags=["obras-documentos"],
)
async def get_document_endpoint(
    document_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    try:
        row = await get_document(db=db, document_id=document_id)
        return DocumentResponse(**document_to_dict(row)).model_dump(by_alias=True)
    except DocumentNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.put(
    "/documentos/{document_id}",
    summary="Actualizar documento",
    tags=["obras-documentos"],
)
async def update_document_endpoint(
    document_id: int,
    data: DocumentUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    try:
        row = await update_document(db=db, document_id=document_id, data=data)
        return DocumentResponse(**document_to_dict(row)).model_dump(by_alias=True)
    except DocumentNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except DocumentValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


# --- Por obra ---


@router.get("/{obra_id}", summary="Obtener obra")
async def get_obra_endpoint(
    obra_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    try:
        obra = await get_obra(db=db, obra_id=obra_id)
        return ObraResponse(**obra_to_dict(obra)).model_dump(by_alias=True)
    except ObraNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.put(
    "/{obra_id}",
    summary="Actualizar obra",
    description="No cambia etapa (usar PUT .../etapa). Dar de baja o reactivar exige super admin.",
)
async def update_obra_endpoint(
    obra_id: int,
    data: ObraUpdate,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    try:
        obra = await update_obra(
            db=db, obra_id=obra_id, data=data, actor=user_auth
        )
        return ObraResponse(**obra_to_dict(obra)).model_dump(by_alias=True)
    except ObraNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except ObraForbiddenError as e:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail=str(e))
    except ObraAlreadyExistsError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except ObraValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.put(
    "/{obra_id}/imagen-principal",
    summary="Subir / reemplazar imagen principal de la obra",
    description=(
        "Multipart field `file`. Se comprime a WebP (~250KB), se sube a S3 "
        "en obras/{id}/cover/ y se guarda en la obra. "
        "Flujo: crear obra → subir imagen (o reemplazar al editar)."
    ),
)
async def upload_cover_image_endpoint(
    obra_id: int,
    file: UploadFile = File(..., description="JPEG, PNG o WebP"),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    raw = await file.read()
    if len(raw) > 15 * 1024 * 1024:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="La imagen no puede superar 15 MB",
        )
    try:
        obra = await set_obra_cover_image(
            db=db,
            obra_id=obra_id,
            raw_bytes=raw,
            content_type=file.content_type,
        )
        return ObraResponse(**obra_to_dict(obra)).model_dump(by_alias=True)
    except ObraNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except ObraValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.delete(
    "/{obra_id}/imagen-principal",
    summary="Quitar imagen principal de la obra",
)
async def delete_cover_image_endpoint(
    obra_id: int,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    try:
        obra = await delete_obra_cover_image(db=db, obra_id=obra_id)
        return ObraResponse(**obra_to_dict(obra)).model_dump(by_alias=True)
    except ObraNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.put(
    "/{obra_id}/etapa",
    summary="Cambiar etapa actual",
    description="Actualiza currentStageId y registra en obra_stage_history.",
)
async def change_stage_endpoint(
    obra_id: int,
    data: ObraStageChange,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    try:
        obra = await change_obra_stage(db=db, obra_id=obra_id, data=data)
        return ObraResponse(**obra_to_dict(obra)).model_dump(by_alias=True)
    except ObraNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
    except ObraValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get(
    "/{obra_id}/etapas-historial",
    summary="Historial de etapas de la obra",
)
async def list_stage_history_endpoint(
    obra_id: int,
    page: int = Query(1, ge=1),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    try:
        result = await list_obra_stage_history(db=db, obra_id=obra_id, page=page)
        return {
            "history": [
                ObraStageHistoryResponse(**h).model_dump(by_alias=True)
                for h in result["history"]
            ],
            "pagination": result["pagination"],
        }
    except ObraNotFoundError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.get(
    "/{obra_id}/clientes",
    summary="Listar clientes de la obra",
    tags=["obras-clientes"],
)
async def list_clients_endpoint(
    obra_id: int,
    page: int = Query(1, ge=1),
    current_only: bool = Query(True),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    try:
        result = await list_obra_clients(
            db=db, obra_id=obra_id, current_only=current_only, page=page
        )
        return {
            "clients": [
                ObraClientResponse(**c).model_dump(by_alias=True)
                for c in result["clients"]
            ],
            "pagination": result["pagination"],
        }
    except ObraClientValidationError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))


@router.post(
    "/{obra_id}/clientes",
    summary="Asociar cliente a la obra",
    tags=["obras-clientes"],
    status_code=status.HTTP_201_CREATED,
)
async def add_client_endpoint(
    obra_id: int,
    data: ObraClientAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    payload = ObraClientCreate(
        obra_id=obra_id,
        person_id=data.person_id,
        role=data.role,
        is_primary=data.is_primary,
        start_date=data.start_date,
    )
    try:
        row = await add_obra_client(db=db, data=payload)
        return ObraClientResponse(**client_to_dict(row)).model_dump(by_alias=True)
    except ObraClientConflictError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except ObraClientValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.get(
    "/{obra_id}/documentos",
    summary="Listar documentos de la obra",
    tags=["obras-documentos"],
)
async def list_obra_documents_endpoint(
    obra_id: int,
    page: int = Query(1, ge=1),
    search: Optional[str] = Query(None),
    visible_to_client: Optional[bool] = Query(None),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    _ = user_auth
    result = await list_documents(
        db=db,
        obra_id=obra_id,
        visible_to_client=visible_to_client,
        page=page,
        search=search,
    )
    return {
        "documents": [
            DocumentResponse(**d).model_dump(by_alias=True)
            for d in result["documents"]
        ],
        "pagination": result["pagination"],
    }


@router.post(
    "/{obra_id}/documentos/archivos",
    summary="Subir archivos de la obra a S3",
    description="Hasta 10 archivos, de 25 MB cada uno. Las imágenes se comprimen.",
    tags=["obras-documentos"],
    status_code=status.HTTP_201_CREATED,
)
async def upload_obra_documents_endpoint(
    obra_id: int,
    files: List[UploadFile] = File(...),
    names: List[str] = Form(...),
    descriptions: List[str] = Form(...),
    visibles: List[int] = Form(...),
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    if len(files) != len(names):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cada archivo necesita su nombre",
        )
    if len(descriptions) != len(files) or len(visibles) != len(files):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Cada archivo necesita nombre, descripción y visibilidad",
        )
    items = []
    for index, upload in enumerate(files):
        items.append(
            (
                await upload.read(),
                upload.filename or "archivo",
                upload.content_type,
                names[index],
                descriptions[index] if index < len(descriptions) else "",
                visibles[index] if index < len(visibles) else 0,
            )
        )
    try:
        rows = await upload_obra_documents(
            db, obra_id=obra_id, items=items, uploaded_by=user_auth.id
        )
        return {
            "documents": [
                DocumentResponse(**row).model_dump(by_alias=True) for row in rows
            ]
        }
    except DocumentConflictError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except DocumentValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))


@router.post(
    "/{obra_id}/documentos",
    summary="Registrar documento (metadatos + fileUrl)",
    description="Si no envías uuid, el backend genera uno. Storage real más adelante.",
    tags=["obras-documentos"],
    status_code=status.HTTP_201_CREATED,
)
async def add_document_endpoint(
    obra_id: int,
    data: DocumentAdd,
    db: Session = Depends(get_db),
    user_auth: User = Depends(require_permission(PERMISSION_OBRAS)),
):
    payload = DocumentCreate(
        uuid=data.uuid,
        obra_id=obra_id,
        document_type_id=data.document_type_id,
        name=data.name,
        description=data.description,
        file_url=data.file_url,
        is_visible_to_client=data.is_visible_to_client,
    )
    try:
        row = await create_document(db=db, data=payload, uploaded_by=user_auth.id)
        return DocumentResponse(**document_to_dict(row)).model_dump(by_alias=True)
    except DocumentConflictError as e:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail=str(e))
    except DocumentValidationError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
