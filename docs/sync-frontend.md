# Guía del frontend Quasar: Sync offline (Fase 8)

Obras remotas sin señal. Complementa [auth-frontend.md](./auth-frontend.md) (PWA + IndexedDB + outbox) y [tareas-frontend.md](./tareas-frontend.md) (dominio de campo).

**Auth:** Bearer + rol **`admin`**. JSON **camelCase**.  
Cada registro nace con **`uuid`** en el cliente.

---

## Qué hay en el backend (ola 1)

| Endpoint | Uso |
|----------|-----|
| `POST /api/v1/sync/push` | Vaciar outbox (lote ≤ 100 ops) |
| `GET /api/v1/sync/pull?since=...` | Traer deltas desde marca de tiempo |
| `POST /api/v1/sync/fotos` | Cola de fotos (multipart) |

Entidades soportadas en push:

| `entity` | `op` | Notas |
|----------|------|--------|
| `task_comment` | `create`, `update` | Idempotente por uuid |
| `task_delay` | `create` | |
| `task_photo` | `create` | Sin archivo → `needs_upload` |
| `task_status` | `update` | `uuid` = uuid de la **tarea** |
| `task_reschedule` | `create` | |

Catálogo / altas de obra: **online-first** por ahora.

---

## Flujo recomendado

```
UI → IndexedDB (fuente de verdad)
         ↓
      outbox
         ↓  (evento online / timer)
   POST /sync/push
         ↓
   por cada result:
     applied|idempotent → marcar synced
     conflict → UI + merge con serverRecord
     needs_upload → POST /sync/fotos
     error → reintentar / mostrar lastError
         ↓
   GET /sync/pull?since=últimoServerTime
         ↓
   merge en IndexedDB
```

Guarda el `serverTime` del push/pull como próximo `since`.

---

## Push

```http
POST /api/v1/sync/push
Authorization: Bearer …
Content-Type: application/json
```

```json
{
  "operations": [
    {
      "opId": "local-outbox-42",
      "entity": "task_comment",
      "op": "create",
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "clientUpdatedAt": "2026-09-24T18:00:00",
      "payload": {
        "taskUuid": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
        "type": "comment",
        "content": "Falta material en torre B"
      }
    },
    {
      "opId": "local-outbox-43",
      "entity": "task_status",
      "op": "update",
      "uuid": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
      "clientUpdatedAt": "2026-09-24T18:01:00",
      "payload": {
        "toStatus": "in_progress",
        "reason": "Inicio en campo"
      }
    },
    {
      "opId": "local-outbox-44",
      "entity": "task_photo",
      "op": "create",
      "uuid": "photo-uuid-del-cliente",
      "payload": {
        "taskUuid": "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee",
        "description": "Avance muro"
      }
    }
  ]
}
```

### Payloads por entidad

**task_comment** (`create` / `update`)

| Campo | Requerido |
|-------|-----------|
| `taskUuid` o `taskId` | create |
| `content` | create |
| `type` | opcional (`comment` por defecto) |

**task_delay** (`create`)

| Campo | |
|-------|--|
| `taskUuid` / `taskId` | sí |
| `delayReasonId`, `startDate`, `endDate`, `daysLost`, `description` | opcionales |

**task_status** (`update`) — `uuid` de la operación = uuid de la tarea

| Campo | |
|-------|--|
| `toStatus` | sí |
| `reason`, `force` | opcionales |

**task_reschedule** (`create`)

| Campo | |
|-------|--|
| `taskUuid` / `taskId` | sí |
| `newStartDate` y/o `newEndDate` | al menos uno |
| `reasonId` o `reason` | al menos uno |

**task_photo** (`create`)

| Campo | |
|-------|--|
| `taskUuid` / `taskId` | sí |
| `fileUrl` | si ya subiste a S3; si no, responde `needs_upload` |
| `description` | opcional |

### Respuesta push

