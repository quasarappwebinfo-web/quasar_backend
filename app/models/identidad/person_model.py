from sqlalchemy import Column, Date, DateTime, Integer, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class Person(Base):
    """Identidad física única (cédula). Una persona puede ser usuario y/o trabajador."""

    __tablename__ = "persons"

    id = Column(Integer, primary_key=True, autoincrement=True)
    document_number = Column(String(20), nullable=False, unique=True)
    name = Column(String(255), nullable=False)
    phone = Column(String(255), nullable=True)
    photo_url = Column(String(255), nullable=True)
    birth_date = Column(Date, nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    users = relationship("User", back_populates="person")
    workers = relationship("Worker", back_populates="person")
    obra_clients = relationship("ObraClient", back_populates="person")
