"""Unique person_id on users (1 persona = 1 usuario).

Revision ID: 002_users_person_unique
Revises: 001_esquema_quasar
Create Date: 2026-03-14
"""
from typing import Sequence, Union

from alembic import op

revision: str = "002_users_person_unique"
down_revision: Union[str, None] = "001_esquema_quasar"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Había usuarios duplicados por person_id (p. ej. person_id=1).
    # Se conserva el usuario con id más bajo; el resto se elimina
    # (refresh_tokens caen por CASCADE si está configurado en FK).
    op.execute(
        """
        DELETE FROM users
        WHERE id NOT IN (
            SELECT min_id FROM (
                SELECT MIN(id) AS min_id
                FROM users
                GROUP BY person_id
            ) AS keepers
        )
        """
    )
    op.create_index(
        "ix_users_person_id",
        "users",
        ["person_id"],
        unique=True,
    )


def downgrade() -> None:
    op.drop_index("ix_users_person_id", table_name="users")
