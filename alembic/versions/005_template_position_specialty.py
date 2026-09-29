"""Add optional specialty_id to task_template_positions.

Revision ID: 005_template_position_specialty
Revises: 004_obras_cover_image
Create Date: 2026-03-19
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "005_template_position_specialty"
down_revision: Union[str, None] = "004_obras_cover_image"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column(
        "task_template_positions",
        sa.Column("specialty_id", sa.Integer(), nullable=True),
    )
    op.create_foreign_key(
        "fk_task_template_positions_specialty_id",
        "task_template_positions",
        "specialties",
        ["specialty_id"],
        ["id"],
        ondelete="NO ACTION",
        onupdate="NO ACTION",
    )


def downgrade() -> None:
    op.drop_constraint(
        "fk_task_template_positions_specialty_id",
        "task_template_positions",
        type_="foreignkey",
    )
    op.drop_column("task_template_positions", "specialty_id")
