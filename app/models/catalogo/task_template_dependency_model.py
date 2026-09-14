from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskTemplateDependency(Base):
    __tablename__ = "task_template_dependencies"

    id = Column(Integer, primary_key=True, autoincrement=True)
    template_version_id = Column(
        Integer,
        ForeignKey("task_template_versions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    depends_on_template_id = Column(
        Integer,
        ForeignKey("task_templates.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    dependency_type = Column(String(30), nullable=False)
    is_required = Column(Integer, default=1)
    blocks_start = Column(Integer, default=1)
    description = Column(Text, nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    template_version = relationship("TaskTemplateVersion", back_populates="dependencies")
    depends_on_template = relationship(
        "TaskTemplate",
        back_populates="dependent_from",
        foreign_keys=[depends_on_template_id],
    )
    overrides = relationship("TaskDependencyOverride", back_populates="template_dependency")
