import uuid
from datetime import datetime
from typing import Optional, Tuple

from sqlalchemy.orm import Session, joinedload

from app.core.security import (
    create_access_token,
    generate_refresh_token_value,
    hash_refresh_token,
    refresh_token_expiry,
    verify_password,
)
from app.models import RefreshToken, User


class InvalidCredentialsError(Exception):
    pass


class InactiveUserError(Exception):
    pass


class InvalidRefreshTokenError(Exception):
    pass


def authenticate_user(db: Session, username: str, password: str) -> User:
    user = (
        db.query(User)
        .options(joinedload(User.role), joinedload(User.person))
        .filter(User.username == username)
        .first()
    )
    if not user or not verify_password(password, user.password):
        raise InvalidCredentialsError("Usuario o contraseña incorrectos")
    if user.is_active != 1:
        raise InactiveUserError("Usuario inactivo")
    return user


def build_access_token_for_user(user: User) -> str:
    role_name = user.role.name if user.role else ""
    return create_access_token(
        data={
            "sub": user.username,
            "user_id": user.id,
            "role_name": role_name,
        }
    )


def issue_refresh_token(
    db: Session,
    user: User,
    *,
    user_agent: Optional[str] = None,
    ip_address: Optional[str] = None,
) -> str:
    raw = generate_refresh_token_value()
    row = RefreshToken(
        user_id=user.id,
        jti=str(uuid.uuid4()),
        token_hash=hash_refresh_token(raw),
        expires_at=refresh_token_expiry(),
        user_agent=(user_agent or "")[:512] or None,
        ip_address=(ip_address or "")[:64] or None,
    )
    db.add(row)
    db.commit()
    return raw


def revoke_refresh_token_row(
    db: Session, row: RefreshToken, replaced_by_jti: Optional[str] = None
) -> None:
    row.revoked_at = datetime.utcnow()
    if replaced_by_jti:
        row.replaced_by_jti = replaced_by_jti
    db.add(row)
    db.commit()


def revoke_all_user_refresh_tokens(db: Session, user_id: int) -> None:
    now = datetime.utcnow()
    (
        db.query(RefreshToken)
        .filter(RefreshToken.user_id == user_id, RefreshToken.revoked_at.is_(None))
        .update({"revoked_at": now}, synchronize_session=False)
    )
    db.commit()


def rotate_refresh_token(
    db: Session,
    raw_token: str,
    *,
    user_agent: Optional[str] = None,
    ip_address: Optional[str] = None,
) -> Tuple[User, str, str]:
    token_hash = hash_refresh_token(raw_token)
    row = db.query(RefreshToken).filter(RefreshToken.token_hash == token_hash).first()
    if not row:
        raise InvalidRefreshTokenError("Refresh token inválido")

    if row.revoked_at is not None:
        revoke_all_user_refresh_tokens(db, row.user_id)
        raise InvalidRefreshTokenError("Refresh token reutilizado; sesiones cerradas")

    if row.expires_at < datetime.utcnow():
        revoke_refresh_token_row(db, row)
        raise InvalidRefreshTokenError("Refresh token expirado")

    user = (
        db.query(User)
        .options(joinedload(User.role), joinedload(User.person))
        .filter(User.id == row.user_id)
        .first()
    )
    if not user or user.is_active != 1:
        revoke_refresh_token_row(db, row)
        raise InvalidRefreshTokenError("Usuario inválido o inactivo")

    new_raw = generate_refresh_token_value()
    new_jti = str(uuid.uuid4())
    new_row = RefreshToken(
        user_id=user.id,
        jti=new_jti,
        token_hash=hash_refresh_token(new_raw),
        expires_at=refresh_token_expiry(),
        user_agent=(user_agent or "")[:512] or None,
        ip_address=(ip_address or "")[:64] or None,
    )
    db.add(new_row)
    row.revoked_at = datetime.utcnow()
    row.replaced_by_jti = new_jti
    db.add(row)
    db.commit()

    access = build_access_token_for_user(user)
    return user, access, new_raw


def logout_with_refresh_token(db: Session, raw_token: Optional[str]) -> None:
    if not raw_token:
        return
    token_hash = hash_refresh_token(raw_token)
    row = db.query(RefreshToken).filter(RefreshToken.token_hash == token_hash).first()
    if row and row.revoked_at is None:
        revoke_refresh_token_row(db, row)
