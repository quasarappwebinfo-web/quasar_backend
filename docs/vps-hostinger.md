# VPS Hostinger — pruebas y producción

Un solo servidor. Cuatro sitios:

| Entorno | Front | API |
|---------|--------|-----|
| Pruebas | `https://test.constructoraquasar.com` | `https://api-test.constructoraquasar.com` |
| Producción | `https://app.constructoraquasar.com` | `https://api.constructoraquasar.com` |

Carpetas en el servidor:

```text
/srv/quasar/staging/backend    # este repo
/srv/quasar/staging/front      # build estático del front
/srv/quasar/prod/backend
/srv/quasar/prod/front
```

Puertos (solo localhost, Nginx es la puerta pública):

| | API | MySQL |
|--|-----|-------|
| Pruebas | `8002` | `3309` |
| Producción | `8003` | `3310` |

En el SSH y el `rsync`, cambia `USUARIO` por el usuario con el que ya entras desde tu Mac.

Docker ya está en el VPS. Todo lo de abajo, salvo el build del front, se corre **dentro** de esa sesión SSH.

---

## 0. DNS

En Hostinger → DNS de `constructoraquasar.com`. El registro `@` hoy apunta a `2.57.91.91`; edítalo para que apunte al VPS. El CNAME `www` déjalo como está:

| Tipo | Nombre | Contenido |
|------|--------|-----------|
| A | `@` | `2.25.255.157` |
| CNAME | `www` | `constructoraquasar.com` |

Agrega cuatro registros **A**, todos con contenido `2.25.255.157`:

| Tipo | Nombre | Contenido | Para qué |
|------|--------|-----------|----------|
| A | `test` | `2.25.255.157` | front de pruebas |
| A | `api-test` | `2.25.255.157` | API de pruebas |
| A | `app` | `2.25.255.157` | front de producción |
| A | `api` | `2.25.255.157` | API de producción |

En el campo Nombre va solo el subdominio (`test`, no `test.constructoraquasar.com`). TTL: `300` está bien.

Espera unos minutos y comprueba desde tu Mac: `ping test.constructoraquasar.com` debe responder `2.25.255.157`. El certificado (paso 5) solo funciona cuando los cuatro ya resuelven.

---

## 1. Entrar y dejar Nginx

Desde tu Mac:

```bash
ssh USUARIO@2.25.255.157
```

En el servidor:

```bash
sudo apt update && sudo apt install -y git nginx certbot python3-certbot-nginx
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

---

## 2. Código y variables

```bash
sudo mkdir -p /srv/quasar/staging /srv/quasar/prod
sudo chown -R $USER:$USER /srv/quasar

git clone URL_DEL_REPO /srv/quasar/staging/backend
git clone URL_DEL_REPO /srv/quasar/prod/backend
mkdir -p /srv/quasar/staging/front /srv/quasar/prod/front
```

En **cada** clon, el Compose lee `.env`. Cópialo desde `.env.example` y cambia al menos esto.

Pruebas — `/srv/quasar/staging/backend/.env`:

```env
ENVIRONMENT=staging
DEBUG=false
API_PORT=8002
DB_HOST_PORT=3309
MYSQL_ROOT_PASSWORD=UNA_CLAVE_LARGA
MYSQL_DATABASE=quasar_staging
SECRET_KEY=GENERA_CON_openssl_rand_hex_32
REFRESH_COOKIE_SECURE=true
CORS_ORIGINS=https://test.constructoraquasar.com
```

Producción — `/srv/quasar/prod/backend/.env`: mismas claves, otros valores:

```env
ENVIRONMENT=prod
DEBUG=false
API_PORT=8003
DB_HOST_PORT=3310
MYSQL_DATABASE=quasar_prod
SECRET_KEY=OTRA_CLAVE_DISTINTA
REFRESH_COOKIE_SECURE=true
CORS_ORIGINS=https://app.constructoraquasar.com
```

`SECRET_KEY` y `MYSQL_ROOT_PASSWORD` distintos en cada entorno. Genera claves con `openssl rand -hex 32`.

En los dos `docker-compose` (staging y prod), publica los puertos solo en localhost. API:

```yaml
ports:
  - "127.0.0.1:${API_PORT}:${API_PORT}"
