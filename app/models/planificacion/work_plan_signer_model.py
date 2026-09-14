from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class WorkPlanSigner(Base):
    __tablename__ = "work_plan_signers"

    id = Column(Integer, primary_key=True, autoincrement=True)
    work_plan_version_id = Column(
        Integer,
        ForeignKey("work_plan_versions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    signature_order = Column(Integer, nullable=True)
    status = Column(String(30), nullable=False)
    requested_at = Column(DateTime, nullable=False, server_default=func.now())
    signed_at = Column(DateTime, nullable=True)
    rejected_at = Column(DateTime, nullable=True)
    rejection_reason = Column(Text, nullable=True)

    work_plan_version = relationship("WorkPlanVersion", back_populates="signers")
    user = relationship("User", foreign_keys=[user_id])
    signatures = relationship("WorkPlanSignature", back_populates="signer")
