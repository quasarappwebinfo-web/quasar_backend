"""Etapa con % de la obra y capítulo perteneciente a una etapa.

Revision ID: 016_chapter_stage
Revises: 015_user_notifications
Create Date: 2026-10-22
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "016_chapter_stage"
down_revision: Union[str, None] = "015_user_notifications"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    stage_cols = {c["name"] for c in insp.get_columns("obra_stages")}
    if "weight_percent" not in stage_cols:
        op.add_column(
            "obra_stages",
            sa.Column("weight_percent", sa.Numeric(6, 2), nullable=True),
        )
    chapter_cols = {c["name"] for c in insp.get_columns("task_chapters")}
    if "stage_id" not in chapter_cols:
        op.add_column(
            "task_chapters",
            sa.Column("stage_id", sa.Integer(), nullable=True),
        )
        op.create_foreign_key(
            "fk_task_chapters_stage",
            "task_chapters",
            "obra_stages",
            ["stage_id"],
            ["id"],
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    chapter_cols = {c["name"] for c in insp.get_columns("task_chapters")}
    if "stage_id" in chapter_cols:
        op.drop_constraint(
            "fk_task_chapters_stage", "task_chapters", type_="foreignkey"
        )
        op.drop_column("task_chapters", "stage_id")
    stage_cols = {c["name"] for c in insp.get_columns("obra_stages")}
    if "weight_percent" in stage_cols:
        op.drop_column("obra_stages", "weight_percent")
