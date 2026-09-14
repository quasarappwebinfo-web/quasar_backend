from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class ObraStageHistory(Base):
    __tablename__ = "obra_stage_history"

    id = Column(Integer, primary_key=True, autoincrement=True)
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    stage_id = Column(
        Integer,
        ForeignKey("obra_stages.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    planned_start_date = Column(Date, nullable=True)
    planned_end_date = Column(Date, nullable=True)
    actual_start_date = Column(Date, nullable=True)
    actual_end_date = Column(Date, nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    obra = relationship("Obra", back_populates="stage_history")
    stage = relationship("ObraStage", back_populates="history_entries")
