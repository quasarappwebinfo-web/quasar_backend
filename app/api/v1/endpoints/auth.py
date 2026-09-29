from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.api.deps import get_current_user, get_db
from app.config import settings
from app.core.cookies import clear_refresh_cookie, set_refresh_cookie
from app.core.limiter import limiter
from app.core.permissions import has_full_access, permission_codes_of
from app.models import User
from app.schemas import AccessTokenResponse, LoginResponse, UserResponse
from app.services.auth_service import (
    InactiveUserError,
    InvalidCredentialsError,
    InvalidRefreshTokenError,
    authenticate_user,
    build_access_token_for_user,
    issue_refresh_token,
    logout_with_refresh_token,
    rotate_refresh_token,
)
from app.services.user_service import user_to_dict

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])


def _client_meta(request: Request) -> tuple[str | None, str | None]:
    ua = request.headers.get("user-agent")
    ip = request.client.host if request.client else None
    return ua, ip


@router.post(
    "/login",
    response_model=LoginResponse,
    summary="Iniciar sesión",
    description=(
        "Devuelve un access token (JWT corto) en el body. "
        "El refresh token se envía solo como cookie HttpOnly (no aparece en JS)."
    ),
)
@limiter.limit("5/minute")
async def login(
    request: Request,
    response: Response,
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db),
):
    try:
        user = authenticate_user(db, form_data.username, form_data.password)
    except InvalidCredentialsError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario o contraseña incorrectos",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except InactiveUserError:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Usuario inactivo",
        )

    access_token = build_access_token_for_user(user)
    ua, ip = _client_meta(request)
    raw_refresh = issue_refresh_token(db, user, user_agent=ua, ip_address=ip)
    set_refresh_cookie(response, raw_refresh)

    return LoginResponse(
        access_token=access_token,
        token_type="bearer",
        expires_in=settings.access_token_expire_minutes * 60,
        user_id=user.id,
        username=user.username,
        name=user.person.name if user.person else user.username,
        role_name=user.role.name if user.role else "",
        is_super=user.is_super or 0,
        has_full_access=has_full_access(user),
        permissions=permission_codes_of(user),
    )


@router.post(
    "/refresh",
    response_model=AccessTokenResponse,
    summary="Renovar access token",
    description=(
        "Lee la cookie HttpOnly `refresh_token`, la rota y devuelve un access token nuevo. "
        "El frontend debe llamar con `credentials: 'include'`."
    ),
)
@limiter.limit("30/minute")
async def refresh(request: Request, response: Response, db: Session = Depends(get_db)):
    raw = request.cookies.get(settings.refresh_cookie_name)
    if not raw:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="No hay sesión (cookie de refresh ausente)",
        )
    try:
        ua, ip = _client_meta(request)
        _user, access_token, new_raw = rotate_refresh_token(
            db, raw, user_agent=ua, ip_address=ip
        )
    except InvalidRefreshTokenError as e:
        clear_refresh_cookie(response)
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
        )

    set_refresh_cookie(response, new_raw)
    return AccessTokenResponse(
        access_token=access_token,
        token_type="bearer",
        expires_in=settings.access_token_expire_minutes * 60,
    )


@router.post(
    "/logout",
    summary="Cerrar sesión",
    description="Revoca el refresh token actual y borra la cookie HttpOnly.",
)
async def logout(request: Request, response: Response, db: Session = Depends(get_db)):
    raw = request.cookies.get(settings.refresh_cookie_name)
    logout_with_refresh_token(db, raw)
    clear_refresh_cookie(response)
    return {"message": "Sesión cerrada"}


@router.get(
    "/me",
    response_model=UserResponse,
    summary="Usuario autenticado",
)
async def me(current_user: User = Depends(get_current_user)):
    return UserResponse(**user_to_dict(current_user)).model_dump(by_alias=True)
