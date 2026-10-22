# Guía del frontend Quasar: Task Pool (Fase 5)

Biblioteca reutilizable de conocimiento constructivo. **No son tareas de obra.**

Complementa:
- [catalogos-frontend.md](./catalogos-frontend.md) — unidades de medida, cargos (`worker_positions`)
- [rrhh-frontend.md](./rrhh-frontend.md) — cuadrillas (referencia opcional en versiones)
- [system-core.md](./system-core.md) — §7–10 (concepto Task Pool / versiones / recomendaciones)

**Auth:** Bearer + rol **`admin`**. JSON **camelCase**.  
Paginación: 15 ítems/página (mismo shape que el resto del API).

---

## Concepto (léelo antes de pintar pantallas)

| Qué es | Qué no es |
|--------|-----------|
| Catálogo de plantillas versionadas | Tareas asignadas a una obra (eso es Fase 6) |
| Identidad de la actividad (capítulo, actividad presupuestal, nombre, código). Cantidad, tiempo, subtareas y cuadrillas son opcionales | Aprobación del supervisor |
| El sistema **recomienda** | Nadie auto-aprueba aquí |

Flujo mental:

```
Capítulo → Plantilla (code único) → Versión draft
    → editar detalle (unidades, cargos, subtareas, deps)
    → Publicar (inmutable)
    → Recomendar(obraQuantity) → valores sugeridos
    → (Fase 6) crear tarea en obra y el supervisor aprueba
```

Cambios a una versión **published**: no se edita. Se crea una **nueva versión** (opcionalmente clonando con `copyFromVersionId`).

### Cómo pintar cada campo

En cada formulario de alta, marca el input según la columna **Al crear**:

| Marca en UI | Significado |
|-------------|-------------|
| **Obligatorio** | Hay que enviarlo. Si falta o viene vacío, el API responde `422`. |
| **Opcional** | Se puede omitir o mandar `null`. La pantalla no debe exigirlo. |
| **Opcional, default N** | Si no se envía, el backend guarda `N`. No lo pidas en el formulario. |

Reglas de producto para el pool:

- La actividad se registra y se publica **sin** cantidades, tiempos, subtareas, cargos, unidades, dependencias ni cuadrillas. Esos bloques enteros son opcionales.
- Si el usuario agrega una fila dentro de un bloque opcional, esa fila sí tiene sus propios campos obligatorios (están en la tabla de esa fila).
- El `PUT` es parcial en todos los recursos: ningún campo es obligatorio. Envía solo lo que cambió. El `code` de la plantilla no se edita.

---

## Status de versión (canónicos)

| Valor | Editable | Recomendación | Uso UI |
|--------|----------|---------------|--------|
| `draft` | Sí | No | Borrador en edición |
| `published` | No (inmutable) | Sí | Versión vigente usable |
| `archived` | No | No | Histórico; no usar para nuevas tareas |

Transiciones:

- `draft` → `published` — `POST .../publicar` (no exige cantidades, tiempos, subtareas ni cuadrillas)
- `published` → `archived` — `POST .../archivar`
- No se archiva un `draft` (400)

---

## Mapa de pantallas sugerido

| Ruta frontend | Pantalla | Contenido |
|---------------|----------|-----------|
| `/maestros/task-pool/etapas` | Etapas | El catálogo de etapas de obra. Obligatorio: nombre y orden. Opcional: descripción y `%` de la obra |
| `/maestros/task-pool/capitulos` | Capítulos | CRUD. Obligatorio: nombre y etapa. Opcional: descripción, orden, `%` de la etapa |
| `/maestros/task-pool/actividades-presupuestales` | Actividades presupuestales | CRUD. Obligatorio: capítulo y nombre. Opcional: zona, descripción, orden, `%` del capítulo |
| `/maestros/task-pool/plantillas` | Listado plantillas | Filtro capítulo, búsqueda, activo |
| `/maestros/task-pool/plantillas/:id` | Detalle plantilla | Meta + listado de versiones |
| `/maestros/task-pool/versiones/:versionId` | Editor de versión | Cabecera + tabs detalle; botones Publicar / Archivar / Nueva versión |
| (modal / drawer) | Recomendar | Input cantidad obra → duración y cargos sugeridos |

