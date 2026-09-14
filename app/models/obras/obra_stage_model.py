from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.orm import relationship

from app.db.base import Base


class ObraStage(Base):
    __tablename__ = "obra_stages"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    display_order = Column(Integer, nullable=False)
    is_active = Column(Integer, default=1)

    obras = relationship("Obra", back_populates="current_stage")
    history_entries = relationship("ObraStageHistory", back_populates="stage")
