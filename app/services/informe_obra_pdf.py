"""Informe ejecutivo de obra en PDF: dos páginas para un rango o una bitácora."""
from __future__ import annotations

import re
from datetime import date, datetime, timedelta
from pathlib import Path
from decimal import Decimal, ROUND_HALF_UP
from typing import Any, Dict, List, Optional, Sequence
from xml.sax.saxutils import escape

from reportlab.lib import colors
from reportlab.lib.enums import TA_LEFT
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import mm
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    Image as PdfImage,
    PageBreak,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)
from reportlab.pdfgen import canvas as pdfcanvas
from sqlalchemy.orm import Session, joinedload

from app.core.db_timezone import get_colombia_now
from app.models.obras.obra_model import Obra
from app.models.operacion.obra_photo_model import ObraPhoto
from app.models.operacion.task_model import Task
from app.models.operacion.task_photo_model import TaskPhoto
from app.models.planificacion.work_plan_model import WorkPlan
from app.models.planificacion.work_plan_task_model import WorkPlanTask
from app.models.rrhh.obra_daily_attendance_model import ObraDailyAttendance
from app.models.rrhh.worker_model import Worker
from app.models import TaskTemplate, TaskTemplateVersion
from app.services.task_service import _plain_progress, _task_placement, obra_fulfillment

BLUE = colors.HexColor("#1d4ed8")
INK = colors.HexColor("#1a1c1f")
MUTED = colors.HexColor("#66707c")
LINE = colors.HexColor("#e6edf5")
SOFT = colors.HexColor("#f4f7fb")
PAGE_W, PAGE_H = letter

MESES = (
    "enero",
    "febrero",
    "marzo",
    "abril",
    "mayo",
    "junio",
    "julio",
    "agosto",
    "septiembre",
    "octubre",
    "noviembre",
    "diciembre",
)
MESES_CORTOS = (
    "ene",
    "feb",
    "mar",
    "abr",
    "may",
    "jun",
    "jul",
    "ago",
    "sep",
    "oct",
    "nov",
    "dic",
)
DIAS = ("lunes", "martes", "miércoles", "jueves", "viernes", "sábado", "domingo")
DIAS_CORTOS = ("Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom")

OBRA_STATUS = {
    "planning": "Planificación",
    "in_progress": "En progreso",
    "on_hold": "En pausa",
    "completed": "Terminada",
    "cancelled": "Cancelada",
}
PLAN_STATUS = {
    "draft": "Borrador",
    "pending_signature": "Pendiente de firma",
    "signed": "Firmada",
    "rejected": "Rechazada",
    "in_execution": "En ejecución",
    "finished": "Terminada",
}
TASK_STATUS = {
    "scheduled": "Programada",
    "in_progress": "En progreso",
    "completed": "Completada",
    "verified": "Verificada",
    "rescheduled": "Reprogramada",
}

_FONTS_READY = False
_LOGO = None


class InformeError(Exception):
    pass


class InformeNotFoundError(InformeError):
    pass


class InformeValidationError(InformeError):
    pass


def _fonts() -> None:
    global _FONTS_READY
    if _FONTS_READY:
        return
    regular = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf"
    bold = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
    pdfmetrics.registerFont(TTFont("Quasar", regular))
    pdfmetrics.registerFont(TTFont("Quasar-Bold", bold))
    _FONTS_READY = True


def _pct(value: Any) -> int:
    if value is None or value == "":
        return 0
    return int(Decimal(str(value)).quantize(Decimal("1"), rounding=ROUND_HALF_UP))


def _short_date(value: Optional[date]) -> str:
    if value is None:
        return "—"
    return f"{value.day} {MESES_CORTOS[value.month - 1]} {value.year}"


def _long_date(value: date) -> str:
    return f"{value.day} de {MESES[value.month - 1]} de {value.year}"


def _range_label(start: date, end: date) -> str:
    if start == end:
        return _long_date(start)
    if start.year == end.year and start.month == end.month:
        return f"{start.day} al {end.day} de {MESES[start.month - 1]} de {start.year}"
    if start.year == end.year:
        return (
            f"{start.day} de {MESES[start.month - 1]} al "
            f"{end.day} de {MESES[end.month - 1]} de {start.year}"
        )
    return f"{_long_date(start)} al {_long_date(end)}"


def _join(names: Sequence[str]) -> str:
    items = [name for name in names if name]
    if not items:
        return ""
    if len(items) == 1:
        return items[0]
    return f"{', '.join(items[:-1])} y {items[-1]}"


def _days(start: date, end: date) -> List[date]:
    out = []
    cursor = start
    while cursor <= end:
        out.append(cursor)
        cursor += timedelta(days=1)
    return out


def _xml(value: Optional[str]) -> str:
    return escape(value or "")


def _clip(value: Optional[str], size: int) -> str:
    text = (value or "").strip()
    if len(text) <= size:
        return text
    return text[: size - 1].rstrip() + "…"


