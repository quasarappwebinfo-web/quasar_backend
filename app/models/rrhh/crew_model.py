from sqlalchemy import Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class Crew(Base):
    """Cuadrilla de trabajadores."""

    __tablename__ = "crews"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    leader_worker_id = Column(
        Integer,
        ForeignKey("workers.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    leader = relationship("Worker", back_populates="led_crews", foreign_keys=[leader_worker_id])
    obra = relationship("Obra", back_populates="crews")
    members = relationship("CrewMember", back_populates="crew")
    task_crew_assignments = relationship("TaskCrewAssignment", back_populates="crew")
    template_crews = relationship("TaskTemplateCrew", back_populates="crew")
