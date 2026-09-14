from sqlalchemy import Column, DateTime, ForeignKey, Integer, String, Text
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func

from app.db.base import Base


class User(Base):
    """Usuario con acceso al sistema. Login por username + password (hash)."""

    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    person_id = Column(
        Integer,
        ForeignKey("persons.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=False,
    )
    username = Column(String(255), nullable=False, unique=True)
    password = Column(Text, nullable=False)
    email = Column(String(255), nullable=True)
    role_id = Column(
        Integer,
        ForeignKey("users_roles.id", ondelete="NO ACTION", onupdate="NO ACTION"),
        nullable=True,
    )
    is_super = Column(Integer, default=0)
    is_active = Column(Integer, default=1)
    deactivation_reason = Column(String(255), nullable=True)
    created_at = Column(DateTime, nullable=False, server_default=func.now())
    updated_at = Column(DateTime, nullable=True, onupdate=func.now())

    person = relationship("Person", back_populates="users")
    role = relationship("UserRole", back_populates="users")
    refresh_tokens = relationship(
        "RefreshToken",
        back_populates="user",
        cascade="all, delete-orphan",
    )
