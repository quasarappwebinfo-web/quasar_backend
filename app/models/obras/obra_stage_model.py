from sqlalchemy import Column, Integer, Numeric, String, Text
from sqlalchemy.orm import relationship

from app.db.base import Base


class ObraStage(Base):
    __tablename__ = "obra_stages"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    display_order = Column(Integer, nullable=False)
    # % que esta etapa aporta al 100% de la obra
    weight_percent = Column(Numeric(6, 2), nullable=True)
    is_active = Column(Integer, default=1)

    obras = relationship("Obra", back_populates="current_stage")
    chapters = relationship("TaskChapter", back_populates="stage")
    history_entries = relationship("ObraStageHistory", back_populates="stage")
