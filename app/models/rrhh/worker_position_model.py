from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class WorkerPosition(Base):
    """Cargo laboral (Oficial, Ayudante, Maestro de obra, etc.)."""

    __tablename__ = "worker_positions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    is_active = Column(Integer, default=1)

    specialties = relationship("Specialty", back_populates="worker_position")
    workers = relationship("Worker", back_populates="worker_position")
    template_positions = relationship("TaskTemplatePosition", back_populates="worker_position")
