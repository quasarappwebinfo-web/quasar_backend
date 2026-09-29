# Guía del frontend Quasar: Identidad (personas, roles, usuarios)

Documento para quien construye el **frontend admin** de la Fase 1 (+ permisos Fase 9).
Complementa [auth-frontend.md](./auth-frontend.md) (login, tokens, offline).

**Auth:** header `Authorization: Bearer <accessToken>`.  
Las rutas de identidad exigen permiso **`identidad`** (admin y super admin lo tienen siempre).

Convención de JSON: el backend usa **camelCase** (`documentNumber`, `personId`, `isActive`, `hasFullAccess`, etc.).

Estados numéricos recurrentes:

| Campo | Valores |
|--------|---------|
| `isActive` (usuarios y roles) | `1` = activo, `2` = inactivo |

Paginación estándar (15 ítems/página):

```json
{
  "pagination": {
    "totalItems": 42,
    "itemsPerPage": 15,
    "currentPage": 1
  }
}
```

---

## Modelo de acceso (Fase 9) — léelo antes de armar la UI

| Nivel | Cómo se reconoce | Acceso | ¿Quién lo gestiona? |
|-------|------------------|--------|---------------------|
| **Super admin** | `isSuper === 1` o `roleName === "super_admin"` | Todo (`hasFullAccess: true`) | **Nadie** lo toca |
| **Admin** | `roleName === "admin"` | Todo (`hasFullAccess: true`) | Solo el **super admin** |
| **Operativo** | cualquier otro rol | Solo `permissions[]` | Admin o super admin |

Reglas de UI:

1. Si `hasFullAccess` → **no** mostrar checklist de permisos (admin/super no usan matriz).
2. Si el usuario editado es super admin → deshabilitar editar / desactivar / reset password / cambiar rol.
3. Si el usuario editado es admin y el actor **no** es super → no permitir editar/desactivar/password.
4. Select de roles al crear: **no** ofrecer `super_admin` (el API ya lo filtra en `/user/roles/active`).
5. Tras login / `GET /auth/me`, guarda `permissions` + `hasFullAccess` para ocultar menús.

Login y `/me` ahora incluyen:

```json
{
  "isSuper": 1,
  "hasFullAccess": true,
  "permissions": ["asistencia", "catalogos", "identidad", "obras"]
}
```

Códigos de permiso (módulos):

| Código | Módulo |
|--------|--------|
| `identidad` | Personas, roles, usuarios |
| `catalogos` | Catálogos maestros |
| `obras` | Obras / clientes / docs |
| `rrhh` | Trabajadores y cuadrillas |
| `asistencia` | Asistencia diaria |
| `task_pool` | Task Pool |
| `tareas` | Tareas en obra |
| `planificacion` | Planes y firmas |
| `sync` | Sync offline |

Catálogo para el checklist:

`GET /api/v1/user/permissions/catalog` → `{ "permissions": [{ "code", "label", "description" }] }`

---

## Flujo de pantallas recomendado

1. **Personas** — alta por cédula (identidad única).
2. **Roles** — etiqueta de negocio (`supervisor`, `maestro`, …). Los de sistema traen `isSystem: true`.
3. **Usuarios** — ligar `personId` + `username` + password + `roleId` + **`permissions`** si no es admin.

No crees un usuario sin persona previa. **Regla:** una persona solo puede tener **un** usuario (`409` si ya tiene).

---

## 1. Personas

Base: `/api/v1/identidad/personas`

### Listar

`GET /api/v1/identidad/personas?page=1&search=opcional`

| Query | Tipo | Uso |
|--------|------|-----|
| `page` | int ≥ 1 | Página |
| `search` | string | Filtra por **nombre** o **documento** |

Respuesta: `{ "persons": [...], "pagination": {...} }`.

### Crear

`POST /api/v1/identidad/personas` → `201`

