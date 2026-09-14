from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskAssignment(Base):
    __tablename__ = "task_assignments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    worker_id = Column(
        Integer,
        ForeignKey("workers.id", ondelete="NO ACTION", onupdate="NO ACTION"),
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

    task = relationship("Task", back_populates="assignments")
    worker = relationship("Worker", back_populates="task_assignments")
    assigned_by_user = relationship("User", foreign_keys=[assigned_by])
    removed_by_user = relationship("User", foreign_keys=[removed_by])