```json
{
  "results": [
    {
      "opId": "local-outbox-42",
      "entity": "task_comment",
      "uuid": "550e8400-e29b-41d4-a716-446655440000",
      "status": "applied",
      "serverId": 91,
      "message": null,
      "serverRecord": { "...": "..." },
      "uploadHint": null
    },
    {
      "opId": "local-outbox-44",
      "entity": "task_photo",
      "uuid": "photo-uuid-del-cliente",
      "status": "needs_upload",
      "uploadHint": "/api/v1/sync/fotos"
    }
  ],
  "applied": 1,
  "conflicts": 0,
  "errors": 0,
  "needsUpload": 1,
  "serverTime": "2026-09-24T18:05:00"
}
```

| `status` | Acción en front |
|----------|-----------------|
| `applied` | Marcar synced; actualizar id/`serverRecord` local |
| `idempotent` | Ya existía el uuid — igual que applied |
| `conflict` | Server ganó (LWW); mostrar `serverRecord` y decidir UI |
| `needs_upload` | Encolar binario → `POST /sync/fotos` |
| `error` | Guardar `message`; reintentar o avisar |

---

## Conflictos (política)

**Last-write-wins** por tiempo:

- Cliente manda `clientUpdatedAt` (marca local del registro).
- Si el servidor tiene `updatedAt` / `createdAt` **más reciente** → `conflict` + `serverRecord`.
- Si no hay `clientUpdatedAt`, no se declara conflicto (se aplica si es válido).

No hay merge automático de campos: el front elige conservar local, aceptar server, o editar de nuevo (nueva op en outbox).

---

## Pull

```http
GET /api/v1/sync/pull?since=2026-09-24T12:00:00&obraId=3&limitPerEntity=200
```

| Query | |
|-------|--|
| `since` | ISO-8601 (obligatorio) |
| `obraId` | opcional — acota a tareas de esa obra |
| `limitPerEntity` | 1–500, default 200 |

Respuesta:

```json
{
  "since": "2026-09-24T12:00:00",
  "serverTime": "2026-09-24T18:05:00",
  "tasks": [],
  "comments": [],
  "delays": [],
  "photos": [],
  "reschedules": [],
  "statusHistory": []
}
```

Los objetos usan la misma forma camelCase que los endpoints de [tareas-frontend.md](./tareas-frontend.md).

Si alguna lista llega llena al `limitPerEntity`, vuelve a pedir con el mismo `since` o avanza por páginas en una versión futura; hoy es un tope de seguridad.

---

## Fotos (cola aparte)

Comprimir en el cliente antes de subir. Flujo:

1. Offline: guarda blob en IndexedDB + outbox `task_photo` **sin** `fileUrl`.
2. Push → `needs_upload`.
3. Con red:

```http
POST /api/v1/sync/fotos
Content-Type: multipart/form-data
```

| Campo form | |
|------------|--|
| `taskUuid` | uuid de la tarea |
| `photoUuid` | mismo uuid de la outbox |
| `file` | imagen |
| `description` | opcional |

Respuesta: `{ "status": "applied"|"idempotent", "photo": { ... } }`.

Alternativa: subir a S3/presign (si lo tienes) y re-push con `fileUrl` en el payload.

---

## Checklist front (Fase 8)

1. [ ] PWA + IndexedDB + outbox — ver [auth-frontend.md](./auth-frontend.md) Parte B
2. [ ] Worker/sync al evento `online` + timer
3. [ ] `POST /sync/push` con lote de ola 1
4. [ ] Manejo de `conflict` / `needs_upload` / `error`
5. [ ] `GET /sync/pull` y merge por uuid
6. [ ] Cola de fotos → `POST /sync/fotos`
7. [ ] Banner de estado de conexión / sync

---

## Errores frecuentes

| Síntoma | Causa típica |
|---------|----------------|
| `entity no soportada` | Typo; solo ola 1 |
| `Transición no permitida` | Status machine de tareas |
| `needs_upload` eterno | No llamaste `/sync/fotos` |
| Pull vacío | `since` posterior a todos los cambios; o `obraId` sin tareas |

Auth: siempre `credentials: 'include'` / Bearer como en auth-frontend.