def _in_range(moment: Optional[datetime], start: date, end: date) -> bool:
    if moment is None:
        return False
    day = moment.date() if isinstance(moment, datetime) else moment
    return start <= day <= end


def _styles() -> Dict[str, ParagraphStyle]:
    _fonts()
    return {
        "h1": ParagraphStyle(
            "h1",
            fontName="Quasar-Bold",
            fontSize=16,
            leading=19,
            textColor=INK,
        ),
        "sub": ParagraphStyle(
            "sub",
            fontName="Quasar",
            fontSize=9,
            leading=12,
            textColor=MUTED,
        ),
        "section": ParagraphStyle(
            "section",
            fontName="Quasar-Bold",
            fontSize=12,
            leading=15,
            textColor=INK,
            spaceBefore=2,
        ),
        "body": ParagraphStyle(
            "body",
            fontName="Quasar",
            fontSize=8.5,
            leading=11,
            textColor=INK,
        ),
        "muted": ParagraphStyle(
            "muted",
            fontName="Quasar",
            fontSize=8,
            leading=10,
            textColor=MUTED,
        ),
        "kpi": ParagraphStyle(
            "kpi",
            fontName="Quasar-Bold",
            fontSize=16,
            leading=18,
            textColor=BLUE,
            alignment=TA_LEFT,
        ),
        "kpiLabel": ParagraphStyle(
            "kpiLabel",
            fontName="Quasar",
            fontSize=7.5,
            leading=9,
            textColor=MUTED,
        ),
        "cell": ParagraphStyle(
            "cell",
            fontName="Quasar",
            fontSize=8,
            leading=10,
            textColor=INK,
        ),
        "head": ParagraphStyle(
            "head",
            fontName="Quasar-Bold",
            fontSize=7.5,
            leading=9,
            textColor=BLUE,
        ),
        "link": ParagraphStyle(
            "link",
            fontName="Quasar",
            fontSize=8,
            leading=10,
            textColor=BLUE,
        ),
        "barNum": ParagraphStyle(
            "barNum",
            fontName="Quasar-Bold",
            fontSize=9,
            leading=11,
            textColor=INK,
            alignment=1,
        ),
        "barDay": ParagraphStyle(
            "barDay",
            fontName="Quasar",
            fontSize=7.5,
            leading=9,
            textColor=MUTED,
            alignment=1,
        ),
    }


class _NumberedCanvas(pdfcanvas.Canvas):
    def __init__(self, *args, **kwargs):
        pdfcanvas.Canvas.__init__(self, *args, **kwargs)
        self._saved_page_states = []

    def showPage(self):
        self._saved_page_states.append(dict(self.__dict__))
        self._startPage()

    def save(self):
        count = len(self._saved_page_states)
        for state in self._saved_page_states:
            self.__dict__.update(state)
            self._paint_footer(count)
            pdfcanvas.Canvas.showPage(self)
        pdfcanvas.Canvas.save(self)

    def _paint_footer(self, count: int):
        generated = getattr(self, "quasar_generated", "")
        self.setFillColor(MUTED)
        self.setFont("Quasar", 8)
        self.drawString(
            16 * mm,
            10 * mm,
            f"Página {self._pageNumber} de {count} · {generated}",
        )


def _logo():
    global _LOGO
    if _LOGO is not None:
        return _LOGO
    path = Path(__file__).resolve().parent.parent / "assets" / "quasar-logo.png"
    from PIL import Image

    image = Image.open(path).convert("RGBA")
    box = image.getbbox()
    if box:
        image = image.crop(box)
    _LOGO = (ImageReader(image), image.size[0], image.size[1])
    return _LOGO


def _header(canvas, doc, *, obra_name: str, obra_code: Optional[str], range_label: str):
    _ = doc
    canvas.saveState()
    logo, pixel_w, pixel_h = _logo()
    logo_h = 14 * mm
    logo_w = logo_h * (pixel_w / pixel_h)
    logo_y = PAGE_H - 23.5 * mm
    canvas.drawImage(
        logo,
        16 * mm,
        logo_y,
        width=logo_w,
        height=logo_h,
        mask="auto",
        preserveAspectRatio=True,
        anchor="sw",
    )

    right = PAGE_W - 16 * mm
    eyebrow = "INFORME DE OBRA"
    canvas.setFont("Quasar", 7.5)
    eyebrow_width = canvas.stringWidth(eyebrow, "Quasar", 7.5) + 0.7 * (len(eyebrow) - 1)
    eyebrow_text = canvas.beginText(right - eyebrow_width, PAGE_H - 11.2 * mm)
    eyebrow_text.setFont("Quasar", 7.5)
    eyebrow_text.setFillColor(BLUE)
    eyebrow_text.setCharSpace(0.7)
    eyebrow_text.textOut(eyebrow)
    canvas.drawText(eyebrow_text)

    name_limit = right - (16 * mm + logo_w + 8 * mm)
    name_size = 16
    canvas.setFont("Quasar-Bold", name_size)
    while name_size > 11 and canvas.stringWidth(obra_name, "Quasar-Bold", name_size) > name_limit:
        name_size -= 0.5
        canvas.setFont("Quasar-Bold", name_size)
    canvas.setFillColor(INK)
    canvas.drawRightString(right, PAGE_H - 17.6 * mm, obra_name)

    detail = range_label + (f"   ·   {obra_code}" if obra_code else "")
    canvas.setFillColor(MUTED)
    canvas.setFont("Quasar", 8)
    canvas.drawRightString(right, PAGE_H - 22 * mm, _clip(detail, 72))

    line_y = PAGE_H - 26.5 * mm
    canvas.setStrokeColor(colors.HexColor("#e3ebf5"))
    canvas.setLineWidth(0.6)
    canvas.line(16 * mm, line_y, right, line_y)
    canvas.setStrokeColor(BLUE)
    canvas.setLineWidth(1.6)
    canvas.line(16 * mm, line_y, 16 * mm + logo_w, line_y)
    canvas.restoreState()


