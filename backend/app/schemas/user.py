import uuid
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field, field_validator
import re


class UserRegister(BaseModel):
    email: EmailStr
    username: str = Field(min_length=3, max_length=50, pattern=r"^[a-zA-Z0-9_]+$")
    display_name: str = Field(min_length=1, max_length=100)
    password: str = Field(min_length=8, max_length=128)
    language: str = Field(default="th", pattern=r"^(th|en)$")

    @field_validator("password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if not re.search(r"[A-Za-z]", v):
            raise ValueError("รหัสผ่านต้องมีตัวอักษรอย่างน้อย 1 ตัว")
        if not re.search(r"\d", v):
            raise ValueError("รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัว")
        return v


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserUpdate(BaseModel):
    display_name: str | None = Field(default=None, min_length=1, max_length=100)
    language: str | None = Field(default=None, pattern=r"^(th|en)$")


class UserPublic(BaseModel):
    id: uuid.UUID
    email: str
    username: str
    display_name: str
    avatar_url: str | None
    language: str
    is_active: bool
    has_password: bool
    created_at: datetime
    last_active_at: datetime

    model_config = {"from_attributes": True}


class UserAdminView(UserPublic):
    is_admin: bool
    mission_count: int = 0
    photo_count: int = 0


class TokenPair(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


class RefreshRequest(BaseModel):
    refresh_token: str


class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str = Field(min_length=8, max_length=128)


class SetPasswordRequest(BaseModel):
    new_password: str = Field(min_length=8, max_length=128)
    confirm_password: str

    @field_validator("new_password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if not re.search(r"[A-Za-z]", v):
            raise ValueError("รหัสผ่านต้องมีตัวอักษรอย่างน้อย 1 ตัว")
        if not re.search(r"\d", v):
            raise ValueError("รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัว")
        return v


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    email: EmailStr
    otp: str = Field(min_length=6, max_length=6, pattern=r"^\d{6}$")
    new_password: str = Field(min_length=8, max_length=128)

    @field_validator("new_password")
    @classmethod
    def password_strength(cls, v: str) -> str:
        if not re.search(r"[A-Za-z]", v):
            raise ValueError("รหัสผ่านต้องมีตัวอักษรอย่างน้อย 1 ตัว")
        if not re.search(r"\d", v):
            raise ValueError("รหัสผ่านต้องมีตัวเลขอย่างน้อย 1 ตัว")
        return v


class GoogleAuthRequest(BaseModel):
    id_token: str
