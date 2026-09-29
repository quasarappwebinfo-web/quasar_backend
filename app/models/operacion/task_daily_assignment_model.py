from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskDailyAssignment(Base):
    """Quién trabaja en una tarea un día concreto (trazabilidad diaria)."""

    __tablename__ = "task_daily_assignments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    work_date = Column(Date, nullable=False)
    worker_id = Column(
        Integer,
        ForeignKey("workers.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
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

    task = relationship("Task", back_populates="daily_assignments")
    worker = relationship("Worker", back_populates="daily_task_assignments")
    assigned_by_user = relationship("User", foreign_keys=[assigned_by])
    removed_by_user = relationship("User", foreign_keys=[removed_by])
