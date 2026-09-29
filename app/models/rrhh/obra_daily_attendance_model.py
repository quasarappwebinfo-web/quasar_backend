from sqlalchemy import Column, Date, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class ObraDailyAttendance(Base):
    """Presencia + firma de llegada de un trabajador en una obra un día concreto."""

    __tablename__ = "obra_daily_attendance"

    id = Column(Integer, primary_key=True, autoincrement=True)
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    work_date = Column(Date, nullable=False)
    worker_id = Column(
        Integer,
        ForeignKey("workers.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    signed_at = Column(DateTime, nullable=False)
    signature_type = Column(String(30), nullable=False)
    signature_data = Column(Text, nullable=True)
    recorded_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    ip_address = Column(String(45), nullable=True)
    user_agent = Column(String(500), nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    removed_at = Column(DateTime, nullable=True)
    removed_by = Column(
        Integer,
        ForeignKey("users.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )

    obra = relationship("Obra", back_populates="daily_attendance")
    worker = relationship("Worker", back_populates="daily_attendance")
    recorded_by_user = relationship("User", foreign_keys=[recorded_by])
    removed_by_user = relationship("User", foreign_keys=[removed_by])
