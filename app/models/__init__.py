"""
Modelos SQLAlchemy por dominio (español):

- identidad: personas, usuarios, roles, refresh tokens
- rrhh: trabajadores, cargos, especialidades, cuadrillas, asignaciones
- obras: obras, etapas, clientes, documentos
- catalogo: Task Pool (plantillas versionadas)
- operacion: tareas de obra, evidencias, retrasos
- planificacion: work plans, firmas
- auditoria: audit_log
"""
from app.models.identidad import Person, User, UserRole, RefreshToken
from app.models.rrhh import (
    WorkerPosition,
    Specialty,
    Worker,
    Crew,
    CrewMember,
    WorkerAssignment,
)
from app.models.obras import (
    ObraSaleType,
    ObraStage,
    Obra,
    ObraClient,
    ObraStageHistory,
    DocumentType,
    Document,
)
from app.models.catalogo import (
    TaskCategory,
    MeasurementUnit,
    TaskTemplate,
    TaskTemplateVersion,
    TaskTemplateMeasurement,
    TaskTemplatePosition,
    TaskTemplateCrew,
    TaskTemplateSubtask,
    TaskTemplateDependency,
)
from app.models.operacion import (
    DelayReason,
    Task,
    TaskAssignment,
    TaskCrewAssignment,
    TaskDependency,
    TaskDependencyOverride,
    TaskStatusHistory,
    TaskReschedule,
    TaskDelayEvent,
    TaskComment,
    TaskPhoto,
)
from app.models.planificacion import (
    WorkPlan,
    WorkPlanVersion,
    WorkPlanTask,
    WorkPlanSigner,
    WorkPlanSignature,
    WorkPlanSignatureEvent,
)
from app.models.auditoria import AuditLog

__all__ = [
    "Person",
    "User",
    "UserRole",
    "RefreshToken",
    "WorkerPosition",
    "Specialty",
    "Worker",
    "Crew",
    "CrewMember",
    "WorkerAssignment",
    "ObraSaleType",
    "ObraStage",
    "Obra",
    "ObraClient",
    "ObraStageHistory",
    "DocumentType",
    "Document",
    "TaskCategory",
    "MeasurementUnit",
    "TaskTemplate",
    "TaskTemplateVersion",
    "TaskTemplateMeasurement",
    "TaskTemplatePosition",
    "TaskTemplateCrew",
    "TaskTemplateSubtask",
    "TaskTemplateDependency",
    "DelayReason",
    "Task",
    "TaskAssignment",
    "TaskCrewAssignment",
    "TaskDependency",
    "TaskDependencyOverride",
    "TaskStatusHistory",
    "TaskReschedule",
    "TaskDelayEvent",
    "TaskComment",
    "TaskPhoto",
    "WorkPlan",
    "WorkPlanVersion",
    "WorkPlanTask",
    "WorkPlanSigner",
    "WorkPlanSignature",
    "WorkPlanSignatureEvent",
    "AuditLog",
]
