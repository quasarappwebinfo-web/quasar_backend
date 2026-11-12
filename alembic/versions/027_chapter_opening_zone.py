"""La marca de un capítulo puede ser de una sola zona.

Revision ID: 027_chapter_opening_zone
Revises: 026_zone_weight
Create Date: 2026-11-11
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "027_chapter_opening_zone"
down_revision: Union[str, None] = "026_zone_weight"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    columns = {column["name"] for column in insp.get_columns("obra_chapter_openings")}
    if "zone_id" not in columns:
        op.add_column(
            "obra_chapter_openings",
            sa.Column("zone_id", sa.Integer(), nullable=True),
        )
        op.create_foreign_key(
            "fk_obra_chapter_opening_zone",
            "obra_chapter_openings",
            "task_zones",
            ["zone_id"],
            ["id"],
        )
    indexes = {item["name"] for item in insp.get_indexes("obra_chapter_openings")}
    if "ix_obra_chapter_opening_obra" not in indexes:
        op.create_index(
            "ix_obra_chapter_opening_obra",
            "obra_chapter_openings",
            ["obra_id"],
        )
    uniques = {item["name"] for item in insp.get_unique_constraints("obra_chapter_openings")}
    if "uq_obra_chapter_opening" in uniques:
        op.drop_constraint(
            "uq_obra_chapter_opening", "obra_chapter_openings", type_="unique"
        )
    uniques = {
        item["name"]
        for item in sa.inspect(bind).get_unique_constraints("obra_chapter_openings")
    }
    if "uq_obra_chapter_zone_opening" not in uniques:
        op.create_unique_constraint(
            "uq_obra_chapter_zone_opening",
            "obra_chapter_openings",
            ["obra_id", "chapter_id", "zone_id"],
        )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    uniques = {item["name"] for item in insp.get_unique_constraints("obra_chapter_openings")}
    if "uq_obra_chapter_zone_opening" in uniques:
        op.drop_constraint(
            "uq_obra_chapter_zone_opening", "obra_chapter_openings", type_="unique"
        )
    if "uq_obra_chapter_opening" not in uniques:
        op.create_unique_constraint(
            "uq_obra_chapter_opening",
            "obra_chapter_openings",
            ["obra_id", "chapter_id"],
        )
    columns = {column["name"] for column in insp.get_columns("obra_chapter_openings")}
    if "zone_id" in columns:
        op.drop_constraint(
            "fk_obra_chapter_opening_zone", "obra_chapter_openings", type_="foreignkey"
        )
        op.drop_column("obra_chapter_openings", "zone_id")