def _table(data, widths, header=True) -> Table:
    table = Table(data, colWidths=widths, repeatRows=1 if header else 0)
    style = [
        ("BACKGROUND", (0, 0), (-1, 0), SOFT),
        ("TEXTCOLOR", (0, 0), (-1, 0), BLUE),
        ("FONTNAME", (0, 0), (-1, -1), "Quasar"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 4),
        ("RIGHTPADDING", (0, 0), (-1, -1), 4),
        ("TOPPADDING", (0, 0), (-1, -1), 3),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 3),
        ("LINEBELOW", (0, 0), (-1, -2), 0.3, LINE),
        ("LINEBELOW", (0, -1), (-1, -1), 0.3, LINE),
    ]
    table.setStyle(TableStyle(style))
    return table


def _kpi_table(items: Sequence[tuple[str, str]], styles) -> Table:
    row_value = [Paragraph(value, styles["kpi"]) for value, _ in items]
    row_label = [Paragraph(label, styles["kpiLabel"]) for _, label in items]
    width = 178 * mm / len(items)
    table = Table([row_value, row_label], colWidths=[width] * len(items))
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), SOFT),
                ("LEFTPADDING", (0, 0), (-1, -1), 8),
                ("RIGHTPADDING", (0, 0), (-1, -1), 6),
                ("TOPPADDING", (0, 0), (0, 0), 8),
                ("BOTTOMPADDING", (0, -1), (-1, -1), 8),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LINEAFTER", (0, 0), (-2, -1), 0.4, LINE),
            ]
        )
    )
    return table


def _narrative(days: Sequence[date], present: set[date], tasks: Sequence[dict]) -> str:
    verified = [task["name"] for task in tasks if task["status"] == "verified"]
    opened = [
        task["name"]
        for task in tasks
        if task["status"] in ("in_progress", "scheduled", "rescheduled")
    ]
    bits = []
    if not days:
        bits.append("El rango no tiene días.")
    elif not present:
        bits.append("No hubo llegadas en el rango.")
    elif len(days) > 10:
        bits.append(f"Hubo personal en {len(present)} de {len(days)} días.")
    else:
        absent = [day for day in days if day not in present]
        if not absent:
            bits.append("Hubo personal todos los días del rango.")
        else:
            bits.append(f"Hubo personal {_span(sorted(present))}.")
            if len(absent) == 1:
                bits.append(f"El {DIAS[absent[0].weekday()]} no hubo llegada.")
            else:
                bits.append(f"Sin llegada {_span(absent)}.")
    if verified:
        bits.append(f"Se verificó {_join(_clip(name, 42) for name in verified[:2])}.")
    if opened:
        bits.append(f"Siguen abiertos {_join(_clip(name, 42) for name in opened[:2])}.")
    elif tasks:
        bits.append("No quedan actividades abiertas en este periodo.")
    return " ".join(bits)


def _span(days: Sequence[date]) -> str:
    ordered = sorted(days)
    if not ordered:
        return ""
    if len(ordered) == 1:
        return f"el {DIAS[ordered[0].weekday()]}"
    contiguous = (
        ordered[-1].toordinal() - ordered[0].toordinal() + 1 == len(ordered)
    )
    if contiguous:
        return f"de {DIAS[ordered[0].weekday()]} a {DIAS[ordered[-1].weekday()]}"
    return "el " + _join(DIAS[day.weekday()] for day in ordered[:6])


def _load_plan(db: Session, plan_id: int) -> WorkPlan:
    plan = db.query(WorkPlan).filter(WorkPlan.id == plan_id).first()
    if plan is None:
        raise InformeNotFoundError("No existe esa bitácora")
    return plan


def _plans_for_range(db: Session, obra_id: int, start: date, end: date) -> List[WorkPlan]:
    return (
        db.query(WorkPlan)
        .filter(
            WorkPlan.obra_id == obra_id,
            WorkPlan.start_date <= end,
            WorkPlan.end_date >= start,
        )
        .order_by(WorkPlan.start_date.asc(), WorkPlan.id.asc())
        .all()
    )


