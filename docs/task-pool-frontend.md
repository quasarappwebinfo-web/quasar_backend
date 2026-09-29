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
| Reglas: cantidad base, duración base, cargos, unidades, subtareas, deps | Aprobación del supervisor |
| El sistema **recomienda** | Nadie auto-aprueba aquí |

Flujo mental:

```
Categoría → Plantilla (code único) → Versión draft
    → editar detalle (unidades, cargos, subtareas, deps)
    → Publicar (inmutable)
    → Recomendar(obraQuantity) → valores sugeridos
    → (Fase 6) crear tarea en obra y el supervisor aprueba
```

Cambios a una versión **published**: no se edita. Se crea una **nueva versión** (opcionalmente clonando con `copyFromVersionId`).

---

## Status de versión (canónicos)

| Valor | Editable | Recomendación | Uso UI |
|--------|----------|---------------|--------|
| `draft` | Sí | No | Borrador en edición |
| `published` | No (inmutable) | Sí | Versión vigente usable |
| `archived` | No | No | Histórico; no usar para nuevas tareas |

Transiciones:

- `draft` → `published` — `POST .../publicar` (exige `baseQuantity` y `baseDurationDays` > 0)
- `published` → `archived` — `POST .../archivar`
- No se archiva un `draft` (400)

---

## Mapa de pantallas sugerido

| Ruta frontend | Pantalla | Contenido |
|---------------|----------|-----------|
| `/maestros/task-pool/categorias` | Categorías | CRUD + `displayOrder` |
| `/maestros/task-pool/plantillas` | Listado plantillas | Filtro categoría, búsqueda, activo |
| `/maestros/task-pool/plantillas/:id` | Detalle plantilla | Meta + listado de versiones |
| `/maestros/task-pool/versiones/:versionId` | Editor de versión | Cabecera + tabs detalle; botones Publicar / Archivar / Nueva versión |
| (modal / drawer) | Recomendar | Input cantidad obra → duración y cargos sugeridos |

Carpeta feature sugerida: `src/task-pool/` (APIs, tipos, pantallas maestros).

---

## Matriz de endpoints

Base común: `/api/v1/catalogo`

| Recurso | Método | Ruta | Notas |
|---------|--------|------|-------|
| Categorías | `GET` | `/categorias-tarea` | `?page&search&activeOnly` → `categories` |
| | `POST` | `/categorias-tarea` | `201` |
| | `GET` | `/categorias-tarea/{id}` | |
| | `PUT` | `/categorias-tarea/{id}` | parcial + `isActive` |
| Zonas | `GET` | `/zonas-tarea` | `?page&search&activeOnly` → `zones` |
| | `POST`/`GET`/`PUT` | `/zonas-tarea[/{id}]` | igual que categorías |
| Act. presupuestal | `GET` | `/actividades-presupuestales` | → `budgetActivities` |
| | `POST`/`GET`/`PUT` | `/actividades-presupuestales[/{id}]` | igual que categorías |
| Plantillas | `GET` | `/plantillas` | `?page&search&categoryId&zoneId&budgetActivityId&activeOnly` → `templates` |
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

## 5.1 Categorías (`task_categories`)

Base: `/api/v1/catalogo/categorias-tarea`

### Crear

```json
{
  "name": "Estructura",
  "description": "Actividades estructurales",
  "displayOrder": 10
}
```

### Respuesta

```json
{
  "id": 1,
  "name": "Estructura",
  "description": "Actividades estructurales",
  "displayOrder": 10,
  "isActive": 1,
  "createdAt": "2026-03-18T12:00:00"
}
```

Lista: `{ "categories": [...], "pagination": { ... } }`.  
Orden por defecto: `displayOrder` ASC, luego `name`.

---

## 5.1b Zonas (`task_zones`) y actividades presupuestales (`task_budget_activities`)

Mismo patrón que categorías (nombre, descripción, orden, soft `isActive`).

- Zonas: `/api/v1/catalogo/zonas-tarea` — ámbito de la obra (Casa, Zona social, …).
- Actividades: `/api/v1/catalogo/actividades-presupuestales` — rubro más fino, **siempre ligado a una categoría** (`categoryId`). Ej. categoría Estructura → actividad Estructura metálica.

Migración: `007_task_zone_budget_activity`.

---

## 5.2 Plantillas (`task_templates`)

Base: `/api/v1/catalogo/plantillas`

La plantilla es la identidad estable (`code`). El conocimiento vive en las **versiones**.

### Crear

