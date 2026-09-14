# Crear el primer usuario (desde el backend)

El primer administrador **no se crea desde el frontend**. Se crea aquí, en el servidor / Docker, con un script.

## Antes de empezar

1. Estar en la carpeta del proyecto.
2. Levantar el stack **siempre** con el `.env` (si no, Compose avisa que faltan `MYSQL_*` y falla):

```bash
docker compose --env-file .env up --build -d
```

3. Si el puerto de MySQL está ocupado (`Bind ... port is already allocated`), cambia `DB_HOST_PORT` en `.env` (ej. `3309`) y vuelve a levantar.
4. Migraciones:

```bash
docker compose --env-file .env exec backend alembic upgrade head
```

## Crear el admin (recomendado)

```bash
docker compose --env-file .env exec backend python scripts/crear_primer_usuario.py
```

El script te pide:

- Cédula / documento  
- Nombre completo  
- Username (login)  
- Email (opcional)  
- Contraseña (dos veces)

Crea automáticamente:

1. Rol `admin` (si no existe)  
2. Persona  
3. Usuario con rol admin y `is_super=1`

## Sin Docker (local)

Desde la carpeta del proyecto, con `.env` apuntando a MySQL:

```bash
python scripts/crear_primer_usuario.py
```

## Probar el login

- Swagger: http://localhost:8002/docs → `POST /api/v1/auth/login`  
- O con curl:

```bash
curl -X POST "http://localhost:8002/api/v1/auth/login" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=TU_USERNAME&password=TU_PASSWORD" \
  -c cookies.txt
```

## Si algo falla

| Mensaje | Qué hacer |
|---------|-----------|
| Error de conexión a BD | Revisa `.env` y que MySQL esté arriba |
| username ya existe | Elige otro username o usa ese para login |
| documento ya existe | Reutiliza la persona; cambia solo el username |

## Alternativa (comandos sueltos del CLI)

```bash
docker compose exec backend python -m app.cli create-role --name admin
docker compose exec backend python -m app.cli create-person --document "123" --name "Tu Nombre"
docker compose exec backend python -m app.cli create-user --person-id 1 --username admin --role admin
```

Para el primer usuario, el script `crear_primer_usuario.py` es más simple: hace los tres pasos juntos.
