import random
import string
import asyncio
from datetime import datetime, timezone, timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update, delete
import httpx

from app.database import get_db
from app.models.user import User, RefreshToken
from app.models.otp import PasswordResetToken
from app.schemas.user import (
    UserRegister, UserLogin, TokenPair, RefreshRequest, UserPublic,
    ForgotPasswordRequest, ResetPasswordRequest, GoogleAuthRequest,
)
from app.core.security import hash_password, verify_password, create_access_token, create_refresh_token, decode_token
from app.config import settings
from app.services.email_service import send_otp_email
from jose import JWTError
import uuid

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenPair, status_code=status.HTTP_201_CREATED)
async def register(body: UserRegister, db: AsyncSession = Depends(get_db)):
    existing = await db.execute(select(User).where(User.email == body.email))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Email นี้ถูกใช้แล้ว")

    existing = await db.execute(select(User).where(User.username == body.username))
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=409, detail="Username นี้ถูกใช้แล้ว")

    user = User(
        email=body.email,
        username=body.username,
        display_name=body.display_name,
        password_hash=hash_password(body.password),
        language=body.language,
    )
    db.add(user)
    await db.flush()

    access_token, expires_in = create_access_token(str(user.id))
    refresh_token_str, refresh_expires = create_refresh_token(str(user.id))
    db.add(RefreshToken(user_id=user.id, token=refresh_token_str, expires_at=refresh_expires))
    await db.commit()

    return TokenPair(access_token=access_token, refresh_token=refresh_token_str, expires_in=expires_in)


