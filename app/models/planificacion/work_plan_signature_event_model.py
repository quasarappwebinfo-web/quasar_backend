from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class WorkPlanSignatureEvent(Base):
    __tablename__ = "work_plan_signature_events"

    id = Column(Integer, primary_key=True, autoincrement=True)
    work_plan_version_id = Column(
        Integer,
        ForeignKey("work_plan_versions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    event_type = Column(String(50), nullable=False)
    event_at = Column(DateTime, nullable=False, server_default=func.now())
    details = Column(Text, nullable=True)

    work_plan_version = relationship("WorkPlanVersion", back_populates="signature_events")
    user = relationship("User", foreign_keys=[user_id])
