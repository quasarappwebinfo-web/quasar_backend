# Guía del frontend Quasar: RRHH operativo (Fase 3)

Trabajadores, asignación a obras y cuadrillas.

Complementa:
- [identidad-frontend.md](./identidad-frontend.md) — personas / usuarios
- [catalogos-frontend.md](./catalogos-frontend.md) — cargos y especialidades (Fase 2)

**Auth:** Bearer + rol **`admin`**. JSON **camelCase**. `isActive`: `1` activo, `2` inactivo.

---

## Conceptos que el frontend no debe mezclar

| Concepto | Qué es | Qué **no** es |
|----------|--------|----------------|
| **Persona** | Identidad (cédula) | Login ni vínculo a obra |
| **Usuario** | Login al sistema | Trabajador automáticamente |
| **Trabajador** | Rol laboral de una persona | Usuario (puede o no tener `linkedUserId`) |
| **Baja de trabajador** (`isActive=2`) | Sale de la nómina / RRHH | Sacar de una obra |
| **Asignación a obra** | Está (o estuvo) en una obra | Baja definitiva |
| **Miembro de cuadrilla** | Pertenece a un equipo | Baja del trabajador |

Flujo típico de alta:

1. Crear/buscar **persona** (`/identidad/personas`)
2. (Opcional) crear **usuario** ligado a esa persona
3. Crear **trabajador** con `personId` + cargo + especialidad (+ `linkedUserId`)
4. Cuando exista obra (Fase 4): **asignar** a obra y/o meter en **cuadrilla**

> Los catálogos de Fase 2 (cargos, especialidades, motivos de retraso, etc.) son maestros reutilizables. Esta fase **consume** cargos/especialidades; no los redefine.

---

## Matriz de endpoints

| Recurso | Base |
|---------|------|
| Trabajadores | `/api/v1/rrhh/trabajadores` |
| Asignaciones | `/api/v1/rrhh/asignaciones` |
| Cuadrillas | `/api/v1/rrhh/cuadrillas` |

Paginación estándar (`totalItems`, `itemsPerPage`, `currentPage`, 15/página).

---

## 3.1 Trabajadores

### Listar

`GET /api/v1/rrhh/trabajadores?page=1&search=&activeOnly=false&workerPositionId=`

| Query | Uso |
|--------|-----|
| `search` | Nombre o cédula de la persona |
| `activeOnly` | Solo no dados de baja |
| `workerPositionId` | Filtrar por cargo |

### Crear

`POST /api/v1/rrhh/trabajadores` → `201`

```json
{
  "personId": 1,
  "workerPositionId": 2,
  "specialtyId": 3,
  "linkedUserId": 5
}
```

Reglas:

- **1 persona = 1 trabajador** → si ya existe: `409`
- Cargo/especialidad deben existir y estar activos
- Si la especialidad está ligada a un cargo, debe coincidir con `workerPositionId`
- `linkedUserId` opcional; si se envía, el usuario debe ser de **la misma persona**

### Obtener / actualizar

- `GET /api/v1/rrhh/trabajadores/{id}`
- `PUT /api/v1/rrhh/trabajadores/{id}` — solo cargo, especialidad, usuario vinculado (no cambia `personId`)

### Baja / reactivar (≠ salida de obra)

`PUT /api/v1/rrhh/trabajadores/{id}/status`

```json
{ "isActive": 2, "deactivationReason": "Fin de contrato" }
```

Reactivar: `{ "isActive": 1 }` (limpia el motivo).

### Respuesta (campos útiles UI)

`id`, `personId`, `personName`, `documentNumber`, `workerPositionId`, `positionName`, `specialtyId`, `specialtyName`, `linkedUserId`, `linkedUsername`, `isActive`, `deactivationReason`, `createdAt`

---

## 3.2 Asignaciones a obras

> Requiere que exista la **obra** (`obraId`). El CRUD de obras es Fase 4; hasta entonces necesitas obras creadas en BD o esperar esa API.

