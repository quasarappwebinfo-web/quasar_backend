from sqlalchemy import Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class Worker(Base):
    """Participación laboral de una persona. is_active = baja definitiva, no salida de obra."""

    __tablename__ = "workers"

    id = Column(Integer, primary_key=True, autoincrement=True)
    person_id = Column(
        Integer,
        ForeignKey("persons.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
        unique=True,
    )
    worker_position_id = Column(
        Integer,
        ForeignKey("worker_positions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    specialty_id = Column(
        Integer,
        ForeignKey("specialties.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    linked_user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    is_active = Column(Integer, default=1)
    deactivation_reason = Column(String(255), nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    person = relationship("Person", back_populates="workers")
    worker_position = relationship("WorkerPosition", back_populates="workers")
    specialty = relationship("Specialty", back_populates="workers")
    linked_user = relationship("User", foreign_keys=[linked_user_id])
    assignments = relationship("WorkerAssignment", back_populates="worker")
    crew_memberships = relationship("CrewMember", back_populates="worker")
    led_crews = relationship("Crew", back_populates="leader")
    task_assignments = relationship("TaskAssignment", back_populates="worker")
    daily_attendance = relationship("ObraDailyAttendance", back_populates="worker")
    daily_task_assignments = relationship(
        "TaskDailyAssignment", back_populates="worker"
    )
