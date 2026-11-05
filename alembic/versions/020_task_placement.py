"""Guarda capítulo, actividad presupuestal y zona en la actividad de la obra.

Revision ID: 020_task_placement
Revises: 019_drop_person_phone_birth
Create Date: 2026-11-05
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "020_task_placement"
down_revision: Union[str, None] = "019_drop_person_phone_birth"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "tasks" not in insp.get_table_names():
        return
    names = {c["name"] for c in insp.get_columns("tasks")}
    if "chapter_id" not in names:
        op.add_column("tasks", sa.Column("chapter_id", sa.Integer(), nullable=True))
        op.create_foreign_key(
            "fk_tasks_chapter",
            "tasks",
            "task_chapters",
            ["chapter_id"],
            ["id"],
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        )
    if "budget_activity_id" not in names:
        op.add_column(
            "tasks", sa.Column("budget_activity_id", sa.Integer(), nullable=True)
        )
        op.create_foreign_key(
            "fk_tasks_budget_activity",
            "tasks",
            "task_budget_activities",
            ["budget_activity_id"],
            ["id"],
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        )
    if "zone_id" not in names:
        op.add_column("tasks", sa.Column("zone_id", sa.Integer(), nullable=True))
        op.create_foreign_key(
            "fk_tasks_zone",
            "tasks",
            "task_zones",
            ["zone_id"],
            ["id"],
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        )
    op.execute(
        sa.text(
            """
            UPDATE tasks AS t
            INNER JOIN task_templates AS tpl ON tpl.id = t.source_template_id
            SET t.chapter_id = tpl.chapter_id,
                t.budget_activity_id = tpl.budget_activity_id,
                t.zone_id = tpl.zone_id
            WHERE t.chapter_id IS NULL
            """
        )
    )
    op.execute(
        sa.text(
            """
            UPDATE tasks AS t
            INNER JOIN task_template_versions AS ver
                ON ver.id = t.source_template_version_id
            INNER JOIN task_templates AS tpl ON tpl.id = ver.task_template_id
            SET t.chapter_id = tpl.chapter_id,
                t.budget_activity_id = tpl.budget_activity_id,
                t.zone_id = tpl.zone_id
            WHERE t.chapter_id IS NULL
            """
        )
    )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "tasks" not in insp.get_table_names():
        return
    fks = {fk["name"] for fk in insp.get_foreign_keys("tasks")}
    names = {c["name"] for c in insp.get_columns("tasks")}
    if "fk_tasks_zone" in fks:
        op.drop_constraint("fk_tasks_zone", "tasks", type_="foreignkey")
    if "zone_id" in names:
        op.drop_column("tasks", "zone_id")
    if "fk_tasks_budget_activity" in fks:
        op.drop_constraint("fk_tasks_budget_activity", "tasks", type_="foreignkey")
    if "budget_activity_id" in names:
        op.drop_column("tasks", "budget_activity_id")
    if "fk_tasks_chapter" in fks:
        op.drop_constraint("fk_tasks_chapter", "tasks", type_="foreignkey")
    if "chapter_id" in names:
        op.drop_column("tasks", "chapter_id")
