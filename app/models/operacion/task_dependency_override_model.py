from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskDependencyOverride(Base):
    __tablename__ = "task_dependency_overrides"

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    template_dependency_id = Column(
        Integer,
        ForeignKey("task_template_dependencies.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    override_type = Column(String(30), nullable=False)
    reason = Column(Text, nullable=True)
    created_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    task = relationship("Task", back_populates="dependency_overrides")
    template_dependency = relationship("TaskTemplateDependency", back_populates="overrides")
    created_by_user = relationship("User", foreign_keys=[created_by])
