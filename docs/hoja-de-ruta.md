# Hoja de ruta de implementación (paso a paso)

Guía práctica de **qué construir y en qué orden** en Quasar Backend (y qué implica el front/offline).

Ya tienes: base Docker/MySQL, auth JWT + refresh cookie, modelos/schemas por dominio, script del primer admin.

Reglas al implementar cada módulo:

1. **Service** (lógica) → **endpoint** (HTTP) → permisos con `require_role` cuando aplique.
2. Preferir **desactivar / historial** antes que borrar (ver `system-core`).
3. Tablas con `uuid`: el cliente puede mandar el uuid (offline); si no viene, lo genera el backend.
4. Acciones importantes → dejar rastro en `audit_log` cuando el módulo esté listo (fase 9).

Documentos relacionados: [`system-core.md`](system-core.md) · [`auth-frontend.md`](auth-frontend.md) · [`estructura-modelos.md`](estructura-modelos.md) · [`primer-usuario.md`](primer-usuario.md) · [`task-pool-frontend.md`](task-pool-frontend.md) · [`tareas-frontend.md`](tareas-frontend.md) · [`planificacion-frontend.md`](planificacion-frontend.md) · [`sync-frontend.md`](sync-frontend.md)

---

## Cómo usar esta lista

- Cada paso = un “paquete” entregable (CRUD o flujo).
- No saltes dominios: **obras** necesita personas; **tareas** necesitan obras + catálogo; **firmas** necesitan planificaciones; **sync offline** al final del núcleo de campo.
- En cada CRUD mínimo: crear, listar (paginado/filtros), obtener por id, actualizar, activar/desactivar (si aplica).

---

## Fase 0 — Base (ya hecha / verificar)

- [x] Docker Compose + MySQL + `.env` (puertos sin choque)
- [x] Auth: login / refresh / logout / me
- [x] Modelos y schemas por dominio
- [x] Primer usuario admin (`scripts/crear_primer_usuario.py`)
- [ ] Migraciones aplicadas (`alembic upgrade head`)
- [ ] Login probado en `/docs`

---

## Fase 1 — Identidad (personas + usuarios)

Sin esto no hay trabajadores ni clientes de obra.

### 1.1 CRUD Personas (`persons`)

**Backend**

- [x] `app/services/` servicio de personas (buscar por cédula, no duplicar `document_number`)
- [x] Endpoints bajo `/api/v1/identidad/personas` (o `/api/v1/persons`)
  - `POST` crear
  - `GET` listar (búsqueda por nombre/documento)
  - `GET /{id}`
  - `PUT /{id}` actualizar datos
- [x] Regla: si la cédula ya existe → error `409` claro (no crear duplicado)

**Docs frontend:** [identidad-frontend.md](./identidad-frontend.md)

**Por qué primero:** persona es la identidad única; usuario y trabajador la reutilizan.

### 1.2 Roles y usuarios (completar lo que ya hay)

- [x] CRUD roles (`users_roles`) — listar activos ya existe parcialmente
- [x] CRUD usuarios admin: crear usuario ligado a `person_id` + `username` + password + rol
- [x] Cambio de contraseña (CLI ya existe; endpoint solo admin o el propio usuario)
- [x] Activar / desactivar usuario con motivo (`deactivation_reason` + más adelante audit)

---

## Fase 2 — Catálogos chicos de RRHH

Antes de trabajadores y plantillas.

**Docs frontend:** [catalogos-frontend.md](./catalogos-frontend.md)

### 2.1 Cargos (`worker_positions`)

- [x] CRUD: Oficial, Ayudante, Maestro, etc. → `/api/v1/rrhh/cargos`

### 2.2 Especialidades (`specialties`)

- [x] CRUD ligadas opcionalmente a un cargo → `/api/v1/rrhh/especialidades`

### 2.3 Motivos de retraso (`delay_reasons`)

- [x] CRUD: lluvia, material, etc. (se usan en operación) → `/api/v1/operacion/motivos-retraso`

### 2.4 Unidades de medida (`measurement_units`)

- [x] CRUD: m², m³, und, etc. (Task Pool y tareas) → `/api/v1/catalogo/unidades-medida`

### 2.5 Tipos de documento / venta / etapas de obra

- [x] `document_types` → `/api/v1/obras/tipos-documento`
- [x] `obra_sale_types` (Por encargo, Para venta) → `/api/v1/obras/tipos-venta`
- [x] `obra_stages` (con `display_order`) → `/api/v1/obras/etapas`

Estos son “maestros”: pocos registros, seed o CRUD admin.

---

## Fase 3 — RRHH operativo

**Docs frontend:** [rrhh-frontend.md](./rrhh-frontend.md)

> Consume catálogos de Fase 2 (cargos/especialidades). Asignaciones y cuadrillas con `obraId` requieren obras (Fase 4).

### 3.1 Trabajadores (`workers`)

