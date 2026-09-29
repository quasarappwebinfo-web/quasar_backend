"""Unique person_id on workers (1 persona = 1 trabajador).

Revision ID: 003_workers_person_unique
Revises: 002_users_person_unique
Create Date: 2026-03-14
"""
from typing import Sequence, Union

from alembic import op

revision: str = "003_workers_person_unique"
down_revision: Union[str, None] = "002_users_person_unique"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute(
        """
        DELETE FROM workers
        WHERE id NOT IN (
            SELECT min_id FROM (
                SELECT MIN(id) AS min_id
                FROM workers
                GROUP BY person_id
            ) AS keepers
        )
        """
    )
    op.create_index(
        "ix_workers_person_id",
        "workers",
        ["person_id"],
        unique=True,
    )


def downgrade() -> None:
    op.drop_index("ix_workers_person_id", table_name="workers")
