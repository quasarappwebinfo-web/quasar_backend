from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskReschedule(Base):
    __tablename__ = "task_reschedules"

    id = Column(Integer, primary_key=True, autoincrement=True)
    uuid = Column(String(36), nullable=False, unique=True, index=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    previous_start_date = Column(Date, nullable=True)
    previous_end_date = Column(Date, nullable=True)
    new_start_date = Column(Date, nullable=True)
    new_end_date = Column(Date, nullable=True)
    reason_id = Column(
        Integer,
        ForeignKey("delay_reasons.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    reason = Column(Text, nullable=True)
    rescheduled_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    rescheduled_at = Column(DateTime, nullable=False, server_default=func.now())

    task = relationship("Task", back_populates="reschedules")
    reason_ref = relationship("DelayReason", back_populates="reschedules")
    rescheduled_by_user = relationship("User", foreign_keys=[rescheduled_by])
