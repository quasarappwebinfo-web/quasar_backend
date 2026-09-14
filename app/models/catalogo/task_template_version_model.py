from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskTemplateVersion(Base):
    """Versión de plantilla. Publicadas = inmutables."""

    __tablename__ = "task_template_versions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_template_id = Column(
        Integer,
        ForeignKey("task_templates.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    version_number = Column(Integer, nullable=False)
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    status = Column(String(30), nullable=False)
    base_quantity = Column(Numeric(15, 4), nullable=True)
    base_duration_days = Column(Numeric(10, 2), nullable=True)
    published_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=True, onupdate=func.now())

    task_template = relationship("TaskTemplate", back_populates="versions")
    measurements = relationship("TaskTemplateMeasurement", back_populates="template_version")
    positions = relationship("TaskTemplatePosition", back_populates="template_version")
    preferred_crews = relationship("TaskTemplateCrew", back_populates="template_version")
    subtasks = relationship("TaskTemplateSubtask", back_populates="template_version")
    dependencies = relationship("TaskTemplateDependency", back_populates="template_version")
    tasks = relationship("Task", back_populates="source_template_version")
