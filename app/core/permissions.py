"""
Catálogo de permisos por módulo (Fase 9).

- super admin / admin → acceso pleno (sin filas en user_permissions).
- resto → solo los códigos asignados en user_permissions.
"""
from __future__ import annotations

from typing import Any, Dict, Iterable, List, Optional, Set

# Roles con bypass total (no usan matriz de permisos)
ROLE_SUPER_ADMIN = "super_admin"
ROLE_ADMIN = "admin"
FULL_ACCESS_ROLES: Set[str] = {ROLE_SUPER_ADMIN, ROLE_ADMIN}

# Roles de sistema sembrados (etiqueta de negocio)
SYSTEM_ROLE_NAMES: tuple[str, ...] = (
    ROLE_SUPER_ADMIN,
    ROLE_ADMIN,
    "supervisor",
    "maestro",
    "cliente",
)

# Códigos canónicos (checklist UI)
PERMISSION_IDENTIDAD = "identidad"
PERMISSION_CATALOGOS = "catalogos"
PERMISSION_OBRAS = "obras"
PERMISSION_RRHH = "rrhh"
PERMISSION_ASISTENCIA = "asistencia"
PERMISSION_TASK_POOL = "task_pool"
PERMISSION_TAREAS = "tareas"
PERMISSION_PLANIFICACION = "planificacion"
PERMISSION_SYNC = "sync"

PERMISSION_CATALOG: tuple[Dict[str, str], ...] = (
    {
        "code": PERMISSION_IDENTIDAD,
        "label": "Personas, roles y usuarios",
        "description": "CRUD de identidad y asignación de permisos",
    },
    {
        "code": PERMISSION_CATALOGOS,
        "label": "Catálogos",
        "description": "Cargos, especialidades, unidades, motivos, etapas, etc.",
    },
    {
        "code": PERMISSION_OBRAS,
        "label": "Obras",
        "description": "Obras, clientes y documentos",
    },
    {
        "code": PERMISSION_RRHH,
        "label": "RRHH",
        "description": "Trabajadores y cuadrillas",
    },
    {
        "code": PERMISSION_ASISTENCIA,
        "label": "Asistencia",
        "description": "Asistencia diaria y asignaciones del día",
    },
    {
        "code": PERMISSION_TASK_POOL,
        "label": "Task Pool",
        "description": "Plantillas, versiones y recomendación",
    },
    {
        "code": PERMISSION_TAREAS,
        "label": "Tareas en obra",
        "description": "Kanban, estados, fotos, retrasos, reprogramaciones",
    },
    {
        "code": PERMISSION_PLANIFICACION,
        "label": "Planificación y firmas",
        "description": "Planes de trabajo, firmantes y comparación",
    },
    {
        "code": PERMISSION_SYNC,
        "label": "Sync offline",
        "description": "Push/pull y cola de fotos",
    },
)

VALID_PERMISSION_CODES: Set[str] = {p["code"] for p in PERMISSION_CATALOG}


def role_name_of(user: Any) -> Optional[str]:
    role = getattr(user, "role", None)
    if role is None:
        return None
    return getattr(role, "name", None)


def is_super_user(user: Any) -> bool:
    """Dueño: is_super=1 o rol super_admin."""
    if getattr(user, "is_super", 0) == 1:
        return True
    return role_name_of(user) == ROLE_SUPER_ADMIN


def has_full_access(user: Any) -> bool:
    """Super admin o admin: no usan checklist de permisos."""
    if is_super_user(user):
        return True
    return role_name_of(user) in FULL_ACCESS_ROLES


def is_admin_user(user: Any) -> bool:
    """Admin de empresa (no necesariamente super)."""
    return role_name_of(user) == ROLE_ADMIN and not is_super_user(user)


def permission_codes_of(user: Any) -> List[str]:
    """Códigos efectivos: todos si full access; si no, los asignados."""
    if has_full_access(user):
        return sorted(VALID_PERMISSION_CODES)
    rows = getattr(user, "permissions", None) or []
    codes = []
    for row in rows:
        code = getattr(row, "permission", None)
        if code in VALID_PERMISSION_CODES:
            codes.append(code)
    return sorted(set(codes))


def user_has_permission(user: Any, code: str) -> bool:
    if code not in VALID_PERMISSION_CODES:
        return False
    if has_full_access(user):
        return True
    rows = getattr(user, "permissions", None) or []
    for row in rows:
        if getattr(row, "permission", None) == code:
            return True
    return False


def user_has_any_permission(user: Any, codes: Iterable[str]) -> bool:
    return any(user_has_permission(user, c) for c in codes)


def validate_permission_codes(codes: Optional[Iterable[str]]) -> List[str]:
    if not codes:
        return []
    out: List[str] = []
    seen: Set[str] = set()
    invalid: List[str] = []
    for c in codes:
        code = str(c).strip()
        if not code:
            continue
        if code not in VALID_PERMISSION_CODES:
            invalid.append(code)
            continue
        if code not in seen:
            seen.add(code)
            out.append(code)
    if invalid:
        raise ValueError(
            "Permisos inválidos: "
            + ", ".join(invalid)
            + f". Válidos: {', '.join(sorted(VALID_PERMISSION_CODES))}"
        )
    return out


def catalog_as_list() -> List[Dict[str, str]]:
    return [dict(p) for p in PERMISSION_CATALOG]
