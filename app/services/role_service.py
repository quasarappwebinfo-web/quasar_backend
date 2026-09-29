from typing import Any, Dict, List, Optional

from sqlalchemy.orm import Session

from app.core.permissions import ROLE_SUPER_ADMIN, SYSTEM_ROLE_NAMES
from app.models import UserRole
from app.schemas import UserRoleCreate, UserRoleUpdate


def role_to_dict(role: UserRole) -> Dict[str, Any]:
    return {
        "id": role.id,
        "name": role.name,
        "is_active": role.is_active,
        "is_system": role.name in SYSTEM_ROLE_NAMES,
    }


class RoleAlreadyExistsError(Exception):
    pass


class RoleNotFoundError(Exception):
    pass


class RoleProtectedError(Exception):
    pass


async def create_role(db: Session, data: UserRoleCreate) -> UserRole:
    name = data.name.strip()
    if name == ROLE_SUPER_ADMIN:
        raise RoleProtectedError(
            "El rol super_admin es de sistema y no se crea por API"
        )
    exists = db.query(UserRole).filter(UserRole.name == name).first()
    if exists:
        raise RoleAlreadyExistsError(f"El rol '{name}' ya existe")

    role = UserRole(name=name, is_active=1)
    db.add(role)
    try:
        db.commit()
        db.refresh(role)
        return role
    except Exception:
        db.rollback()
        raise


async def get_role(db: Session, role_id: int) -> UserRole:
    role = db.query(UserRole).filter(UserRole.id == role_id).first()
    if not role:
        raise RoleNotFoundError(f"Rol con ID {role_id} no encontrado")
    return role


async def list_roles(
    db: Session,
    page: int = 1,
    search: Optional[str] = None,
    active_only: bool = False,
) -> Dict[str, Any]:
    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    base_query = db.query(UserRole)
    if active_only:
        base_query = base_query.filter(UserRole.is_active == 1)
    if search:
        base_query = base_query.filter(UserRole.name.ilike(f"%{search.strip()}%"))

    total_items = base_query.count()
    roles = (
        base_query.order_by(UserRole.name.asc())
        .offset(offset)
        .limit(limit_per_page)
        .all()
    )

    return {
        "roles": [role_to_dict(r) for r in roles],
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def list_active_roles(db: Session) -> List[Dict[str, Any]]:
    roles = (
        db.query(UserRole)
        .filter(UserRole.is_active == 1)
        .order_by(UserRole.name.asc())
        .all()
    )
    return [{"id": role.id, "name": role.name} for role in roles]


async def update_role(
    db: Session, role_id: int, data: UserRoleUpdate
) -> UserRole:
    role = await get_role(db, role_id)

    if role.name == ROLE_SUPER_ADMIN:
        raise RoleProtectedError(
            "El rol super_admin no se puede renombrar ni desactivar"
        )

    if data.name is not None and data.name != role.name:
        if data.name.strip() == ROLE_SUPER_ADMIN:
            raise RoleProtectedError("No se puede renombrar a super_admin")
        if role.name in SYSTEM_ROLE_NAMES:
            raise RoleProtectedError(
                f"El rol de sistema '{role.name}' no se puede renombrar"
            )
        conflict = (
            db.query(UserRole)
            .filter(UserRole.name == data.name, UserRole.id != role_id)
            .first()
        )
        if conflict:
            raise RoleAlreadyExistsError(f"El rol '{data.name}' ya existe")

    update_data = data.model_dump(exclude_unset=True)
    if "is_active" in update_data and update_data["is_active"] not in (1, 2):
        raise ValueError("is_active debe ser 1 (activo) o 2 (inactivo)")
    if (
        "is_active" in update_data
        and update_data["is_active"] == 2
        and role.name in (ROLE_SUPER_ADMIN, "admin")
    ):
        raise RoleProtectedError(
            f"El rol '{role.name}' no se puede desactivar"
        )

    for field, value in update_data.items():
        setattr(role, field, value)

    try:
        db.commit()
        db.refresh(role)
        return role
    except Exception:
        db.rollback()
        raise
