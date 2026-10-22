"""Pesos de cumplimiento (subtarea → actividad → BA → cat/zona).

Revision ID: 010_progress_weights
Revises: 009_task_trace_documents
Create Date: 2026-03-25
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "010_progress_weights"
down_revision: Union[str, None] = "009_task_trace_documents"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)

    def _has(table: str, column: str) -> bool:
        if table not in insp.get_table_names():
            return False
        return column in {c["name"] for c in insp.get_columns(table)}

    if not _has("task_template_subtasks", "weight_percent"):
        op.add_column(
            "task_template_subtasks",
            sa.Column(
                "weight_percent",
                sa.Numeric(6, 2),
                nullable=False,
                server_default="0",
            ),
        )
    if not _has("task_templates", "budget_weight_percent"):
        op.add_column(
            "task_templates",
            sa.Column("budget_weight_percent", sa.Numeric(6, 2), nullable=True),
        )
    ba_cols = (
        {c["name"] for c in insp.get_columns("task_budget_activities")}
        if "task_budget_activities" in insp.get_table_names()
        else set()
    )
    if "zone_id" not in ba_cols:
        op.add_column(
            "task_budget_activities",
            sa.Column("zone_id", sa.Integer(), nullable=True),
        )
        op.create_foreign_key(
            "fk_task_budget_activities_zone",
            "task_budget_activities",
            "task_zones",
            ["zone_id"],
            ["id"],
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        )
    if (
        "category_weight_percent" not in ba_cols
        and "chapter_weight_percent" not in ba_cols
    ):
        op.add_column(
            "task_budget_activities",
            sa.Column("category_weight_percent", sa.Numeric(6, 2), nullable=True),
        )
    if "zone_weight_percent" not in ba_cols:
        op.add_column(
            "task_budget_activities",
            sa.Column("zone_weight_percent", sa.Numeric(6, 2), nullable=True),
        )
    if not _has("tasks", "weight_percent"):
        op.add_column(
            "tasks",
            sa.Column("weight_percent", sa.Numeric(6, 2), nullable=True),
        )
    if not _has("tasks", "budget_weight_percent"):
        op.add_column(
            "tasks",
            sa.Column("budget_weight_percent", sa.Numeric(6, 2), nullable=True),
        )


def downgrade() -> None:
    op.drop_column("tasks", "budget_weight_percent")
    op.drop_column("tasks", "weight_percent")
    op.drop_column("task_budget_activities", "zone_weight_percent")
    op.drop_column("task_budget_activities", "category_weight_percent")
    op.drop_constraint(
        "fk_task_budget_activities_zone",
        "task_budget_activities",
        type_="foreignkey",
    )
    op.drop_column("task_budget_activities", "zone_id")
    op.drop_column("task_templates", "budget_weight_percent")
    op.drop_column("task_template_subtasks", "weight_percent")
