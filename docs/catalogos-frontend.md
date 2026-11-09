# Guía del frontend Quasar: Catálogos (Fase 2)

CRUD admin de maestros pequeños: cargos, especialidades, motivos de retraso y unidades.

Tipos de venta, tipos de documento y etapas de obra **siguen en el API**, pero la app ya no tiene pantalla para administrarlos. `/dashboard/maestros/*` redirige a Inicio. El formulario de obra todavía puede leer tipos de venta. Los documentos de la obra ya no piden tipo.

Complementa [auth-frontend.md](./auth-frontend.md) e [identidad-frontend.md](./identidad-frontend.md).

**Auth:** `Authorization: Bearer <accessToken>` + rol **`admin`** en todas estas rutas.

JSON en **camelCase**. Estados: `isActive` → `1` activo, `2` inactivo.

Paginación (15/página):

```json
{
  "pagination": {
    "totalItems": 10,
    "itemsPerPage": 15,
    "currentPage": 1
  }
}
```

Query común en listados:

| Query | Uso |
|--------|-----|
| `page` | Página (≥ 1) |
| `search` | Texto (nombre / descripción / símbolo según catálogo) |
| `activeOnly=true` | Solo activos — ideal para **selects** |

Patrón de cada catálogo: `GET` lista · `POST` crear (`201`) · `GET /{id}` · `PUT /{id}` (parcial; incluye `isActive`).

Errores: `400` validación · `404` no existe · `409` nombre/símbolo duplicado.

---

## Matriz de endpoints

| Catálogo | Base URL | Colección en lista |
|----------|----------|--------------------|
| Cargos | `/api/v1/rrhh/cargos` | `positions` |
| Especialidades | `/api/v1/rrhh/especialidades` | `specialties` |
| Motivos de retraso | `/api/v1/operacion/motivos-retraso` | `delayReasons` |
| Unidades de medida | `/api/v1/catalogo/unidades-medida` | `measurementUnits` |
| Tipos de documento | `/api/v1/obras/tipos-documento` | `documentTypes` |
| Tipos de venta | `/api/v1/obras/tipos-venta` | `saleTypes` |
| Etapas de obra | `/api/v1/obras/etapas` | `stages` |

---

## 2.1 Cargos (`worker_positions`)

Base: `/api/v1/rrhh/cargos`

Ejemplos: Oficial, Ayudante, Maestro.

### Crear

```json
{ "name": "Oficial" }
```

### Respuesta

```json
{ "id": 1, "name": "Oficial", "isActive": 1 }
```

### Actualizar / desactivar

```json
{ "name": "Oficial mayor", "isActive": 2 }
```

**UI:** pantalla admin simple (tabla + modal). Los selects de alta de trabajador/especialidad usan `?activeOnly=true`.

---

## 2.2 Especialidades (`specialties`)

Base: `/api/v1/rrhh/especialidades`

Ligadas **opcionalmente** a un cargo (`workerPositionId`).

### Listar con filtro por cargo

`GET /api/v1/rrhh/especialidades?workerPositionId=1&activeOnly=true`

### Crear

```json
{
  "name": "Electricidad",
  "workerPositionId": 1
}
```

`workerPositionId` puede omitirse o ser `null`. Si se envía un id inexistente → `400`.

### Respuesta

```json
{
  "id": 1,
  "name": "Electricidad",
  "workerPositionId": 1,
  "isActive": 1
}
```

**UI:** selector de cargo (cargos activos) opcional al crear/editar. En formularios de trabajador, filtrar especialidades por el cargo elegido.

---

## 2.3 Motivos de retraso (`delay_reasons`)

Base: `/api/v1/operacion/motivos-retraso`

Usados al registrar retrasos en operación (lluvia, material, etc.).

### Crear

```json
{
  "name": "Lluvia",
  "description": "Condiciones climáticas adversas"
}
```

### Respuesta

```json
{
  "id": 1,
  "name": "Lluvia",
  "description": "Condiciones climáticas adversas",
  "isActive": 1
}
```

`search` mira nombre y descripción.

---

## 2.4 Unidades de medida (`measurement_units`)

Base: `/api/v1/catalogo/unidades-medida`

Para Task Pool y tareas (m², m³, und, …).

### Crear

```json
{ "name": "Metro cuadrado", "symbol": "m²" }
```

`name` y `symbol` deben ser únicos (conflicto → `409`).

### Respuesta

```json
{
  "id": 1,
  "name": "Metro cuadrado",
  "symbol": "m²",
  "isActive": 1
}
```

**UI select:** mostrar `symbol` (y name en tooltip o secundario).

---

## 2.5 Tipos de documento / venta / etapas

Estos tres catálogos **no tienen pantalla** en la app. El API de lectura sigue para no romper filas viejas. No construir de nuevo «Configuración global».

### Tipos de documento — `/api/v1/obras/tipos-documento`

```json
{
  "name": "Licencia de construcción",
  "description": "Permiso municipal"
}
```

Respuesta: `id`, `name`, `description`, `isActive`.

### Tipos de venta — `/api/v1/obras/tipos-venta`

Ejemplos: «Por encargo», «Para venta».

```json
{ "name": "Por encargo" }
```

Respuesta: `id`, `name`, `isActive`.

### Etapas de obra — `/api/v1/obras/etapas`

Ordenadas por `displayOrder` (no por nombre).

```json
{
  "name": "Cimentación",
  "description": "Fase inicial",
  "displayOrder": 10
}
```

Respuesta:

```json
{
  "id": 1,
  "name": "Cimentación",
  "description": "Fase inicial",
  "displayOrder": 10,
  "isActive": 1
}
```

El stepper de etapas de la obra, si todavía aparece en el formulario, ordena por `displayOrder`. El **Progreso de la construcción** de la ficha no usa estas etapas: usa capítulos y zonas.

---

## Flujos de pantalla

1. **RRHH:** Cargos y especialidades (la especialidad depende del cargo).
2. **Listado General Act.:** unidades de medida, junto con capítulos, subcapítulos, zonas y actividades registradas.
3. Motivos de retraso siguen en el API para los retrasos de una actividad.

En formularios de negocio (trabajador, obra, tarea):

- Cargar opciones con `GET …?activeOnly=true` (y cache corta en cliente).
- No mostrar inactivos en selects de alta; sí en pantallas de administración.

---

## Checklist frontend

- [ ] CRUD cargos
- [ ] CRUD especialidades (filtro `workerPositionId` + validación de cargo)
- [ ] CRUD motivos de retraso
- [ ] CRUD unidades de medida (mostrar símbolo)
- [ ] Selects de formularios con `activeOnly=true`
- [ ] No hay pantalla de tipos de documento, tipos de venta ni etapas
- [ ] Manejo de `409` en nombres duplicados

RRHH operativo (trabajadores, obras, cuadrillas): [rrhh-frontend.md](./rrhh-frontend.md).

Task Pool (plantillas versionadas): [task-pool-frontend.md](./task-pool-frontend.md).