Carpeta feature sugerida: `src/task-pool/` (APIs, tipos, pantallas maestros).

---

## Matriz de endpoints

Base común: `/api/v1/catalogo`

| Recurso | Método | Ruta | Notas |
|---------|--------|------|-------|
| Capítulos | `GET` | `/capitulos-tarea` | `?page&search&activeOnly` → `chapters` |
| | `POST` | `/capitulos-tarea` | `201` |
| | `GET` | `/capitulos-tarea/{id}` | |
| | `PUT` | `/capitulos-tarea/{id}` | parcial + `isActive` |
| Zonas | `GET` | `/zonas-tarea` | `?page&search&activeOnly` → `zones` |
| | `POST`/`GET`/`PUT` | `/zonas-tarea[/{id}]` | igual que capítulos |
| Act. presupuestal | `GET` | `/actividades-presupuestales` | → `budgetActivities` |
| | `POST`/`GET`/`PUT` | `/actividades-presupuestales[/{id}]` | igual que capítulos |
| Plantillas | `GET` | `/plantillas` | `?page&search&chapterId&zoneId&budgetActivityId&activeOnly` → `templates` |
| | `POST` | `/plantillas` | `201`; `code` único |
| | `GET` | `/plantillas/{id}` | |
| | `PUT` | `/plantillas/{id}` | no cambia `code` |
| Versiones | `GET` | `/plantillas-versiones` | `?page&templateId&status` → `versions` |
| | `POST` | `/plantillas-versiones` | siempre nace `draft`; opcional `copyFromVersionId` |
| | `GET` | `/plantillas-versiones/{id}` | versión + detalle completo |
| | `PUT` | `/plantillas-versiones/{id}` | solo `draft` |
| | `POST` | `/plantillas-versiones/{id}/publicar` | → `published` |
| | `POST` | `/plantillas-versiones/{id}/archivar` | published → archived |
| | `POST` | `/plantillas-versiones/{id}/recomendar` | body `obraQuantity` |
| Unidades | `POST` | `/plantillas-versiones/{id}/unidades` | solo draft |
| | `DELETE` | `/plantillas-versiones/unidades/{itemId}` | `204` |
| Cargos | `POST` | `/plantillas-versiones/{id}/cargos` | solo draft |
| | `DELETE` | `/plantillas-versiones/cargos/{itemId}` | `204` |
| Subtareas | `POST` | `/plantillas-versiones/{id}/subtareas` | solo draft |
| | `PUT` | `/plantillas-versiones/subtareas/{itemId}` | solo draft |
| | `DELETE` | `/plantillas-versiones/subtareas/{itemId}` | `204` |
| Dependencias | `POST` | `/plantillas-versiones/{id}/dependencias` | solo draft; apunta a **plantilla**, no a versión |
| | `DELETE` | `/plantillas-versiones/dependencias/{itemId}` | `204` |

Errores: `400` validación / status incorrecto · `404` no existe · `409` nombre/`code` duplicado.

---

## 5.1 Capítulos (`task_chapters`)

Base: `/api/v1/catalogo/capitulos-tarea`

### Crear

```json
{
  "name": "Estructura",
  "stageId": 1,
  "description": "Actividades estructurales",
  "displayOrder": 10,
  "weightPercent": 25
}
```

| Campo | Al crear | En el `PUT` | Qué es |
|-------|----------|-------------|--------|
| `name` | **Obligatorio** | Opcional | Nombre del capítulo. 1–150 caracteres |
| `stageId` | **Obligatorio** | Opcional | Etapa de obra (`/api/v1/obras/etapas`) activa. El capítulo pertenece a esa etapa |
| `description` | Opcional | Opcional | Texto libre |
| `displayOrder` | Opcional, default `0` | Opcional | Orden en listados |
| `weightPercent` | Opcional | Opcional | `%` del capítulo dentro del 100% de su etapa. El `%` de la etapa es el que aporta a la obra. `0`–`100` |
| `isActive` | No se envía (el backend guarda `1`) | Opcional | `1` activo, `2` inactivo |

