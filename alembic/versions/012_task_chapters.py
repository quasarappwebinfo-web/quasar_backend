"""Renombra categoría del Task Pool a capítulo.

Revision ID: 012_task_chapters
Revises: 011_user_permissions
Create Date: 2026-10-22
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "012_task_chapters"
down_revision: Union[str, None] = "011_user_permissions"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _drop_fks_and_indexes(table: str, column: str) -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    fk_names = [
        fk["name"]
        for fk in insp.get_foreign_keys(table)
        if column in (fk.get("constrained_columns") or []) and fk.get("name")
    ]
    index_names = [
        ix["name"]
        for ix in insp.get_indexes(table)
        if (ix.get("column_names") or []) == [column] and ix.get("name")
    ]
    for name in fk_names:
        op.drop_constraint(name, table, type_="foreignkey")
    for name in index_names:
        try:
            op.drop_index(name, table_name=table)
        except Exception:
            # MySQL a veces elimina el índice al soltar la FK.
            pass


def upgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    tables = set(insp.get_table_names())
    if "task_categories" not in tables:
        return

    ba_columns = {c["name"] for c in insp.get_columns("task_budget_activities")}
    for table, column in (
        ("task_templates", "category_id"),
        ("task_budget_activities", "category_id"),
    ):
        if table in tables:
            _drop_fks_and_indexes(table, column)

    op.rename_table("task_categories", "task_chapters")
    op.alter_column(
        "task_templates",
        "category_id",
        new_column_name="chapter_id",
        existing_type=sa.Integer(),
        existing_nullable=False,
    )
    op.alter_column(
        "task_budget_activities",
        "category_id",
        new_column_name="chapter_id",
        existing_type=sa.Integer(),
        existing_nullable=True,
    )
    if "category_weight_percent" in ba_columns:
        op.alter_column(
            "task_budget_activities",
            "category_weight_percent",
            new_column_name="chapter_weight_percent",
            existing_type=sa.Numeric(6, 2),
            existing_nullable=True,
        )

    op.create_foreign_key(
        "fk_task_templates_chapter_id",
        "task_templates",
        "task_chapters",
        ["chapter_id"],
        ["id"],
        ondelete="NO ACTION",
        onupdate="NO ACTION",
    )
    op.create_index(
        "ix_task_templates_chapter_id", "task_templates", ["chapter_id"]
    )
    op.create_foreign_key(
        "fk_task_budget_activities_chapter_id",
        "task_budget_activities",
        "task_chapters",
        ["chapter_id"],
        ["id"],
        ondelete="NO ACTION",
        onupdate="NO ACTION",
    )
    op.create_index(
        "ix_task_budget_activities_chapter_id",
        "task_budget_activities",
        ["chapter_id"],
    )


def downgrade() -> None:
    bind = op.get_bind()
    insp = sa.inspect(bind)
    if "task_chapters" not in set(insp.get_table_names()):
        return

    ba_columns = {c["name"] for c in insp.get_columns("task_budget_activities")}
    for table, column in (
        ("task_templates", "chapter_id"),
        ("task_budget_activities", "chapter_id"),
    ):
        _drop_fks_and_indexes(table, column)

    op.rename_table("task_chapters", "task_categories")
    op.alter_column(
        "task_templates",
        "chapter_id",
        new_column_name="category_id",
        existing_type=sa.Integer(),
        existing_nullable=False,
    )
    op.alter_column(
        "task_budget_activities",
        "chapter_id",
        new_column_name="category_id",
        existing_type=sa.Integer(),
        existing_nullable=True,
    )
    if "chapter_weight_percent" in ba_columns:
        op.alter_column(
            "task_budget_activities",
            "chapter_weight_percent",
            new_column_name="category_weight_percent",
            existing_type=sa.Numeric(6, 2),
            existing_nullable=True,
        )

    op.create_foreign_key(
        "fk_task_templates_category_id",
        "task_templates",
        "task_categories",
        ["category_id"],
        ["id"],
        ondelete="NO ACTION",
        onupdate="NO ACTION",
    )
    op.create_index(
        "ix_task_templates_category_id", "task_templates", ["category_id"]
    )
    op.create_foreign_key(
        "fk_task_budget_activities_category_id",
        "task_budget_activities",
        "task_categories",
        ["category_id"],
        ["id"],
        ondelete="NO ACTION",
        onupdate="NO ACTION",
    )
    op.create_index(
        "ix_task_budget_activities_category_id",
        "task_budget_activities",
        ["category_id"],
    )
