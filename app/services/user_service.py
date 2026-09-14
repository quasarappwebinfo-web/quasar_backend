from typing import Any, Dict, List, Optional

from fastapi import HTTPException, status
from sqlalchemy import or_
from sqlalchemy.orm import Session, joinedload

from app.core.security import hash_password
from app.models import User
from app.schemas import UserCreate, UserUpdate


def user_to_dict(user: User) -> Dict[str, Any]:
    return {
        "id": user.id,
        "person_id": user.person_id,
        "username": user.username,
        "email": user.email,
        "role_id": user.role_id,
        "is_super": user.is_super or 0,
        "is_active": user.is_active,
        "person_name": user.person.name if user.person else "",
        "role_name": user.role.name if user.role else "",
        "created_at": user.created_at,
    }


class UserAlreadyExistsError(Exception):
    pass


class UserNotFoundError(Exception):
    pass


async def create_user(db: Session, user: UserCreate) -> User:
    exists = db.query(User).filter(User.username == user.username).first()
    if exists:
        raise UserAlreadyExistsError("El nombre de usuario ya está en uso")

    db_user = User(
        person_id=user.person_id,
        username=user.username,
        password=hash_password(user.password),
        email=user.email,
        role_id=user.role_id,
        is_super=user.is_super,
        is_active=1,
    )
    db.add(db_user)
    try:
        db.commit()
        db.refresh(db_user)
        return (
            db.query(User)
            .options(joinedload(User.role), joinedload(User.person))
            .filter(User.id == db_user.id)
            .first()
        )
    except Exception:
        db.rollback()
        raise


async def update_user(db: Session, user_id: int, user_update: UserUpdate) -> User:
    db_user = db.query(User).filter(User.id == user_id).first()
    if not db_user:
        raise UserNotFoundError(f"Usuario con ID {user_id} no encontrado")

    if user_update.username is not None and user_update.username != db_user.username:
        existing_user = (
            db.query(User)
            .filter(User.username == user_update.username, User.id != user_id)
            .first()
        )
        if existing_user:
            raise UserAlreadyExistsError("El nombre de usuario ya está en uso")

    update_data = user_update.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(db_user, field, value)

    try:
        db.commit()
        db.refresh(db_user)
        return (
            db.query(User)
            .options(joinedload(User.role), joinedload(User.person))
            .filter(User.id == db_user.id)
            .first()
        )
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

    base_query = db.query(User).options(joinedload(User.role), joinedload(User.person))
    if status_id is not None:
        base_query = base_query.filter(User.is_active == status_id)
    if search:
        from app.models import Person

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


def update_status_user(db: Session, user_id: int) -> User:
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Usuario: {user_id} No Encontrado",
        )
    if user_id == 1 or user.is_super == 1:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario Maestro No Puede Ser Modificado",
        )
    try:
        user.is_active = 2 if user.is_active == 1 else 1
        db.commit()
        db.refresh(user)
        return (
            db.query(User)
            .options(joinedload(User.role), joinedload(User.person))
            .filter(User.id == user.id)
            .first()
        )
    except HTTPException:
        db.rollback()
        raise
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Error Al Cambiar El Estado Del Usuario: {str(e)}",
        )


async def list_active_roles(db: Session) -> List[Dict[str, Any]]:
    from app.models import UserRole

    roles = db.query(UserRole).filter(UserRole.is_active == 1).all()
    return [{"id": role.id, "name": role.name} for role in roles]
