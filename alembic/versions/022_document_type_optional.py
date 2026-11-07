"""El tipo de documento deja de ser obligatorio.

Revision ID: 022_document_type_optional
Revises: 021_chapter_global
Create Date: 2026-11-07
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "022_document_type_optional"
down_revision: Union[str, None] = "021_chapter_global"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "documents" not in insp.get_table_names():
        return
    column = next(
        (col for col in insp.get_columns("documents") if col["name"] == "document_type_id"),
        None,
    )
    if column and column.get("nullable") is False:
        op.alter_column(
            "documents",
            "document_type_id",
            existing_type=sa.Integer(),
            nullable=True,
        )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "documents" not in insp.get_table_names():
        return
    op.execute(
        sa.text(
            """
            UPDATE documents
            SET document_type_id = (
                SELECT id FROM document_types ORDER BY id LIMIT 1
            )
            WHERE document_type_id IS NULL
            """
        )
    )
    op.alter_column(
        "documents",
        "document_type_id",
        existing_type=sa.Integer(),
        nullable=False,
    )