### Respuesta

```json
{
  "id": 1,
  "name": "Estructura",
  "stageId": 1,
  "stageName": "Estructura",
  "description": "Actividades estructurales",
  "displayOrder": 10,
  "weightPercent": "25.00",
  "isActive": 1,
  "createdAt": "2026-03-18T12:00:00"
}
```

Lista: `{ "chapters": [...], "pagination": { ... } }`.  
Orden por defecto: `displayOrder` ASC, luego `name`.

---

## 5.1b Zonas (`task_zones`) y actividades presupuestales (`task_budget_activities`)

### Zona — `/api/v1/catalogo/zonas-tarea`

Ámbito de la obra (Casa, Zona social, …). No participa en el `%` de cumplimiento.

| Campo | Al crear | En el `PUT` | Qué es |
|-------|----------|-------------|--------|
| `name` | **Obligatorio** | Opcional | 1–150 caracteres |
| `description` | Opcional | Opcional | Texto libre |
| `displayOrder` | Opcional, default `0` | Opcional | Orden |
| `isActive` | No se envía | Opcional | `1` activo, `2` inactivo |

### Actividad presupuestal — `/api/v1/catalogo/actividades-presupuestales`

Rubro dentro de un capítulo. Ejemplo: capítulo Estructura → actividad Estructura metálica.

| Campo | Al crear | En el `PUT` | Qué es |
|-------|----------|-------------|--------|
| `chapterId` | **Obligatorio** | Opcional | Capítulo al que pertenece. Tiene que existir y estar activo |
| `name` | **Obligatorio** | Opcional | 1–150 caracteres. Único dentro del mismo capítulo |
| `zoneId` | Opcional | Opcional | Zona. Se puede dejar vacía |
| `description` | Opcional | Opcional | Texto libre |
| `displayOrder` | Opcional, default `0` | Opcional | Orden |
| `chapterWeightPercent` | Opcional | Opcional | `%` de cumplimiento de esta actividad dentro del 100% de su capítulo. `0`–`100` |
| `zoneWeightPercent` | Opcional | Opcional | `%` que aporta al 100% de su zona. `0`–`100`. No hace falta para el avance global |
| `isActive` | No se envía | Opcional | `1` activo, `2` inactivo |

Migración: `007_task_zone_budget_activity`.

---

## 5.2 Plantillas (`task_templates`)

Base: `/api/v1/catalogo/plantillas`

La plantilla es la identidad estable (`code`). El conocimiento vive en las **versiones**.

### Crear

```json
{
  "chapterId": 1,
  "zoneId": 2,
  "budgetActivityId": 3,
  "name": "Vaciado de losa",
  "code": "EST-LOSA-01",
  "description": "Vaciado de losa de concreto"
}
```

| Campo | Al crear | En el `PUT` | Qué es |
|-------|----------|-------------|--------|
| `chapterId` | **Obligatorio** | Opcional | Capítulo activo |
| `budgetActivityId` | **Obligatorio** | Opcional | Actividad presupuestal activa, y del mismo `chapterId` |
| `name` | **Obligatorio** | Opcional | 1–255 caracteres |
| `code` | **Obligatorio** | No se puede cambiar | Código único. Si se repite, `409` |
| `zoneId` | Opcional | Opcional | Zona. La actividad se guarda sin zona |
| `description` | Opcional | Opcional | Texto libre |
| `budgetWeightPercent` | No se envía | No se envía | Lo calcula el backend: 100 dividido entre las actividades activas de esa actividad presupuestal. 1 actividad = 100, 2 = 50, 3 = 33.33. Al crear, mover o activar/desactivar una, se recalculan todas las de ese grupo |
| `isActive` | No se envía | Opcional | `1` activo, `2` inactivo |

### Respuesta

```json
{
  "id": 1,
  "chapterId": 1,
  "chapterName": "Estructura",
  "zoneId": 2,
  "zoneName": "Casa",
  "budgetActivityId": 3,
  "budgetActivityName": "Estructura metálica",
  "name": "Vaciado de losa",
  "code": "EST-LOSA-01",
  "description": "Vaciado de losa de concreto",
  "budgetWeightPercent": "50.00",
  "isActive": 1,
  "createdAt": "2026-03-18T12:00:00"
}
```

