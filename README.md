# Quasar Backend

API FastAPI con autenticación JWT, MySQL 8, Alembic y Docker Compose (dev / staging / prod).

## Requisitos

- Docker y Docker Compose v2
- (Opcional) Python 3.11+ para desarrollo local sin contenedor

## Arranque rápido (desarrollo)

```bash
# 1. Copiar variables de entorno
cp .env.example .env

# 2. Revisar puertos en .env (API 8002; MySQL host 3309 — 3308 lo usa onix)
# API_PORT=8002
# DB_HOST_PORT=3309

# 3. Levantar stack (usa siempre --env-file .env)
docker compose --env-file .env up --build -d

# 4. Migraciones
docker compose --env-file .env exec backend alembic upgrade head

# 5. Primer usuario admin (script interactivo)
docker compose --env-file .env exec backend python scripts/crear_primer_usuario.py
```

- Docs: http://localhost:8002/docs  
- Health: http://localhost:8002/health  
- Guía primer usuario: [`docs/primer-usuario.md`](docs/primer-usuario.md)

## Variables de entorno

Ver `.env.example`. Lo importante:

| Variable | Descripción | Valor local Quasar |
|----------|-------------|--------------------|
| `API_PORT` | Puerto de la API (host y contenedor) | `8002` |
| `DB_HOST_PORT` | Puerto MySQL en tu máquina → 3306 del contenedor | `3309` (evitar choque con otros proyectos) |
| `DATABASE_URL` | En Compose usa host `db`; en local sin Docker usa `127.0.0.1:${DB_HOST_PORT}` | — |
| `SECRET_KEY` | Clave JWT (cámbiala en staging/prod) | — |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Vida del access JWT | `15` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | Vida del refresh (cookie) | `14` |
| `REFRESH_COOKIE_SECURE` | Cookie solo por HTTPS | `false` local / `true` prod |

## Entornos Compose

```bash
# Desarrollo (docker-compose.yml)
docker compose --env-file .env up --build

# Staging
docker compose -f docker-compose.staging.yml -p quasar_backend_staging --env-file .env.staging up -d

# Producción
docker compose -f docker-compose.prod.yml -p quasar_backend_prod --env-file .env.production up -d
```

Nombres de contenedores / volúmenes / redes usan el prefijo `quasar_backend` para no chocar con otros proyectos en la misma máquina.

## CLI

```bash
python -m app.cli create-role --name admin
python -m app.cli create-person --document "123" --name "Admin Quasar"
python -m app.cli create-user --person-id 1 --username admin --password '...' --role admin
python -m app.cli change-password --username admin
python -m app.cli list-users
python -m app.cli list-roles
```

Estructura de modelos/schemas por dominio → [`docs/estructura-modelos.md`](docs/estructura-modelos.md).

**Primer usuario admin** (obligatorio desde backend) → [`docs/primer-usuario.md`](docs/primer-usuario.md) / `scripts/crear_primer_usuario.py`.

## Endpoints principales

| Método | Ruta | Auth |
|--------|------|------|
| `POST` | `/api/v1/auth/login` | Público (rate limit 5/min); setea cookie refresh HttpOnly |
| `POST` | `/api/v1/auth/refresh` | Cookie refresh; rota y devuelve access nuevo |
| `POST` | `/api/v1/auth/logout` | Revoca refresh y borra cookie |
| `GET` | `/api/v1/auth/me` | Bearer JWT (access) |
| `GET/POST` | `/api/v1/user/users` | Rol `admin` |
| `PUT` | `/api/v1/user/users/{id}` | Rol `admin` |
| `PUT` | `/api/v1/user/users/{id}/update-status` | Rol `admin` |
| `GET` | `/api/v1/user/roles/active` | Rol `admin` |
| `GET` | `/health` | Público |

**Frontend:** auth + obras remotas (offline-first / PWA). Guía → [`docs/auth-frontend.md`](docs/auth-frontend.md).

**Dominio del producto:** núcleo del sistema (obras, Task Pool, planificaciones, firmas, trazabilidad) → [`docs/system-core.md`](docs/system-core.md).

**Qué implementar y en qué orden** → [`docs/hoja-de-ruta.md`](docs/hoja-de-ruta.md).

## Desarrollo local sin Docker (API)

1. Levanta solo MySQL con Compose o usa el `DB_HOST_PORT` ya mapeado.
2. En `.env` cambia `DATABASE_URL` a:

```env
DATABASE_URL=mysql+pymysql://root:TU_PASSWORD@127.0.0.1:3308/quasar_db
```

3. Instala deps y corre:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements-dev.txt
alembic upgrade head
uvicorn app.main:app --host 0.0.0.0 --port 8002 --reload
```

## Estructura

```text
quasar_backend/
├── alembic/
├── app/
│   ├── api/v1/endpoints/   # auth, user
│   ├── core/               # security, timezone, limiter
│   ├── db/                 # base, session
│   ├── models/users/
│   ├── schemas/
│   ├── services/
│   ├── cli.py
│   ├── config.py
│   └── main.py
├── docker/
├── docker-compose.yml
├── docker-compose.staging.yml
├── docker-compose.prod.yml
└── requirements.txt
```
