from typing import Any, Dict, List, Optional

from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload

from app.core.permissions import (
    ROLE_ADMIN,
    ROLE_SUPER_ADMIN,
    has_full_access,
    is_admin_user,
    is_super_user,
    permission_codes_of,
    validate_permission_codes,
)
from app.core.security import hash_password, verify_password
from app.models import Person, User, UserPermission, UserRole
from app.schemas import ChangePasswordRequest, UserCreate, UserStatusUpdate, UserUpdate


def user_to_dict(user: User) -> Dict[str, Any]:
    return {
        "id": user.id,
        "person_id": user.person_id,
        "username": user.username,
        "email": user.email,
        "role_id": user.role_id,
        "is_super": user.is_super or 0,
        "is_active": user.is_active,
        "deactivation_reason": user.deactivation_reason,
        "person_name": user.person.name if user.person else "",
        "role_name": user.role.name if user.role else "",
        "permissions": permission_codes_of(user),
        "has_full_access": has_full_access(user),
        "created_at": user.created_at,
    }


class UserAlreadyExistsError(Exception):
    pass


class PersonAlreadyHasUserError(Exception):
    """Una persona solo puede tener un usuario de sistema."""

    pass


class UserNotFoundError(Exception):
    pass


class PersonNotFoundForUserError(Exception):
    pass


class RoleNotFoundForUserError(Exception):
    pass


class InvalidPasswordError(Exception):
    pass


class MasterUserProtectedError(Exception):
    pass


class UserPermissionError(Exception):
    """Actor no autorizado a gestionar el target."""

    pass


def _load_user(db: Session, user_id: int) -> Optional[User]:
    return (
        db.query(User)
        .options(
            joinedload(User.role),
            joinedload(User.person),
            joinedload(User.permissions),
        )
        .filter(User.id == user_id)
        .first()
    )


def _assert_can_manage(actor: User, target: User, *, action: str) -> None:
    """
    Reglas:
    - Nadie gestiona a un super admin (salvo el propio cambio de password).
    - Solo un super admin gestiona a un admin.
    - Admin/super gestiona al resto.
    """
    if is_super_user(target):
        raise MasterUserProtectedError(
            f"El super admin no puede ser objeto de: {action}"
        )
    if is_admin_user(target) and not is_super_user(actor):
        raise UserPermissionError(
            f"Solo el super admin puede {action} a un admin"
        )
    if not has_full_access(actor):
        raise UserPermissionError(
            f"Se requiere admin o super admin para {action}"
        )


def _role_is_full_access(role: Optional[UserRole]) -> bool:
    if role is None:
        return False
    return role.name in (ROLE_ADMIN, ROLE_SUPER_ADMIN)


def _replace_permissions(
    db: Session, user: User, codes: Optional[List[str]], *, role: Optional[UserRole]
) -> None:
    """Admin/super no guardan filas; operativos sí."""
    # Borrar actuales
    db.query(UserPermission).filter(UserPermission.user_id == user.id).delete(
        synchronize_session=False
    )
    if _role_is_full_access(role) or (user.is_super or 0) == 1:
        return
    validated = validate_permission_codes(codes)
    for code in validated:
        db.add(UserPermission(user_id=user.id, permission=code))


async def get_user(db: Session, user_id: int) -> User:
    user = _load_user(db, user_id)
    if not user:
        raise UserNotFoundError(f"Usuario con ID {user_id} no encontrado")
    return user


async def create_user(
    db: Session, user: UserCreate, *, actor: User
) -> User:
    if not has_full_access(actor):
        raise UserPermissionError("Se requiere admin o super admin para crear usuarios")

    if not db.query(Person).filter(Person.id == user.person_id).first():
        raise PersonNotFoundForUserError(
            f"No existe persona con ID {user.person_id}"
        )

    person_user = db.query(User).filter(User.person_id == user.person_id).first()
    if person_user:
        raise PersonAlreadyHasUserError(
            f"La persona con ID {user.person_id} ya tiene un usuario "
            f"(username '{person_user.username}')"
        )

    role: Optional[UserRole] = None
    if user.role_id is not None:
        role = db.query(UserRole).filter(UserRole.id == user.role_id).first()
        if not role:
            raise RoleNotFoundForUserError(f"No existe rol con ID {user.role_id}")
        if role.is_active != 1:
            raise RoleNotFoundForUserError(
                f"El rol con ID {user.role_id} está inactivo"
            )
        if role.name == ROLE_SUPER_ADMIN:
            raise UserPermissionError(
                "No se puede asignar el rol super_admin por API "
                "(reservado al dueño / bootstrap)"
            )
        if role.name == ROLE_ADMIN and not is_super_user(actor):
            raise UserPermissionError(
                "Solo el super admin puede crear usuarios con rol admin"
            )

    exists = db.query(User).filter(User.username == user.username).first()
    if exists:
        raise UserAlreadyExistsError("El nombre de usuario ya está en uso")

    # Validar permisos antes de insertar
    if role and not _role_is_full_access(role):
        try:
            validate_permission_codes(user.permissions)
        except ValueError as e:
            raise UserPermissionError(str(e)) from e
    elif user.permissions:
        # Se ignoran en admin, pero avisamos suave: los descartamos
        pass

    db_user = User(
        person_id=user.person_id,
        username=user.username,
        password=hash_password(user.password),
        email=user.email,
        role_id=user.role_id,
        is_super=0,
        is_active=1,
    )
    db.add(db_user)
    try:
        db.flush()
        _replace_permissions(db, db_user, user.permissions, role=role)
        db.commit()
        return _load_user(db, db_user.id)
    except Exception:
        db.rollback()
        raise