Lista: `{ "templates": [...], "pagination": { ... } }`.

Filtros útiles:

| Query | Uso |
|--------|-----|
| `chapterId` | Filtrar por capítulo |
| `activeOnly=true` | Selectors / pickers |
| `search` | Nombre o código |

---

## 5.3 Versiones (`task_template_versions`)

Base: `/api/v1/catalogo/plantillas-versiones`

### Crear draft

```json
{
  "taskTemplateId": 1,
  "name": "Vaciado de losa v1",
  "description": "Rendimiento inicial",
  "baseQuantity": 100,
  "baseDurationDays": 5,
  "copyFromVersionId": null
}
```

| Campo | Al crear | En el `PUT` (solo `draft`) | Qué es |
|-------|----------|----------------------------|--------|
| `taskTemplateId` | **Obligatorio** | No se envía | Plantilla dueña de la versión |
| `name` | **Obligatorio** | Opcional | 1–255 caracteres |
| `versionNumber` | Opcional | No se envía | Si se omite, el backend pone el siguiente entero de esa plantilla |
| `description` | Opcional | Opcional | Texto libre |
| `baseQuantity` | Opcional | Opcional | Cantidad base. No hace falta para guardar ni para publicar |
| `baseDurationDays` | Opcional | Opcional | Días base. No hace falta para guardar ni para publicar |
| `copyFromVersionId` | Opcional | No se envía | Clona unidades, cargos, subtareas y dependencias de otra versión |

Status inicial: siempre **`draft`**. Publicar no exige ninguno de los campos opcionales.

### Actualizar cabecera (solo draft)

```json
{
  "name": "Vaciado de losa v1 (ajustado)",
  "baseQuantity": 120,
  "baseDurationDays": 4.5
}
```

### GET detalle completo

`GET /plantillas-versiones/{versionId}`

```json
{
  "version": {
    "id": 10,
    "taskTemplateId": 1,
    "templateCode": "EST-LOSA-01",
    "templateName": "Vaciado de losa",
    "versionNumber": 1,
    "name": "Vaciado de losa v1",
    "description": "...",
    "status": "draft",
    "baseQuantity": "100.00",
    "baseDurationDays": "5.00",
    "publishedAt": null,
    "createdAt": "..."
  },
  "measurements": [ /* unidades */ ],
  "positions": [ /* cargos recomendados */ ],
  "subtasks": [ /* subtareas estándar */ ],
  "dependencies": [ /* deps a otras plantillas */ ],
  "preferredCrews": [ /* lectura; CRUD de crews no es foco Fase 5 */ ]
}
```

### Publicar

`POST /plantillas-versiones/{id}/publicar`

Requisitos:

- Status actual = `draft`

Cantidad, duración, subtareas, cargos y cuadrillas pueden ir vacíos. Tras publicar: **inmutable**. Cualquier `PUT` o `POST` de detalle → `400`.

### Archivar

`POST /plantillas-versiones/{id}/archivar`

Solo desde `published`. Sirve para retirar versiones viejas del uso diario sin borrar histórico.

### Heurística UI de edición

| Status | Cabecera | Tabs detalle | Acciones |
|--------|----------|--------------|----------|
| `draft` | Editable | CRUD ítems | Publicar |
| `published` | Solo lectura | Solo lectura | Archivar · “Nueva versión” (clone) |
| `archived` | Solo lectura | Solo lectura | “Nueva versión” si hace falta |

Botón **Nueva versión**: `POST /plantillas-versiones` con `copyFromVersionId` = versión actual.

---

## Detalle de versión (solo draft)

### Unidades (`task_template_measurements`)

`POST /plantillas-versiones/{id}/unidades`

```json
{ "unitId": 3, "isPrimary": 1 }
```

Agregar una unidad es opcional. Si se agrega:

| Campo | Al crear la fila | Qué es |
|-------|------------------|--------|
| `unitId` | **Obligatorio** | Unidad activa de `/api/v1/catalogo/unidades-medida` |
| `isPrimary` | Opcional, default `0` | `1` la marca primaria y desmarca las demás de esa versión |

