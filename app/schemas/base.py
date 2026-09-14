from datetime import datetime
from typing import Optional

from pydantic import BaseModel, ConfigDict


def to_camel_case(snake_str: str) -> str:
    components = snake_str.split("_")
    return components[0] + "".join(x.capitalize() for x in components[1:])


class BaseSchema(BaseModel):
    model_config = ConfigDict(
        populate_by_name=True,
        from_attributes=True,
        alias_generator=to_camel_case,
    )


class TimestampSchema(BaseSchema):
    update_date: Optional[datetime] = None


class BaseResponseSchema(BaseSchema):
    id: int


class BaseCreateSchema(BaseSchema):
    pass


class BaseUpdateSchema(BaseSchema):
    pass
