# Guía del frontend Quasar: auth + obras remotas (offline-first / PWA)

Documento para quien construye el **frontend**. Cubre dos cosas que van juntas desde el día 1:

1. **Cómo autenticarse** con el backend (sin `localStorage` para tokens)
2. **Cómo debe funcionar la app en obras sin señal** (PWA + datos locales + sincronización)

Quasar se usa en **zonas remotas**: no vale “primero online y luego offline”. El frontend debe nacer **offline-first**.

---

# Parte A — Autenticación

## Idea en una frase

| Pieza | Dónde vive | Quién la ve | Para qué sirve |
|--------|------------|-------------|----------------|
| **Access token** (JWT) | Memoria del frontend (variable JS) | Tu código JS | Llamar a la API unos minutos (`Authorization: Bearer …`) |
| **Refresh token** | Cookie `HttpOnly` | Solo el navegador (JS **no** puede leerla) | Pedir un access nuevo sin volver a escribir usuario/contraseña |

El backend **nunca** te pide que guardes el refresh en `localStorage`. Lo manda solo como cookie.

---

## Por qué `localStorage` era mala idea (aunque todo el mundo lo hacía)

Muchos tutoriales hacen esto:

1. Login → el API devuelve `access_token`
2. Frontend: `localStorage.setItem('token', access_token)`
3. En cada request: leer de `localStorage` y poner el header

**Problema:** cualquier script malicioso en tu página (XSS) puede leer esa clave y hacerse pasar por el usuario.

`localStorage` **no es un cofre**. Es un cajón que **todo el JavaScript de tu origen puede abrir**.

**Importante:** eso aplica a **tokens**. Más abajo verás que **sí** usamos almacenamiento local (IndexedDB) para **datos de obra** — eso es otra cosa, y es obligatorio para offline.

| Guardar en el dispositivo | ¿OK? |
|---------------------------|------|
| Access / refresh JWT en `localStorage` | ❌ No |
| Datos de negocio (registros, pendientes de sync) en IndexedDB | ✅ Sí |
| Preferencias no sensibles | ✅ Sí (con cuidado) |

---

## Qué hace el backend hoy (auth)

### 1. Login (`POST /api/v1/auth/login`)

- Body (form OAuth2, como en Swagger): `username` + `password`
- Respuesta JSON: `accessToken`, `expiresIn`, datos de usuario
- Cookie automática: `refresh_token` con flags:
  - `HttpOnly` → JS no la lee
  - `Secure` → en prod con HTTPS (en local suele ir en `false`)
  - `SameSite=Lax` → reduce CSRF
  - `Path=/api/v1/auth` → solo se manda a rutas de auth (refresh/logout)

### 2. Llamadas a la API (cuando hay red)

```http
Authorization: Bearer <access_token>
```

El access va **en memoria** (React state, Zustand, un módulo `auth.ts`, etc.). **No** en `localStorage` ni en `sessionStorage`.

### 3. Cuando el access expire (~15 min)

`POST /api/v1/auth/refresh` **con cookies**:

```js
const res = await fetch('http://localhost:8002/api/v1/auth/refresh', {
  method: 'POST',
  credentials: 'include', // OBLIGATORIO
});
const data = await res.json();
// data.accessToken → guardar otra vez en memoria
```

### 4. Logout

```js
await fetch('http://localhost:8002/api/v1/auth/logout', {
  method: 'POST',
  credentials: 'include',
});
// borrar access de memoria + limpiar lo que corresponda de la sesión en UI
```

---

## Ejemplo mínimo de auth (fetch + memoria)

```js
// authStore.js — access solo en memoria
let accessToken = null;

export function getAccessToken() {
  return accessToken;
}

export function setAccessToken(token) {
  accessToken = token;
}

export function clearAccessToken() {
  accessToken = null;
}

const API = 'http://localhost:8002';

export async function login(username, password) {
  const body = new URLSearchParams();
  body.set('username', username);
  body.set('password', password);

  const res = await fetch(`${API}/api/v1/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    credentials: 'include',
    body,
  });
  if (!res.ok) throw new Error('Login falló');
  const data = await res.json();
  setAccessToken(data.accessToken);
  return data;
}

export async function refreshAccessToken() {
  const res = await fetch(`${API}/api/v1/auth/refresh`, {
    method: 'POST',
    credentials: 'include',
  });
  if (!res.ok) {
    clearAccessToken();
    throw new Error('Sesión expirada');
  }
  const data = await res.json();
  setAccessToken(data.accessToken);
  return data.accessToken;
}

export async function apiFetch(path, options = {}) {
  const headers = new Headers(options.headers || {});
  if (accessToken) headers.set('Authorization', `Bearer ${accessToken}`);

  let res = await fetch(`${API}${path}`, {
    ...options,
    headers,
    credentials: 'include',
  });

  if (res.status === 401) {
    await refreshAccessToken();
    headers.set('Authorization', `Bearer ${accessToken}`);
    res = await fetch(`${API}${path}`, {
      ...options,
      headers,
      credentials: 'include',
    });
  }
  return res;
}

