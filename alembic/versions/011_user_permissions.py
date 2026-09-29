"""Permisos por usuario + roles de sistema (Fase 9).

Revision ID: 011_user_permissions
Revises: 010_progress_weights
Create Date: 2026-09-25
"""
from typing import Sequence, Union

import sqlalchemy as sa
from alembic import op

revision: str = "011_user_permissions"
down_revision: Union[str, None] = "010_progress_weights"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

SYSTEM_ROLES = (
    "super_admin",
    "admin",
    "supervisor",
    "maestro",
    "cliente",
)


def upgrade() -> None:
    op.create_table(
        "user_permissions",
        sa.Column("id", sa.Integer(), autoincrement=True, nullable=False),
        sa.Column("user_id", sa.Integer(), nullable=False),
        sa.Column("permission", sa.String(length=50), nullable=False),
        sa.ForeignKeyConstraint(
            ["user_id"],
            ["users.id"],
            name="fk_user_permissions_user_id",
            ondelete="CASCADE",
            onupdate="NO ACTION",
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("user_id", "permission", name="uq_user_permission"),
    )
    op.create_index(
        "ix_user_permissions_user_id",
        "user_permissions",
        ["user_id"],
        unique=False,
    )

    # Roles de sistema (idempotente)
    roles = sa.table(
        "users_roles",
        sa.column("id", sa.Integer),
        sa.column("name", sa.String),
        sa.column("is_active", sa.Integer),
    )
    conn = op.get_bind()
    existing = {
        row[0]
        for row in conn.execute(sa.select(roles.c.name)).fetchall()
    }
    for name in SYSTEM_ROLES:
        if name not in existing:
            conn.execute(
                roles.insert().values(name=name, is_active=1)
            )


def downgrade() -> None:
    op.drop_index("ix_user_permissions_user_id", table_name="user_permissions")
    op.drop_table("user_permissions")