- [x] Crear trabajador: `person_id` (persona previa) + cargo + especialidad
- [x] Listar / filtrar activos
- [x] Vincular `linked_user_id` opcional (misma persona)
- [x] Baja definitiva (`is_active` + motivo) ≠ salida de obra
- [x] 1 persona = 1 trabajador

### 3.2 Asignación a obras (`worker_assignments`)

- [x] Asignar trabajador a obra (`start_date`, `end_date` null = vigente)
- [x] Cerrar asignación (poner `end_date`) — historial, no borrar

### 3.3 Cuadrillas (`crews` + `crew_members`)

- [x] Crear cuadrilla (nombre, líder, obra actual opcional)
- [x] Agregar / sacar miembros (`joined_at` / `left_at`)
- [x] Listar miembros actuales (`left_at IS NULL`)

---

## Fase 4 — Obras

**Docs frontend:** [obras-frontend.md](./obras-frontend.md)

### 4.1 CRUD Obras (`obras`)

- [x] Crear obra: nombre, `sale_type_id`, status, fechas, ubicación
- [x] Cliente **no obligatorio** al crear
- [x] Listar / filtrar por status, ciudad, etapa
- [x] Cambiar etapa actual + registrar en `obra_stage_history`

### 4.2 Clientes de obra (`obra_clients`)

- [x] Asociar `person_id` con rol (`comprador`, `propietario`, `contacto`)
- [x] Marcar primario; historial con `end_date`

### 4.3 Documentos de obra (`documents`)

- [x] Subir metadatos + `file_url` (storage local/S3 más adelante)
- [x] Generar/`uuid` para sync futuro
- [x] Flag `is_visible_to_client`

**Hito:** ya puedes administrar una obra con gente y papeles, sin tareas aún.

---

## Fase 5 — Task Pool (catálogo)

Conocimiento reutilizable. **No son tareas de obra.**

Doc frontend: [task-pool-frontend.md](./task-pool-frontend.md)

### 5.1 Categorías (`task_categories`)

- [x] CRUD con `display_order`

### 5.2 Plantillas (`task_templates`)

- [x] CRUD: nombre, `code` único, categoría

### 5.3 Versiones (`task_template_versions`)

- [x] Crear versión `draft`
- [x] Definir `base_quantity`, `base_duration_days`
- [x] Cargos recomendados (`task_template_positions`)
- [x] Unidades (`task_template_measurements`)
- [x] Subtareas estándar (`task_template_subtasks`)
- [x] Dependencias entre plantillas (`task_template_dependencies`)
- [x] **Publicar** versión → queda inmutable; cambios = **nueva versión**
- [x] Archivar versiones viejas

### 5.4 Servicio de recomendación (mínimo)

- [x] Dada plantilla versionada + cantidad de obra → calcular duración estimada  
  (ej. `cantidad_obra / base_quantity * base_duration_days`)
- [x] Devolver **recomendado** (el supervisor aún no aprueba aquí; eso es en la tarea)

**Principio:** el sistema recomienda; nadie auto-aprueba.

---

## Fase 6 — Operación (tareas en obra)

Aquí nace el día a día en campo (luego offline).

