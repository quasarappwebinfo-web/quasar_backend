#!/usr/bin/env python3
"""
Crea el primer usuario administrador del sistema Quasar.

Desde la raíz del proyecto (con .env y BD disponibles):

    python scripts/crear_primer_usuario.py

Con Docker:

    docker compose exec backend python scripts/crear_primer_usuario.py

Ver: docs/primer-usuario.md
"""
from __future__ import annotations

import getpass
import sys
from pathlib import Path

# Permite ejecutar el script desde la raíz del repo
ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))


def main() -> int:
    print("=" * 50)
    print("  Quasar — crear primer usuario (super admin)")
    print("=" * 50)
    print()
    print("Esto crea (si no existen):")
    print("  1) Roles de sistema (super_admin, admin, supervisor, maestro, cliente)")
    print("  2) Persona (cédula + nombre)")
    print("  3) Usuario dueño (rol super_admin, is_super=1)")
    print()

    document = input("Cédula / documento: ").strip()
    name = input("Nombre completo: ").strip()
    username = input("Username (para login): ").strip()
    email = input("Email (opcional, Enter para omitir): ").strip() or None

    password = getpass.getpass("Contraseña: ")
    password2 = getpass.getpass("Repetir contraseña: ")
    if password != password2:
        print("Error: las contraseñas no coinciden.", file=sys.stderr)
        return 1
    if not document or not name or not username or not password:
        print("Error: documento, nombre, username y contraseña son obligatorios.", file=sys.stderr)
        return 1

    from app.core.security import hash_password
    from app.db.session import SessionLocal
    from app.models import Person, User, UserRole

    db = SessionLocal()
    try:
        # 1) Roles de sistema
        for role_name in ("super_admin", "admin", "supervisor", "maestro", "cliente"):
            r = db.query(UserRole).filter(UserRole.name == role_name).first()
            if not r:
                r = UserRole(name=role_name, is_active=1)
                db.add(r)
                db.flush()
                print(f"✓ Rol '{role_name}' creado (id={r.id})")
            else:
                print(f"• Rol '{role_name}' ya existía (id={r.id})")

        role = db.query(UserRole).filter(UserRole.name == "super_admin").first()

        # 2) Persona
        person = db.query(Person).filter(Person.document_number == document).first()
        if not person:
            person = Person(document_number=document, name=name)
            db.add(person)
            db.flush()
            print(f"✓ Persona creada (id={person.id})")
        else:
            print(f"• Persona ya existía (id={person.id}, {person.name})")

        # 3) Usuario
        existing = db.query(User).filter(User.username == username).first()
        if existing:
            print(f"Error: el username '{username}' ya existe (id={existing.id}).", file=sys.stderr)
            db.rollback()
            return 1

        user = User(
            person_id=person.id,
            username=username,
            password=hash_password(password),
            email=email,
            role_id=role.id,
            is_super=1,
            is_active=1,
        )
        db.add(user)
        db.commit()
        print(f"✓ Usuario creado (id={user.id}, username={username}, rol=super_admin, is_super=1)")
        print()
        print("Listo. Puedes iniciar sesión en POST /api/v1/auth/login")
        print(f"  username: {username}")
        print("  password: (la que acabas de ingresar)")
        return 0
    except Exception as e:
        db.rollback()
        print(f"Error: {e}", file=sys.stderr)
        return 1
    finally:
        db.close()


if __name__ == "__main__":
    raise SystemExit(main())
