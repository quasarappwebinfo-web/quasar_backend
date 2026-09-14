from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskDelayEvent(Base):
    __tablename__ = "task_delay_events"

    id = Column(Integer, primary_key=True, autoincrement=True)
    uuid = Column(String(36), nullable=False, unique=True, index=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    delay_reason_id = Column(
        Integer,
        ForeignKey("delay_reasons.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    start_date = Column(Date, nullable=True)
    end_date = Column(Date, nullable=True)
    days_lost = Column(Numeric(10, 2), nullable=True)
    description = Column(Text, nullable=True)
    created_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    task = relationship("Task", back_populates="delay_events")
    delay_reason = relationship("DelayReason", back_populates="delay_events")
    created_by_user = relationship("User", foreign_keys=[created_by])