**Docs frontend:** [tareas-frontend.md](./tareas-frontend.md) · Figma [Tasks View](https://www.figma.com/design/6uvMxV1IJaVg3EIGiTDZMU/Quasar-App?node-id=18-597)

### 6.1 Crear tarea desde plantilla

- [x] Elegir obra + `source_template_version_id` + cantidad
- [x] Copiar/calcular: nombre, unidad, `estimated_duration_days`
- [x] Campos `approved_duration_days` / fechas los define el supervisor
- [x] Estado inicial `scheduled`
- [x] Registrar `task_status_history`
- [x] Asignar `uuid` (cliente o servidor)

### 6.2 Subtareas

- [x] Desde plantilla → hijas con `parent_task_id`
- [x] O crear subtareas manuales

### 6.3 Dependencias de tarea

- [x] Instanciar deps desde plantilla
- [x] Overrides locales (`task_dependency_overrides`) con motivo
- [x] Al iniciar: si `blocks_start` y dependencia no cumplida → **advertir / bloquear** (no silenciar)

### 6.4 Asignar recursos

- [x] Trabajadores (`task_assignments`)
- [x] Cuadrillas (`task_crew_assignments`)
- [x] Distinguir recomendado (plantilla) vs asignado (estas tablas)

### 6.5 Ciclo de vida

- [x] Transiciones: `scheduled` → `in_progress` → `completed` → `verified` (y `rescheduled`)
- [x] Cada cambio → `task_status_history`
- [x] Retrasos → `task_delay_events`
- [x] Reprogramaciones → `task_reschedules` (nunca pisar fechas sin historial)

### 6.6 Evidencia y comunicación

- [x] Comentarios / instrucciones (`task_comments`, type)
- [x] Fotos (`task_photos` + `uuid`)
- [x] (Upload de archivos: endpoint aparte o presigned URL)

**Hito campo:** registrar qué pasó en la tarea con evidencia.

---

## Fase 7 — Planificación y firmas

**Docs frontend:** [planificacion-frontend.md](./planificacion-frontend.md)

### 7.1 Work plans

- [x] Crear planificación por obra y periodo
- [x] Versión 1 con snapshot de tareas en `work_plan_tasks`
- [x] Estados: `draft` → `pending_signature` → `signed` / `rejected`

### 7.2 Firmas

- [x] Definir firmantes (`work_plan_signers`)
- [x] Solicitar firma (`requested_by` / eventos)
- [x] Firmar / rechazar (sin guardar passwords/tokens en `signature_data`)
- [x] Eventos: `requested`, `viewed`, `signed`, `rejected`, `cancelled`
- [x] Versión **firmada = inmutable**; cambio → nueva versión

### 7.3 Comparación planificado / aprobado / real

- [x] Endpoint o vista que combine snapshots + tarea actual + delays

---

## Fase 8 — Offline / sync (obras remotas)

No lo dejes para “después del producto”: el núcleo de **campo** (fase 6) debe nacer pensando en sync.

Orden sugerido:

1. [ ] Front: PWA + IndexedDB + outbox (ver `auth-frontend.md` + `sync-frontend.md`)
2. [x] Backend: `POST /api/v1/sync/push` (lote de cambios con uuid)
3. [x] Backend: `GET /api/v1/sync/pull?since=...`
4. [x] Conflictos: política simple (último `updated_at` / `clientUpdatedAt` → `conflict`)
5. [x] Fotos: cola aparte (`POST /api/v1/sync/fotos`; comprimir en front)

Primera ola offline (recomendado): comentarios, delays, fotos, cambios de estado, reprogramaciones.  
Catálogo y altas de obra pueden ser online-first al inicio.

Detalle de contrato: [`sync-frontend.md`](sync-frontend.md).

---

## Fase 9 — Auditoría y endurecimiento

- [ ] Helper `registrar_auditoria(...)` usado en create/update/deactivate
- [ ] Rate limits en endpoints sensibles
- [x] **Identidad de acceso (roles + permisos por usuario)** — ver §9.1
- [ ] Tests de los flujos críticos (login, crear obra, crear tarea, firmar)

### 9.1 Roles y permisos (implementado)

| Nivel | Quién | Acceso | ¿Alguien lo puede “tocar”? |
|-------|--------|--------|----------------------------|
| **Super admin** | Dueño (`is_super=1` / rol `super_admin`) | Todo | **Nadie** |
| **Admin** | Rol `admin` | Todo | Solo el **super admin** |
| **Usuario operativo** | supervisor / maestro / cliente / custom | Solo `permissions[]` | Admin o super |

Implementación:

- Tabla `user_permissions` + migración `011_user_permissions`
- Catálogo: `GET /api/v1/user/permissions/catalog`
- Create/update usuario acepta `permissions: string[]`
- `require_permission("obras"|…)` en endpoints (admin/super bypass)
- Login y `/auth/me` devuelven `permissions`, `hasFullAccess`, `isSuper`
- Script primer usuario → rol `super_admin` + `is_super=1`

Contrato front: [`identidad-frontend.md`](identidad-frontend.md).

---

## Orden resumido (checklist corta)

| # | Qué hacer |
|---|-----------|
| 1 | CRUD **Personas** |
| 2 | Completar **Usuarios / roles** |
| 3 | Maestros: cargos, especialidades, unidades, motivos, etapas, tipos venta/doc |
| 4 | CRUD **Trabajadores** + asignaciones a obra |
| 5 | CRUD **Cuadrillas** + miembros |
| 6 | CRUD **Obras** + clientes + documentos |
| 7 | **Task Pool**: categorías → plantillas → versiones (publicar inmutable) |
| 8 | **Recomendación** de duración/recursos (solo sugiere) |
| 9 | **Tareas** en obra (desde plantilla) + deps + asignaciones |
| 10 | Estados, retrasos, reprogramaciones |
| 11 | Comentarios + fotos |
| 12 | **Planificaciones** + snapshots |
| 13 | **Firmas** + eventos |
| 14 | **Sync push/pull** + PWA offline |
| 15 | **Audit log** + **super admin** intocable + permisos por usuario (no-admins) |

---

## Convención de carpetas al codear cada paso

Para el paso N (ejemplo personas):

```text
app/services/identidad/person_service.py   # o person_service.py en services/
app/api/v1/endpoints/identidad/person.py
# schemas y models ya existen en identidad/
```

Misma idea por dominio: `rrhh/`, `obras/`, `catalogo/`, `operacion/`, `planificacion/`.

---

## Próximo paso concreto (empezar mañana)

**Paso 1.1 — CRUD Personas**

1. `person_service.py`: create / get / list / update (unique por `document_number`)
2. Router `GET/POST/PUT` bajo `/api/v1/identidad/personas`
3. Proteger con `require_role(["admin"])` (o admin + supervisor)
4. Probar en Swagger con el usuario del script

Cuando eso esté, sigue 1.2 (usuarios) y luego fase 2 (maestros).
