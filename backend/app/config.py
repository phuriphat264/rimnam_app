from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    APP_NAME: str = "Rimnam Chanthabun API"
    DEBUG: bool = False
    API_VERSION: str = "v1"
    ALLOWED_ORIGINS: str = "http://localhost:3000"

    DATABASE_URL: str = "postgresql+asyncpg://postgres:password@localhost:5432/rimnam_db"

    SECRET_KEY: str = "CHANGE-THIS-IN-PRODUCTION-USE-32-CHAR-MINIMUM"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
    REFRESH_TOKEN_EXPIRE_DAYS: int = 30

    STORAGE_BACKEND: str = "local"  # "local" | "s3"
    UPLOAD_DIR: str = "./uploads"
    MAX_UPLOAD_SIZE_MB: int = 10

    # S3/MinIO (optional)
    S3_ENDPOINT_URL: str = ""
    S3_ACCESS_KEY: str = ""
    S3_SECRET_KEY: str = ""
    S3_BUCKET_NAME: str = "rimnam-photos"
    S3_PUBLIC_URL: str = ""

    FIRST_ADMIN_EMAIL: str = "admin@rimnam.com"
    FIRST_ADMIN_PASSWORD: str = "changeme"

    # Email (for password reset OTP)
    SMTP_HOST: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USER: str = ""
    SMTP_PASSWORD: str = ""
    SMTP_FROM_EMAIL: str = ""   # email ที่แสดงใน From: (ถ้าว่างใช้ SMTP_USER)
    SMTP_FROM_NAME: str = "ริมน้ำจันทบูร"
    BREVO_API_KEY: str = ""
    RESEND_API_KEY: str = ""

    # Google OAuth
    GOOGLE_CLIENT_ID: str = ""

    @property
    def origins(self) -> List[str]:
        return [o.strip() for o in self.ALLOWED_ORIGINS.split(",")]

    @property
    def max_upload_bytes(self) -> int:
        return self.MAX_UPLOAD_SIZE_MB * 1024 * 1024


settings = Settings()
