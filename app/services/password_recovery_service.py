"""Recuperación de acceso con código de un solo uso enviado al correo."""
import hashlib
import logging
import secrets
from datetime import datetime, timedelta
from typing import Optional

from sqlalchemy import func
from sqlalchemy.orm import Session

from app.config import settings
from app.core.security import hash_password
from app.models import PasswordResetCode, RefreshToken, User
from app.services.mail_service import send_email

logger = logging.getLogger(__name__)

CODE_DIGITS = 6
MAX_ATTEMPTS = 5
RESEND_COOLDOWN_SECONDS = 60

REQUEST_MESSAGE = (
    "Si el usuario tiene correo, enviamos un código para recuperar el acceso."
)


class InvalidResetCodeError(Exception):
    pass


def _now() -> datetime:
    return datetime.utcnow()


def _hash_code(user_id: int, code: str) -> str:
    raw = f"{user_id}:{code}".encode("utf-8")
    return hashlib.sha256(raw).hexdigest()


def _find_user(db: Session, identifier: str) -> Optional[User]:
    ident = identifier.strip()
    if not ident:
        return None
    by_username = db.query(User).filter(User.username == ident).all()
    rows = by_username or (
        db.query(User).filter(func.lower(User.email) == ident.lower()).all()
    )
    if len(rows) != 1:
        return None
    user = rows[0]
    if user.is_active != 1:
        return None
    if not (user.email or "").strip():
        return None
    return user


def _latest_open_code(db: Session, user_id: int) -> Optional[PasswordResetCode]:
    return (
        db.query(PasswordResetCode)
        .filter(
            PasswordResetCode.user_id == user_id,
            PasswordResetCode.used_at.is_(None),
        )
        .order_by(PasswordResetCode.id.desc())
        .first()
    )


def request_password_reset(db: Session, identifier: str) -> None:
    """Siempre termina igual si el correo sale o si no hay a quién escribirle.

    Quien llama distingue solo cuando el envío no está configurado o falla.
    """
    user = _find_user(db, identifier)
    if user is None:
        return

    now = _now()
    latest = _latest_open_code(db, user.id)
    if latest and latest.created_at and latest.created_at > now - timedelta(
        seconds=RESEND_COOLDOWN_SECONDS
    ):
        return

    (
        db.query(PasswordResetCode)
        .filter(
            PasswordResetCode.user_id == user.id,
            PasswordResetCode.used_at.is_(None),
        )
        .update({"used_at": now}, synchronize_session=False)
    )
    code = f"{secrets.randbelow(10 ** CODE_DIGITS):0{CODE_DIGITS}d}"
    row = PasswordResetCode(
        user_id=user.id,
        code_hash=_hash_code(user.id, code),
        expires_at=now + timedelta(minutes=settings.password_reset_code_minutes),
        attempts=0,
        created_at=now,
    )
    db.add(row)
    db.commit()

    minutes = settings.password_reset_code_minutes
    body = (
        f"Recibimos una solicitud para recuperar el acceso de {user.username}.\n\n"
        f"Tu usuario es: {user.username}\n"
        f"Código: {code}\n\n"
        f"Vence en {minutes} minutos y solo sirve una vez. "
        "Si no fuiste tú, ignora este correo."
    )
    try:
        send_email(
            to=user.email.strip(),
            subject="Código para recuperar tu acceso a Quasar",
            body=body,
        )
    except Exception:
        row.used_at = _now()
        db.commit()
        raise
    logger.info("Código de recuperación enviado al usuario %s", user.id)


def confirm_password_reset(
    db: Session, identifier: str, code: str, new_password: str
) -> None:
    user = _find_user(db, identifier)
    row = _latest_open_code(db, user.id) if user else None
    now = _now()
    if (
        row is None
        or row.expires_at < now
        or row.attempts >= MAX_ATTEMPTS
        or not code.isdigit()
        or len(code) != CODE_DIGITS
    ):
        if row is not None and (row.expires_at < now or row.attempts >= MAX_ATTEMPTS):
            row.used_at = now
            db.commit()
        raise InvalidResetCodeError("El código no es válido o ya venció.")

    row.attempts += 1
    if not secrets.compare_digest(row.code_hash, _hash_code(user.id, code)):
        if row.attempts >= MAX_ATTEMPTS:
            row.used_at = now
        db.commit()
        raise InvalidResetCodeError("El código no es válido o ya venció.")

    user.password = hash_password(new_password)
    row.used_at = now
    (
        db.query(RefreshToken)
        .filter(RefreshToken.user_id == user.id, RefreshToken.revoked_at.is_(None))
        .update({"revoked_at": now}, synchronize_session=False)
    )
    db.commit()
