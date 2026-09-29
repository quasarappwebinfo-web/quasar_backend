from app.api.v1.endpoints.catalog_router_factory import build_catalog_router
from app.schemas import (
    MeasurementUnitCreate,
    MeasurementUnitResponse,
    MeasurementUnitUpdate,
)
from app.services import catalog_services as svc

measurement_unit_router = build_catalog_router(
    prefix="/api/v1/catalogo/unidades-medida",
    tags=["catalogo-unidades"],
    response_model=MeasurementUnitResponse,
    create_model=MeasurementUnitCreate,
    update_model=MeasurementUnitUpdate,
    collection_key="measurementUnits",
    create_fn=svc.create_measurement_unit,
    get_fn=svc.get_measurement_unit,
    list_fn=svc.list_measurement_units,
    update_fn=svc.update_measurement_unit,
    to_dict_fn=svc.measurement_unit_to_dict,
    entity_summary="unidades de medida",
)