def _tasks_for_plans(db: Session, plans: Sequence[WorkPlan]) -> List[Task]:
    version_ids = [plan.current_version_id for plan in plans if plan.current_version_id]
    if not version_ids:
        return []
    task_ids = {
        row[0]
        for row in db.query(WorkPlanTask.task_id)
        .filter(WorkPlanTask.work_plan_version_id.in_(version_ids))
        .all()
    }
    if not task_ids:
        return []
    rows = (
        db.query(Task)
        .options(
            joinedload(Task.subtasks),
            joinedload(Task.chapter),
            joinedload(Task.budget_activity),
            joinedload(Task.zone),
            joinedload(Task.source_template).options(
                joinedload(TaskTemplate.chapter),
                joinedload(TaskTemplate.budget_activity),
                joinedload(TaskTemplate.zone),
            ),
            joinedload(Task.source_template_version)
            .joinedload(TaskTemplateVersion.task_template)
            .options(
                joinedload(TaskTemplate.chapter),
                joinedload(TaskTemplate.budget_activity),
                joinedload(TaskTemplate.zone),
            ),
        )
        .filter(Task.id.in_(task_ids), Task.parent_task_id.is_(None))
        .all()
    )
    unique = []
    seen = set()
    for task in rows:
        if task.id in seen:
            continue
        seen.add(task.id)
        unique.append(task)
    unique.sort(key=lambda task: (task.name or "").lower())
    return unique


def _attendance(db: Session, obra_id: int, start: date, end: date):
    return (
        db.query(ObraDailyAttendance)
        .options(
            joinedload(ObraDailyAttendance.worker).joinedload(Worker.person),
            joinedload(ObraDailyAttendance.worker).joinedload(Worker.worker_position),
            joinedload(ObraDailyAttendance.worker).joinedload(Worker.specialty),
        )
        .filter(
            ObraDailyAttendance.obra_id == obra_id,
            ObraDailyAttendance.work_date >= start,
            ObraDailyAttendance.work_date <= end,
            ObraDailyAttendance.removed_at.is_(None),
        )
        .order_by(ObraDailyAttendance.work_date.asc(), ObraDailyAttendance.signed_at.asc())
        .all()
    )


def _people(rows) -> List[dict]:
    bucket: Dict[int, dict] = {}
    for row in rows:
        worker = row.worker
        person = worker.person if worker else None
        item = bucket.setdefault(
            row.worker_id,
            {
                "name": person.name if person and person.name else f"Trabajador #{row.worker_id}",
                "cargo": worker.worker_position.name if worker and worker.worker_position else "—",
                "especialidad": worker.specialty.name if worker and worker.specialty else "—",
                "days": set(),
            },
        )
        item["days"].add(row.work_date)
    people = list(bucket.values())
    people.sort(key=lambda item: (-len(item["days"]), item["name"].lower()))
    return people


def _photos(db: Session, obra_id: int, task_ids: Sequence[int], start: date, end: date):
    counts: Dict[int, int] = {task_id: 0 for task_id in task_ids}
    items = []
    if task_ids:
        photos = (
            db.query(TaskPhoto)
            .options(joinedload(TaskPhoto.task))
            .join(Task, Task.id == TaskPhoto.task_id)
            .filter(Task.obra_id == obra_id)
            .all()
        )
        id_set = set(task_ids)
        for photo in photos:
            moment = photo.taken_at or photo.created_at
            if not _in_range(moment, start, end):
                continue
            task = photo.task
            parent_id = task.parent_task_id if task and task.parent_task_id else (task.id if task else None)
            if parent_id not in id_set:
                continue
            counts[parent_id] = counts.get(parent_id, 0) + 1
            items.append(
                {
                    "when": moment,
                    "title": task.parent.name if task and task.parent else (task.name if task else "Actividad"),
                    "caption": photo.description or (task.name if task else "Evidencia de actividad"),
                    "file_url": photo.file_url,
                }
            )
    obra_photos = db.query(ObraPhoto).filter(ObraPhoto.obra_id == obra_id).all()
    for photo in obra_photos:
        if not _in_range(photo.created_at, start, end):
            continue
        items.append(
            {
                "when": photo.created_at,
                "title": "Foto de la obra",
                "caption": photo.description or "Foto de la obra",
                "file_url": photo.file_url,
            }
        )
    items.sort(key=lambda item: item["when"] or datetime.min, reverse=True)
    return counts, items


def _activity_rows(tasks: Sequence[Task], photo_counts: Dict[int, int]) -> List[dict]:
    rows = []
    for task in tasks:
        chapter, activity, zone = _task_placement(task)
        where = " · ".join(
            part
            for part in (
                chapter.name if chapter else None,
                activity.name if activity else None,
                zone.name if zone else None,
            )
            if part
        )
        if task.status in ("completed", "verified"):
            progress = 100
        else:
            progress = _pct(_plain_progress([task]))
        rows.append(
            {
                "name": task.name,
                "where": where or "—",
                "status": task.status,
                "status_label": TASK_STATUS.get(task.status, task.status),
                "progress": progress,
                "photos": photo_counts.get(task.id, 0),
            }
        )
    return rows


