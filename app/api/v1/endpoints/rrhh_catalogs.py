from app.api.v1.endpoints.catalog_router_factory import build_catalog_router
from app.schemas import (
    SpecialtyCreate,
    SpecialtyResponse,
    SpecialtyUpdate,
    WorkerPositionCreate,
    WorkerPositionResponse,
    WorkerPositionUpdate,
)
from app.services import catalog_services as svc

worker_position_router = build_catalog_router(
    prefix="/api/v1/rrhh/cargos",
    tags=["rrhh-cargos"],
    response_model=WorkerPositionResponse,
    create_model=WorkerPositionCreate,
    update_model=WorkerPositionUpdate,
    collection_key="positions",
    create_fn=svc.create_worker_position,
    get_fn=svc.get_worker_position,
    list_fn=svc.list_worker_positions,
    update_fn=svc.update_worker_position,
    to_dict_fn=svc.worker_position_to_dict,
    entity_summary="cargos",
)

specialty_router = build_catalog_router(
    prefix="/api/v1/rrhh/especialidades",
    tags=["rrhh-especialidades"],
    response_model=SpecialtyResponse,
    create_model=SpecialtyCreate,
    update_model=SpecialtyUpdate,
    collection_key="specialties",
    create_fn=svc.create_specialty,
    get_fn=svc.get_specialty,
    list_fn=svc.list_specialties,
    update_fn=svc.update_specialty,
    to_dict_fn=svc.specialty_to_dict,
    entity_summary="especialidades",
    supports_position_filter=True,
)
