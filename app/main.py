"""
Aplicación FastAPI — Quasar Backend.
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded

from app.api.v1.endpoints import (
    asistencia,
    auth,
    catalogo_catalogs,
    crew,
    obra,
    operacion_catalogs,
    obras_catalogs,
    person,
    role,
    rrhh_catalogs,
    sync,
    task_ops,
    task_pool,
    user,
    worker,
    work_plan,
)
from app.config import settings
from app.core.limiter import limiter

app = FastAPI(
    title=settings.app_name,
    debug=settings.debug,
    docs_url="/docs" if settings.debug or settings.environment != "prod" else None,
    redoc_url="/redoc" if settings.debug or settings.environment != "prod" else None,
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

cors_origins = [o.strip() for o in settings.cors_origins.split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health", tags=["health"])
async def health():
    return {"status": "ok", "app": settings.app_name, "environment": settings.environment}


app.include_router(auth.router)
app.include_router(person.router)
app.include_router(role.router)
app.include_router(user.router)
app.include_router(rrhh_catalogs.worker_position_router)
app.include_router(rrhh_catalogs.specialty_router)
app.include_router(operacion_catalogs.delay_reason_router)
app.include_router(catalogo_catalogs.measurement_unit_router)
app.include_router(obras_catalogs.document_type_router)
app.include_router(obras_catalogs.obra_sale_type_router)
app.include_router(obras_catalogs.obra_stage_router)
app.include_router(worker.router)
app.include_router(asistencia.router)
app.include_router(asistencia.task_day_router)
app.include_router(crew.router)
app.include_router(obra.router)
app.include_router(task_pool.router)
app.include_router(task_ops.router)
app.include_router(work_plan.router)
app.include_router(sync.router)
