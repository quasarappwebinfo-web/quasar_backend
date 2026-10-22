"""Valor día y cuenta Nequi del trabajador.

Revision ID: 017_worker_pay
Revises: 016_chapter_stage
Create Date: 2026-10-22
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "017_worker_pay"
down_revision: Union[str, None] = "016_chapter_stage"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    cols = {c["name"] for c in insp.get_columns("workers")}
    if "daily_rate" not in cols:
        op.add_column(
            "workers",
            sa.Column("daily_rate", sa.Numeric(12, 2), nullable=True),
        )
    if "bank_account" not in cols:
        op.add_column(
            "workers",
            sa.Column("bank_account", sa.String(40), nullable=True),
        )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    cols = {c["name"] for c in insp.get_columns("workers")}
    if "bank_account" in cols:
        op.drop_column("workers", "bank_account")
    if "daily_rate" in cols:
        op.drop_column("workers", "daily_rate")
