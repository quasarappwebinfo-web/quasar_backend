from sqlalchemy import Column, ForeignKey, Integer, String, UniqueConstraint
from sqlalchemy.orm import relationship

from app.db.base import Base


class UserPermission(Base):
    """Permiso de módulo asignado a un usuario operativo (no admin/super)."""

    __tablename__ = "user_permissions"
    __table_args__ = (
        UniqueConstraint("user_id", "permission", name="uq_user_permission"),
    )

    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(
        Integer,
        ForeignKey("users.id", ondelete="CASCADE", onupdate="NO ACTION"),
        nullable=False,
        index=True,
    )
    permission = Column(String(50), nullable=False)

    user = relationship("User", back_populates="permissions")