@router.post("/login", response_model=TokenPair)
async def login(body: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()

    if not user or not user.password_hash or not verify_password(body.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Email หรือรหัสผ่านไม่ถูกต้อง")

    if not user.is_active:
        raise HTTPException(status_code=403, detail="บัญชีนี้ถูกปิดการใช้งาน")

    access_token, expires_in = create_access_token(str(user.id))
    refresh_token_str, refresh_expires = create_refresh_token(str(user.id))
    db.add(RefreshToken(user_id=user.id, token=refresh_token_str, expires_at=refresh_expires))
    await db.execute(update(User).where(User.id == user.id).values(last_active_at=datetime.now(timezone.utc)))
    await db.commit()

    return TokenPair(access_token=access_token, refresh_token=refresh_token_str, expires_in=expires_in)


@router.post("/refresh", response_model=TokenPair)
async def refresh_token(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    try:
        payload = decode_token(body.refresh_token)
        if payload.get("type") != "refresh":
            raise ValueError
        user_id = uuid.UUID(payload["sub"])
    except (JWTError, ValueError):
        raise HTTPException(status_code=401, detail="Refresh token ไม่ถูกต้อง")

    result = await db.execute(
        select(RefreshToken).where(
            RefreshToken.token == body.refresh_token,
            RefreshToken.revoked == False,
            RefreshToken.expires_at > datetime.now(timezone.utc),
        )
    )
    token_record = result.scalar_one_or_none()
    if not token_record:
        raise HTTPException(status_code=401, detail="Refresh token หมดอายุหรือถูกยกเลิก")

    token_record.revoked = True
    access_token, expires_in = create_access_token(str(user_id))
    new_refresh, new_expires = create_refresh_token(str(user_id))
    db.add(RefreshToken(user_id=user_id, token=new_refresh, expires_at=new_expires))
    await db.commit()

    return TokenPair(access_token=access_token, refresh_token=new_refresh, expires_in=expires_in)


@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
async def logout(body: RefreshRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(RefreshToken).where(RefreshToken.token == body.refresh_token))
    token_record = result.scalar_one_or_none()
    if token_record:
        token_record.revoked = True
        await db.commit()


# ────────────────────────────────────────────────────────────
# Forgot Password (OTP via Email)
# ────────────────────────────────────────────────────────────

@router.post("/forgot-password", status_code=status.HTTP_204_NO_CONTENT)
async def forgot_password(body: ForgotPasswordRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()

    print(f"[OTP] forgot-password for {body.email}, user_found={user is not None}", flush=True)
    if not user:
        raise HTTPException(status_code=404, detail="ไม่พบบัญชีที่ใช้ email นี้")

    otp = "".join(random.choices(string.digits, k=6))
    otp_hash = hash_password(otp)
    expires_at = datetime.now(timezone.utc) + timedelta(minutes=15)

    await db.execute(delete(PasswordResetToken).where(PasswordResetToken.email == body.email))
    db.add(PasswordResetToken(email=body.email, otp_hash=otp_hash, expires_at=expires_at))
    await db.commit()

    print(f"[OTP] sending email to {body.email}, otp={otp}", flush=True)
    try:
        await asyncio.to_thread(send_otp_email, body.email, otp)
        print(f"[OTP] email sent OK", flush=True)
    except Exception as e:
        print(f"[Email error] {e}", flush=True)


@router.post("/reset-password", status_code=status.HTTP_204_NO_CONTENT)
async def reset_password(body: ResetPasswordRequest, db: AsyncSession = Depends(get_db)):
    now = datetime.now(timezone.utc)

    # หา OTP token ล่าสุดที่ยังไม่หมดอายุและยังไม่ใช้
    result = await db.execute(
        select(PasswordResetToken).where(
            PasswordResetToken.email == body.email,
            PasswordResetToken.used == False,
            PasswordResetToken.expires_at > now,
        ).order_by(PasswordResetToken.created_at.desc()).limit(1)
    )
    token_record = result.scalar_one_or_none()

    if not token_record or not verify_password(body.otp, token_record.otp_hash):
        raise HTTPException(status_code=400, detail="OTP ไม่ถูกต้องหรือหมดอายุแล้ว")

    # อัพเดทรหัสผ่าน
    result = await db.execute(select(User).where(User.email == body.email))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="ไม่พบผู้ใช้")

    user.password_hash = hash_password(body.new_password)  # ทำงานได้ทั้ง set ครั้งแรก (Google) และ reset
    token_record.used = True
    await db.commit()


# ────────────────────────────────────────────────────────────
# Google OAuth
# ────────────────────────────────────────────────────────────

@router.post("/google", response_model=TokenPair)
async def google_auth(body: GoogleAuthRequest, db: AsyncSession = Depends(get_db)):
    # ตรวจสอบ Google ID token ผ่าน Google tokeninfo endpoint
    async with httpx.AsyncClient() as client:
        resp = await client.get(
            "https://oauth2.googleapis.com/tokeninfo",
            params={"id_token": body.id_token},
            timeout=10,
        )

    if resp.status_code != 200:
        raise HTTPException(status_code=401, detail="Google token ไม่ถูกต้อง")

    info = resp.json()

    # ตรวจสอบ audience (ต้องตรงกับ GOOGLE_CLIENT_ID ของแอป)
    if settings.GOOGLE_CLIENT_ID and info.get("aud") != settings.GOOGLE_CLIENT_ID:
        raise HTTPException(status_code=401, detail="Google token audience ไม่ตรงกัน")

    google_id = info.get("sub")
    email = info.get("email")
    name = info.get("name") or info.get("email", "").split("@")[0]
    picture = info.get("picture")

    if not google_id or not email:
        raise HTTPException(status_code=400, detail="ข้อมูล Google token ไม่ครบถ้วน")

    # หา user ที่มี google_id นี้อยู่แล้ว
    result = await db.execute(select(User).where(User.google_id == google_id))
    user = result.scalar_one_or_none()

    if not user:
        # หา user จาก email (อาจสมัครด้วย email+password ก่อนหน้านี้)
        result = await db.execute(select(User).where(User.email == email))
        user = result.scalar_one_or_none()

        if user:
            # ผูก Google ID กับบัญชีที่มีอยู่
            user.google_id = google_id
            if not user.avatar_url and picture:
                user.avatar_url = picture
        else:
            # สร้างผู้ใช้ใหม่
            username_base = email.split("@")[0].replace(".", "_").replace("-", "_")
            username = username_base[:50]

            # ตรวจ username ซ้ำ
            suffix = 0
            while True:
                candidate = username if suffix == 0 else f"{username_base[:47]}_{suffix}"
                exists = await db.execute(select(User).where(User.username == candidate))
                if not exists.scalar_one_or_none():
                    username = candidate
                    break
                suffix += 1

            user = User(
                email=email,
                username=username,
                display_name=name,
                password_hash=None,
                google_id=google_id,
                avatar_url=picture,
            )
            db.add(user)
            await db.flush()

    if not user.is_active:
        raise HTTPException(status_code=403, detail="บัญชีนี้ถูกปิดการใช้งาน")

    await db.execute(update(User).where(User.id == user.id).values(last_active_at=datetime.now(timezone.utc)))

    access_token, expires_in = create_access_token(str(user.id))
    refresh_token_str, refresh_expires = create_refresh_token(str(user.id))
    db.add(RefreshToken(user_id=user.id, token=refresh_token_str, expires_at=refresh_expires))
    await db.commit()

    return TokenPair(access_token=access_token, refresh_token=refresh_token_str, expires_in=expires_in)
