from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskTemplateSubtask(Base):
    __tablename__ = "task_template_subtasks"

    id = Column(Integer, primary_key=True, autoincrement=True)
    template_version_id = Column(
        Integer,
        ForeignKey("task_template_versions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    display_order = Column(Integer, nullable=False)
    is_required = Column(Integer, default=1)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    template_version = relationship("TaskTemplateVersion", back_populates="subtasks")