async def update_user(
    db: Session,
    user_id: int,
    user_update: UserUpdate,
    *,
    actor: User,
) -> User:
    db_user = _load_user(db, user_id)
    if not db_user:
        raise UserNotFoundError(f"Usuario con ID {user_id} no encontrado")

    _assert_can_manage(actor, db_user, action="actualizar")

    if user_update.username is not None and user_update.username != db_user.username:
        existing_user = (
            db.query(User)
            .filter(User.username == user_update.username, User.id != user_id)
            .first()
        )
        if existing_user:
            raise UserAlreadyExistsError("El nombre de usuario ya está en uso")

    new_role = db_user.role
    if user_update.role_id is not None:
        role = db.query(UserRole).filter(UserRole.id == user_update.role_id).first()
        if not role:
            raise RoleNotFoundForUserError(
                f"No existe rol con ID {user_update.role_id}"
            )
        if role.name == ROLE_SUPER_ADMIN:
            raise UserPermissionError(
                "No se puede asignar el rol super_admin por API"
            )
        if role.name == ROLE_ADMIN and not is_super_user(actor):
            raise UserPermissionError(
                "Solo el super admin puede asignar el rol admin"
            )
        new_role = role

    update_data = user_update.model_dump(exclude_unset=True)
    permissions_provided = "permissions" in update_data
    permissions_value = update_data.pop("permissions", None)

    for field, value in update_data.items():
        setattr(db_user, field, value)

    try:
        if permissions_provided:
            if new_role and not _role_is_full_access(new_role):
                try:
                    validate_permission_codes(permissions_value)
                except ValueError as e:
                    raise UserPermissionError(str(e)) from e
            _replace_permissions(
                db, db_user, permissions_value, role=new_role
            )
        elif user_update.role_id is not None and _role_is_full_access(new_role):
            # Pasó a admin → limpia permisos
            _replace_permissions(db, db_user, None, role=new_role)

        db.commit()
        return _load_user(db, user_id)
    except UserPermissionError:
        db.rollback()
        raise
    except Exception:
        db.rollback()
        raise


async def list_users(
    db: Session,
    status_id: Optional[int] = None,
    page: int = 1,
    search: Optional[str] = None,
) -> Dict[str, Any]:
    limit_per_page = 15
    offset = (page - 1) * limit_per_page

    base_query = db.query(User).options(
        joinedload(User.role),
        joinedload(User.person),
        joinedload(User.permissions),
    )
    if status_id is not None:
        base_query = base_query.filter(User.is_active == status_id)
    if search:
        base_query = base_query.join(Person).filter(
            or_(
                Person.name.ilike(f"%{search}%"),
                User.username.ilike(f"%{search}%"),
                User.email.ilike(f"%{search}%"),
            )
        )

    total_items = base_query.count()
    users = base_query.offset(offset).limit(limit_per_page).all()
    users_data = [user_to_dict(user) for user in users]

    return {
        "users": users_data,
        "pagination": {
            "totalItems": total_items,
            "itemsPerPage": limit_per_page,
            "currentPage": page,
        },
    }


async def update_status_user(
    db: Session,
    user_id: int,
    data: UserStatusUpdate,
    *,
    actor: User,
) -> User:
    user = _load_user(db, user_id)
    if not user:
        raise UserNotFoundError(f"Usuario con ID {user_id} no encontrado")

    _assert_can_manage(actor, user, action="activar/desactivar")

    if data.is_active not in (1, 2):
        raise ValueError("is_active debe ser 1 (activo) o 2 (inactivo)")

    if data.is_active == 2:
        reason = (data.deactivation_reason or "").strip()
        if not reason:
            raise ValueError(
                "deactivation_reason es obligatorio al desactivar un usuario"
            )
        user.is_active = 2
        user.deactivation_reason = reason
    else:
        user.is_active = 1
        user.deactivation_reason = None

    try:
        db.commit()
        return _load_user(db, user.id)
    except Exception:
        db.rollback()
        raise


async def change_password(
    db: Session,
    user_id: int,
    data: ChangePasswordRequest,
    *,
    actor: User,
    require_current: bool,
) -> User:
    """
    Cambia la contraseña de user_id.
    - Propio usuario: exige current_password.
    - Admin/super sobre otro: no exige current; no puede tocar super admin;
      solo super puede tocar admin.
    """
    user = _load_user(db, user_id)
    if not user:
        raise UserNotFoundError(f"Usuario con ID {user_id} no encontrado")

    is_self = actor.id == user_id

    if not is_self:
        if is_super_user(user):
            raise MasterUserProtectedError(
                "No se puede cambiar la contraseña del super admin"
            )
        if is_admin_user(user) and not is_super_user(actor):
            raise UserPermissionError(
                "Solo el super admin puede cambiar la contraseña de un admin"
            )
        if not has_full_access(actor):
            raise PermissionError("No tienes permisos para cambiar esta contraseña")

    if require_current or is_self:
        if not data.current_password:
            raise InvalidPasswordError("Debes indicar la contraseña actual")
        if not verify_password(data.current_password, user.password):
            raise InvalidPasswordError("La contraseña actual es incorrecta")

    user.password = hash_password(data.new_password)
    try:
        db.commit()
        return _load_user(db, user.id)
    except Exception:
        db.rollback()
        raise
