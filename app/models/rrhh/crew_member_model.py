from sqlalchemy import Column, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class CrewMember(Base):
    """Historial de pertenencia a una cuadrilla. left_at NULL = sigue activo."""

    __tablename__ = "crew_members"

    id = Column(Integer, primary_key=True, autoincrement=True)
    crew_id = Column(
        Integer,
        ForeignKey("crews.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    worker_id = Column(
        Integer,
        ForeignKey("workers.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    joined_at = Column(DateTime, nullable=False, server_default=func.now())
    left_at = Column(DateTime, nullable=True)

    crew = relationship("Crew", back_populates="members")
    worker = relationship("Worker", back_populates="crew_memberships")
