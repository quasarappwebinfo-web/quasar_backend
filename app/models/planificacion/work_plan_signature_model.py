from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship

from app.db.base import Base


class WorkPlanSignature(Base):
    __tablename__ = "work_plan_signatures"

    id = Column(Integer, primary_key=True, autoincrement=True)
    work_plan_signer_id = Column(
        Integer,
        ForeignKey("work_plan_signers.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    signature_type = Column(String(30), nullable=False)
    signature_data = Column(Text, nullable=True)
    signed_at = Column(DateTime, nullable=False)
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(String(500), nullable=True)

    signer = relationship("WorkPlanSigner", back_populates="signatures")
    user = relationship("User", foreign_keys=[user_id])
