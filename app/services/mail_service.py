"""Envío de correo por SMTP. La recuperación de acceso es el único uso."""
import logging
import smtplib
from email.message import EmailMessage

from app.config import settings

logger = logging.getLogger(__name__)


class MailNotConfiguredError(Exception):
    pass


class MailSendError(Exception):
    pass


def smtp_configured() -> bool:
    return bool((settings.smtp_host or "").strip() and (settings.smtp_from or "").strip())


def send_email(*, to: str, subject: str, body: str) -> None:
    if not smtp_configured():
        raise MailNotConfiguredError("SMTP no configurado")
    message = EmailMessage()
    message["Subject"] = subject
    message["From"] = settings.smtp_from
    message["To"] = to
    message.set_content(body)
    try:
        if settings.smtp_use_ssl:
            server = smtplib.SMTP_SSL(
                settings.smtp_host, settings.smtp_port, timeout=20
            )
        else:
            server = smtplib.SMTP(settings.smtp_host, settings.smtp_port, timeout=20)
        with server:
            server.ehlo()
            if settings.smtp_starttls and not settings.smtp_use_ssl:
                server.starttls()
                server.ehlo()
            if (settings.smtp_username or "").strip():
                server.login(settings.smtp_username, settings.smtp_password)
            server.send_message(message)
    except MailNotConfiguredError:
        raise
    except Exception as exc:
        logger.warning("No se pudo enviar el correo de recuperación: %s", exc)
        raise MailSendError("No se pudo enviar el correo") from exc
