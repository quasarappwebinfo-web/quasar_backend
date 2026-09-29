# Guía del frontend Quasar: Obras (Fase 4)

CRUD de obras, clientes, historial de etapas, metadatos de documentos e imagen principal.

Complementa:
- [catalogos-frontend.md](./catalogos-frontend.md) — tipos de venta, etapas, tipos de documento
- [identidad-frontend.md](./identidad-frontend.md) — personas (clientes)
- [rrhh-frontend.md](./rrhh-frontend.md) — asignar gente a `obraId`

**Auth:** Bearer + rol **`admin`**. JSON **camelCase**.  
En el frontend Quasar el access token va en memoria y el refresh en cookie HttpOnly (`credentials: 'include'`).

---

## Mapa de pantallas (IA real)

Las obras **no** viven en un módulo “Proyectos” aparte: van en el **Dashboard** (Figma *Dashboard View* + *Project View*).

| Ruta frontend | Pantalla | Contenido |
|---------------|----------|-----------|
| `/dashboard` | Listado / KPIs | Tarjetas de obra, búsqueda, “Nueva obra”, KPIs |
| `/dashboard/obras/:obraId` | Project View | Stepper de etapas, sitio, métricas, admin (etapa/clientes/docs) |
| `/dashboard/maestros/*` | Maestros de obra | Tipos de venta, etapas, tipos de documento |
| `/projects` | Redirect | → `/dashboard` |

Sidebar: en el detalle de obra se marca **Proyectos**; en el listado, **Dashboard**.

Carpeta feature: `src/obras/` (APIs, tipos, Dashboard, Project View, maestros).

---

## Status de obra (canónicos)

| Valor | Uso UI |
|--------|--------|
| `planning` | En planificación (default al crear) |
| `in_progress` | En ejecución |
| `on_hold` | Pausada |
| `completed` | Finalizada / “Lista” en tarjeta |
| `cancelled` | Cancelada |

`isActive` (`1`/`2`) es baja lógica del registro; **no** sustituye a `status`.

`currentStageId` es la **etapa constructiva** (catálogo `/obras/etapas`), distinta del status.

### Heurísticas de UI (sin API de avance/tareas aún)

| Señal | Cómo se calcula hoy |
|--------|---------------------|
| Progreso % | Índice de `currentStageId` en etapas ordenadas por `displayOrder` (100% si `completed`) |
| “A tiempo” / “Retraso” | Retraso si `estimatedEndDate` &lt; hoy y la obra no está finalizada/cancelada |
| Personal en sitio | Conteos desde `GET /rrhh/asignaciones?currentOnly=true` |
| Estado de tareas / “Tareas recientes” | [tareas-frontend.md](./tareas-frontend.md) (Fase 6) |

---

## Imagen principal (cover)

Campo en respuestas: **`coverImageUrl`** (URL firmada S3, temporal).

| Acción | Método | Ruta |
|--------|--------|------|
| Subir / reemplazar | `PUT` | `/api/v1/obras/{id}/imagen-principal` |
| Quitar | `DELETE` | `/api/v1/obras/{id}/imagen-principal` |

- Body: `multipart/form-data`, campo **`file`** (JPEG/PNG/WebP, máx. **15 MB** de entrada).
- El backend **comprime** a WebP (~250 KB, lado máx. 1600 px) y sube a S3:
  `{S3_KEY_PREFIX}obras/{obraId}/cover/{uuid}.webp`
- `coverImageUrl` en la respuesta del API es una **URL firmada** (presigned), válida ~24 h.
  El bucket suele ser privado: el link “bonito” sin firma da `AccessDenied` en el navegador.
