"""esquema inicial Quasar (dominios completos)

Revision ID: 001_esquema_quasar
Revises:
Create Date: 2026-03-14 13:00:00.000000

"""
from typing import Sequence, Union

from alembic import op

from app.db.base import Base
import app.models  # noqa: F401

revision: str = "001_esquema_quasar"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    """Crea todas las tablas registradas en Base.metadata."""
    bind = op.get_bind()
    Base.metadata.create_all(bind=bind)


def downgrade() -> None:
    bind = op.get_bind()
    Base.metadata.drop_all(bind=bind)
