"""
Sesión de base de datos: engine, sessionmaker y dependencia get_db para FastAPI.
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.config import settings
from app.core.db_timezone import MYSQL_SESSION_INIT_COMMAND

db_url = settings.get_database_url()

if not db_url or not str(db_url).strip():
    raise ValueError("DATABASE_URL no está configurada correctamente (revisa .env).")

engine = create_engine(
    db_url,
    pool_pre_ping=True,
    pool_recycle=3600,
    echo=settings.debug,
    connect_args={"init_command": MYSQL_SESSION_INIT_COMMAND},
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