- Si quieres links públicos permanentes, en S3 → bucket → Permissions → Bucket policy:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadCovers",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::TU-BUCKET/quasar-dev/obras/*/cover/*"
    }
  ]
}
```

  y en `.env`: `S3_USE_PRESIGNED_URLS=false` (también hay que relajar Block Public Access para esa policy).
- Flujo UI: **1)** `POST /obras` → **2)** `PUT .../imagen-principal` (también al editar).
- Al reemplazar, se borra la imagen anterior en S3.
- **No** mandes `Content-Type: application/json` en este `fetch`; deja que el browser ponga el boundary del multipart.
- Sí envía `Authorization: Bearer …` (y `credentials: 'include'` si usas el cliente Quasar).

Ejemplo:

```js
const form = new FormData()
form.append('file', fileInput.files[0])
await fetch(`${API}/api/v1/obras/${obraId}/imagen-principal`, {
  method: 'PUT',
  headers: { Authorization: `Bearer ${accessToken}` },
  credentials: 'include',
  body: form,
})
```

**UI:** en tarjetas del Dashboard y en “Sitio de trabajo” de Project View usar `coverImageUrl` cuando exista; si no, placeholder local.

> Estado frontend Quasar: tipado `coverImageUrl`, upload/quitar en modal de obra, y visualización en tarjetas + Sitio de trabajo.

---

## Matriz de endpoints

| Recurso | Rutas base | Colección lista |
|---------|------------|-----------------|
| Obras | `/api/v1/obras` | `obras` |
| Imagen principal | `PUT/DELETE /api/v1/obras/{id}/imagen-principal` | — (devuelve obra) |
| Cambiar etapa | `PUT /api/v1/obras/{id}/etapa` | — |
| Historial etapas | `GET /api/v1/obras/{id}/etapas-historial` | `history` |
| Clientes | `/api/v1/obras/{id}/clientes` · `/api/v1/obras/clientes/{id}` | `clients` |
| Documentos | `/api/v1/obras/{id}/documentos` · `/api/v1/obras/documentos/{id}` | `documents` |

Catálogos (maestros, CRUD admin):

| Catálogo | Base | Colección |
|----------|------|-----------|
| Tipos de venta | `/api/v1/obras/tipos-venta` | `saleTypes` |
| Etapas | `/api/v1/obras/etapas` | `stages` (ordenar por `displayOrder`) |
| Tipos de documento | `/api/v1/obras/tipos-documento` | `documentTypes` |

Selects: `?activeOnly=true`. Paginación estándar (`totalItems`, `itemsPerPage`, `currentPage`, 15/página).

---

## 4.1 Obras

### Listar

`GET /api/v1/obras?page=1&search=&status=&city=&currentStageId=&activeOnly=`

| Query | Uso |
|--------|-----|
| `search` | Nombre o código |
| `status` | Uno de los 5 canónicos |
| `city` | Ciudad |
| `currentStageId` | Etapa constructiva |
| `activeOnly` | Solo `isActive=1` |

### Crear (cliente **no** obligatorio)

`POST /api/v1/obras` → `201`

```json
{
  "name": "Residencial Los Pinos",
  "code": "OBR-001",
  "saleTypeId": 1,
  "address": "Calle 10 #20-30",
  "city": "Medellín",
  "neighborhood": "Laureles",
  "startDate": "2026-04-01",
  "estimatedEndDate": "2026-12-01",
  "currentStageId": 1,
  "status": "planning"
}
```

- Si envías `currentStageId`, se crea también la primera fila de historial.
- `code` único si se envía → `409` si duplica.
- `saleTypeId` debe existir y estar activo.

### Actualizar

`PUT /api/v1/obras/{id}` — datos generales / status / `isActive`.  
**No** cambies etapa aquí (usar `PUT .../etapa`).

### Cambiar etapa

`PUT /api/v1/obras/{id}/etapa`

```json
{
  "stageId": 2,
  "plannedStartDate": "2026-05-01",
  "plannedEndDate": "2026-06-15",
  "actualStartDate": "2026-05-02"
}
```

Actualiza `currentStageId` + inserta en `obra_stage_history`. Misma etapa → `400`.

### Historial

`GET /api/v1/obras/{id}/etapas-historial` → `{ "history": [...], "pagination": {...} }`

### Respuesta obra

Incluye: `id`, `name`, `code`, `saleTypeId`, `saleTypeName`, ubicación, fechas, `currentStageId`, `currentStageName`, `status`, **`coverImageUrl`**, `isActive`, `createdAt`.

---

## 4.2 Clientes de obra

Roles permitidos: **`comprador`**, **`propietario`**, **`contacto`**.

### Listar / agregar

- `GET /api/v1/obras/{obraId}/clientes?currentOnly=true`
- `POST /api/v1/obras/{obraId}/clientes`

```json
{
  "personId": 3,
  "role": "comprador",
  "isPrimary": 1,
  "startDate": "2026-04-01"
}
```

- Persona vigente ya en la obra → `409`
- `isPrimary: 1` desmarca otros primarios vigentes
- Historial: no borrar; **cerrar** con `endDate`

### Actualizar / cerrar

- `PUT /api/v1/obras/clientes/{clientId}`
- `PUT /api/v1/obras/clientes/{clientId}/cerrar?endDate=2026-06-01` (si omites fecha → hoy)

Respuesta: `personName`, `documentNumber`, `role`, `isPrimary`, fechas.

**UI:** obra “para venta” puede crearse sin cliente; asociar después en Project View → Administrar → Clientes.

---

## 4.3 Documentos

Por ahora: **metadatos + `fileUrl`** (URL ya subida o placeholder). Storage de archivos de documento (S3) aparte de la cover.

### Listar / crear

- `GET /api/v1/obras/{obraId}/documentos?search=&visibleToClient=`
- `POST /api/v1/obras/{obraId}/documentos`

```json
{
  "uuid": null,
  "documentTypeId": 1,
  "name": "Licencia",
  "description": "Permiso municipal",
  "fileUrl": "https://files.example.com/licencia.pdf",
  "isVisibleToClient": 1
}
```

- Si `uuid` viene vacío/null → el backend genera UUID (sync offline futuro)
- Si el cliente manda uuid duplicado → `409`
- `uploadedBy` = usuario autenticado

### Ver / editar

- `GET /api/v1/obras/documentos/{id}`
- `PUT /api/v1/obras/documentos/{id}` — name, description, fileUrl, isVisibleToClient (no uuid)

---

## Flujo de pantalla

1. **Maestros** (`/dashboard/maestros`): tipo de venta + etapas (+ tipos documento)
2. **Dashboard** → Nueva obra (sin cliente; opcional etapa inicial)
3. Subir **imagen principal** en el modal (crear/editar) → `PUT .../imagen-principal`
4. Abrir **Project View** → stepper refleja etapas; “Administrar obra” para etapa / clientes / docs
5. RRHH: asignar trabajadores / cuadrillas con ese `obraId`
6. (Futuro) tareas reales alimentan métricas y “Tareas recientes”

### Project View — bloques

1. Header: nombre + “Vista General Del Proyecto” + rango de fechas
2. **Progreso de la construcción** — stepper (Terminado / En progreso / Siguiente)
3. **Sitio de trabajo** — cover + thumbs (galería completa pendiente)
4. **Global / Periodo / Estado tareas** — anillos (tareas aún placeholder)
5. **Tareas recientes** — placeholder → `/tasks`
6. **Administrar obra** — pestañas Etapas · Clientes · Documentos (+ editar / baja)

Modales: overlay a viewport completo (portal a `document.body`); responsive en teléfono.

---

## Checklist frontend

### Hecho en Quasar (`src/obras/`)

- [x] Obras en Dashboard (no módulo Proyectos aislado)
- [x] Project View alineada a Figma
- [x] CRUD obras (crear / editar / `isActive`)
- [x] Select status con los 5 valores canónicos
- [x] Cambio de etapa + historial
- [x] Clientes: roles, primario, cerrar vínculo
- [x] Documentos: alta con `fileUrl` + flag visible al cliente
- [x] Manejo `409` en `code` de obra (y mensajes de conflicto en clientes/docs)
- [x] Maestros: tipos de venta, etapas, tipos de documento
- [x] Layout responsive (dashboard + project view + modales)

### Pendiente / mejorar

- [x] Tipar y mostrar `coverImageUrl` en tarjetas y Sitio de trabajo
- [x] Subir / reemplazar / quitar imagen principal (multipart)
- [ ] Filtros de listado por `status` / `city` / `currentStageId` (hoy: search + `activeOnly`)
- [ ] Galería de sitio (thumbs reales) cuando exista API
- [ ] Métricas y listado de tareas cuando exista Fase tareas
- [ ] KPIs “A tiempo / Retrasadas” con definición de negocio más fina (hoy heurística por `estimatedEndDate`)
