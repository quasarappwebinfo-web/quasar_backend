from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.orm import relationship

from app.db.base import Base


class DelayReason(Base):
    __tablename__ = "delay_reasons"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    is_active = Column(Integer, default=1)

    delay_events = relationship("TaskDelayEvent", back_populates="delay_reason")
    reschedules = relationship("TaskReschedule", back_populates="reason_ref")
