# Guía del frontend Quasar: Bitácoras y planes (Fase 7)

Compromiso operativo: **qué se va a hacer** en una obra y periodo, con snapshot del periodo.

En el menú esta zona se llama **Bitácoras obras**. La app **no pide firmas** de planificación. Las tablas `work_plan_signers` y los eventos viejos siguen en la base, pero las rutas de solicitar, firmar, rechazar y firmantes ya no están en el API. El acuse de llegada del día es otra cosa: vive en asistencia.

Complementa:
- [tareas-frontend.md](./tareas-frontend.md) — tareas que entran al plan
- [obras-frontend.md](./obras-frontend.md) — obra
- [identidad-frontend.md](./identidad-frontend.md) — usuarios

**Auth:** Bearer + permiso **`planificacion`**. JSON **camelCase**.

---

## Concepto

| Idea | Detalle |
|------|---------|
| Work plan | Periodo + lista de tareas de una obra |
| Versión | Snapshot de las tareas de ese periodo |
| Estado en pantalla | Siempre **Borrador**. `draft`, `pending_signature`, `signed` y `rejected` se etiquetan igual |
| Edición | El plan se puede editar sin importar el estado guardado |

El historial de la app muestra creación y edición. No muestra firmas.

Agregar una actividad al periodo vigente (`POST /api/v1/operacion/tareas/agregar-al-periodo`) **no** cambia el plan a `pending_signature` y **no** avisa a los administradores. Pide una justificación de al menos 8 caracteres y, si la actividad es única, capítulo, subcapítulo y zona.

---

## Flujo de la app

```
Crear plan (obra + fechas + actividades)
  → v1 + snapshots
Editar cabecera, agregar o quitar actividades
Comparar snapshot vs tarea actual vs delays
```

---

## Matriz de endpoints

Base: `/api/v1/planificacion/planes`

| Acción | Método | Ruta |
|--------|--------|------|
| Listar | `GET` | `?obraId&status&search&page` → `workPlans` |
| Pendientes | `GET` | `/pendientes?obraId` → actividades de periodos anteriores sin completar |
| Crear | `POST` | `/` → `201` |
| Detalle | `GET` | `/{id}` |
| Editar cabecera | `PUT` | `/{id}` |
| Comparar | `GET` | `/{id}/comparar?versionId=` |
| Registrar vista | `POST` | `/{id}/vista` — compatibilidad; ya no escribe historial |
| Nueva versión | `POST` | `/{id}/nueva-version` → `201` |
| + Tarea snapshot | `POST` | `/versiones/{versionId}/tareas` |
| − Snapshot | `DELETE` | `/snapshots/{id}` → `204` |

---

## 7.1 Crear planificación

`POST /api/v1/planificacion/planes`

```json
{
  "uuid": null,
  "obraId": 1,
  "name": "Semana 36 — Bellagio Casa 19",
  "startDate": "2026-09-01",
  "endDate": "2026-09-07",
  "templateIds": [4, 8],
  "taskIds": [10, 11]
}
```

| Campo | Al crear | Qué es |
|-------|----------|--------|
| `obraId`, `name`, `startDate`, `endDate` | **Obligatorio** | Periodo |
| `templateIds` | Opcional | Actividades registradas que se crean en el periodo. No pide versión, cantidad ni rendimiento |
| `taskIds` | Opcional | Actividades ya existentes. Si no están completadas ni verificadas, sus fechas pasan a este periodo |

Hace falta al menos un id en `templateIds` o en `taskIds`.

`GET /pendientes?obraId=` devuelve las actividades de periodos anteriores con status `scheduled`, `in_progress` o `rescheduled`. La pantalla del periodo nuevo las muestra para agregarlas.

Crea:
- Plan `draft`
- Versión `1` con snapshots en `work_plan_tasks`
- `currentVersionId` apuntando a v1

### Editar cabecera (draft)

```json
{ "name": "Semana 36 (ajustada)", "startDate": "2026-09-02", "endDate": "2026-09-08" }
```

### Agregar / quitar tareas del snapshot

```json
{ "taskId": 15, "plannedStartDate": null, "plannedEndDate": null }
```

`POST /versiones/{versionId}/tareas` agrega una actividad que ya es de esa obra. No pide que tenga fechas: si sigue abierta, el periodo de la bitácora pasa a ser su inicio y su fin.  
`DELETE /snapshots/{snapshotId}` la quita de esta bitácora.

---

## 7.2 Firmas

No hay firmantes, solicitud, firma ni rechazo en la app. No reconstruir esas pantallas. El acuse de llegada está en [asistencia-frontend.md](./asistencia-frontend.md).

`POST /{planId}/nueva-version` sigue disponible para planes cuyo estado guardado sea `signed` o `rejected`. La interfaz no lo usa como paso obligatorio: un plan se edita en su versión actual.

---

## 7.3 Comparación planificado / aprobado / real

`GET /{planId}/comparar?versionId=`

Por cada ítem del snapshot:

| Bloque | Campos |
|--------|--------|
| Planificado (foto) | `taskNameSnapshot`, fechas snapshot, `estimatedDurationDaysSnapshot`, `approvedDurationDaysSnapshot` |
| Actual (tarea) | `currentStatus`, fechas plan/real, duraciones actuales |
| Real / pérdidas | `daysLostTotal`, `delayCount` |
| Diff | `varianceNote` (texto corto) |

Ideal para tabla “Lo planeado vs lo que pasó”.

---

## Detalle `GET /{id}`

```json
{
  "workPlan": { ... },
  "versions": [ { "versionNumber": 2, "isImmutable": false, ... } ],
  "currentVersion": {
    "version": { ... },
    "tasks": [ /* snapshots */ ],
    "signers": [ ... ],
    "events": [ ... ]
  }
}
```

---

## Pantallas sugeridas

| Ruta en la app | Contenido |
|------|-----------|
| Bitácoras obras | Listado de planes. El estado se muestra como Borrador |
| Detalle del plan | Periodo, actividades y historial de creación/edición |
| Comparar | Tabla planificado / actual / delays |

---

## Checklist QA

- [ ] Crear plan con 2–3 tareas → ver snapshots
- [ ] Editar un plan cuyo estado guardado no sea `draft` → la app lo permite
- [ ] Agregar actividad al periodo con justificación corta → 400
- [ ] Comparar muestra diffs de fechas y retrasos  

---

## Relación con otras fases

| Fase | |
|------|--|
| **6** | Tareas fuente del snapshot |
| **7** | Esta guía |
| **8** | Offline: `uuid` en create del plan |
