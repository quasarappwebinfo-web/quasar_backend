# VPS Hostinger — pruebas y producción

Un solo servidor. Cuatro sitios:

| Entorno | Front | API |
|---------|--------|-----|
| Pruebas | `https://test.constructoraquasar.com` | `https://api-test.constructoraquasar.com` |
| Producción | `https://app.constructoraquasar.com` | `https://api.constructoraquasar.com` |

Carpetas en el servidor:

```text
/srv/quasar/staging/backend     # quasar_backend
/srv/quasar/staging/frontend    # quasar_frontend (Nginx sirve frontend/dist)
/srv/quasar/prod/backend
/srv/quasar/prod/frontend
```

Puertos (solo localhost, Nginx es la puerta pública):

| | API | MySQL |
|--|-----|-------|
| Pruebas | `8002` | `3309` |
| Producción | `8003` | `3310` |

Repos (cuenta GitHub `quasarappwebinfo-web`):

| | Repo | En el Mac (clave de Quasar, no la de JuCaMaL-T) |
|--|------|--------------------------------------------------|
| Backend | `quasar_backend` | `git@github.com-quasar:quasarappwebinfo-web/quasar_backend.git` |
| Front | `quasar_frontend` | `git@github.com-quasar:quasarappwebinfo-web/quasar_frontend.git` |

En el VPS no existe el alias `github.com-quasar`. Cada repo se clona con su propia deploy key: GitHub no acepta la misma clave en los dos repos.

En el SSH, cambia `USUARIO` por el usuario con el que ya entras desde tu Mac.

Docker ya está en el VPS. Todo lo de abajo se corre **dentro** de esa sesión SSH.

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
curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
sudo apt install -y nodejs
sudo ufw allow OpenSSH
sudo ufw allow 80
sudo ufw allow 443
sudo ufw enable
```

---

## 2. Código y variables

Backend y front se clonan dos veces (pruebas y producción). Entra a GitHub con la cuenta `quasarappwebinfo-web` (no con JuCaMaL-T).

Una clave por repo, las dos solo lectura:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_quasar -N ""
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_quasar_front -N ""
cat ~/.ssh/id_ed25519_quasar.pub
cat ~/.ssh/id_ed25519_quasar_front.pub
```

- La primera línea va en `quasar_backend` → Settings → Deploy keys.
- La segunda va en `quasar_frontend` → Settings → Deploy keys.

Si el backend ya clona con `~/.ssh/id_ed25519_quasar`, no regeneres esa clave: solo crea la del front y pégala en `quasar_frontend`.

```bash
cat >> ~/.ssh/config << 'EOF'
Host github.com
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_quasar
  IdentitiesOnly yes

Host github.com-front
  HostName github.com
  User git
  IdentityFile ~/.ssh/id_ed25519_quasar_front
  IdentitiesOnly yes
EOF
chmod 600 ~/.ssh/config
```

```bash
sudo mkdir -p /srv/quasar/staging /srv/quasar/prod
sudo chown -R $USER:$USER /srv/quasar

Pruebas usa la rama `develop`. Producción usa `main`.

```bash
git clone -b develop git@github.com:quasarappwebinfo-web/quasar_backend.git /srv/quasar/staging/backend
git clone -b main git@github.com:quasarappwebinfo-web/quasar_backend.git /srv/quasar/prod/backend
git clone -b develop git@github.com-front:quasarappwebinfo-web/quasar_frontend.git /srv/quasar/staging/frontend
git clone -b main git@github.com-front:quasarappwebinfo-web/quasar_frontend.git /srv/quasar/prod/frontend
```
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
    root /srv/quasar/staging/frontend/dist;
    location / {
        try_files $uri $uri/ /index.html;
    }
}

server {
    listen 80;
    server_name api-test.constructoraquasar.com;
    client_max_body_size 25m;
    location / {
        proxy_pass http://127.0.0.1:8002;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
        proxy_send_timeout 120s;
    }
}

server {
    listen 80;
    server_name app.constructoraquasar.com;
    root /srv/quasar/prod/frontend/dist;
    location / {
        try_files $uri $uri/ /index.html;
    }
}

server {
    listen 80;
    server_name api.constructoraquasar.com;
    client_max_body_size 25m;
    location / {
        proxy_pass http://127.0.0.1:8003;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_read_timeout 120s;
        proxy_send_timeout 120s;
    }
}
```

```bash
sudo ln -s /etc/nginx/sites-available/quasar /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx
```

`client_max_body_size 25m` va en los dos `server` de la API (`api-test` y `api`). Sin eso Nginx rechaza las fotos del celular (el límite de fábrica es 1 MB) y la app las deja en sync. Si Certbot ya creó los bloques `listen 443`, el límite se agrega ahí, no solo en el puerto 80.

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

## 6. Construir el front

En el VPS. `VITE_API_URL` queda grabada en el build; cada entorno tiene la suya. `.env` no se sube a GitHub.

Pruebas:

```bash
cd /srv/quasar/staging/frontend
printf 'VITE_API_URL=https://api-test.constructoraquasar.com\n' > .env
npm ci
npm run build
```

Producción:

```bash
cd /srv/quasar/prod/frontend
printf 'VITE_API_URL=https://api.constructoraquasar.com\n' > .env
npm ci
npm run build
```

Nginx sirve `frontend/dist`. No hace falta reiniciarlo. Si el sitio ya apuntaba a `/srv/quasar/staging/front` o `/srv/quasar/prod/front`, cambia esos `root` por `.../frontend/dist` y recarga Nginx.

---

## Día a día

Todo en el servidor. Pruebas está en `develop`; producción en `main`. `git pull` trae la rama que ya tiene cada carpeta.

**Actualizar front de pruebas:**

```bash
cd /srv/quasar/staging/frontend
git pull
npm ci
npm run build
```

**Actualizar front de producción:**

```bash
cd /srv/quasar/prod/frontend
git pull
npm ci
npm run build
```

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
