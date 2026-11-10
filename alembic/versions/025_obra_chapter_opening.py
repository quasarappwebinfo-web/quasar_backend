"""Avance inicial de capítulos al crear una obra ya empezada.

Revision ID: 025_obra_chapter_opening
Revises: 024_password_reset_codes
Create Date: 2026-11-10
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "025_obra_chapter_opening"
down_revision: Union[str, None] = "024_password_reset_codes"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "obra_chapter_openings" in insp.get_table_names():
        return
    op.create_table(
        "obra_chapter_openings",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("obra_id", sa.Integer(), nullable=False),
        sa.Column("chapter_id", sa.Integer(), nullable=False),
        sa.Column("mode", sa.String(length=20), nullable=False),
        sa.Column("progress_percent", sa.Numeric(5, 2), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(["obra_id"], ["obras.id"]),
        sa.ForeignKeyConstraint(["chapter_id"], ["task_chapters.id"]),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("obra_id", "chapter_id", name="uq_obra_chapter_opening"),
    )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "obra_chapter_openings" in insp.get_table_names():
        op.drop_table("obra_chapter_openings")
