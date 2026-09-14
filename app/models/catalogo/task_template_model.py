from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskTemplate(Base):
    """Plantilla del Task Pool (catálogo). No es una tarea de obra."""

    __tablename__ = "task_templates"

    id = Column(Integer, primary_key=True, autoincrement=True)
    category_id = Column(
        Integer,
        ForeignKey("task_categories.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    name = Column(String(255), nullable=False)
    code = Column(String(100), nullable=False, unique=True)
    description = Column(Text, nullable=True)
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=True, onupdate=func.now())

    category = relationship("TaskCategory", back_populates="templates")
    versions = relationship("TaskTemplateVersion", back_populates="task_template")
    dependent_from = relationship(
        "TaskTemplateDependency",
        back_populates="depends_on_template",
        foreign_keys="TaskTemplateDependency.depends_on_template_id",
    )
