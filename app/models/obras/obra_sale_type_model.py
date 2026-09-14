from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class ObraSaleType(Base):
    __tablename__ = "obra_sale_types"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False, unique=True)
    is_active = Column(Integer, default=1)

    obras = relationship("Obra", back_populates="sale_type")
