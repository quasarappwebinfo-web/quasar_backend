from typing import List

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session, joinedload

from app.core.permissions import (
    user_has_any_permission,
    user_has_permission,
)
from app.core.security import verify_token
from app.db.session import get_db
from app.models import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")


def get_current_user(
    db: Session = Depends(get_db),
    token: str = Depends(oauth2_scheme),
) -> User:
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="No se pudo validar las credenciales",
        headers={"WWW-Authenticate": "Bearer"},
    )
    payload = verify_token(token)
    if payload is None:
        raise credentials_exception

    username: str | None = payload.get("sub")
    if not username:
        raise credentials_exception

    user = (
        db.query(User)
        .options(
            joinedload(User.role),
            joinedload(User.person),
            joinedload(User.permissions),
        )
        .filter(User.username == username)
        .first()
    )
    if user is None:
        raise credentials_exception
    if user.is_active != 1:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuario inactivo",
        )
    return user


def require_role(allowed_roles: List[str]):
    """Compat: exige rol por nombre. Preferir require_permission."""

    def role_checker(current_user: User = Depends(get_current_user)) -> User:
        role_name = current_user.role.name if current_user.role else None
        if role_name not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="No tienes permisos para esta acción",
            )
        return current_user

    return role_checker


def require_permission(*codes: str):
    """
    Exige al menos uno de los códigos.
    Super admin y admin bypassan (acceso pleno).
    """
    if not codes:
        raise ValueError("require_permission necesita al menos un código")

    def permission_checker(
        current_user: User = Depends(get_current_user),
    ) -> User:
        if user_has_any_permission(current_user, codes):
            return current_user
        needed = ", ".join(codes)
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Se requiere permiso: {needed}",
        )

    return permission_checker


def require_all_permissions(*codes: str):
    """Exige todos los códigos (admin/super bypass)."""
    if not codes:
        raise ValueError("require_all_permissions necesita al menos un código")

    def permission_checker(
        current_user: User = Depends(get_current_user),
    ) -> User:
        if all(user_has_permission(current_user, c) for c in codes):
            return current_user
        needed = ", ".join(codes)
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Se requieren permisos: {needed}",
        )

    return permission_checker