def _plan_label(plans: Sequence[WorkPlan]) -> str:
    if not plans:
        return "Sin bitácora en el rango"
    if len(plans) == 1:
        plan = plans[0]
        return f"{plan.name} · {PLAN_STATUS.get(plan.status, plan.status)}"
    return f"{len(plans)} bitácoras en el rango"


async def build_informe_pdf(
    db: Session,
    *,
    obra_id: Optional[int] = None,
    plan_id: Optional[int] = None,
    date_from: Optional[date] = None,
    date_to: Optional[date] = None,
    prepared_by: str,
    public_origin: str,
) -> tuple[bytes, str]:
    if plan_id is not None:
        plan = _load_plan(db, plan_id)
        obra_id = plan.obra_id
        date_from = plan.start_date
        date_to = plan.end_date
        plans = [plan]
    else:
        plans = None
    if obra_id is None or date_from is None or date_to is None:
        raise InformeValidationError("Indica la obra y el rango de fechas")
    if date_to < date_from:
        raise InformeValidationError("La fecha final tiene que ser posterior a la inicial")
    if (date_to - date_from).days > 120:
        raise InformeValidationError("El rango máximo del informe es de 120 días")

    obra = (
        db.query(Obra)
        .options(joinedload(Obra.current_stage))
        .filter(Obra.id == obra_id)
        .first()
    )
    if obra is None:
        raise InformeNotFoundError("No existe esa obra")
    if plans is None:
        plans = _plans_for_range(db, obra.id, date_from, date_to)

    tasks = _tasks_for_plans(db, plans)
    attendance = _attendance(db, obra.id, date_from, date_to)
    people = _people(attendance)
    _ = (public_origin, prepared_by)
    photo_counts, photos = _photos(
        db, obra.id, [task.id for task in tasks], date_from, date_to
    )
    activities = _activity_rows(tasks, photo_counts)
    fulfillment = await obra_fulfillment(db, obra.id)
    period_percent = _pct(_plain_progress(tasks)) if tasks else 0
    global_percent = _pct(fulfillment.get("progress_percent"))
    period_caption = (
        "Cumplimiento de esta bitácora"
        if len(plans) == 1
        else "Cumplimiento del periodo"
    )

    payload = _render(
        obra=obra,
        start=date_from,
        end=date_to,
        plan_label=_plan_label(plans),
        people=people,
        attendance=attendance,
        activities=activities,
        photos=photos,
        fulfillment=fulfillment,
        global_percent=global_percent,
        period_percent=period_percent,
        period_caption=period_caption,
    )
    raw_code = obra.code or f"obra-{obra.id}"
    code = re.sub(r"[^A-Za-z0-9_-]+", "-", raw_code).strip("-") or f"obra-{obra.id}"
    filename = f"informe-{code}-{date_from.isoformat()}-{date_to.isoformat()}.pdf"
    return payload, filename


