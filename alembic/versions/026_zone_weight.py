"""Porcentaje configurable de cada zona sobre la obra.

Revision ID: 026_zone_weight
Revises: 025_obra_chapter_opening
Create Date: 2026-11-11
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "026_zone_weight"
down_revision: Union[str, None] = "025_obra_chapter_opening"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    columns = {column["name"] for column in insp.get_columns("task_zones")}
    if "weight_percent" in columns:
        return
    op.add_column(
        "task_zones",
        sa.Column("weight_percent", sa.Numeric(6, 2), nullable=True),
    )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    columns = {column["name"] for column in insp.get_columns("task_zones")}
    if "weight_percent" not in columns:
        return
    op.drop_column("task_zones", "weight_percent")
