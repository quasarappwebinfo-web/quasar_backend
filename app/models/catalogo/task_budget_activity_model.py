from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class TaskBudgetActivity(Base):
    """Actividad presupuestal ligada a una categoría (y opcionalmente zona).

    Ej.: categoría «Estructura» → actividad «Estructura metálica».
    Los pesos los define el cliente: % hacia categoría y % hacia zona.
    """

    __tablename__ = "task_budget_activities"

    id = Column(Integer, primary_key=True, autoincrement=True)
    category_id = Column(
        Integer,
        ForeignKey("task_categories.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    zone_id = Column(
        Integer,
        ForeignKey("task_zones.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    name = Column(String(150), nullable=False)
    description = Column(Text, nullable=True)
    display_order = Column(Integer, nullable=False)
    # % que esta BA aporta al 100% de su categoría
    category_weight_percent = Column(Numeric(6, 2), nullable=True)
    # % que esta BA aporta al 100% de su zona
    zone_weight_percent = Column(Numeric(6, 2), nullable=True)
    is_active = Column(Integer, default=1)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=True, onupdate=func.now())

    category = relationship("TaskCategory", back_populates="budget_activities")
    zone = relationship("TaskZone", back_populates="budget_activities")
    templates = relationship("TaskTemplate", back_populates="budget_activity")
