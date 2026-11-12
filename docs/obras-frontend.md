# Guía del frontend Quasar: Obras (Fase 4)

CRUD de obras, clientes, documentos en S3 e imagen principal. El avance que se pinta en la ficha sale de las actividades, no de las etapas.

Complementa:
- [catalogos-frontend.md](./catalogos-frontend.md) — unidades y demás maestros que sí tienen pantalla
- [tareas-frontend.md](./tareas-frontend.md) — cumplimiento, bitácora y galería
- [identidad-frontend.md](./identidad-frontend.md) — personas (clientes)
- [rrhh-frontend.md](./rrhh-frontend.md) — asignar gente a `obraId`

**Auth:** Bearer + rol **`admin`**. JSON **camelCase**.  
En el frontend Quasar el access token va en memoria y el refresh en cookie HttpOnly (`credentials: 'include'`).

---

## Mapa de pantallas

El menú dice **Obras** para el listado y **Inicio** para el tablero. `/projects` redirige a `/dashboard`. `/dashboard/maestros/*` también redirige a Inicio: no hay pantalla de tipos de venta, etapas ni tipos de documento.

| Ruta frontend | Pantalla | Contenido |
|---------------|----------|-----------|
| `/dashboard` | Inicio | Tarjetas de obra, búsqueda, “Nueva obra” |
| `/dashboard/obras/:obraId` | Ficha de la obra | Avance por capítulos y zonas, sitio, bitácora, clientes y archivos |
| `/dashboard/obras/:obraId/galeria` | Galería | Fotos de la obra, las más nuevas primero |

Carpeta feature: `src/obras/`. El listado general de actividades vive en `src/task-pool/` y en el menú se llama **Listado General Act.**

---

## Status de obra (canónicos)

| Valor | Uso UI |
|--------|--------|
| `planning` | En planificación (default al crear) |
| `in_progress` | En ejecución |
| `on_hold` | Pausada |
| `completed` | Finalizada / “Lista” en tarjeta |
| `cancelled` | Cancelada |

`isActive` (`1`/`2`) es la baja lógica del registro; **no** sustituye a `status`. Solo el super admin puede cambiarla.

`currentStageId` sigue en el API y en el formulario de la obra. **No** es el progreso que se muestra en la ficha. Ese sale de `GET /api/v1/operacion/tareas/cumplimiento`.

| Señal en la ficha | Cómo se calcula |
|--------|---------------------|
| **% global obra ejecutada** | Suma de `peso de la zona × avance de la zona`. El avance de la zona suma `peso del capítulo × avance de ese capítulo en esa zona`. Una zona o un capítulo sin `%` aporta 0 |
| **% cumplimiento bitácora actual** | Promedio simple de las actividades del periodo de la bitácora. No es un pedazo de la casa |
| **Progreso de la construcción** | Una fila por zona activa, con su `%` de la obra. En cada fila salen todos los capítulos activos, medidos solo con las actividades de esa zona |
| Personal en sitio | Conteos desde `GET /rrhh/asignaciones?currentOnly=true` |

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

**UI:** la portada se muestra completa (`object-fit: contain`) en la tarjeta, en la ficha y en la vista previa del formulario. Las miniaturas de la galería sí recortan (`cover`). Debajo de la portada y de las últimas fotos van **Ver galería** y **Subir fotos**. La galería ordena por fecha de toma o de carga, la más nueva primero.

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
| Documentos | `POST /api/v1/obras/{id}/documentos/archivos` · `GET/POST /documentos` · `/api/v1/obras/documentos/{id}` | `documents` |

Los catálogos de tipo de venta, etapa y tipo de documento siguen en el API. La app no los administra:

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
- En el mismo guardado se copian las actividades del catálogo con `isFixed: 1` y activas. Quedan programadas (`scheduled`), con el nombre, la descripción, el capítulo, el subcapítulo, la zona y el `%` de la plantilla. La respuesta de la obra no las incluye: cárgalas con `GET /api/v1/operacion/tareas?obraId=`.
- Si después una no aplica, se quita desde el tablero de actividades de esa obra. El modal pide confirmación. `DELETE /api/v1/operacion/tareas/{id}` deja en `audit_log` quién la quitó y a qué hora. No la borra del catálogo ni de otras obras.
- Cambiar **Fija** en el catálogo no modifica las obras ya creadas. La siguiente obra usa la lista vigente.

### Actualizar

`PUT /api/v1/obras/{id}` — datos generales y status.  
Cambiar `isActive` (dar de baja o reactivar) solo lo acepta el **super admin**; otro usuario recibe `403`. La ficha muestra el botón únicamente a ese rol.  
**No** cambies etapa aquí (usar `PUT .../etapa`).

