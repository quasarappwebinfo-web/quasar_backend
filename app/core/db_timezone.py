"""
Zona horaria de negocio y de sesión MySQL: hora legal de Colombia (Bogotá).

Colombia usa UTC−5 todo el año (sin horario de verano). Se usa el offset fijo
`-05:00` en MySQL para no depender de tablas de zonas horarias del servidor.

Convención del proyecto:
- Valores `NOW()`, `CURRENT_TIMESTAMP` y `func.now()` en SQL usan esta sesión:
  se guardan y leen como hora local de Colombia.
- Los helpers `get_colombia_time*` y fechas por defecto en Python deben alinearse
  con la misma convención (datetime naive = pared de Bogotá cuando se persiste).
"""
from datetime import datetime, timedelta, timezone

# Offset fijo Colombia (sin DST)
COLOMBIA_UTC_OFFSET = timedelta(hours=-5)
COLOMBIA_TZ = timezone(COLOMBIA_UTC_OFFSET)

# MySQL: SET SESSION time_zone (offset; no requiere mysql.time_zone_* cargadas)
MYSQL_SESSION_TIMEZONE = "-05:00"
MYSQL_SESSION_INIT_COMMAND = f"SET SESSION time_zone = '{MYSQL_SESSION_TIMEZONE}'"


def get_colombia_now() -> datetime:
    """Hora actual en Colombia como datetime naive (pared de Bogotá)."""
    return datetime.now(COLOMBIA_TZ).replace(tzinfo=None)
