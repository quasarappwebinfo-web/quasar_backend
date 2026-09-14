from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class AuditLog(Base):
    __tablename__ = "audit_log"

    id = Column(Integer, primary_key=True, autoincrement=True)
    entity_type = Column(String(50), nullable=False)
    entity_id = Column(Integer, nullable=False)
    action = Column(String(50), nullable=False)
    field_changed = Column(String(100), nullable=True)
    old_value = Column(String(255), nullable=True)
    new_value = Column(String(255), nullable=True)
    reason = Column(Text, nullable=True)
    changed_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    changed_at = Column(DateTime, nullable=False, server_default=func.now())

    changed_by_user = relationship("User", foreign_keys=[changed_by])