```

MySQL, igual con `DB_HOST_PORT`:

```yaml
ports:
  - "127.0.0.1:${DB_HOST_PORT}:3306"
```

---

## 3. Levantar backend

Pruebas:

```bash
cd /srv/quasar/staging/backend
docker compose -f docker-compose.staging.yml --env-file .env up -d --build
docker compose -f docker-compose.staging.yml --env-file .env exec backend alembic upgrade head
docker compose -f docker-compose.staging.yml --env-file .env exec backend python scripts/crear_primer_usuario.py
```

Producción:

```bash
cd /srv/quasar/prod/backend
docker compose -f docker-compose.prod.yml --env-file .env up -d --build
docker compose -f docker-compose.prod.yml --env-file .env exec backend alembic upgrade head
docker compose -f docker-compose.prod.yml --env-file .env exec backend python scripts/crear_primer_usuario.py
```

Comprueba en el servidor: `curl -s localhost:8002/health` y `curl -s localhost:8003/health`.

---

## 4. Nginx

```bash
sudo nano /etc/nginx/sites-available/quasar
```

```nginx
server {
    listen 80;
    server_name test.constructoraquasar.com;
    root /srv/quasar/staging/front;
    location / {
        try_files $uri $uri/ /index.html;
    }
}

server {
    listen 80;
    server_name api-test.constructoraquasar.com;
    location / {
        proxy_pass http://127.0.0.1:8002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}

server {
    listen 80;
    server_name app.constructoraquasar.com;
    root /srv/quasar/prod/front;
    location / {
        try_files $uri $uri/ /index.html;
    }
}

server {
    listen 80;
    server_name api.constructoraquasar.com;
    location / {
        proxy_pass http://127.0.0.1:8003;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/quasar /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx
```

---

## 5. HTTPS

Cuando el DNS ya apunte al VPS:

```bash
sudo certbot --nginx \
  -d test.constructoraquasar.com -d api-test.constructoraquasar.com \
  -d app.constructoraquasar.com -d api.constructoraquasar.com
```

Certbot renueva solo. El front debe llamar a la API por `https://api-test...` o `https://api...`, nunca por el puerto 8002/8003.

---

## 6. Subir el front

En tu Mac, dentro del repo del frontend (Vite deja el build en `dist/`; si el tuyo es `build/`, cambia la carpeta).

Pruebas — la API del build debe ser `https://api-test.constructoraquasar.com`:

```bash
npm run build
rsync -avz --delete dist/ USUARIO@2.25.255.157:/srv/quasar/staging/front/
```

Producción — la API del build debe ser `https://api.constructoraquasar.com`:

```bash
npm run build
rsync -avz --delete dist/ USUARIO@2.25.255.157:/srv/quasar/prod/front/
```

No hace falta reiniciar Nginx: son archivos estáticos.

---

## Día a día

Siempre en el servidor, salvo el front (se construye en el Mac y se copia con `rsync`).

**Actualizar backend de pruebas** (el compose monta el código; si cambió `requirements.txt`, añade `--build`):

```bash
cd /srv/quasar/staging/backend
git pull
docker compose -f docker-compose.staging.yml --env-file .env up -d
docker compose -f docker-compose.staging.yml --env-file .env exec backend alembic upgrade head
```

**Actualizar backend de producción** (el código va dentro de la imagen: siempre `--build`):

```bash
cd /srv/quasar/prod/backend
git pull
docker compose -f docker-compose.prod.yml --env-file .env up -d --build
docker compose -f docker-compose.prod.yml --env-file .env exec backend alembic upgrade head
```

**Solo migraciones** — mismo `exec backend alembic upgrade head` del entorno que tocaste. Si no hay migraciones nuevas, no hace nada.

**Logs:**

```bash
docker compose -f docker-compose.prod.yml --env-file .env logs -f backend
```

**Reiniciar sin reconstruir:**

```bash
docker compose -f docker-compose.prod.yml --env-file .env restart backend
```
