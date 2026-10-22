"""Vincula la tarea de obra con la actividad registrada, sin exigir versión.

Revision ID: 014_task_source_template
Revises: 013_chapter_weight
Create Date: 2026-10-22
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "014_task_source_template"
down_revision: Union[str, None] = "013_chapter_weight"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "tasks" not in insp.get_table_names():
        return
    names = {c["name"] for c in insp.get_columns("tasks")}
    if "source_template_id" not in names:
        op.add_column(
            "tasks",
            sa.Column("source_template_id", sa.Integer(), nullable=True),
        )
        op.create_foreign_key(
            "fk_tasks_source_template",
            "tasks",
            "task_templates",
            ["source_template_id"],
            ["id"],
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        )
    op.execute(
        sa.text(
            """
            UPDATE tasks
            SET source_template_id = (
                SELECT task_template_id
                FROM task_template_versions
                WHERE task_template_versions.id = tasks.source_template_version_id
            )
            WHERE source_template_id IS NULL
              AND source_template_version_id IS NOT NULL
            """
        )
    )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "tasks" not in insp.get_table_names():
        return
    names = {c["name"] for c in insp.get_columns("tasks")}
    if "source_template_id" not in names:
        return
    fks = {fk["name"] for fk in insp.get_foreign_keys("tasks")}
    if "fk_tasks_source_template" in fks:
        op.drop_constraint("fk_tasks_source_template", "tasks", type_="foreignkey")
    op.drop_column("tasks", "source_template_id")
