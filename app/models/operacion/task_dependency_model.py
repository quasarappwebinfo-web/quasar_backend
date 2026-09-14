from sqlalchemy import Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskDependency(Base):
    __tablename__ = "task_dependencies"

    id = Column(Integer, primary_key=True, autoincrement=True)
    task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    depends_on_task_id = Column(
        Integer,
        ForeignKey("tasks.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    dependency_type = Column(String(30), nullable=False)
    is_required = Column(Integer, default=1)
    blocks_start = Column(Integer, default=1)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    task = relationship("Task", back_populates="dependencies", foreign_keys=[task_id])
    depends_on_task = relationship("Task", foreign_keys=[depends_on_task_id])