`DELETE /plantillas-versiones/unidades/{itemId}` → `204`

Respuesta ejemplo:

```json
{
  "id": 1,
  "templateVersionId": 10,
  "unitId": 3,
  "unitName": "Metro cúbico",
  "unitSymbol": "m³",
  "isPrimary": 1,
  "createdAt": "..."
}
```

### Cargos recomendados (`task_template_positions`)

`POST /plantillas-versiones/{id}/cargos`

```json
{
  "workerPositionId": 2,
  "specialtyId": 5,
  "quantity": 4,
  "isRequired": 1
}
```

Agregar un cargo es opcional. Si se agrega, esta fila sí pide cantidad:

| Campo | Al crear la fila | En el `PUT` | Qué es |
|-------|------------------|-------------|--------|
| `workerPositionId` | **Obligatorio** | No se cambia | Cargo activo de `/api/v1/rrhh/cargos` |
| `quantity` | **Obligatorio** | Opcional | Personas de ese cargo. Tiene que ser `> 0` |
| `specialtyId` | Opcional | No se cambia | Especialidad activa. Si está ligada a un cargo, debe coincidir |
| `isRequired` | Opcional, default `1` | Opcional | `1` o `0` |

`DELETE /plantillas-versiones/cargos/{itemId}` → `204`

### Subtareas estándar (`task_template_subtasks`)

`POST /plantillas-versiones/{id}/subtareas`

```json
{
  "name": "Armado de formaleta",
  "description": null,
  "displayOrder": 1,
  "isRequired": 1
}
```

Agregar una subtarea es opcional. Si se agrega:

| Campo | Al crear la fila | En el `PUT` | Qué es |
|-------|------------------|-------------|--------|
| `name` | **Obligatorio** | Opcional | 1–255 caracteres |
| `description` | Opcional | Opcional | Texto libre |
| `displayOrder` | Opcional, default `0` | Opcional | Orden |
| `isRequired` | Opcional, default `1` | Opcional | `1` o `0` |
| `weightPercent` | Opcional | Opcional | `%` dentro de la actividad. `0`–`100`. Si no se envía, queda `0` |

No hace falta que los `%` de las subtareas sumen 100 para publicar.

`DELETE .../subtareas/{itemId}` → `204`.

### Dependencias entre plantillas (`task_template_dependencies`)

Importante: `dependsOnTemplateId` apunta a una **plantilla** (`task_templates.id`), no a una versión concreta. En obra (Fase 6) se resolverá contra la versión vigente de esa plantilla.

`POST /plantillas-versiones/{id}/dependencias`

```json
{
  "dependsOnTemplateId": 5,
  "dependencyType": "finish_to_start",
  "isRequired": 1,
  "blocksStart": 1,
  "description": "Debe terminar el armado antes del vaciado"
}
```

Agregar una dependencia es opcional. Si se agrega:

| Campo | Al crear la fila | Qué es |
|-------|------------------|--------|
| `dependsOnTemplateId` | **Obligatorio** | Id de otra **plantilla**, no de una versión |
| `dependencyType` | Opcional, default `finish_to_start` | Uno de los valores de abajo |
| `isRequired` | Opcional, default `1` | `1` o `0` |
| `blocksStart` | Opcional, default `1` | `1` o `0` |
| `description` | Opcional | Texto libre |

`dependencyType` válidos:

| Valor | Significado típico |
|--------|-------------------|
| `finish_to_start` | Default: A termina → B puede empezar |
| `start_to_start` | A y B arrancan juntos / B tras inicio de A |
| `finish_to_finish` | B termina cuando A termina |
| `start_to_finish` | Raro; B termina tras inicio de A |

`DELETE .../dependencias/{itemId}` → `204`.

### Cuadrillas

No hay alta de cuadrillas en el pool. No armes un campo obligatorio de cuadrilla en el formulario de la actividad. Si el detalle trae `preferredCrews`, muéstralo solo como lectura.

---

## 5.4 Recomendación (mínimo)

`POST /plantillas-versiones/{versionId}/recomendar`

Solo versiones **`published`**.

### Request

