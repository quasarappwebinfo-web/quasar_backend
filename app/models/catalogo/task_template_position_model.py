from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskTemplatePosition(Base):
    __tablename__ = "task_template_positions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    template_version_id = Column(
        Integer,
        ForeignKey("task_template_versions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    worker_position_id = Column(
        Integer,
        ForeignKey("worker_positions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    specialty_id = Column(
        Integer,
        ForeignKey("specialties.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    quantity = Column(Numeric(10, 2), nullable=False)
    is_required = Column(Integer, default=1)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    template_version = relationship("TaskTemplateVersion", back_populates="positions")
    worker_position = relationship("WorkerPosition", back_populates="template_positions")
    specialty = relationship("Specialty")
