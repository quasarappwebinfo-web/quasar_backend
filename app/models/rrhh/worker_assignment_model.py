from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class WorkerAssignment(Base):
    """Asignación histórica de un trabajador a una obra. end_date NULL = vigente."""

    __tablename__ = "worker_assignments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    worker_id = Column(
        Integer,
        ForeignKey("workers.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    assigned_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    worker = relationship("Worker", back_populates="assignments")
    obra = relationship("Obra", back_populates="worker_assignments")
    assigned_by_user = relationship("User", foreign_keys=[assigned_by])