```json
{ "obraQuantity": 250, "targetDurationDays": 10 }
```

| Campo | Al pedir recomendación | Qué es |
|-------|------------------------|--------|
| `obraQuantity` | **Obligatorio** | Cantidad de la obra. `> 0`. Este llamado sí es un rendimiento: solo tiene sentido si la versión publicada tiene `baseQuantity` y `baseDurationDays` |
| `targetDurationDays` | Opcional | Días objetivo. `> 0` si se envía |

La respuesta incluye la unidad primaria (`unitSymbol` / `unitName`). Registrar o publicar la actividad no pasa por este endpoint.

### Fórmula

```
scaleFactor = obraQuantity / baseQuantity
duración a ritmo base = baseDurationDays × scaleFactor

Sin targetDurationDays:
  recommendedDurationDays = duración a ritmo base
  recommendedQuantity(cargo) = quantity × scaleFactor

Con targetDurationDays:
  recommendedDurationDays = targetDurationDays
  crewScale = (duración a ritmo base) / targetDurationDays
  recommendedQuantity(cargo) = quantity × scaleFactor × crewScale
```

Ejemplo: base 100 m³ / 5 días / 4 personas; obra 250 m³ → factor `2.5` → a ritmo base `12.5` días y `10` personas. Si quieres gastar `10` días → intensidad `1.25` → `12.5` personas.
### Response

```json
{
  "templateVersionId": 10,
  "templateCode": "EST-LOSA-01",
  "versionNumber": 1,
  "status": "published",
  "baseQuantity": "100.00",
  "baseDurationDays": "5.00",
  "obraQuantity": "250",
  "scaleFactor": "2.5000",
  "recommendedDurationDays": "12.50",
  "recommendedPositions": [
    {
      "workerPositionId": 2,
      "positionName": "Oficial",
      "baseQuantity": "4.00",
      "recommendedQuantity": "10.00",
      "isRequired": 1
    }
  ],
  "note": "Valores RECOMENDADOS por el sistema. No están aprobados ni asignados; el responsable de obra decide."
}
```

### UI: cómo mostrar la recomendación

1. Badge o copy claro: **“Recomendado — pendiente de aprobación”**.
2. No persistir como aprobado en esta fase.
3. En Fase 6, al crear la tarea, estos valores alimentan `estimated_*`; el supervisor escribe `approved_*`.

**Principio:** el sistema recomienda; nadie auto-aprueba.

---

## Flujo feliz (checklist QA frontend)

1. Crear capítulo: solo el nombre es obligatorio. `weightPercent` es opcional.
2. Crear actividad presupuestal: `chapterId` y nombre obligatorios. `chapterWeightPercent` es opcional.
3. Crear plantilla: `chapterId`, `budgetActivityId`, `name` y `code` obligatorios. Zona opcional. `budgetWeightPercent` lo calcula el backend.
4. Crear versión draft (cantidad y duración opcionales).
5. El detalle (unidades, cargos, subtareas, cuadrillas) es opcional.
6. **Publicar** la versión.
7. Verificar que `PUT` cabecera y `POST` detalle fallan con 400.
8. Llamar **recomendar** con una cantidad y validar el factor.
9. Crear nueva versión con `copyFromVersionId` y comprobar que el detalle se clonó.
10. Archivar la versión publicada anterior.

---

## Errores frecuentes

| Situación | HTTP | Mensaje típico |
|-----------|------|----------------|
| Editar versión published | 400 | Solo se puede editar una versión en draft |
| Recomendar draft | 400 | Solo se recomienda desde una versión published |
| `code` plantilla duplicado | 409 | … |
| Capítulo / plantilla / versión inexistente | 404 | … |
| Archivar draft | 400 | No archives un draft… |

---

## Relación con fases siguientes

| Fase | Qué hace con el Task Pool |
|------|---------------------------|
| **6** | Crear tarea de obra desde `sourceTemplateVersionId` + cantidad; copiar/recomendar; supervisor aprueba |
| **7+** | Avance, overrides de dependencias, asignación real de gente |

Hasta entonces, el frontend solo administra el catálogo y puede demoear el endpoint de recomendación.
