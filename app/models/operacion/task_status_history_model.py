from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskStatusHistory(Base):
    __tablename__ = "task_status_history"

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    from_status = Column(String(30), nullable=True)
    to_status = Column(String(30), nullable=False)
    reason = Column(Text, nullable=True)
    changed_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    changed_at = Column(DateTime, nullable=False, server_default=func.now())

    task = relationship("Task", back_populates="status_history")
    changed_by_user = relationship("User", foreign_keys=[changed_by])
