from sqlalchemy import Column, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class Specialty(Base):
    """Especialidad (Estructura, Eléctrico, Plomería, Acabados, etc.)."""

    __tablename__ = "specialties"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    worker_position_id = Column(
        Integer,
        ForeignKey("worker_positions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    is_active = Column(Integer, default=1)

    worker_position = relationship("WorkerPosition", back_populates="specialties")
    workers = relationship("Worker", back_populates="specialty")
