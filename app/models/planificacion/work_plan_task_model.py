from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class WorkPlanTask(Base):
    """Snapshot de tarea en una versión de planificación (para firmas históricas)."""

    __tablename__ = "work_plan_tasks"

    id = Column(Integer, primary_key=True, autoincrement=True)
    work_plan_version_id = Column(
        Integer,
        ForeignKey("work_plan_versions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    task_name_snapshot = Column(String(255), nullable=False)
    task_description_snapshot = Column(Text, nullable=True)
    quantity_snapshot = Column(Numeric(15, 4), nullable=True)
    unit_snapshot = Column(String(30), nullable=True)
    planned_start_date = Column(Date, nullable=False)
    planned_end_date = Column(Date, nullable=False)
    estimated_duration_days_snapshot = Column(Numeric(10, 2), nullable=True)
    approved_duration_days_snapshot = Column(Numeric(10, 2), nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    work_plan_version = relationship("WorkPlanVersion", back_populates="tasks")
    task = relationship("Task", back_populates="work_plan_tasks")
