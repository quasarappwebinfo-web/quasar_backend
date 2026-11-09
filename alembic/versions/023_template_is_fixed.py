"""Marca las actividades del catálogo que se copian al crear una obra.

Revision ID: 023_template_is_fixed
Revises: 022_document_type_optional
Create Date: 2026-11-09
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "023_template_is_fixed"
down_revision: Union[str, None] = "022_document_type_optional"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "task_templates" not in insp.get_table_names():
        return
    names = {c["name"] for c in insp.get_columns("task_templates")}
    if "is_fixed" not in names:
        op.add_column(
            "task_templates",
            sa.Column("is_fixed", sa.Integer(), nullable=False, server_default="0"),
        )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "task_templates" not in insp.get_table_names():
        return
    names = {c["name"] for c in insp.get_columns("task_templates")}
    if "is_fixed" in names:
        op.drop_column("task_templates", "is_fixed")
