from sqlalchemy import Column, DateTime, ForeignKey, Integer
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskTemplateMeasurement(Base):
    __tablename__ = "task_template_measurements"

    id = Column(Integer, primary_key=True, autoincrement=True)
    template_version_id = Column(
        Integer,
        ForeignKey("task_template_versions.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    unit_id = Column(
        Integer,
        ForeignKey("measurement_units.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    is_primary = Column(Integer, default=0)
    created_at = Column(DateTime, nullable=False, server_default=func.now())

    template_version = relationship("TaskTemplateVersion", back_populates="measurements")
    unit = relationship("MeasurementUnit", back_populates="template_measurements")
