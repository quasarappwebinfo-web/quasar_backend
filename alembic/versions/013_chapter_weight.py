"""% de cumplimiento del capítulo hacia el global de la obra.

Revision ID: 013_chapter_weight
Revises: 012_task_chapters
Create Date: 2026-10-22
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "013_chapter_weight"
down_revision: Union[str, None] = "012_task_chapters"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    tables = set(insp.get_table_names())
    table = "task_chapters" if "task_chapters" in tables else None
    if table is None and "task_categories" in tables:
        table = "task_categories"
    if table is None:
        return
    names = {c["name"] for c in insp.get_columns(table)}
    if "weight_percent" in names:
        return
    op.add_column(
        table,
        sa.Column("weight_percent", sa.Numeric(6, 2), nullable=True),
    )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    tables = set(insp.get_table_names())
    table = "task_chapters" if "task_chapters" in tables else "task_categories"
    if table not in tables:
        return
    names = {c["name"] for c in insp.get_columns(table)}
    if "weight_percent" not in names:
        return
    op.drop_column(table, "weight_percent")
