"""Marca los capítulos que se hacen una vez para toda la obra.

Revision ID: 021_chapter_global
Revises: 020_task_placement
Create Date: 2026-11-05
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "021_chapter_global"
down_revision: Union[str, None] = "020_task_placement"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "task_chapters" not in insp.get_table_names():
        return
    names = {c["name"] for c in insp.get_columns("task_chapters")}
    if "is_global" not in names:
        op.add_column(
            "task_chapters",
            sa.Column("is_global", sa.Integer(), nullable=False, server_default="0"),
        )
    op.execute(
        sa.text(
            """
            UPDATE task_chapters
            SET is_global = 1
            WHERE name LIKE '%preliminar%'
            """
        )
    )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "task_chapters" not in insp.get_table_names():
        return
    names = {c["name"] for c in insp.get_columns("task_chapters")}
    if "is_global" in names:
        op.drop_column("task_chapters", "is_global")
