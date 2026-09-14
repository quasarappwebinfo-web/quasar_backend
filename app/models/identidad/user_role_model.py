from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship

from app.db.base import Base


class UserRole(Base):
    """Rol de acceso al sistema (Administrador, Supervisor, Cliente, etc.)."""

    __tablename__ = "users_roles"

    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(255), nullable=False)
    is_active = Column(Integer, default=1)

    users = relationship("User", back_populates="role")
