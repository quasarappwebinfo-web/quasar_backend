"""
CLI administrativo.
Uso: python -m app.cli <comando> --help
"""
import click
from sqlalchemy.orm import Session

from app.core.security import hash_password
from app.db.session import SessionLocal
from app.models import Person, User, UserRole


@click.group()
def cli():
    """Operaciones administrativas."""
    pass


@cli.command("create-person")
@click.option("--document", prompt="Cédula / documento", help="document_number único")
@click.option("--name", prompt="Nombre completo")
@click.option("--phone", default=None)
def create_person_cmd(document: str, name: str, phone: str | None):
    db: Session = SessionLocal()
    try:
        if db.query(Person).filter(Person.document_number == document).first():
            click.echo(f"Error: ya existe persona con documento '{document}'", err=True)
            return
        person = Person(document_number=document, name=name, phone=phone)
        db.add(person)
        db.commit()
        click.echo(f"Persona creada id={person.id} documento={document}")
    except Exception as e:
        db.rollback()
        click.echo(f"Error: {e}", err=True)
        raise
    finally:
        db.close()


@cli.command("create-user")
@click.option("--person-id", type=int, prompt="ID de persona (persons.id)")
@click.option("--username", prompt="Username (login)")
@click.option("--password", prompt=True, hide_input=True, confirmation_prompt=True)
@click.option("--email", default=None)
@click.option("--role", default="admin", prompt="Rol (name en users_roles)")
@click.option("--active/--inactive", default=True)
def create_user_cmd(
    person_id: int,
    username: str,
    password: str,
    email: str | None,
    role: str,
    active: bool,
):
    db: Session = SessionLocal()
    try:
        if not db.query(Person).filter(Person.id == person_id).first():
            click.echo(f"Error: no existe persons.id={person_id}", err=True)
            return
        existing_person_user = (
            db.query(User).filter(User.person_id == person_id).first()
        )
        if existing_person_user:
            click.echo(
                f"Error: la persona {person_id} ya tiene usuario "
                f"'{existing_person_user.username}'",
                err=True,
            )
            return
        if db.query(User).filter(User.username == username).first():
            click.echo(f"Error: el usuario '{username}' ya existe", err=True)
            return

        user_role = db.query(UserRole).filter(UserRole.name == role).first()
        if not user_role:
            click.echo(f"Error: el rol '{role}' no existe. Usa create-role.", err=True)
            return

        user = User(
            person_id=person_id,
            username=username,
            password=hash_password(password),
            email=email,
            role_id=user_role.id,
            is_active=1 if active else 2,
        )
        db.add(user)
        db.commit()
        click.echo(f"Usuario '{username}' creado con rol '{role}'.")
    except Exception as e:
        db.rollback()
        click.echo(f"Error: {e}", err=True)
        raise
    finally:
        db.close()


@cli.command("create-role")
@click.option("--name", prompt="Nombre del rol")
@click.option("--active/--inactive", default=True)
def create_role_cmd(name: str, active: bool):
    db: Session = SessionLocal()
    try:
        if db.query(UserRole).filter(UserRole.name == name).first():
            click.echo(f"Error: el rol '{name}' ya existe", err=True)
            return
        role = UserRole(name=name, is_active=1 if active else 2)
        db.add(role)
        db.commit()
        click.echo(f"Rol '{name}' creado.")
    except Exception as e:
        db.rollback()
        click.echo(f"Error: {e}", err=True)
        raise
    finally:
        db.close()


@cli.command("change-password")
@click.option("--username", required=True)
@click.option("--new-password", prompt=True, hide_input=True, confirmation_prompt=True)
def change_password_cmd(username: str, new_password: str):
    db: Session = SessionLocal()
    try:
        user = db.query(User).filter(User.username == username).first()
        if not user:
            click.echo(f"Error: usuario '{username}' no encontrado", err=True)
            return
        user.password = hash_password(new_password)
        db.commit()
        click.echo("Contraseña actualizada.")
    except Exception as e:
        db.rollback()
        click.echo(f"Error: {e}", err=True)
        raise
    finally:
        db.close()


@cli.command("list-users")
def list_users_cmd():
    db: Session = SessionLocal()
    try:
        for u in db.query(User).all():
            click.echo(
                f"id={u.id} username={u.username} person_id={u.person_id} "
                f"active={u.is_active} role_id={u.role_id}"
            )
    finally:
        db.close()


@cli.command("list-roles")
def list_roles_cmd():
    db: Session = SessionLocal()
    try:
        for r in db.query(UserRole).all():
            click.echo(f"id={r.id} name={r.name} active={r.is_active}")
    finally:
        db.close()


if __name__ == "__main__":
    cli()
