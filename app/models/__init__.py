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
from app.models.identidad import (
    Person,
    User,
    UserRole,
    UserPermission,
    RefreshToken,
    UserNotification,
)
from app.models.rrhh import (
    WorkerPosition,
    Specialty,
    Worker,
    Crew,
    CrewMember,
    WorkerAssignment,
    ObraDailyAttendance,
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
    TaskChapter,
    TaskZone,
    TaskBudgetActivity,
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
    TaskDailyAssignment,
    TaskDependency,
    TaskDependencyOverride,
    TaskStatusHistory,
    TaskReschedule,
    TaskDelayEvent,
    TaskComment,
    ObraPhoto,
    TaskPhoto,
    TaskDocument,
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
    "UserPermission",
    "RefreshToken",
    "UserNotification",
    "WorkerPosition",
    "Specialty",
    "Worker",
    "Crew",
    "CrewMember",
    "WorkerAssignment",
    "ObraDailyAttendance",
    "ObraSaleType",
    "ObraStage",
    "Obra",
    "ObraClient",
    "ObraStageHistory",
    "DocumentType",
    "Document",
    "TaskChapter",
    "TaskZone",
    "TaskBudgetActivity",
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
    "TaskDailyAssignment",
    "TaskDependency",
    "TaskDependencyOverride",
    "TaskStatusHistory",
    "TaskReschedule",
    "TaskDelayEvent",
    "TaskComment",
    "ObraPhoto",
    "TaskPhoto",
    "TaskDocument",
    "WorkPlan",
    "WorkPlanVersion",
    "WorkPlanTask",
    "WorkPlanSigner",
    "WorkPlanSignature",
    "WorkPlanSignatureEvent",
    "AuditLog",
]
