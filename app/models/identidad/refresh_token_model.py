from datetime import datetime

from sqlalchemy import Column, DateTime, ForeignKey, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class RefreshToken(Base):
    """Refresh token opaco (solo hash en BD) para renovar el access JWT."""

    __tablename__ = "refresh_tokens"

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE", onupdate="NO ACTION"),
        nullable=False,
        index=True,
    )
    jti = Column(String(64), nullable=False, unique=True)
    token_hash = Column(String(64), nullable=False, unique=True, index=True)
    expires_at = Column(DateTime, nullable=False)
    revoked_at = Column(DateTime, nullable=True)
    replaced_by_jti = Column(String(64), nullable=True)
    created_at = Column(DateTime, nullable=False, default=datetime.utcnow)
    user_agent = Column(String(512), nullable=True)
    ip_address = Column(String(64), nullable=True)

    user = relationship("User", back_populates="refresh_tokens")
