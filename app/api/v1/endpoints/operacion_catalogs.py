from app.api.v1.endpoints.catalog_router_factory import build_catalog_router
from app.schemas import DelayReasonCreate, DelayReasonResponse, DelayReasonUpdate
from app.services import catalog_services as svc

delay_reason_router = build_catalog_router(
    prefix="/api/v1/operacion/motivos-retraso",
    tags=["operacion-motivos-retraso"],
    response_model=DelayReasonResponse,
    create_model=DelayReasonCreate,
    update_model=DelayReasonUpdate,
    collection_key="delayReasons",
    create_fn=svc.create_delay_reason,
    get_fn=svc.get_delay_reason,
    list_fn=svc.list_delay_reasons,
    update_fn=svc.update_delay_reason,
    to_dict_fn=svc.delay_reason_to_dict,
    entity_summary="motivos de retraso",
)
