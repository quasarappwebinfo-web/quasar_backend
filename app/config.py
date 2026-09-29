"""
Configuración centralizada — única fuente de verdad para variables de entorno.
"""
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Todas las variables se leen desde `.env` en desarrollo; en prod, del entorno del proceso."""

    model_config = SettingsConfigDict(env_file=".env", case_sensitive=False, extra="ignore")

    database_url: str
    mysql_root_password: str = ""
    mysql_database: str = "quasar_db"

    secret_key: str
    algorithm: str = "HS256"
    # Access JWT corto; el refresh (cookie HttpOnly) mantiene la sesión.
    access_token_expire_minutes: int = 15
    refresh_token_expire_days: int = 14

    jwt_issuer: str = "quasar_backend"
    jwt_audience: str = "quasar_frontend"

    refresh_cookie_name: str = "refresh_token"
    refresh_cookie_path: str = "/api/v1/auth"
    # En local HTTP debe ser false; en prod/staging con HTTPS: true
    refresh_cookie_secure: bool = False
    refresh_cookie_samesite: str = "lax"

    app_name: str = "Quasar Backend"
    debug: bool = False
    environment: str = "local"

    api_port: int = 8002

    cors_origins: str = (
        "http://localhost,http://localhost:3000,http://localhost:5173,"
        "http://127.0.0.1,http://127.0.0.1:3000"
    )

    # AWS S3 — opcionales hasta implementar uploads
    aws_region: str = "us-east-2"
    aws_access_key_id: str = ""
    aws_secret_access_key: str = ""
    s3_bucket: str = ""
    s3_key_prefix: str = ""
    s3_public_base_url: str = ""
    # true = coverImageUrl firmada (bucket privado). false = URL pública (requiere policy).
    s3_use_presigned_urls: bool = True
    s3_presign_expire_seconds: int = 86400  # 24h para cards del front

    def get_database_url(self) -> str:
        url = self.database_url
        if "${MYSQL_ROOT_PASSWORD}" in url:
            url = url.replace("${MYSQL_ROOT_PASSWORD}", self.mysql_root_password)
        if "${MYSQL_DATABASE}" in url:
            url = url.replace("${MYSQL_DATABASE}", self.mysql_database)
        return url


settings = Settings()
