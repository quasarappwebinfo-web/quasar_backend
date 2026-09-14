from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskCrewAssignment(Base):
    __tablename__ = "task_crew_assignments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    crew_id = Column(
        Integer,
        ForeignKey("crews.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    start_date = Column(Date, nullable=True)
    end_date = Column(Date, nullable=True)
    assigned_at = Column(DateTime, nullable=False, server_default=func.now())
    assigned_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    removed_at = Column(DateTime, nullable=True)
    removed_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )

    task = relationship("Task", back_populates="crew_assignments")
    crew = relationship("Crew", back_populates="task_crew_assignments")
    assigned_by_user = relationship("User", foreign_keys=[assigned_by])
    removed_by_user = relationship("User", foreign_keys=[removed_by])
