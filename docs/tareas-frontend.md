# Guía del frontend Quasar: Tareas en obra (Fase 6)

Día a día en campo. **No es el Task Pool** — aquí viven las instancias reales de una obra.

Complementa:
- [task-pool-frontend.md](./task-pool-frontend.md) — plantillas versionadas + recomendación
- [obras-frontend.md](./obras-frontend.md) — obra / Project View
- [rrhh-frontend.md](./rrhh-frontend.md) — trabajadores y cuadrillas
- [catalogos-frontend.md](./catalogos-frontend.md) — motivos de retraso, unidades
- [sync-frontend.md](./sync-frontend.md) — push/pull offline (ola 1 de campo)
- Figma: [Tasks View](https://www.figma.com/design/6uvMxV1IJaVg3EIGiTDZMU/Quasar-App?node-id=18-597) (Kanban) · [Single Task View](https://www.figma.com/design/6uvMxV1IJaVg3EIGiTDZMU/Quasar-App?node-id=21-924) (drawer detalle)

**Auth:** Bearer + rol **`admin`**. JSON **camelCase**.  
`uuid` opcional en create (offline: genéralo en el cliente).

---

## Concepto

| Task Pool (Fase 5) | Tarea en obra (Fase 6) |
|--------------------|-------------------------|
| Receta reutilizable | Instancia en Bellagio Casa 19 |
| Recomienda duración/cargos | Supervisor **aprueba** fechas y gente |
| Dependencias entre plantillas | Dependencias entre tareas de la obra |
| Sin evidencia | Fotos, comentarios, retrasos, historial |

Principio: el sistema recomienda; **nadie auto-aprueba**.

---

## Status (canónicos ↔ Figma)

| API | Columna Kanban |
|-----|----------------|
| `scheduled` | PROGRAMADAS |
| `in_progress` | EN PROGRESO |
| `completed` | COMPLETADAS |
| `verified` | VERIFICADAS |
| `rescheduled` | RE-PROGRAMADAS |

Transiciones permitidas:

```
scheduled  → in_progress | rescheduled
in_progress → completed | rescheduled | scheduled
completed  → verified | in_progress
verified   → (terminal)
rescheduled → scheduled | in_progress
```

`rescheduled` **solo** vía `POST .../reprogramar` (nunca con `.../estado`).

---

## Pantalla Kanban (Figma)

Ruta sugerida: `/tareas` o `/obras/:obraId/tareas`.

| UI | API |
|----|-----|
| Filtro proyecto | `obraId` |
| Filtro capítulo | `chapterId` (capítulo Task Pool) |
| Rango fechas | `dateFrom` + `dateTo` |
| Columnas + contadores | `GET /tablero?obraId=` |
| Avance por capítulo y global | `GET /cumplimiento?obraId=` |
| “+” por columna | Wizard → `POST /desde-plantilla` (nace siempre `scheduled`) |
| Drag de card | `POST /{id}/estado` |
| Card | campos de `TaskResponse` (abajo) |

### Cumplimiento de la obra

`GET /api/v1/operacion/tareas/cumplimiento?obraId=`

`obraId` es el único query y es **obligatorio**. No hay body.

| Campo de la respuesta | Qué pintar |
|-----------------------|------------|
| `progressPercent` | Avance global de la obra, `0`–`100`. Usa el `%` del capítulo y el de la actividad presupuestal |
| `period` | Plan que cubre hoy (o el más reciente). `progressPercent` es el avance de las actividades de ese periodo, con los mismos `%` |
| `activityStatus` | Conteos del periodo: `completed` (completadas + verificadas), `inProgress`, `pending` (programadas + reprogramadas). Si no hay periodo, cuenta toda la obra |
| `chapters[].chapterName` | Nombre del capítulo |
| `chapters[].weightPercent` | `%` que ese capítulo aporta al global. Puede venir `null` si no se cargó en el pool |
| `chapters[].progressPercent` | Cómo va ese capítulo |
| `chapters[].budgetActivities[].budgetActivityName` | Actividad presupuestal |
| `chapters[].budgetActivities[].weightPercent` | `%` de esa actividad dentro del capítulo. Puede venir `null` |
| `chapters[].budgetActivities[].progressPercent` | Cómo va esa actividad presupuestal |

Si un grupo no tiene pesos cargados, el backend reparte el avance de ese grupo por igual. No pidas esos `%` para poder ver la pantalla.

### Card — contrato visual

| UI | Campo |
|----|--------|
| Título | `name` |
| Badge color | `chapterName` (+ color local por capítulo) |
| Avatar / nombre / rol | `primaryAssignee.initials`, `.workerName` o `.crewName`, `.positionName` |
| % barra (solo en progreso) | `progressPercent` (subtareas hechas / total) |
| Fecha | `plannedStartDate` / `plannedEndDate`; si reprogramada sin fecha → copy “Movido…” |
| Clip + N | `attachmentCount` (fotos + documentos) |

---

## Drawer detalle (Figma Single Task View)

Al hacer click en una card del Kanban se abre el panel derecho.  
Carga: `GET /api/v1/operacion/tareas/{id}` (incluye subtareas, fotos, docs, notas, delays, `activity`).

| Bloque UI | Comportamiento | API |
|-----------|----------------|-----|
| Título + badge status | `task.name`, `task.status` | — |
| Editar / Guardar | lápiz + **GUARDAR CAMBIOS** | `PUT /{id}` (setea `updatedBy` + `updatedAt`) |
| Fechas programada / límite | `plannedStartDate` / `plannedEndDate` | `PUT` |
| Asignado | `primaryAssignee` o `assignments` | asignaciones existentes |
| Capítulo | `chapterName` | — |
| Descripción | `description` | `PUT` |
| **Marcar como retrasada** | toggle + motivo 0/250 | `POST /{id}/marcar-retraso` |
| **Subtareas** N/M + % | `subtasks` + `progressPercent` | checkbox → `POST /{id}/subtareas/{subId}/toggle?completed=` |
| + Add subtask | nueva hija | `POST /` con `parentTaskId` |
| **Notas** feed | lista + input | `comments` / `POST /{id}/comentarios` (`type: comment`) |
| Ver todas | timeline | `GET /{id}/actividad` o `activity` del detalle |
| **Evidencia fotográfica** | galería + Add Photo | `POST /{id}/fotos` multipart |
| Documentos / clip | adjuntos PDF/planos | `POST /{id}/documentos` multipart |
| **MARCAR COMO COMPLETADA** | CTA primario | `POST /{id}/estado` `{ "toStatus": "completed" }` |

### Retraso (toggle)

```json
{
  "delayed": true,
  "delayReasonId": 1,
  "description": "Espera de concreto",
  "daysLost": null
}
```

- `delayed: true` → abre (o actualiza) un `task_delay_events` sin `endDate` → `task.isDelayed = true`
- `delayed: false` → cierra retrasos abiertos (`endDate = hoy`)

### Checkbox subtarea

`POST /{taskId}/subtareas/{subtaskId}/toggle?completed=true`  
→ `completed` (o `scheduled` si `completed=false`) + historial.

### Documentos

`POST /{id}/documentos` — `multipart`: `file`, `description?`, `uuid?`  
Máx. 25 MB. Key S3: `.../tareas/{taskId}/docs/{uuid}.{ext}`  
Clip de la card: `attachmentCount = photoCount + documentCount`.

### Trazabilidad (quién / cuándo)

En cada `TaskResponse`:

| Campo | Significado |
|-------|-------------|
| `createdBy` / `createdByName` / `createdAt` | Quién creó y cuándo |
| `updatedBy` / `updatedByName` / `updatedAt` | Última edición de cabecera |

Feed unificado `GET /{id}/actividad` (también en detalle como `activity`):

| `eventType` | Origen |
|-------------|--------|
| `created` | alta de tarea |
| `updated` | `PUT` cabecera |
| `status_change` | `task_status_history` |
| `note` / `instruction` | comentarios |
| `photo` | foto |
| `document` | documento |
| `delay` | retraso |
| `reschedule` | reprogramación |

Cada ítem: `at`, `userId`, `userName`, `summary`, `detail`.

Migración: `alembic upgrade` → `009_task_trace_documents` (`tasks.updated_by` + tabla `task_documents`).

---

## Matriz de endpoints

Base: `/api/v1/operacion/tareas`

| Acción | Método | Ruta |
|--------|--------|------|
| Listar | `GET` | `?obraId&status&chapterId&search&dateFrom&dateTo&parentOnly&parentTaskId&page` |
| Kanban | `GET` | `/tablero?obraId=` |
| Cumplimiento | `GET` | `/cumplimiento?obraId=` → ver campos abajo |
| Desde plantilla | `POST` | `/desde-plantilla` → `201` |
| Al periodo | `POST` | `/agregar-al-periodo` → `201`. Pool sin versión, o actividad solo de la obra. Exige justificación, avisa a los admins y deja el plan del periodo en `pending_signature` |
| Manual / subtarea | `POST` | `/` → `201` |
| Detalle | `GET` | `/{id}` |
| Editar cabecera | `PUT` | `/{id}` |
| Cambiar status | `POST` | `/{id}/estado` |
| Reprogramar | `POST` | `/{id}/reprogramar` |
| Deps | `GET/POST` | `/{id}/dependencias` |
| Quitar dep | `DELETE` | `/dependencias/{itemId}` → `204` |
| Override dep | `POST` | `/{id}/overrides-dependencia` |
| Asignaciones | `GET` | `/{id}/asignaciones?currentOnly=` |
| + Trabajador | `POST` | `/{id}/asignaciones/trabajadores` |
| − Trabajador | `DELETE` | `/asignaciones/trabajadores/{id}` → `204` |
| + Cuadrilla | `POST` | `/{id}/asignaciones/cuadrillas` |
| − Cuadrilla | `DELETE` | `/asignaciones/cuadrillas/{id}` → `204` |
| Retraso | `POST` | `/{id}/retrasos` |
| Comentario | `POST` | `/{id}/comentarios` |
| Editar comentario | `PUT` | `/comentarios/{id}` |
| Subir foto | `POST` | `/{id}/fotos` (multipart) |
| Borrar foto | `DELETE` | `/fotos/{id}` → `204` |

Errores: `400` · `404` · `409` (duplicado **o** inicio bloqueado por deps).

---

## 6.1 Crear desde plantilla

`POST /api/v1/operacion/tareas/desde-plantilla`

```json
{
  "uuid": "optional-client-uuid",
  "obraId": 1,
  "sourceTemplateVersionId": 10,
  "plannedQuantity": 250,
  "approvedDurationDays": 10,
  "plannedStartDate": "2026-09-05",
  "plannedEndDate": "2026-09-15",
  "name": null,
  "copySubtasks": true,
  "instantiateDependencies": true
}
```

| Campo | Al crear | Qué es |
|-------|----------|--------|
| `obraId` | **Obligatorio** | Obra donde nace la tarea |
| `templateId` | Obligatorio si no hay versión | Actividad registrada. Sin versión la tarea queda programada, sin cantidad, duración ni sugerencia |
| `sourceTemplateVersionId` | Opcional | Si se envía, tiene que estar `published`. Copia unidad, subtareas y dependencias |
| `uuid` | Opcional | Id de cliente. Si se omite, lo genera el backend |
| `plannedQuantity` | Opcional | Cantidad de obra. Sin ella, la tarea se crea igual y no hay duración estimada |
| `approvedDurationDays` | Opcional | Si no se envía y hay estimación, se usa esa. Si no hay estimación, queda vacío |
| `plannedStartDate` | Opcional | Fecha |
| `plannedEndDate` | Opcional | Fecha |
| `name` | Opcional | Si se omite, se usa el nombre de la plantilla |
| `description` | Opcional | Si se omite, se usa la de la versión |
| `copySubtasks` | Opcional, default `true` | Copia las subtareas de la versión. Si la versión no tiene, no pasa nada |
| `instantiateDependencies` | Opcional, default `true` | Intenta crear dependencias en la misma obra |

Qué hace el backend:

1. Con solo `templateId` crea la tarea en `scheduled`, copia el nombre y el `%` de la actividad registrada, y no calcula rendimiento.
2. Si viene `sourceTemplateVersionId`, exige versión **`published`**. Si hay `plannedQuantity`, `baseQuantity` y `baseDurationDays`, calcula `estimatedDurationDays = baseDuration × (obraQty / baseQty)`. Si faltan, la tarea se crea igual, sin duración estimada.
3. `approvedDurationDays` = el que mandes, o la estimación cuando existe.
4. Copia unidad primaria de la plantilla.
5. Status `scheduled` + fila en `task_status_history`.
6. Si `copySubtasks`: crea hijas con `parentTaskId`.
7. Si `instantiateDependencies`: busca en la **misma obra** una tarea cuya plantilla coincida con `dependsOnTemplateId` y crea `task_dependencies`.

En planificación el periodo usa `templateId` y no pide versión ni recomendación. El wizard de rendimiento, si se usa, sigue así:

1. Elegir plantilla published → mostrar recomendación (`POST .../recomendar` del Task Pool).
2. Supervisor edita duración aprobada + fechas.
3. Crear → card en PROGRAMADAS.

### Manual / subtarea

`POST /api/v1/operacion/tareas`

```json
{
  "obraId": 1,
  "parentTaskId": 55,
  "name": "Revisar tubería embebida",
  "plannedStartDate": "2026-09-06"
}
```

| Campo | Al crear | Qué es |
|-------|----------|--------|
| `obraId` | **Obligatorio** | Obra |
| `name` | **Obligatorio** | 1–255 caracteres |
| `parentTaskId` | Opcional | Si viene, la tarea es subtarea de ese padre y debe ser de la misma obra |
| `uuid` | Opcional | Id de cliente |
| `description` | Opcional | Texto libre |
| `unitId` | Opcional | Unidad de medida |
| `plannedQuantity` | Opcional | Cantidad |
| `estimatedDurationDays` | Opcional | Días estimados |
| `approvedDurationDays` | Opcional | Días aprobados |
| `plannedStartDate` | Opcional | Fecha |
| `plannedEndDate` | Opcional | Fecha |
| `weightPercent` | Opcional | `%` de la subtarea dentro del padre. `0`–`100`. No es obligatorio ni en subtareas |

---

## 6.2 Subtareas

- Vienen de plantilla al crear, o `POST` manual con `parentTaskId`.
- Listado Kanban: `parentOnly=true` (default) → solo padres.
- Detalle: `GET /{id}` incluye `subtasks[]`.
- `progressPercent` = subtareas `completed|verified` / total.

---

## 6.3 Dependencias

### Listar / agregar

```json
{
  "dependsOnTaskId": 40,
  "dependencyType": "finish_to_start",
  "isRequired": 1,
  "blocksStart": 1
}
```

Tipos: `finish_to_start` | `start_to_start` | `finish_to_finish` | `start_to_finish`.

### Override local (no toca el Task Pool)

`POST /{id}/overrides-dependencia`

```json
{
  "templateDependencyId": 3,
  "overrideType": "waive",
  "reason": "En esta obra el acabado no requiere lijado previo"
}
```

| `overrideType` | Efecto |
|----------------|--------|
| `waive` | Quita la dep instanciada (no aplica) |
| `relax` | Deja la dep pero `blocksStart=0` |

**Motivo obligatorio.**

### Al iniciar (`POST /{id}/estado` con `toStatus: "in_progress"`)

Si hay deps con `blocksStart=1` y el prerequisito **no** está `completed`/`verified`:

- Sin `force`: **`409`** con body:

```json
{
  "detail": {
    "message": "No se puede iniciar: hay dependencias bloqueantes",
    "blocked": true,
    "blockingDependencies": [
      {
        "dependencyId": 1,
        "dependsOnTaskId": 40,
        "dependsOnTaskName": "Excavación y nivelación",
        "dependsOnStatus": "scheduled",
        "dependencyType": "finish_to_start",
        "blocksStart": 1,
        "message": "«Excavación…» está en status=scheduled. Debe estar completed o verified antes de iniciar."
      }
    ]
  }
}
```

- Con `"force": true`: inicia igual y deja rastro `[FORZADO: …]` en historial.

**UI:** modal claro (qué bloquea). No silenciar.

---

## 6.4 Asignar recursos

Recomendado (plantilla) ≠ asignado (estas tablas).

```json
{ "workerId": 7, "startDate": "2026-09-05" }
```

```json
{ "crewId": 2 }
```

Soft-remove con `DELETE` (llena `removedAt`).  
`primaryAssignee` en la card = primer worker activo, si no primera cuadrilla.

---

## 6.5 Ciclo de vida

### Cambiar status

`POST /{id}/estado`

```json
{ "toStatus": "in_progress", "reason": null, "force": false }
```

Efectos:

- → `in_progress`: setea `actualStartDate` si vacío.
- → `completed`: setea `actualEndDate` si vacío.
- Siempre escribe `task_status_history`.

### Reprogramar (nunca pisar fechas sin historial)

`POST /{id}/reprogramar`

```json
{
  "newStartDate": "2026-09-12",
  "newEndDate": "2026-09-20",
  "reasonId": 1,
  "reason": "Fecha por convenir con proveedor"
}
```

Requiere `reasonId` y/o `reason`. Actualiza fechas planificadas, status → `rescheduled`, fila en `task_reschedules`.

### Retrasos

- Completo: `POST /{id}/retrasos`
- Toggle drawer: `POST /{id}/marcar-retraso` (arriba)

---

## 6.6 Evidencia

### Comentarios / notas

```json
{ "type": "comment", "content": "Verificar instalaciones antes de fundir" }
```

`type`: `comment` (Notas del drawer) | `instruction`.

### Fotos

`POST /{id}/fotos` — `multipart/form-data`:

| Campo | |
|-------|--|
| `file` | JPEG/PNG/WebP (se comprime a WebP) |
| `description` | opcional |
| `uuid` | opcional (offline) |

Key S3: `{prefix}obras/{obraId}/tareas/{taskId}/fotos/{uuid}.webp`  
Respuesta: `fileUrl` resuelta (presigned o pública según env).

### Documentos

`POST /{id}/documentos` — mismo patrón multipart (sin compresión de imagen).

---

## Detalle `GET /{id}`

```json
{
  "task": { /* TaskResponse + isDelayed, createdByName, updatedByName, attachmentCount */ },
  "subtasks": [],
  "dependencies": [],
  "overrides": [],
  "assignments": { "workers": [], "crews": [] },
  "statusHistory": [],
  "reschedules": [],
  "delays": [],
  "comments": [],
  "photos": [],
  "documents": [],
  "activity": []
}
```

---

## Ejemplo Bellagio — Fundición losa

1. Task Pool: plantilla published 100 m³ / 5 días.  
2. `POST /desde-plantilla` con `plannedQuantity: 250` → estimado 12.5 d; apruebas 10.  
3. Card en **PROGRAMADAS**.  
4. Intentar iniciar sin excavación lista → `409` bloqueo.  
5. Completar excavación → iniciar losa → **EN PROGRESO** + %.  
6. Subir foto del vaciado → `photoCount: 1`.  
7. Completar → Verificar.  
8. Puertas: `POST /reprogramar` → **RE-PROGRAMADAS**.

---

## Checklist QA front

- [ ] Click card abre drawer con `GET /{id}`  
- [ ] Toggle retraso + motivo 250 chars  
- [ ] Checkbox subtarea actualiza %  
- [ ] Nota aparece en feed con autor/hora  
- [ ] Foto + documento suben; clip usa `attachmentCount`  
- [ ] Actividad muestra created/updated/status/note/photo  
- [ ] Offline: `uuid` propio en create/foto/documento  

---

## Relación con fases

| Fase | |
|------|--|
| **5** | Catálogo / recommend |
| **6** | Esta guía |
| **7** | [planificacion-frontend.md](./planificacion-frontend.md) — work plans + firmas |