export async function logout() {
  await fetch(`${API}/api/v1/auth/logout`, {
    method: 'POST',
    credentials: 'include',
  });
  clearAccessToken();
}
```

Con **axios**: `axios.defaults.withCredentials = true` y el header `Authorization` con el access en memoria.

---

## CORS

1. El origen del frontend debe estar en `CORS_ORIGINS` del `.env` del backend.
2. Auth y sync con **`credentials: 'include'`** / `withCredentials: true`.
3. En producción: HTTPS y `REFRESH_COOKIE_SECURE=true`.

## Arranque de la app (F5) con red

1. `POST /api/v1/auth/refresh` con `credentials: 'include'`
2. Si OK → access en memoria + opcional `/api/v1/auth/me`
3. Si falla → pantalla de login

## Arranque **sin** red (obras remotas)

1. No habrá refresh ni `/me` contra el servidor.
2. Si **antes** hubo un login exitoso y ya hay **datos locales** del usuario, la app debe abrir en modo offline (ver Parte B).
3. El **primer login** de un dispositivo nuevo **sí necesita internet** una vez (no hay magia: hay que validar usuario/contraseña en el servidor).

---

## Endpoints de auth (referencia)

| Método | Ruta | Cookies | Header Bearer |
|--------|------|---------|---------------|
| `POST` | `/api/v1/auth/login` | Set-Cookie refresh | No |
| `POST` | `/api/v1/auth/refresh` | Envía + rota cookie | No |
| `POST` | `/api/v1/auth/logout` | Revoca y borra cookie | No |
| `GET` | `/api/v1/auth/me` | No hace falta | Sí |

Variables útiles:

- `ACCESS_TOKEN_EXPIRE_MINUTES=15`
- `REFRESH_TOKEN_EXPIRE_DAYS=14`
- `REFRESH_COOKIE_SECURE=false` en local; `true` en HTTPS prod
- `CORS_ORIGINS=...` con la URL exacta del frontend

Si fallan las cookies: ¿`credentials: 'include'`? ¿origen en CORS?

---

# Parte B — Obras remotas: PWA + offline-first + sync

## Por qué esto es obligatorio desde el día 1

En obra a menudo **no hay señal** o es intermitente. El usuario debe poder:

- Abrir la app instalada
- **Usar el flujo de trabajo completo** sobre datos locales
- Y cuando vuelva internet, **sincronizar** con el backend Quasar

Una PWA “solo para instalar” **no alcanza**. Hace falta:

| Pieza | Para qué |
|--------|----------|
| **PWA** (manifest + service worker) | Instalar, abrir sin red, cachear la “cáscara” (HTML/JS/CSS/íconos) |
| **Base local** (IndexedDB u similar) | Guardar datos de negocio y trabajar offline |
| **Cola de pendientes** | Cada create/update/delete offline queda en cola |
| **Sync** (push / pull) | Al recuperar red: subir cambios y bajar los del servidor |

Regla de oro del frontend:

> **Lee y escribe primero en local. El servidor se actualiza cuando hay red.**

No al revés (“solo si el fetch funciona, entonces guardo”).

---

## Qué tiene que hacer el frontend (checklist)

### 1. Convertir el proyecto en PWA

- [ ] `manifest.webmanifest` (nombre Quasar, íconos 192 y 512, `display: standalone`, `start_url`)
- [ ] Service worker (p. ej. con `vite-plugin-pwa` si usas Vite)
- [ ] Cachear el shell de la app (JS/CSS/HTML/íconos)
- [ ] **No** cachear a ciegas respuestas privadas de la API como si fueran estáticos
- [ ] Desplegar en **HTTPS** (en `localhost` el navegador permite PWA para desarrollo)
- [ ] Probar “Añadir a pantalla de inicio” / Instalar en un celular real

### 2. Base de datos local

- [ ] Elegir almacenamiento: **IndexedDB** (recomendado; libs como Dexie) — no uses `localStorage` para datos de obra
- [ ] Tablas/colecciones espejo de lo que el usuario necesita en campo
- [ ] Cada registro nuevo offline nace con **`uuid`** generado en el cliente (no esperes el `id` del servidor para seguir trabajando)
- [ ] Campos útiles: `updatedAt`, `syncStatus` (`synced` | `pending` | `conflict`), `deletedAt` (borrado suave si aplica)

### 3. Cola de sincronización

- [ ] Tabla `outbox` / `pendingSync` con operaciones: `{ id, entity, entityUuid, op, payload, createdAt, tries, lastError }`
- [ ] Cada alta/edición/baja en UI → escribe en IndexedDB **y** encola el cambio
- [ ] Al detectar `online`, procesar la cola (reintentos con backoff)
- [ ] Mostrar en UI: “Sin conexión”, “N cambios pendientes”, “Sincronizando…”, “Al día”

### 4. Capa de datos (patrón recomendado)

```text
Pantalla / formulario
        │
        ▼
  repositorio local (IndexedDB)   ←── siempre
        │
        ├── si hay red ──► sync (push/pull) ──► API Quasar
        └── si no hay red ──► solo local + outbox