def _render(**data) -> bytes:
    styles = _styles()
    obra: Obra = data["obra"]
    start: date = data["start"]
    end: date = data["end"]
    range_label = _range_label(start, end)
    place_parts = []
    for part in (obra.address, obra.neighborhood, obra.city):
        text = (part or "").strip()
        if text and (not place_parts or place_parts[-1].lower() != text.lower()):
            place_parts.append(text)
    place = ", ".join(place_parts)
    generated = _long_date(get_colombia_now().date())

    story: List[Any] = []
    if place:
        story.append(Paragraph(_xml(place), styles["sub"]))
        story.append(Spacer(1, 3 * mm))

    meta = [
        [
            Paragraph("Etapa", styles["head"]),
            Paragraph("Estado", styles["head"]),
            Paragraph("Inicio", styles["head"]),
            Paragraph("Fin estimado", styles["head"]),
        ],
        [
            Paragraph(_xml(obra.current_stage.name if obra.current_stage else "—"), styles["cell"]),
            Paragraph(_xml(OBRA_STATUS.get(obra.status, obra.status)), styles["cell"]),
            Paragraph(_short_date(obra.start_date), styles["cell"]),
            Paragraph(_short_date(obra.estimated_end_date), styles["cell"]),
        ],
        [
            Paragraph("Bitácora", styles["head"]),
            Paragraph("", styles["head"]),
            Paragraph("", styles["head"]),
            Paragraph("", styles["head"]),
        ],
        [
            Paragraph(_xml(data["plan_label"]), styles["cell"]),
            Paragraph("", styles["cell"]),
            Paragraph("", styles["cell"]),
            Paragraph("", styles["cell"]),
        ],
    ]
    meta_table = Table(meta, colWidths=[46 * mm, 46 * mm, 43 * mm, 43 * mm])
    meta_table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), SOFT),
                ("LEFTPADDING", (0, 0), (-1, -1), 6),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                ("TOPPADDING", (0, 0), (-1, -1), 2),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 2),
                ("SPAN", (0, 2), (-1, 2)),
                ("SPAN", (0, 3), (-1, 3)),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
            ]
        )
    )
    story.append(meta_table)
    story.append(Spacer(1, 4 * mm))
    story.append(
        _kpi_table(
            [
                (f"{data['global_percent']}%", "Cumplimiento de la obra"),
                (f"{data['period_percent']}%", data["period_caption"]),
                (str(len(data["people"])), "Personas distintas"),
                (str(len(data["attendance"])), "Llegadas en el periodo"),
            ],
            styles,
        )
    )
    story.append(Spacer(1, 3 * mm))
    days = _days(start, end)
    by_day: Dict[date, set] = {}
    for row in data["attendance"]:
        by_day.setdefault(row.work_date, set()).add(row.worker_id)
    present = set(by_day)
    story.append(Paragraph(_xml(_narrative(days, present, data["activities"])), styles["body"]))
    story.append(Spacer(1, 3 * mm))
    story.extend(
        _zone_and_days(
            data["fulfillment"],
            data["global_percent"],
            days,
            by_day,
            styles,
        )
    )
    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph("Personal en obra", styles["section"]))
    story.append(Spacer(1, 1.5 * mm))
    story.append(_people_table(data["people"], styles))
    hidden_people = len(data["people"]) - 8
    if hidden_people > 0:
        story.append(
            Paragraph(f"+ {hidden_people} personas más en el rango.", styles["muted"])
        )
    story.append(Paragraph("Una llegada quitada no aparece.", styles["muted"]))
    story.append(PageBreak())

    story.append(Paragraph("Qué se hizo y las fotos", styles["section"]))
    story.append(
        Paragraph(
            f"Actividades de las bitácoras que cruzan el rango · {_xml(range_label)}",
            styles["sub"],
        )
    )
    story.append(Spacer(1, 2 * mm))
    story.append(_status_pills(data["activities"], styles))
    story.append(Spacer(1, 2 * mm))
    story.append(_activity_table(data["activities"], styles))
    story.append(Paragraph(_xml(_open_line(data["activities"])), styles["body"]))
    story.append(Spacer(1, 3 * mm))
    story.extend(_chapter_bars(data["fulfillment"], styles))
    story.append(Spacer(1, 3 * mm))
    story.append(Paragraph("Fotos recientes del periodo", styles["section"]))
    story.append(Spacer(1, 1.5 * mm))
    story.append(_photo_strip(data["photos"], styles))
    closed = sum(
        1 for task in data["activities"] if task["status"] in ("completed", "verified")
    )
    photo_total = len(data["photos"])
    shown_photos = min(8, photo_total)
    photo_tail = (
        f"{photo_total} fotos en el periodo, aquí las {shown_photos} más recientes."
        if photo_total
        else "sin fotos en el periodo."
    )
    story.append(Spacer(1, 3 * mm))
    story.append(
        Paragraph(
            _xml(
                f"{len(data['people'])} personas · {closed} actividades cerradas · "
                f"obra {data['global_percent']}% · periodo {data['period_percent']}% · "
                f"{photo_tail}"
            ),
            styles["body"],
        )
    )

    from io import BytesIO

    buffer = BytesIO()

    def on_page(canvas, doc):
        canvas.quasar_generated = generated
        _header(
            canvas,
            doc,
            obra_name=obra.name,
            obra_code=obra.code,
            range_label=range_label,
        )

    frame = Frame(
        16 * mm,
        16 * mm,
        PAGE_W - 32 * mm,
        PAGE_H - 46 * mm,
        showBoundary=0,
    )
    doc = BaseDocTemplate(
        buffer,
        pagesize=letter,
        title=f"Informe de obra · {obra.name}",
        author="Quasar",
    )
    doc.addPageTemplates([PageTemplate(id="informe", frames=[frame], onPage=on_page)])
    doc.build(story, canvasmaker=_NumberedCanvas)
    return buffer.getvalue()


