from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class Obra(Base):
    __tablename__ = "obras"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    code = Column(String(100), nullable=True, unique=True)
    sale_type_id = Column(
        Integer,
        ForeignKey("obra_sale_types.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    address = Column(String(255), nullable=True)
    city = Column(String(150), nullable=True)
    neighborhood = Column(String(150), nullable=True)
    start_date = Column(Date, nullable=True)
    estimated_end_date = Column(Date, nullable=True)
    actual_end_date = Column(Date, nullable=True)
    current_stage_id = Column(
        Integer,
        ForeignKey("obra_stages.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    status = Column(String(30), nullable=False)
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=True, onupdate=func.now())

    sale_type = relationship("ObraSaleType", back_populates="obras")
    current_stage = relationship("ObraStage", back_populates="obras")
    clients = relationship("ObraClient", back_populates="obra")
    stage_history = relationship("ObraStageHistory", back_populates="obra")
    documents = relationship("Document", back_populates="obra")
    worker_assignments = relationship("WorkerAssignment", back_populates="obra")
    crews = relationship("Crew", back_populates="obra")
    tasks = relationship("Task", back_populates="obra")
    work_plans = relationship("WorkPlan", back_populates="obra")
