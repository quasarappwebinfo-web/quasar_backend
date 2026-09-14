import hashlib
import logging
import secrets
import uuid
from datetime import datetime, timedelta, timezone

from jose import ExpiredSignatureError, JWTError, jwt
from passlib.context import CryptContext

from app.config import settings

logger = logging.getLogger(__name__)

pwd_context = CryptContext(schemes=["bcrypt_sha256", "bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    expire = now + (
        expires_delta
        if expires_delta
        else timedelta(minutes=settings.access_token_expire_minutes)
    )
    to_encode.update(
        {
            "exp": expire,
            "iat": now,
            "jti": str(uuid.uuid4()),
            "iss": settings.jwt_issuer,
            "aud": settings.jwt_audience,
            "type": "access",
        }
    )
    return jwt.encode(to_encode, settings.secret_key, algorithm=settings.algorithm)


def verify_token(token: str) -> dict | None:
    try:
        payload = jwt.decode(
            token,
            settings.secret_key,
            algorithms=[settings.algorithm],
            audience=settings.jwt_audience,
            issuer=settings.jwt_issuer,
        )
        if payload.get("type") and payload.get("type") != "access":
            logger.warning("JWT con type inesperado: %s", payload.get("type"))
            return None
        return payload
    except ExpiredSignatureError:
        logger.warning("JWT expirado")
        return None
    except JWTError as e:
        logger.warning("JWT inválido: %s", e)
        return None


def generate_refresh_token_value() -> str:
    """Valor opaco que se envía al cliente (cookie). No es un JWT."""
    return secrets.token_urlsafe(48)


def hash_refresh_token(raw_token: str) -> str:
    return hashlib.sha256(raw_token.encode("utf-8")).hexdigest()


def refresh_token_expiry() -> datetime:
    return datetime.utcnow() + timedelta(days=settings.refresh_token_expire_days)