### Marcar capítulos de una obra en marcha

`GET /api/v1/obras/{id}/capitulos` lo puede leer quien tenga permiso de obras o de tareas.  
`PUT /api/v1/obras/{id}/capitulos` solo lo acepta el **super admin**.

```json
{
  "chapters": [
    { "chapterId": 1, "zoneId": 1, "mode": "completed" },
    { "chapterId": 1, "zoneId": 2, "mode": "running" },
    { "chapterId": 2, "zoneId": 1, "mode": "open" }
  ]
}
```

La marca es de un capítulo **en una zona**. Estructura puede estar completada en Casa y en marcha en Zona Social.

- `completed`: esa zona queda en 100 %. No se le agregan actividades de ese capítulo en esa zona. Una actividad sin zona entra en todas, así que tampoco se agrega si alguna zona del capítulo está completada. Una actividad que ya existe sí puede entrar a una bitácora.
- `running`: esa zona sigue admitiendo actividades. `progressPercent` es opcional (1–99) y queda como piso de esa zona.
- `open`: quita la marca de esa zona.
- La ficha muestra el botón **Capítulos** solo al super admin. El capítulo desaparece del selector solo cuando está completado en todas las zonas. En la zona, se ocultan las que ya están completadas.

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

La ficha sube el archivo. No pide tipo ni un enlace. Cada archivo lleva nombre, descripción y si es visible al cliente.

- Máximo **10** archivos por obra y **25 MB** cada uno.
- Las imágenes se comprimen (en el cliente a JPEG y en el servidor a WebP, lado máx. 2200 px, objetivo ~350 KB).
- PDF y CAD se guardan tal cual si caben en 25 MB, para que sigan abriendo.
- Clave S3: `obras/{obraId}/documentos/{uuid}.{ext}`.
- `document_type_id` quedó nullable. La columna no se elimina. El alta por JSON con `fileUrl` sigue para compatibilidad.

### Subir archivos

`POST /api/v1/obras/{obraId}/documentos/archivos`  
`multipart/form-data` con cuatro listas del mismo largo: `files`, `names`, `descriptions`, `visibles`.

Respuesta: `{ "documents": [ ... ] }`. `fileUrl` de cada documento es la URL pública o firmada, no la clave cruda.

### Listar y el alta vieja

- `GET /api/v1/obras/{obraId}/documentos?search=&visibleToClient=`
- `POST /api/v1/obras/{obraId}/documentos` sigue aceptando JSON con `fileUrl`. `documentTypeId` es opcional.

### Ver / editar

- `GET /api/v1/obras/documentos/{id}`
- `PUT /api/v1/obras/documentos/{id}` — name, description, fileUrl, isVisibleToClient (no uuid)

---

## Flujo de pantalla

1. **Obras** → Nueva obra. El código de la obra no se pide. El cliente es opcional.
2. Subir **imagen principal** en el modal → `PUT .../imagen-principal`.
3. Abrir la ficha: progreso por capítulos y zonas, anillos de la casa y de la bitácora, y fotos. Las actividades van en `/dashboard/obras/:obraId/actividades`.
4. Documentos: **Subir archivos**. Clientes en la misma zona de administración.
5. RRHH: asignar trabajadores a ese `obraId`.

### Ficha de la obra — bloques

1. Header: nombre y rango de fechas
2. **Progreso de la construcción** — círculos con el `%` adentro, una línea por zona
3. **Sitio de trabajo** — portada completa, últimas fotos, **Ver galería** y **Subir fotos**
4. **% global obra ejecutada** y **% cumplimiento bitácora actual**
5. Enlace a **Actividades de la obra**, el tablero por capítulo
6. Clientes y documentos

Modales: overlay a viewport completo (portal a `document.body`); responsive en teléfono.

---

## Checklist frontend

### Hecho en Quasar (`src/obras/`)

- [x] Listado de obras en Inicio
- [x] Ficha con progreso por capítulos y zonas
- [x] CRUD obras (crear / editar / `isActive`). El código no se muestra
- [x] Select status con los 5 valores canónicos
- [x] Clientes: roles, primario, cerrar vínculo
- [x] Documentos: subida a S3, nombre, descripción y visible al cliente. Sin tipo
- [x] Portada completa y galería de más nueva a más vieja
- [x] Layout responsive

### Sigue en el API y ya no se administra en pantalla

- [x] Tipos de venta, etapas y tipos de documento
- [x] Alta JSON de documento con `fileUrl`
