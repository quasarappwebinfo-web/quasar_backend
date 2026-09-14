from typing import Optional

from pydantic import Field

from app.schemas.base import BaseSchema


class Token(BaseSchema):
    access_token: str
    token_type: str = "bearer"


class TokenData(BaseSchema):
    username: Optional[str] = None
    role_name: Optional[str] = None


class LoginRequest(BaseSchema):
    username: str = Field(..., min_length=1)
    password: str = Field(..., min_length=1)


class LoginResponse(BaseSchema):
    access_token: str
    token_type: str = "bearer"
    expires_in: int = Field(..., description="Segundos de vida del access token")
    user_id: int
    username: str
    name: str
    role_name: str


class AccessTokenResponse(BaseSchema):
    access_token: str
    token_type: str = "bearer"
    expires_in: int
