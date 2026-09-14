"""
Estructura de modelos y schemas (dominios en español).

Carpetas espejo en `app/models/` y `app/schemas/`:

| Carpeta | Dominio |
|---------|---------|
| `identidad/` | persons, users, users_roles, refresh_tokens |
| `rrhh/` | workers, cargos, especialidades, cuadrillas, asignaciones |
| `obras/` | obras, etapas, clientes, documentos |
| `catalogo/` | Task Pool (plantillas versionadas) |
| `operacion/` | tareas de obra, evidencias, retrasos, reprogramaciones |
| `planificacion/` | work plans, firmas, snapshots |
| `auditoria/` | audit_log |

## Ajustes respecto al DBML original

- `users.username` + `users.password` (hash) → login OAuth2
- `refresh_tokens` → sesión segura (cookie HttpOnly)
- `uuid` en entidades que se crean offline: tasks, task_photos, task_comments,
  task_delay_events, task_reschedules, work_plans, documents

Los **nombres de tablas/columnas** se mantienen en inglés como en el diseño de BD.
Las **carpetas y docs** van en español.
"""
