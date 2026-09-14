from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class Task(Base):
    """Instancia de actividad en una obra (operación)."""

    __tablename__ = "tasks"

    id = Column(Integer, primary_key=True, autoincrement=True)
    uuid = Column(String(36), nullable=False, unique=True, index=True)
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    source_template_version_id = Column(
        Integer,
        ForeignKey("task_template_versions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    parent_task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    unit_id = Column(
        Integer,
        ForeignKey("measurement_units.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    planned_quantity = Column(Numeric(15, 4), nullable=True)
    template_base_quantity = Column(Numeric(15, 4), nullable=True)
    template_base_duration_days = Column(Numeric(10, 2), nullable=True)
    estimated_duration_days = Column(Numeric(10, 2), nullable=True)
    approved_duration_days = Column(Numeric(10, 2), nullable=True)
    planned_start_date = Column(Date, nullable=True)
    planned_end_date = Column(Date, nullable=True)
    actual_start_date = Column(Date, nullable=True)
    actual_end_date = Column(Date, nullable=True)
    status = Column(String(30), nullable=False)
    created_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=True, onupdate=func.now())

    obra = relationship("Obra", back_populates="tasks")
    source_template_version = relationship("TaskTemplateVersion", back_populates="tasks")
    parent = relationship("Task", remote_side=[id], backref="subtasks")
    unit = relationship("MeasurementUnit", back_populates="tasks")
    created_by_user = relationship("User", foreign_keys=[created_by])
    assignments = relationship("TaskAssignment", back_populates="task")
    crew_assignments = relationship("TaskCrewAssignment", back_populates="task")
    dependencies = relationship(
        "TaskDependency",
        back_populates="task",
        foreign_keys="TaskDependency.task_id",
    )
    dependency_overrides = relationship("TaskDependencyOverride", back_populates="task")
    status_history = relationship("TaskStatusHistory", back_populates="task")
    reschedules = relationship("TaskReschedule", back_populates="task")
    delay_events = relationship("TaskDelayEvent", back_populates="task")
    comments = relationship("TaskComment", back_populates="task")
    photos = relationship("TaskPhoto", back_populates="task")
    work_plan_tasks = relationship("WorkPlanTask", back_populates="task")
