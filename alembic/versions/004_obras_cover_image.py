"""Add cover_image_key to obras.

Revision ID: 004_obras_cover_image
Revises: 003_workers_person_unique
Create Date: 2026-03-15
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "004_obras_cover_image"
down_revision: Union[str, None] = "003_workers_person_unique"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    cols = {c["name"] for c in sa.inspect(bind).get_columns("obras")}
    if "cover_image_key" in cols:
        return
    op.add_column(
        "obras",
        sa.Column("cover_image_key", sa.String(length=500), nullable=True),
    )


def downgrade() -> None:
    op.drop_column("obras", "cover_image_key")