```json
{
  "documentNumber": "1234567890",
  "name": "Ana Pérez",
  "phone": "3001234567",
  "photoUrl": null,
  "birthDate": "1990-05-12"
}
```

| Código | Significado |
|--------|-------------|
| `201` | Creada |
| `409` | Cédula ya existe |

### Obtener / actualizar

- `GET /api/v1/identidad/personas/{id}`
- `PUT /api/v1/identidad/personas/{id}` — **no** cambia `documentNumber`

---

## 2. Roles

Base: `/api/v1/identidad/roles`

### Listar

`GET /api/v1/identidad/roles?page=1&search=&activeOnly=false`

Campos: `id`, `name`, `isActive`, `isSystem`.

Roles de sistema: `super_admin`, `admin`, `supervisor`, `maestro`, `cliente`.

### Atajo select

`GET /api/v1/user/roles/active` → no incluye `super_admin`.

### Crear / actualizar

- `POST /api/v1/identidad/roles` `{ "name": "coordinador" }`
- `PUT /api/v1/identidad/roles/{id}` — no renombrar sistema ni desactivar `admin`/`super_admin` (`403`)

---

## 3. Usuarios

Base: `/api/v1/user`

### Catálogo de permisos

`GET /api/v1/user/permissions/catalog`

### Listar / obtener

`GET /api/v1/user/users?page=1&statusId=1&search=`  
`GET /api/v1/user/users/{id}`

Campos clave: `isSuper`, `hasFullAccess`, `permissions`, `roleName`, `isActive`, `deactivationReason`.

### Crear

`POST /api/v1/user/users` → `201`

Operativo:

```json
{
  "personId": 2,
  "username": "juan.supervisor",
  "password": "secreto-seguro",
  "email": "juan@empresa.com",
  "roleId": 3,
  "permissions": ["obras", "tareas", "asistencia", "sync"]
}
```

Admin (sin checklist; `permissions` se ignora):

```json
{
  "personId": 3,
  "username": "ana.admin",
  "password": "secreto-seguro",
  "roleId": 2
}
```

| Código | Causa |
|--------|--------|
| `403` | Crear admin sin ser super; asignar `super_admin` |
| `409` | Persona ya tiene usuario |

### Actualizar

`PUT /api/v1/user/users/{id}`

```json
{
  "username": "juan.supervisor",
  "roleId": 3,
  "permissions": ["obras", "tareas", "sync"]
}
```

Omitir `permissions` = no tocar. `permissions: []` = quitar todos. Pasar a `admin` limpia filas.

`isSuper` ya no se envía por API.

### Activar / desactivar

`PUT /api/v1/user/users/{id}/update-status`

```json
{ "isActive": 2, "deactivationReason": "Fin de contrato" }
```

`403` si es super, o admin gestionado por no-super.

### Password

- `PUT /api/v1/user/users/{id}/password` `{ "newPassword": "…" }` (admin/super; no toca super)
- `PUT /api/v1/user/me/password` con `currentPassword`

---

## Matriz rápida

| Acción | Método | Ruta | Permiso |
|--------|--------|------|---------|
| Catálogo permisos | GET | `/api/v1/user/permissions/catalog` | identidad |
| Personas / roles | … | `/api/v1/identidad/…` | identidad |
| Usuarios | … | `/api/v1/user/users…` | identidad |
| Password propia | PUT | `/api/v1/user/me/password` | autenticado |

---

## Checklist frontend

- [ ] Guardar `permissions` + `hasFullAccess` tras login/`/me` y filtrar menú
- [ ] Pantallas Personas / Roles / Usuarios
- [ ] Checklist de permisos solo si el target **no** tiene full access
- [ ] Bloquear acciones sobre super admin; admins solo editables por super
- [ ] Modal desactivar con motivo
- [ ] Reset password + cambiar mi contraseña

Catálogos: [catalogos-frontend.md](./catalogos-frontend.md).
