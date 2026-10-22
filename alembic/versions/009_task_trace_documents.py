"""Trazabilidad drawer + documentos de tarea.

Revision ID: 009_task_trace_documents
Revises: 008_budget_activity_category
Create Date: 2026-03-24
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "009_task_trace_documents"
down_revision: Union[str, None] = "008_budget_activity_category"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    task_cols = {c["name"] for c in insp.get_columns("tasks")}
    if "updated_by" in task_cols and "task_documents" in insp.get_table_names():
        return
    if "updated_by" not in task_cols:
        op.add_column(
            "tasks",
            sa.Column("updated_by", sa.Integer(), nullable=True),
        )
        op.create_foreign_key(
            "fk_tasks_updated_by",
            "tasks",
            "users",
            ["updated_by"],
            ["id"],
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        )
    if "task_documents" in insp.get_table_names():
        return
    op.create_table(
        "task_documents",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("uuid", sa.String(length=36), nullable=False),
        sa.Column("task_id", sa.Integer(), nullable=False),
        sa.Column("name", sa.String(length=255), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("file_url", sa.String(length=500), nullable=False),
        sa.Column("content_type", sa.String(length=100), nullable=True),
        sa.Column("file_size_bytes", sa.Integer(), nullable=True),
        sa.Column("uploaded_by", sa.Integer(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["task_id"],
            ["tasks.id"],
            name="fk_task_documents_task_id",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.ForeignKeyConstraint(
            ["uploaded_by"],
            ["users.id"],
            name="fk_task_documents_uploaded_by",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("uuid"),
    )
    op.create_index("ix_task_documents_uuid", "task_documents", ["uuid"])


def downgrade() -> None:
    op.drop_index("ix_task_documents_uuid", table_name="task_documents")
    op.drop_table("task_documents")
    op.drop_constraint("fk_tasks_updated_by", "tasks", type_="foreignkey")
    op.drop_column("tasks", "updated_by")
