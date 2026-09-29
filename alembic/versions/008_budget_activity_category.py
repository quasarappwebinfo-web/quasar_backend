"""Link budget activities to task categories.

Revision ID: 008_budget_activity_category
Revises: 007_task_zone_budget_activity
Create Date: 2026-03-24
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "008_budget_activity_category"
down_revision: Union[str, None] = "007_task_zone_budget_activity"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "task_budget_activities",
        sa.Column("category_id", sa.Integer(), nullable=True),
    )
    op.create_foreign_key(
        "fk_task_budget_activities_category_id",
        "task_budget_activities",
        "task_categories",
        ["category_id"],
        ["id"],
        ondelete="NO ACTION",
        onupdate="NO ACTION",
    )
    op.create_index(
        "ix_task_budget_activities_category_id",
        "task_budget_activities",
        ["category_id"],
    )


def downgrade() -> None:
    op.drop_index(
        "ix_task_budget_activities_category_id",
        table_name="task_budget_activities",
    )
    op.drop_constraint(
        "fk_task_budget_activities_category_id",
        "task_budget_activities",
        type_="foreignkey",
    )
    op.drop_column("task_budget_activities", "category_id")
