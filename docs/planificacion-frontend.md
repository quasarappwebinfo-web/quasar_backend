# Guía del frontend Quasar: Planificación y firmas (Fase 7)

Compromiso operativo: **qué se va a hacer** en una obra y periodo, con snapshot histórico y firmas.

Complementa:
- [tareas-frontend.md](./tareas-frontend.md) — tareas que entran al plan
- [obras-frontend.md](./obras-frontend.md) — obra
- [identidad-frontend.md](./identidad-frontend.md) — usuarios firmantes
- [system-core.md](./system-core.md) — §§20–30

**Auth:** Bearer + rol **`admin`**. JSON **camelCase**.

---

## Concepto

| Idea | Detalle |
|------|---------|
| Work plan | Periodo + lista de tareas de una obra |
| Versión | Snapshot congelable; firmas van a **una versión** |
| Firmada | **Inmutable**; cambio = nueva versión |
| Firma | Aprueba esa versión (no “la obra” en abstracto) |
| `signatureData` | Nota/referencia — **nunca** password ni token |

Estados del plan:

| Status | UI |
|--------|-----|
| `draft` | Editable: tareas, firmantes, fechas |
| `pending_signature` | Esperando firmas; no editar (cancelar → draft) |
| `signed` | Todos firmaron; inmutable |
| `rejected` | Algún firmante rechazó; nueva versión para iterar |

Firmantes: `pending` → `signed` | `rejected`.

Eventos: `created` · `edited` · `requested` · `viewed` · `signed` · `rejected` · `cancelled`.

El historial registra creación del plan/versión, ediciones (cabecera, tareas, firmantes) y cada firma/rechazo.

---

## Flujo feliz

```
Crear plan (obra + fechas + taskIds)
  → v1 draft + snapshots
Agregar firmantes
Solicitar firma → pending_signature + evento requested
(Firmantes) vista → viewed
(Firmantes) firmar / rechazar
  → si todos firman: signed + version.signedAt
  → si uno rechaza: rejected
Cambios → POST nueva-version → draft v2
Comparar snapshot vs tarea actual vs delays
```

---

## Matriz de endpoints

Base: `/api/v1/planificacion/planes`

| Acción | Método | Ruta |
|--------|--------|------|
| Listar | `GET` | `?obraId&status&search&page` → `workPlans` |
| Crear | `POST` | `/` → `201` |
| Detalle | `GET` | `/{id}` |
| Editar cabecera | `PUT` | `/{id}` (solo draft) |
| Comparar | `GET` | `/{id}/comparar?versionId=` |
| Solicitar firma | `POST` | `/{id}/solicitar-firma` |
| Cancelar solicitud | `POST` | `/{id}/cancelar-firma` |
| Registrar vista | `POST` | `/{id}/vista` |
| Firmar | `POST` | `/{id}/firmar` |
| Rechazar | `POST` | `/{id}/rechazar` |
| Nueva versión | `POST` | `/{id}/nueva-version` → `201` |
| + Tarea snapshot | `POST` | `/versiones/{versionId}/tareas` |
| − Snapshot | `DELETE` | `/snapshots/{id}` → `204` |
| + Firmante | `POST` | `/versiones/{versionId}/firmantes` |
| − Firmante | `DELETE` | `/firmantes/{id}` → `204` |

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
  "taskIds": [10, 11, 12]
}
```

Requisitos por tarea: `plannedStartDate` y `plannedEndDate` (si faltan → 400).

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

`POST /versiones/{versionId}/tareas` — solo draft.  
`DELETE /snapshots/{snapshotId}`.

---

## 7.2 Firmas

### Firmantes

```json
{ "userId": 3, "signatureOrder": 1 }
```

`POST /versiones/{versionId}/firmantes` (draft).

### Solicitar

`POST /{planId}/solicitar-firma`

- Exige ≥1 tarea y ≥1 firmante
- `draft|rejected` → `pending_signature`
- Evento `requested` (`requestedBy` = usuario actual)

### Vista

`POST /{planId}/vista` → evento `viewed` (firmante o solicitante).

### Firmar

`POST /{planId}/firmar` — el usuario autenticado debe ser firmante `pending`.

```json
{
  "signatureType": "acknowledgment",
  "signatureData": "Aprobado en reunión de obra 2026-09-01"
}
```

`signatureType`: `acknowledgment` | `electronic`.

El backend:
- Rechaza `signatureData` con password/token/secret…
- Guarda IP y User-Agent
- Evento `signed`
- Si **todos** firmaron → plan `signed` + `version.signedAt`

Respuesta:

```json
{
  "workPlan": { "status": "signed", ... },
  "signer": { "status": "signed", ... },
  "fullySigned": true
}
```

### Rechazar

```json
{ "reason": "Falta cuadrilla de electricistas esa semana" }
```

→ firmante `rejected`, plan `rejected`, evento `rejected`.

### Cancelar solicitud

`POST /{planId}/cancelar-firma` → `pending_signature` → `draft` + evento `cancelled`.

### Nueva versión (post signed/rejected)

`POST /{planId}/nueva-version`

```json
{
  "taskIds": null,
  "name": null,
  "startDate": null,
  "endDate": null
}
```

- `taskIds: null` → re-snapshot de las mismas tareas (datos **actuales** de la tarea)
- Plan vuelve a `draft` con `versionNumber` + 1
- Firmantes **no** se copian (hay que volver a definirlos)

**Regla UI:** si `status === 'signed'` o `version.isImmutable`, todo el snapshot es solo lectura; CTA = “Nueva versión”.

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

Ideal para tabla “Lo firmado vs lo que pasó”.

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

| Ruta | Contenido |
|------|-----------|
| `/obras/:obraId/planes` | Listado por obra + status |
| `/planes/:id` | Detalle versión actual, timeline de eventos, CTA firmar |
| `/planes/:id/comparar` | Tabla planificado / actual / delays |

---

## Checklist QA

- [ ] Crear plan con 2–3 tareas → ver snapshots  
- [ ] Solicitar firma sin firmantes → 400  
- [ ] Firmar con usuario no firmante → 400  
- [ ] `signatureData` con `"password":"..."` → 400  
- [ ] Todos firman → `signed` + inmutable  
- [ ] Intentar agregar tarea a signed → 400  
- [ ] Nueva versión → draft vN + comparar muestra diffs  

---

## Relación con otras fases

| Fase | |
|------|--|
| **6** | Tareas fuente del snapshot |
| **7** | Esta guía |
| **8** | Offline: `uuid` en create del plan |