### Listar

`GET /api/v1/rrhh/asignaciones?workerId=&obraId=&currentOnly=false&page=1`

`currentOnly=true` → solo vigentes (`endDate` null).

### Asignar

`POST /api/v1/rrhh/asignaciones` → `201`

```json
{
  "workerId": 1,
  "obraId": 10,
  "startDate": "2026-03-01",
  "endDate": null
}
```

- `assignedBy` lo pone el backend (usuario autenticado)
- No permite trabajador inactivo
- No permite otra asignación **vigente** del mismo trabajador en la **misma** obra → `409`
- Historial: **nunca borrar**; cerrar con endDate

### Cerrar asignación

`PUT /api/v1/rrhh/asignaciones/{id}/cerrar`

```json
{ "endDate": "2026-06-30" }
```

Si omites `endDate`, usa la fecha de hoy.

### Respuesta

`id`, `workerId`, `obraId`, `startDate`, `endDate`, `assignedBy`, `personName`, `obraName`, `createdAt`

**UI:** en ficha de trabajador, pestaña “Obras” con vigentes + historial. Botón “Sacar de obra” = cerrar asignación, **no** baja de trabajador.

---

## 3.3 Cuadrillas

### Listar / CRUD

| Acción | Método | Ruta |
|--------|--------|------|
| Listar | GET | `/api/v1/rrhh/cuadrillas?search=&activeOnly=&obraId=` |
| Crear | POST | `/api/v1/rrhh/cuadrillas` |
| Ver | GET | `/api/v1/rrhh/cuadrillas/{id}` |
| Editar | PUT | `/api/v1/rrhh/cuadrillas/{id}` |

Crear:

```json
{
  "name": "Cuadrilla A",
  "leaderWorkerId": 1,
  "obraId": 10
}
```

Si envías `leaderWorkerId`, el backend también lo agrega como **miembro vigente**.

`isActive` en update: `1` \| `2` (desactivar cuadrilla ≠ sacar miembros uno a uno).

### Miembros

| Acción | Método | Ruta |
|--------|--------|------|
| Listar | GET | `/api/v1/rrhh/cuadrillas/{id}/miembros?currentOnly=true` |
| Agregar | POST | `/api/v1/rrhh/cuadrillas/{id}/miembros` |
| Sacar | PUT | `/api/v1/rrhh/cuadrillas/miembros/{membershipId}/sacar` |

Agregar body:

```json
{ "workerId": 2 }
```

- Miembro ya vigente en esa cuadrilla → `409`
- Sacar pone `leftAt` (historial); listar con `currentOnly=true` (default) solo muestra `leftAt == null`

Respuesta miembro: `id`, `crewId`, `workerId`, `joinedAt`, `leftAt`, `personName`, `documentNumber`

---

## Dependencias de otras fases

| Necesitas… | De dónde |
|------------|----------|
| Persona | Fase 1 `/identidad/personas` |
| Usuario (opcional) | Fase 1 `/user/users` |
| Cargo / especialidad | Fase 2 `/rrhh/cargos`, `/rrhh/especialidades` |
| Obra (`obraId`) | Fase 4 (aún no hay CRUD HTTP) |

En selects: `activeOnly=true` en cargos, especialidades y trabajadores.

---

## Checklist frontend

- [ ] Alta trabajador: persona → cargo/especialidad → (opcional) usuario vinculado
- [ ] Manejo `409` si la persona ya es trabajador
- [ ] Baja con motivo; copy claro: “baja RRHH ≠ sacar de obra”
- [ ] Pantalla asignaciones (cuando haya obras): asignar / cerrar, historial
- [ ] Cuadrillas: crear, miembros actuales, sacar (historial)
- [ ] No borrar asignaciones ni membresías; solo cerrar / leftAt

Obras (CRUD, clientes, documentos): [obras-frontend.md](./obras-frontend.md).
