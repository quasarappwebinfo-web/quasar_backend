"""Zona + actividad presupuestal en Task Pool.

Revision ID: 007_task_zone_budget_activity
Revises: 006_daily_attendance
Create Date: 2026-03-24
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "007_task_zone_budget_activity"
down_revision: Union[str, None] = "006_daily_attendance"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "task_zones",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("name", sa.String(length=150), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("display_order", sa.Integer(), nullable=False),
        sa.Column("is_active", sa.Integer(), server_default="1", nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_table(
        "task_budget_activities",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("name", sa.String(length=150), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("display_order", sa.Integer(), nullable=False),
        sa.Column("is_active", sa.Integer(), server_default="1", nullable=True),
        sa.Column(
            "created_at",
            sa.DateTime(),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column("updated_at", sa.DateTime(), nullable=True),
        sa.PrimaryKeyConstraint("id"),
    )
    op.add_column(
        "task_templates",
        sa.Column("zone_id", sa.Integer(), nullable=True),
    )
    op.add_column(
        "task_templates",
        sa.Column("budget_activity_id", sa.Integer(), nullable=True),
    )
    op.create_foreign_key(
        "fk_task_templates_zone_id",
        "task_templates",
        "task_zones",
        ["zone_id"],
        ["id"],
        ondelete="NO ACTION",
        onupdate="NO ACTION",
    )
    op.create_foreign_key(
        "fk_task_templates_budget_activity_id",
        "task_templates",
        "task_budget_activities",
        ["budget_activity_id"],
        ["id"],
        ondelete="NO ACTION",
        onupdate="NO ACTION",
    )


def downgrade() -> None:
    op.drop_constraint(
        "fk_task_templates_budget_activity_id",
        "task_templates",
        type_="foreignkey",
    )
    op.drop_constraint(
        "fk_task_templates_zone_id",
        "task_templates",
        type_="foreignkey",
    )
    op.drop_column("task_templates", "budget_activity_id")
    op.drop_column("task_templates", "zone_id")
    op.drop_table("task_budget_activities")
    op.drop_table("task_zones")
