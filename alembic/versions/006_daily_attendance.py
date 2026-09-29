"""Daily obra attendance + daily task assignments.

Revision ID: 006_daily_attendance
Revises: 005_template_position_specialty
Create Date: 2026-03-23
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "006_daily_attendance"
down_revision: Union[str, None] = "005_template_position_specialty"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.create_table(
        "obra_daily_attendance",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("obra_id", sa.Integer(), nullable=False),
        sa.Column("work_date", sa.Date(), nullable=False),
        sa.Column("worker_id", sa.Integer(), nullable=False),
        sa.Column("signed_at", sa.DateTime(), nullable=False),
        sa.Column("signature_type", sa.String(length=30), nullable=False),
        sa.Column("signature_data", sa.Text(), nullable=True),
        sa.Column("recorded_by", sa.Integer(), nullable=False),
        sa.Column("ip_address", sa.String(length=45), nullable=True),
        sa.Column("user_agent", sa.String(length=500), nullable=True),
        sa.Column("created_at", sa.DateTime(), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("removed_at", sa.DateTime(), nullable=True),
        sa.Column("removed_by", sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(
            ["obra_id"],
            ["obras.id"],
            name="fk_obra_daily_attendance_obra_id",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.ForeignKeyConstraint(
            ["worker_id"],
            ["workers.id"],
            name="fk_obra_daily_attendance_worker_id",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.ForeignKeyConstraint(
            ["recorded_by"],
            ["users.id"],
            name="fk_obra_daily_attendance_recorded_by",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.ForeignKeyConstraint(
            ["removed_by"],
            ["users.id"],
            name="fk_obra_daily_attendance_removed_by",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_obra_daily_attendance_obra_date",
        "obra_daily_attendance",
        ["obra_id", "work_date"],
    )
    op.create_index(
        "ix_obra_daily_attendance_worker_date",
        "obra_daily_attendance",
        ["worker_id", "work_date"],
    )

    op.create_table(
        "task_daily_assignments",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("task_id", sa.Integer(), nullable=False),
        sa.Column("work_date", sa.Date(), nullable=False),
        sa.Column("worker_id", sa.Integer(), nullable=False),
        sa.Column("assigned_at", sa.DateTime(), server_default=sa.text("CURRENT_TIMESTAMP"), nullable=False),
        sa.Column("assigned_by", sa.Integer(), nullable=False),
        sa.Column("removed_at", sa.DateTime(), nullable=True),
        sa.Column("removed_by", sa.Integer(), nullable=True),
        sa.ForeignKeyConstraint(
            ["task_id"],
            ["tasks.id"],
            name="fk_task_daily_assignments_task_id",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.ForeignKeyConstraint(
            ["worker_id"],
            ["workers.id"],
            name="fk_task_daily_assignments_worker_id",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.ForeignKeyConstraint(
            ["assigned_by"],
            ["users.id"],
            name="fk_task_daily_assignments_assigned_by",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.ForeignKeyConstraint(
            ["removed_by"],
            ["users.id"],
            name="fk_task_daily_assignments_removed_by",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_task_daily_assignments_task_date",
        "task_daily_assignments",
        ["task_id", "work_date"],
    )
    op.create_index(
        "ix_task_daily_assignments_worker_date",
        "task_daily_assignments",
        ["worker_id", "work_date"],
    )


def downgrade() -> None:
    op.drop_index("ix_task_daily_assignments_worker_date", table_name="task_daily_assignments")
    op.drop_index("ix_task_daily_assignments_task_date", table_name="task_daily_assignments")
    op.drop_table("task_daily_assignments")
    op.drop_index("ix_obra_daily_attendance_worker_date", table_name="obra_daily_attendance")
    op.drop_index("ix_obra_daily_attendance_obra_date", table_name="obra_daily_attendance")
    op.drop_table("obra_daily_attendance")