def _zone_and_days(fulfillment, global_percent, days, by_day, styles):
    zones = fulfillment.get("zones") or []
    zone_lines = []
    for zone in zones:
        weight = zone.get("weight_percent")
        progress = _pct(zone.get("progress_percent"))
        if weight is None:
            aporte = "—"
            weight_label = "sin peso"
        else:
            aporte = str(_pct(Decimal(str(weight)) * Decimal(progress) / Decimal(100)))
            weight_label = f"peso {_pct(weight)}"
        zone_lines.append(
            Paragraph(
                f"<b>{_xml(zone.get('zone_name') or 'Zona')}</b> · {weight_label} · "
                f"avance {progress}% · aporta {aporte}",
                styles["cell"],
            )
        )
    if not zone_lines:
        zone_lines = [Paragraph("Sin zonas activas.", styles["muted"])]
    zone_lines.append(
        Paragraph(f"{global_percent}% cumplimiento global", styles["muted"])
    )
    left = zone_lines
    if len(days) <= 10:
        counts = []
        labels = []
        for day in days:
            counts.append(Paragraph(str(len(by_day.get(day, ()))), styles["barNum"]))
            labels.append(Paragraph(DIAS_CORTOS[day.weekday()], styles["barDay"]))
        day_table = Table([counts, labels], colWidths=[78 * mm / len(days)] * len(days))
        day_table.setStyle(
            TableStyle(
                [
                    ("ALIGN", (0, 0), (-1, -1), "CENTER"),
                    ("TOPPADDING", (0, 0), (-1, -1), 1),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 1),
                ]
            )
        )
        right = [
            Paragraph("Llegadas por día", styles["head"]),
            Spacer(1, 1 * mm),
            day_table,
        ]
    else:
        right = [
            Paragraph(
                f"Llegadas por día: {len(by_day)} días con personal de {len(days)}.",
                styles["cell"],
            )
        ]
    right_table = Table([[item] for item in right], colWidths=[78 * mm])
    right_table.setStyle(
        TableStyle(
            [
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 0),
                ("TOPPADDING", (0, 0), (-1, -1), 0),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 1),
            ]
        )
    )
    left_table = Table([[item] for item in left], colWidths=[96 * mm])
    left_table.setStyle(
        TableStyle(
            [
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                ("TOPPADDING", (0, 0), (-1, -1), 1),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 1),
            ]
        )
    )
    wrap = Table([[left_table, right_table]], colWidths=[100 * mm, 78 * mm])
    wrap.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 0),
            ]
        )
    )
    return [Paragraph("Cumplimiento global", styles["section"]), Spacer(1, 1.5 * mm), wrap]


def _people_table(people: Sequence[dict], styles) -> Table:
    header = [
        Paragraph("Nombre", styles["head"]),
        Paragraph("Cargo", styles["head"]),
        Paragraph("Especialidad", styles["head"]),
        Paragraph("Días", styles["head"]),
    ]
    body = []
    shown = list(people[:8])
    for person in shown:
        body.append(
            [
                Paragraph(_xml(person["name"]), styles["cell"]),
                Paragraph(_xml(person["cargo"]), styles["cell"]),
                Paragraph(_xml(person["especialidad"]), styles["cell"]),
                Paragraph(str(len(person["days"])), styles["cell"]),
            ]
        )
    if not body:
        body.append(
            [
                Paragraph("Sin llegadas en el periodo.", styles["muted"]),
                Paragraph("", styles["cell"]),
                Paragraph("", styles["cell"]),
                Paragraph("", styles["cell"]),
            ]
        )
    return _table([header, *body], [70 * mm, 38 * mm, 50 * mm, 20 * mm])


def _status_pills(activities: Sequence[dict], styles) -> Table:
    counts = {
        "verified": 0,
        "completed": 0,
        "in_progress": 0,
        "scheduled": 0,
    }
    for task in activities:
        key = task["status"]
        if key == "rescheduled":
            key = "scheduled"
        if key in counts:
            counts[key] += 1
    labels = [
        (counts["verified"], "verificada" if counts["verified"] == 1 else "verificadas"),
        (counts["completed"], "completada" if counts["completed"] == 1 else "completadas"),
        (counts["in_progress"], "en progreso"),
        (counts["scheduled"], "programada" if counts["scheduled"] == 1 else "programadas"),
    ]
    cells = [
        Paragraph(f"<b>{count}</b> {label}", styles["cell"]) for count, label in labels
    ]
    table = Table([cells], colWidths=[44.5 * mm] * 4)
    table.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), SOFT),
                ("ALIGN", (0, 0), (-1, -1), "CENTER"),
                ("TOPPADDING", (0, 0), (-1, -1), 5),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 5),
                ("LINEAFTER", (0, 0), (-2, -1), 0.3, LINE),
            ]
        )
    )
    return table


def _activity_table(activities: Sequence[dict], styles) -> Table:
    header = [
        Paragraph("Actividad", styles["head"]),
        Paragraph("Dónde", styles["head"]),
        Paragraph("Estado", styles["head"]),
        Paragraph("Avance", styles["head"]),
        Paragraph("Fotos", styles["head"]),
    ]
    rows = []
    shown = list(activities[:8])
    for task in shown:
        rows.append(
            [
                Paragraph(_xml(_clip(task["name"], 42)), styles["cell"]),
                Paragraph(_xml(_clip(task["where"], 48)), styles["cell"]),
                Paragraph(_xml(task["status_label"]), styles["cell"]),
                Paragraph(f"{task['progress']}%", styles["cell"]),
                Paragraph(str(task["photos"]), styles["cell"]),
            ]
        )
    if len(activities) > len(shown):
        rows.append(
            [
                Paragraph(
                    f"+ {len(activities) - len(shown)} actividades más en el rango.",
                    styles["muted"],
                ),
                Paragraph("", styles["cell"]),
                Paragraph("", styles["cell"]),
                Paragraph("", styles["cell"]),
                Paragraph("", styles["cell"]),
            ]
        )
    if not rows:
        rows.append(
            [
                Paragraph("Ninguna bitácora del rango tiene actividades.", styles["muted"]),
                Paragraph("", styles["cell"]),
                Paragraph("", styles["cell"]),
                Paragraph("", styles["cell"]),
                Paragraph("", styles["cell"]),
            ]
        )
    return _table([header, *rows], [48 * mm, 58 * mm, 28 * mm, 22 * mm, 22 * mm])


