from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskPhoto(Base):
    __tablename__ = "task_photos"

    id = Column(Integer, primary_key=True, autoincrement=True)
    uuid = Column(String(36), nullable=False, unique=True, index=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    file_url = Column(String(500), nullable=False)
    description = Column(Text, nullable=True)
    taken_at = Column(DateTime, nullable=True)
    uploaded_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    task = relationship("Task", back_populates="photos")
    uploaded_by_user = relationship("User", foreign_keys=[uploaded_by])
