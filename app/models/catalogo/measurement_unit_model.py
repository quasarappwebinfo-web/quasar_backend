from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class MeasurementUnit(Base):
    __tablename__ = "measurement_units"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    symbol = Column(String(30), nullable=False)
    is_active = Column(Integer, default=1)

    template_measurements = relationship("TaskTemplateMeasurement", back_populates="unit")
    tasks = relationship("Task", back_populates="unit")
