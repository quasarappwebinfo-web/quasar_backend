from sqlalchemy import Column, Integer, String, Text
from sqlalchemy.orm import relationship

from app.db.base import Base


class DocumentType(Base):
    __tablename__ = "document_types"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    is_active = Column(Integer, default=1)

    documents = relationship("Document", back_populates="document_type")
