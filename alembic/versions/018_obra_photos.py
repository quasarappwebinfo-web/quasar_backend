"""Fotos de obra sin actividad.

Revision ID: 018_obra_photos
Revises: 017_worker_pay
Create Date: 2026-10-31
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "018_obra_photos"
down_revision: Union[str, None] = "017_worker_pay"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "obra_photos" in insp.get_table_names():
        return
    op.create_table(
        "obra_photos",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("uuid", sa.String(length=36), nullable=False),
        sa.Column("obra_id", sa.Integer(), nullable=False),
        sa.Column("file_url", sa.String(length=500), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("uploaded_by", sa.Integer(), nullable=False),
        sa.Column(
            "created_at",
            sa.DateTime(),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.ForeignKeyConstraint(
            ["obra_id"],
            ["obras.id"],
            name="fk_obra_photos_obra_id",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.ForeignKeyConstraint(
            ["uploaded_by"],
            ["users.id"],
            name="fk_obra_photos_uploaded_by",
            ondelete="NO ACTION",
            onupdate="NO ACTION",
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("uuid"),
    )
    op.create_index("ix_obra_photos_uuid", "obra_photos", ["uuid"])
    op.create_index("ix_obra_photos_obra_id", "obra_photos", ["obra_id"])


def downgrade() -> None:
    op.drop_index("ix_obra_photos_obra_id", table_name="obra_photos")
    op.drop_index("ix_obra_photos_uuid", table_name="obra_photos")
    op.drop_table("obra_photos")
