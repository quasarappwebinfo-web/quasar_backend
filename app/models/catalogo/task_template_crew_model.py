from sqlalchemy import Column, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskTemplateCrew(Base):
    __tablename__ = "task_template_crews"

    id = Column(Integer, primary_key=True, autoincrement=True)
    template_version_id = Column(
        Integer,
        ForeignKey("task_template_versions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    crew_id = Column(
        Integer,
        ForeignKey("crews.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    is_preferred = Column(Integer, default=0)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    template_version = relationship("TaskTemplateVersion", back_populates="preferred_crews")
    crew = relationship("Crew", back_populates="template_crews")