```

Las pantallas de obra **no** deberían llamar a `fetch` directo como única fuente de verdad. Llaman al repositorio local; el sync es un servicio aparte.

### 5. Auth + offline juntos

- [ ] Primer login: **con red** → guardar en local lo mínimo de perfil (userId, nombre, rol) para mostrar UI offline
- [ ] Access JWT: solo memoria (Parte A)
- [ ] Sin red: no intentes login/refresh; entra con sesión local ya conocida si existe
- [ ] Al volver la red: `refresh` → si OK, lanzar sync; si el refresh falla, pedir login otra vez (los datos locales pueden conservarse hasta confirmar)

### 6. UX mínima en obra

- [ ] Banner visible de estado de conexión / sync
- [ ] No bloquear al usuario si falla un sync puntual (reintentar después)
- [ ] Evitar pantallas en blanco: si no hay datos locales aún, mensaje claro (“Necesitas conectar una vez para descargar la obra”)

---

## Qué pedirá / tendrá el backend (para que el front se prepare)

Hoy el backend tiene auth, usuarios y base lista. Para sync de obras, el contrato típico (a implementar en Quasar junto con los módulos de negocio) será del estilo:

| Acción | Idea |
|--------|------|
| **Push** | `POST /api/v1/sync/push` — el cliente manda el lote de la outbox |
| **Pull** | `GET /api/v1/sync/pull?since=ISO-8601` — el servidor devuelve cambios desde esa marca |
| **IDs** | El cliente manda `uuid`; el servidor lo respeta / mapea |
| **Conflictos** | Política acordada (p. ej. último `updatedAt` gana, o marcar `conflict` y avisar en UI) |

Hasta que existan esos endpoints, el frontend **igual** puede:

1. Montar PWA + IndexedDB + outbox
2. Implementar el primer módulo de obra **solo local**
3. Dejar el adaptador de sync listo para enchufar al API

No esperes a “tener todo el CRUD online” para empezar el offline: al revés.

---

## Alcance día 1 (no intentes hervir el océano)

**Obligatorio desde el inicio (producto obras remotas):**

1. PWA instalable + app que abre sin red  
2. Un **flujo de negocio real** 100 % usable offline (el más crítico en obra)  
3. Outbox + reintento al recuperar red  
4. Auth según Parte A  

**Puede venir justo después (mismo patrón):**

- Más módulos de obra  
- Fotos (comprimir, cola aparte, subir cuando haya buena señal)  
- Conflictos avanzados / pantallas de resolución  

Antes de codear el módulo 1, acuerda por escrito las **3–5 acciones** que un usuario en obra debe poder hacer sin señal (ej. registrar avance, checklist, novedad, material, foto). Eso define qué tablas van a IndexedDB primero.

---

## Errores comunes (evítalos)

| Error | Por qué duele en obra |
|-------|------------------------|
| App solo funciona si `fetch` responde | Sin señal no hay producto |
| Guardar JWT en `localStorage` “para offline” | Inseguro; el refresh ya está en cookie; el offline se basa en **datos**, no en clavar el access |
| Cachear con service worker toda la API | Riesgo de datos viejos/privados mal servidos |
| Usar solo `id` autoincremental del servidor | Offline no puedes crear registros encadenados con confianza |
| No mostrar estado de sync | El usuario no sabe si “ya subió” o no |
| Primer uso exige 20 pantallas online | En obra necesitan un flujo corto usable ya |

---

## Resumen para quien implementa el front

| Tema | Qué hacer |
|------|-----------|
| Tokens | Access en **memoria**; refresh en **cookie**; `credentials: 'include'` |
| Tokens | Nunca en `localStorage` |
| Datos de obra | Sí en **IndexedDB** (o equivalente) |
| Escrituras | Local primero + **outbox** |
| Red | Al volver: refresh auth → **push** → **pull** |
| PWA | Manifest + service worker; HTTPS en prod |
| Día 1 | Offline-first en el núcleo de obra, no “luego lo vemos” |

---

## Orden de implementación sugerido

1. Auth (Parte A) funcionando en local con el API  
2. PWA (instalar + abrir sin red el shell)  
3. IndexedDB + un módulo de obra offline  
4. Outbox + worker/sync al evento `online`  
5. Conectar push/pull cuando el backend exponga sync  
6. Ampliar módulos con el mismo patrón  

Si algo de auth falla: primero `credentials` y CORS.  
Si algo de offline falla: primero “¿la pantalla lee de IndexedDB o solo del `fetch`?”.
