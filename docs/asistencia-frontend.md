# Guía del frontend Quasar: Asistencia diaria y gente en tarea

Modelo operativo real (rotación alta). **No** usa cuadrillas fijas.

Complementa:
- [rrhh-frontend.md](./rrhh-frontend.md) — trabajadores / vínculo a obra (periodo)
- [tareas-frontend.md](./tareas-frontend.md) — tareas en obra
- [obras-frontend.md](./obras-frontend.md) — Project View

**Auth:** Bearer + rol **`admin`**. JSON **camelCase**.

Migración: `006_daily_attendance`.

---

## Modelo (3 capas)

```
1) Trabajador en RRHH
2) Obra — vínculo periodo (asignaciones) + asistencia del día con firma
3) Tarea — gente del día (historial)
```

La **especialidad** del Task Pool es solo recomendación. **No** se valida al poner gente en una tarea.

Las **cuadrillas** quedan deprecated en API (el front ya no las muestra).

---

## Matriz de endpoints

### Asistencia (obra / día)

Base: `/api/v1/rrhh/asistencia`

| Acción | Método | Ruta |
|--------|--------|------|
| Listar | `GET` | `?obraId=&date=&currentOnly=&page=` → `attendance` |
| Registrar llegada | `POST` | `/` → `201` |

La llegada es **definitiva**: no hay anular/borrar. La registra el **admin**
(`recordedBy`); no se pide firma del trabajador.

```json
{
  "obraId": 1,
  "workDate": "2026-03-23",
  "workerId": 7,
  "signatureType": "acknowledgment",
  "signatureData": "Registrado por administrador en obra"
}
```

## Requisitos al registrar llegada

- Trabajador activo en RRHH
- `signatureType: "acknowledgment"` (recomendado) — sin canvas del trabajador
- Queda auditado quién registró (`recordedBy`), IP y user-agent
- **No** hace falta asignarlo antes en RRHH “En obra”
- Sin duplicado el mismo día en la misma obra
- Inmutable: no se puede anular

`signatureType: "electronic"` + imagen base64 sigue soportado (legacy).

### Gente del día (tarea)

Base: `/api/v1/operacion/tareas`

| Acción | Método | Ruta |
|--------|--------|------|
| Listar | `GET` | `/{taskId}/gente-dia?date=&currentOnly=` → `assignments` |
| Asignar | `POST` | `/{taskId}/gente-dia` → `201` |
| Quitar | `DELETE` | `/gente-dia/{assignmentId}` → `204` |

```json
{ "workerId": 7, "workDate": "2026-03-23" }
```

Requisito: el trabajador debe tener **asistencia firmada** ese día en la obra de la tarea.  
**No** se filtra por especialidad.

---

## Kanban / primaryAssignee

`TaskResponse.primaryAssignee` prioriza gente **de hoy** (`task_daily_assignments`).  
Si no hay, cae a asignación larga duración; luego cuadrilla (legacy).

---

## Pantallas sugeridas

| Ruta | Contenido |
|------|-----------|
| `/dashboard/obras/:obraId/asistencia` | Día + presentes (registra admin, inmutable) |
| Detalle tarea | “Hoy trabajan…” + historial |
| Project View | CTA “Asistencia de hoy” |

---

## Checklist

- [x] API asistencia diaria (acuse admin / firma legacy)
- [x] API gente-día en tarea (historial soft)
- [x] primaryAssignee usa gente de hoy
- [x] Cuadrillas marcadas deprecated
- [ ] Front: pantalla asistencia + drawer de tarea
- [ ] Project View CTA
