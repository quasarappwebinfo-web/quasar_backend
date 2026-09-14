from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class ObraClient(Base):
    __tablename__ = "obra_clients"

    id = Column(Integer, primary_key=True, autoincrement=True)
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    person_id = Column(
        Integer,
        ForeignKey("persons.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    role = Column(String(30), nullable=False)
    is_primary = Column(Integer, default=0)
    start_date = Column(Date, nullable=True)
    end_date = Column(Date, nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    obra = relationship("Obra", back_populates="clients")
    person = relationship("Person", back_populates="obra_clients")
