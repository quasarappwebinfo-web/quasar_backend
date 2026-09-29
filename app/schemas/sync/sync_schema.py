"""Schemas sync offline (Fase 8)."""
from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import Field

from app.schemas.base import BaseSchema

SYNC_ENTITIES = (
    "task_comment",
    "task_delay",
    "task_photo",
    "task_status",
    "task_reschedule",
)
SYNC_OPS = ("create", "update")


class SyncOperation(BaseSchema):
    """Una entrada de la outbox del cliente."""

    op_id: str = Field(..., description="Id local de la outbox (eco en la respuesta)")
    entity: str = Field(..., description="task_comment|task_delay|task_photo|task_status|task_reschedule")
    op: str = Field(..., description="create|update")
    uuid: str = Field(..., max_length=36, description="uuid del registro (cliente)")
    client_updated_at: Optional[datetime] = Field(
        None,
        description="Marca de tiempo del cliente; sirve para conflictos",
    )
    payload: Dict[str, Any] = Field(default_factory=dict)


class SyncPushRequest(BaseSchema):
    operations: List[SyncOperation] = Field(..., min_length=1, max_length=100)


class SyncOpResult(BaseSchema):
    op_id: str
    entity: str
    uuid: str
    status: str = Field(
        ...,
        description="applied|idempotent|conflict|needs_upload|error",
    )
    server_id: Optional[int] = None
    message: Optional[str] = None
    server_record: Optional[Dict[str, Any]] = None
    upload_hint: Optional[str] = None


class SyncPushResponse(BaseSchema):
    results: List[SyncOpResult]
    applied: int = 0
    conflicts: int = 0
    errors: int = 0
    needs_upload: int = 0
    server_time: datetime


class SyncPullResponse(BaseSchema):
    since: datetime
    server_time: datetime
    tasks: List[Dict[str, Any]] = []
    comments: List[Dict[str, Any]] = []
    delays: List[Dict[str, Any]] = []
    photos: List[Dict[str, Any]] = []
    reschedules: List[Dict[str, Any]] = []
    status_history: List[Dict[str, Any]] = []
