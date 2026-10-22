from datetime import datetime
from decimal import Decimal
from typing import Optional

from pydantic import Field, field_validator

from app.schemas.base import BaseCreateSchema, BaseResponseSchema, BaseSchema, BaseUpdateSchema


def _clean_account(value: object) -> Optional[str]:
    if value is None:
        return None
    text = " ".join(str(value).split())
    return text or None


class WorkerCreate(BaseCreateSchema):
    person_id: int
    worker_position_id: Optional[int] = None
    specialty_id: Optional[int] = None
    linked_user_id: Optional[int] = None
    daily_rate: Optional[Decimal] = Field(
        None,
        ge=0,
        le=Decimal("99999999.99"),
        description="Pago por día. Entra en la liquidación: valor día × días con asistencia.",
    )
    bank_account: Optional[str] = Field(
        None,
        max_length=40,
        description="Cuenta Nequi. Sale en el Excel de liquidación.",
    )

    @field_validator("bank_account", mode="before")
    @classmethod
    def clean_bank_account(cls, value: object) -> Optional[str]:
        return _clean_account(value)

    @field_validator("daily_rate", mode="before")
    @classmethod
    def empty_rate(cls, value: object) -> object:
        if value is None or value == "":
            return None
        return value


class WorkerUpdate(BaseUpdateSchema):
    worker_position_id: Optional[int] = None
    specialty_id: Optional[int] = None
    linked_user_id: Optional[int] = None
    daily_rate: Optional[Decimal] = Field(None, ge=0, le=Decimal("99999999.99"))
    bank_account: Optional[str] = Field(None, max_length=40)

    @field_validator("bank_account", mode="before")
    @classmethod
    def clean_bank_account(cls, value: object) -> Optional[str]:
        return _clean_account(value)

    @field_validator("daily_rate", mode="before")
    @classmethod
    def empty_rate(cls, value: object) -> object:
        if value is None or value == "":
            return None
        return value


class WorkerStatusUpdate(BaseSchema):
    """Baja definitiva del trabajador (≠ salida de obra)."""

    is_active: int = Field(..., description="1=activo, 2=inactivo")
    deactivation_reason: Optional[str] = Field(
        None,
        max_length=255,
        description="Obligatorio al desactivar (isActive=2)",
    )


class WorkerResponse(BaseResponseSchema):
    person_id: int
    worker_position_id: Optional[int] = None
    specialty_id: Optional[int] = None
    linked_user_id: Optional[int] = None
    daily_rate: Optional[float] = None
    bank_account: Optional[str] = None
    is_active: int
    deactivation_reason: Optional[str] = None
    person_name: Optional[str] = None
    document_number: Optional[str] = None
    position_name: Optional[str] = None
    specialty_name: Optional[str] = None
    linked_username: Optional[str] = None
    created_at: Optional[datetime] = None
