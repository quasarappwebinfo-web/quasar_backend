from sqlalchemy import Column, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class WorkPlanVersion(Base):
    __tablename__ = "work_plan_versions"

    id = Column(Integer, primary_key=True, autoincrement=True)
    work_plan_id = Column(
        Integer,
        ForeignKey("work_plans.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    version_number = Column(Integer, nullable=False)
    created_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    signed_at = Column(DateTime, nullable=True)

    work_plan = relationship("WorkPlan", back_populates="versions")
    created_by_user = relationship("User", foreign_keys=[created_by])
    tasks = relationship("WorkPlanTask", back_populates="work_plan_version")
    signers = relationship("WorkPlanSigner", back_populates="work_plan_version")
    signature_events = relationship("WorkPlanSignatureEvent", back_populates="work_plan_version")
