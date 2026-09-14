from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskComment(Base):
    __tablename__ = "task_comments"

    id = Column(Integer, primary_key=True, autoincrement=True)
    uuid = Column(String(36), nullable=False, unique=True, index=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    type = Column(String(30), nullable=False)
    content = Column(Text, nullable=False)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=True, onupdate=func.now())

    task = relationship("Task", back_populates="comments")
    user = relationship("User", foreign_keys=[user_id])
