"""
Cliente S3 para medios de Quasar.
"""
from __future__ import annotations

import uuid
from functools import lru_cache
from typing import Any, Optional

from app.config import settings


class S3ConfigError(Exception):
    pass


class S3UploadError(Exception):
    pass


def _require_s3_config() -> None:
    if not settings.s3_bucket or not settings.aws_access_key_id:
        raise S3ConfigError(
            "S3 no configurado: define S3_BUCKET, AWS_ACCESS_KEY_ID y "
            "AWS_SECRET_ACCESS_KEY en el entorno"
        )


def _boto():
    try:
        import boto3
        from botocore.exceptions import BotoCoreError, ClientError
    except ImportError as e:
        raise S3ConfigError(
            "Falta el paquete boto3 en la imagen. Rebuild: "
            "docker compose build --no-cache backend && docker compose up -d backend"
        ) from e
    return boto3, BotoCoreError, ClientError


@lru_cache(maxsize=1)
def get_s3_client() -> Any:
    _require_s3_config()
    boto3, _, _ = _boto()
    return boto3.client(
        "s3",
        region_name=settings.aws_region,
        aws_access_key_id=settings.aws_access_key_id,
        aws_secret_access_key=settings.aws_secret_access_key,
    )


def build_object_key(*parts: str) -> str:
    """Une prefijo de entorno + carpetas. Ej: quasar-dev/obras/1/cover/uuid.webp"""
    prefix = (settings.s3_key_prefix or "").strip().strip("/")
    cleaned = [p.strip().strip("/") for p in parts if p and str(p).strip()]
    path = "/".join(cleaned)
    return f"{prefix}/{path}" if prefix else path


def obra_cover_key(obra_id: int, extension: str = "webp") -> str:
    return build_object_key(
        "obras",
        str(obra_id),
        "cover",
        f"{uuid.uuid4().hex}.{extension.lstrip('.')}",
    )


def upload_bytes(
    *,
    key: str,
    data: bytes,
    content_type: str,
) -> str:
    """Sube bytes a S3. Devuelve la key."""
    _, BotoCoreError, ClientError = _boto()
    try:
        client = get_s3_client()
        client.put_object(
            Bucket=settings.s3_bucket,
            Key=key,
            Body=data,
            ContentType=content_type,
            CacheControl="public, max-age=31536000",
        )
        return key
    except (BotoCoreError, ClientError) as e:
        raise S3UploadError(f"Error al subir a S3: {e}") from e


def delete_object(key: Optional[str]) -> None:
    if not key:
        return
    _, BotoCoreError, ClientError = _boto()
    try:
        client = get_s3_client()
        client.delete_object(Bucket=settings.s3_bucket, Key=key)
    except (BotoCoreError, ClientError, S3ConfigError):
        pass


def public_object_url(key: str) -> str:
    """
    URL estable virtual-hosted:
    https://{bucket}.s3.{region}.amazonaws.com/{key}
    """
    key = key.lstrip("/")
    base = (settings.s3_public_base_url or "").strip().rstrip("/")
    if base and "tu-bucket" not in base:
        return f"{base}/{key}"
    bucket = settings.s3_bucket
    region = settings.aws_region
    return f"https://{bucket}.s3.{region}.amazonaws.com/{key}"


def presigned_get_url(key: str, expires_in: Optional[int] = None) -> str:
    """URL temporal (solo si el bucket es privado y no usas base pública)."""
    _, BotoCoreError, ClientError = _boto()
    try:
        client = get_s3_client()
        return client.generate_presigned_url(
            "get_object",
            Params={"Bucket": settings.s3_bucket, "Key": key},
            ExpiresIn=expires_in or settings.s3_presign_expire_seconds,
        )
    except (BotoCoreError, ClientError, S3ConfigError):
        return public_object_url(key)


def resolve_media_url(key: Optional[str]) -> Optional[str]:
    """
    Por defecto URL firmada (bucket privado → el <img> del front sí carga).
    Si S3_USE_PRESIGNED_URLS=false y hay base pública + policy de lectura → URL estable.
    """
    if not key:
        return None
    if settings.s3_use_presigned_urls:
        try:
            return presigned_get_url(key)
        except Exception:
            return public_object_url(key)
    return public_object_url(key)
