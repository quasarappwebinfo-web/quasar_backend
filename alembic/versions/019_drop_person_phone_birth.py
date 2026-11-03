"""Quitar teléfono y fecha de nacimiento de personas.

Revision ID: 019_drop_person_phone_birth
Revises: 018_obra_photos
Create Date: 2026-11-03
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "019_drop_person_phone_birth"
down_revision: Union[str, None] = "018_obra_photos"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "persons" not in insp.get_table_names():
        return
    cols = {c["name"] for c in insp.get_columns("persons")}
    if "phone" in cols:
        op.drop_column("persons", "phone")
    if "birth_date" in cols:
        op.drop_column("persons", "birth_date")


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "persons" not in insp.get_table_names():
        return
    cols = {c["name"] for c in insp.get_columns("persons")}
    if "phone" not in cols:
        op.add_column("persons", sa.Column("phone", sa.String(255), nullable=True))
    if "birth_date" not in cols:
        op.add_column("persons", sa.Column("birth_date", sa.Date(), nullable=True))
