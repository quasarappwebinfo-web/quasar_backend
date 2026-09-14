from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class WorkPlan(Base):
    __tablename__ = "work_plans"

    id = Column(Integer, primary_key=True, autoincrement=True)
    uuid = Column(String(36), nullable=False, unique=True, index=True)
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    name = Column(String(255), nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    status = Column(String(30), nullable=False)
    current_version_id = Column(Integer, nullable=True)
    requested_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=True, onupdate=func.now())

    obra = relationship("Obra", back_populates="work_plans")
    requested_by_user = relationship("User", foreign_keys=[requested_by])
    versions = relationship("WorkPlanVersion", back_populates="work_plan")