```json
{
  "categoryId": 1,
  "zoneId": 2,
  "budgetActivityId": 3,
  "name": "Vaciado de losa",
  "code": "EST-LOSA-01",
  "description": "Vaciado de losa de concreto"
}
```

- `code` único (409 si se repite).
- `categoryId`, `zoneId` y `budgetActivityId` obligatorios al crear (catálogos activos).
- `PUT` puede cambiar categoría, zona, actividad, nombre, descripción, `isActive`; **no** el `code`.

### Respuesta

```json
{
  "id": 1,
  "categoryId": 1,
  "categoryName": "Estructura",
  "zoneId": 2,
  "zoneName": "Casa",
  "budgetActivityId": 3,
  "budgetActivityName": "Estructura metálica",
  "name": "Vaciado de losa",
  "code": "EST-LOSA-01",
  "description": "Vaciado de losa de concreto",
  "isActive": 1,
  "createdAt": "2026-03-18T12:00:00"
}
```

Lista: `{ "templates": [...], "pagination": { ... } }`.

Filtros útiles:

| Query | Uso |
|--------|-----|
| `categoryId` | Filtrar por categoría |
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

- Si omites `versionNumber`, el backend asigna el siguiente entero de esa plantilla.
- `copyFromVersionId`: clona unidades, cargos, subtareas y dependencias desde otra versión (útil al iterar).
- Status inicial: siempre **`draft`**.

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
- `baseQuantity` > 0
- `baseDurationDays` > 0

Tras publicar: **inmutable**. Cualquier `PUT` o `POST` de detalle → `400`.

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

- `unitId` de `/api/v1/catalogo/unidades-medida` (activo).
- Si `isPrimary: 1`, el backend desmarca las demás primarias de esa versión.
- `DELETE /plantillas-versiones/unidades/{itemId}` → `204`

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

- `workerPositionId` de `/api/v1/rrhh/cargos`.
- `specialtyId` opcional de `/api/v1/rrhh/especialidades` (debe ser activa; si la especialidad está ligada a un cargo, debe coincidir).
- `quantity` > 0 (cantidad base de personas para la `baseQuantity` de la versión).
- `DELETE /plantillas-versiones/cargos/{itemId}` → `204`

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

`PUT /plantillas-versiones/subtareas/{itemId}` — parcial.  
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

`dependencyType` válidos:

| Valor | Significado típico |
|--------|-------------------|
| `finish_to_start` | Default: A termina → B puede empezar |
| `start_to_start` | A y B arrancan juntos / B tras inicio de A |
| `finish_to_finish` | B termina cuando A termina |
| `start_to_finish` | Raro; B termina tras inicio de A |

`DELETE .../dependencias/{itemId}` → `204`.

---

## 5.4 Recomendación (mínimo)

`POST /plantillas-versiones/{versionId}/recomendar`

Solo versiones **`published`**.

### Request

```json
{ "obraQuantity": 250, "targetDurationDays": 10 }
```

`targetDurationDays` es opcional. La respuesta incluye la unidad primaria (`unitSymbol` / `unitName`).

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

1. Crear categoría con `displayOrder`.
2. Crear plantilla con `code` único.
3. Crear versión draft con `baseQuantity` / `baseDurationDays`.
4. Agregar unidad primaria, 1–2 cargos, subtareas, una dependencia.
5. **Publicar** la versión.
6. Verificar que `PUT` cabecera y `POST` detalle fallan con 400.
7. Llamar **recomendar** con una cantidad y validar el factor.
8. Crear nueva versión con `copyFromVersionId` y comprobar que el detalle se clonó.
9. Archivar la versión publicada anterior.

---

## Errores frecuentes

| Situación | HTTP | Mensaje típico |
|-----------|------|----------------|
| Editar versión published | 400 | Solo se puede editar una versión en draft |
| Publicar sin bases | 400 | baseQuantity / baseDurationDays debe ser > 0 |
| Recomendar draft | 400 | Solo se recomienda desde una versión published |
| `code` plantilla duplicado | 409 | … |
| Categoría / plantilla / versión inexistente | 404 | … |
| Archivar draft | 400 | No archives un draft… |

---

## Relación con fases siguientes

| Fase | Qué hace con el Task Pool |
|------|---------------------------|
| **6** | Crear tarea de obra desde `sourceTemplateVersionId` + cantidad; copiar/recomendar; supervisor aprueba |
| **7+** | Avance, overrides de dependencias, asignación real de gente |

Hasta entonces, el frontend solo administra el catálogo y puede demoear el endpoint de recomendación.
