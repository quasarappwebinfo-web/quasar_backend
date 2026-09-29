"""
Compresión de imágenes para subir a S3 (mínimo peso usable en UI).
"""
from __future__ import annotations

from io import BytesIO
from typing import Tuple

from PIL import Image, ImageOps

# Lado máximo (px) — suficiente para cards / hero de obra
MAX_SIDE_PX = 1600
# Objetivo de peso; se baja calidad hasta acercarse
TARGET_MAX_BYTES = 250_000  # ~250 KB
MIN_QUALITY = 40
START_QUALITY = 78
ALLOWED_CONTENT_TYPES = {
    "image/jpeg",
    "image/jpg",
    "image/png",
    "image/webp",
    "image/heic",
    "image/heif",
}


class ImageProcessingError(Exception):
    pass


def compress_image_for_upload(
    raw: bytes,
    *,
    content_type: str | None = None,
    max_side: int = MAX_SIDE_PX,
    target_max_bytes: int = TARGET_MAX_BYTES,
) -> Tuple[bytes, str, str]:
    """
    Redimensiona + convierte a WebP con calidad adaptativa.

    Returns:
        (bytes_comprimidos, content_type, extensión)  — siempre image/webp
    """
    if not raw:
        raise ImageProcessingError("Archivo vacío")

    if content_type and content_type.lower() not in ALLOWED_CONTENT_TYPES:
        # Algunos clientes mandan application/octet-stream; intentamos abrir igual
        if content_type.lower() not in ("application/octet-stream", ""):
            raise ImageProcessingError(
                f"Tipo no permitido: {content_type}. Usa JPEG, PNG o WebP."
            )

    try:
        img = Image.open(BytesIO(raw))
        img = ImageOps.exif_transpose(img)
    except Exception as e:
        raise ImageProcessingError(f"No se pudo leer la imagen: {e}") from e

    if img.mode in ("RGBA", "LA"):
        background = Image.new("RGB", img.size, (255, 255, 255))
        alpha = img.split()[-1]
        background.paste(img, mask=alpha)
        img = background
    elif img.mode != "RGB":
        img = img.convert("RGB")

    w, h = img.size
    longest = max(w, h)
    if longest > max_side:
        scale = max_side / float(longest)
        new_size = (max(1, int(w * scale)), max(1, int(h * scale)))
        img = img.resize(new_size, Image.Resampling.LANCZOS)

    quality = START_QUALITY
    output = BytesIO()
    img.save(output, format="WEBP", quality=quality, method=6)
    data = output.getvalue()

    while len(data) > target_max_bytes and quality > MIN_QUALITY:
        quality = max(MIN_QUALITY, quality - 8)
        output = BytesIO()
        img.save(output, format="WEBP", quality=quality, method=6)
        data = output.getvalue()

    # Si aún es enorme, reduce dimensiones otra vez
    side = max_side
    while len(data) > target_max_bytes and side > 800:
        side = int(side * 0.75)
        w, h = img.size
        longest = max(w, h)
        scale = side / float(longest)
        img = img.resize(
            (max(1, int(w * scale)), max(1, int(h * scale))),
            Image.Resampling.LANCZOS,
        )
        output = BytesIO()
        img.save(output, format="WEBP", quality=MIN_QUALITY, method=6)
        data = output.getvalue()

    return data, "image/webp", "webp"