def _open_line(activities: Sequence[dict]) -> str:
    opened = [
        f"{_clip(task['name'], 36)} {task['progress']}%"
        for task in activities
        if task["status"] in ("in_progress", "scheduled", "rescheduled")
    ]
    if not opened:
        return "No quedan actividades abiertas en este periodo."
    return "Siguen abiertas: " + ", ".join(opened[:4]) + "."


def _chapter_bars(fulfillment, styles):
    chapters = [
        chapter
        for chapter in (fulfillment.get("chapters") or [])
        if _pct(chapter.get("progress_percent")) > 0
    ]
    chapters.sort(
        key=lambda chapter: _pct(chapter.get("weight_percent")),
        reverse=True,
    )
    if not chapters:
        return [Paragraph("Los capítulos de la obra siguen en cero.", styles["muted"])]
    lines = [Paragraph("Avance por capítulo", styles["section"]), Spacer(1, 1.5 * mm)]
    for chapter in chapters[:4]:
        weight = chapter.get("weight_percent")
        weight_label = f" · peso {_pct(weight)}" if weight is not None else ""
        lines.append(
            Paragraph(
                f"{_xml(chapter.get('chapter_name') or 'Capítulo')} "
                f"{_pct(chapter.get('progress_percent'))}%{weight_label}",
                styles["cell"],
            )
        )
    return lines


def _photo_jpeg(file_url: Optional[str]):
    key = _storage_key(file_url)
    if not key:
        return None
    try:
        from app.services.s3_service import get_s3_client
        from app.config import settings

        obj = get_s3_client().get_object(Bucket=settings.s3_bucket, Key=key)
        raw = obj["Body"].read()
    except Exception:
        return None
    try:
        from io import BytesIO
        from PIL import Image as PilImage

        image = PilImage.open(BytesIO(raw))
        image = image.convert("RGB")
        image.thumbnail((1100, 820))
        out = BytesIO()
        image.save(out, format="JPEG", quality=82)
        out.seek(0)
        width, height = image.size
        max_w = 86 * mm
        max_h = 68 * mm
        scale = min(max_w / width, max_h / height)
        return PdfImage(out, width=width * scale, height=height * scale)
    except Exception:
        return None


def _storage_key(file_url: Optional[str]) -> Optional[str]:
    if not file_url:
        return None
    value = file_url.strip()
    if not value:
        return None
    if not value.startswith("http"):
        return value.lstrip("/")
    from urllib.parse import urlparse

    path = urlparse(value).path.lstrip("/")
    bucket = ""
    try:
        from app.config import settings

        bucket = (settings.s3_bucket or "").strip("/")
    except Exception:
        bucket = ""
    if bucket and path.startswith(bucket + "/"):
        path = path[len(bucket) + 1 :]
    return path or None


def _photo_card(photo: dict, styles):
    moment = photo["when"]
    stamp = _short_date(moment.date()) if isinstance(moment, datetime) else "—"
    caption = Paragraph(
        f"<b>{_xml(stamp)}</b> · {_xml(_clip(photo['title'], 42))}<br/>{_xml(_clip(photo['caption'], 70))}",
        styles["cell"],
    )
    image = _photo_jpeg(photo.get("file_url"))
    body = [image, Spacer(1, 1.2 * mm), caption] if image else [caption]
    card = Table([[item] for item in body], colWidths=[86 * mm])
    card.setStyle(
        TableStyle(
            [
                ("BACKGROUND", (0, 0), (-1, -1), SOFT),
                ("LEFTPADDING", (0, 0), (-1, -1), 4),
                ("RIGHTPADDING", (0, 0), (-1, -1), 4),
                ("TOPPADDING", (0, 0), (-1, -1), 4),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("ALIGN", (0, 0), (-1, 0), "CENTER"),
            ]
        )
    )
    return card


def _photo_strip(photos: Sequence[dict], styles):
    shown = list(photos[:8])
    if not shown:
        return Paragraph("No hay fotos en el periodo.", styles["muted"])
    rows = []
    pair: List[Any] = []
    for photo in shown:
        pair.append(_photo_card(photo, styles))
        if len(pair) == 2:
            rows.append(pair)
            pair = []
    if pair:
        pair.append(Paragraph("", styles["cell"]))
        rows.append(pair)
    table = Table(rows, colWidths=[89 * mm, 89 * mm])
    table.setStyle(
        TableStyle(
            [
                ("VALIGN", (0, 0), (-1, -1), "TOP"),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 2 * mm),
                ("TOPPADDING", (0, 0), (-1, -1), 0),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 3 * mm),
            ]
        )
    )
    return table
