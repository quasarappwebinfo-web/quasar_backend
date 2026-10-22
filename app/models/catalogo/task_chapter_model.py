from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskChapter(Base):
    __tablename__ = "task_chapters"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    display_order = Column(Integer, nullable=False)
    stage_id = Column(
        Integer,
        ForeignKey("obra_stages.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    # % que este capítulo aporta al 100% de su etapa
    weight_percent = Column(Numeric(6, 2), nullable=True)
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=True, onupdate=func.now())

    stage = relationship("ObraStage", back_populates="chapters")
    templates = relationship("TaskTemplate", back_populates="chapter")
    budget_activities = relationship(
        "TaskBudgetActivity", back_populates="chapter"
    )
