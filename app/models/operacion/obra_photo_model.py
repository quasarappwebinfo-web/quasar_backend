from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class ObraPhoto(Base):
    """Foto de la obra, sin actividad asociada."""

    __tablename__ = "obra_photos"

    id = Column(Integer, primary_key=True, autoincrement=True)
    uuid = Column(String(36), nullable=False, unique=True, index=True)
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
        index=True,
    )
    file_url = Column(String(500), nullable=False)
    description = Column(Text, nullable=False)
    uploaded_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    obra = relationship("Obra", foreign_keys=[obra_id])
    uploaded_by_user = relationship("User", foreign_keys=[uploaded_by])
