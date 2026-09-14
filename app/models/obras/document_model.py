from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class Document(Base):
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True, autoincrement=True)
    uuid = Column(String(36), nullable=False, unique=True, index=True)
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    document_type_id = Column(
        Integer,
        ForeignKey("document_types.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    name = Column(String(255), nullable=False)
    description = Column(Text, nullable=True)
    file_url = Column(String(500), nullable=False)
    is_visible_to_client = Column(Integer, default=0)
    uploaded_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    obra = relationship("Obra", back_populates="documents")
    document_type = relationship("DocumentType", back_populates="documents")
    uploaded_by_user = relationship("User", foreign_keys=[uploaded_by])
