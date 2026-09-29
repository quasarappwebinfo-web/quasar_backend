from app.api.v1.endpoints.catalog_router_factory import build_catalog_router
from app.schemas import (
    DocumentTypeCreate,
    DocumentTypeResponse,
    DocumentTypeUpdate,
    ObraSaleTypeCreate,
    ObraSaleTypeResponse,
    ObraSaleTypeUpdate,
    ObraStageCreate,
    ObraStageResponse,
    ObraStageUpdate,
)
from app.services import catalog_services as svc

document_type_router = build_catalog_router(
    prefix="/api/v1/obras/tipos-documento",
    tags=["obras-tipos-documento"],
    response_model=DocumentTypeResponse,
    create_model=DocumentTypeCreate,
    update_model=DocumentTypeUpdate,
    collection_key="documentTypes",
    create_fn=svc.create_document_type,
    get_fn=svc.get_document_type,
    list_fn=svc.list_document_types,
    update_fn=svc.update_document_type,
    to_dict_fn=svc.document_type_to_dict,
    entity_summary="tipos de documento",
)

obra_sale_type_router = build_catalog_router(
    prefix="/api/v1/obras/tipos-venta",
    tags=["obras-tipos-venta"],
    response_model=ObraSaleTypeResponse,
    create_model=ObraSaleTypeCreate,
    update_model=ObraSaleTypeUpdate,
    collection_key="saleTypes",
    create_fn=svc.create_obra_sale_type,
    get_fn=svc.get_obra_sale_type,
    list_fn=svc.list_obra_sale_types,
    update_fn=svc.update_obra_sale_type,
    to_dict_fn=svc.obra_sale_type_to_dict,
    entity_summary="tipos de venta",
)

obra_stage_router = build_catalog_router(
    prefix="/api/v1/obras/etapas",
    tags=["obras-etapas"],
    response_model=ObraStageResponse,
    create_model=ObraStageCreate,
    update_model=ObraStageUpdate,
    collection_key="stages",
    create_fn=svc.create_obra_stage,
    get_fn=svc.get_obra_stage,
    list_fn=svc.list_obra_stages,
    update_fn=svc.update_obra_stage,
    to_dict_fn=svc.obra_stage_to_dict,
    entity_summary="etapas de obra",
)
