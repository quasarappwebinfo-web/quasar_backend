"""Validación de signatureData (nota o data URL base64 de imagen)."""
from __future__ import annotations

import json
from typing import Optional

FORBIDDEN_SIGNATURE_KEYS = (
    "password",
    "passwd",
    "token",
    "access_token",
    "refresh_token",
    "secret",
    "credential",
    "authorization",
)


class SignatureDataError(ValueError):
    pass


def assert_no_secrets(signature_data: Optional[str]) -> None:
    if not signature_data:
        return
    stripped = signature_data.strip()
    # Canvas / imagen en base64: no aplicar chequeo de substrings
    if stripped.startswith("data:image/") and ";base64," in stripped:
        return
    lower = signature_data.lower()
    for key in FORBIDDEN_SIGNATURE_KEYS:
        if key in lower:
            raise SignatureDataError(
                f"signatureData no puede contener '{key}'. "
                "Nunca guardes passwords ni tokens en la firma."
            )
    try:
        parsed = json.loads(signature_data)
        if isinstance(parsed, dict):
            for k in parsed.keys():
                if str(k).lower() in FORBIDDEN_SIGNATURE_KEYS:
                    raise SignatureDataError(
                        f"signatureData no puede incluir la clave '{k}'"
                    )
    except (json.JSONDecodeError, TypeError):
        pass


def is_image_data_url(signature_data: Optional[str]) -> bool:
    if not signature_data:
        return False
    stripped = signature_data.strip()
    return stripped.startswith("data:image/") and ";base64," in stripped
