from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String, UniqueConstraint
from sqlalchemy.sql import func

from app.db.base import Base


class ObraChapterOpening(Base):
    """Avance con el que un capítulo llega al crear la obra."""

    __tablename__ = "obra_chapter_openings"
    __table_args__ = (
        UniqueConstraint("obra_id", "chapter_id", name="uq_obra_chapter_opening"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    obra_id = Column(
        Integer,
        ForeignKey("obras.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    chapter_id = Column(
        Integer,
        ForeignKey("task_chapters.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    mode = Column(String(20), nullable=False)
    progress_percent = Column(Numeric(5, 2), nullable=False)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
