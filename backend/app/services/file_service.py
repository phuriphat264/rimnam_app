"""
บริการจัดการไฟล์ รองรับ 2 backend:
  - local: เก็บใน ./uploads/ (Development)
  - s3:    อัพโหลดไปยัง Cloudflare R2 (Production)

โครงสร้างโฟลเดอร์ใน bucket / local:
  avatars/
  └── {user_id}/
      └── {uuid}.jpg                         ← รูปโปรไฟล์

  missions/
  ├── 1/
  │   └── {user_id}_{uuid}.jpg               ← รูปภารกิจ สถานที่ 1
  ├── 2/
  │   └── {user_id}_{uuid}.jpg
  └── ... (3-6)
"""

import uuid
import os
import io
import asyncio
import aiofiles
from pathlib import Path
from PIL import Image
from fastapi import UploadFile, HTTPException, status
from app.config import settings


ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp"}
MAX_DIMENSION = 2048


# ── Public API ──────────────────────────────────────────────────

async def save_mission_photo(
    file: UploadFile,
    user_id: uuid.UUID,
    place_id: str,
) -> tuple[str, str, int]:
    """
    อัพโหลดรูปภารกิจ
    key: missions/{place_id}/{user_id}_{uuid}.jpg
    """
    processed = await _validate_and_process(file)
    filename = f"{user_id}_{uuid.uuid4().hex}.jpg"
    key = f"missions/{place_id}/{filename}"
    url = await _store(processed, key)
    return filename, url, len(processed)


async def save_avatar_photo(
    file: UploadFile,
    user_id: uuid.UUID,
) -> tuple[str, str, int]:
    """
    อัพโหลดรูปโปรไฟล์
    key: avatars/{user_id}/{uuid}.jpg
    """
    processed = await _validate_and_process(file)
    filename = f"{uuid.uuid4().hex}.jpg"
    key = f"avatars/{user_id}/{filename}"
    url = await _store(processed, key)
    return filename, url, len(processed)


async def delete_photo_file(url: str) -> None:
    """ลบไฟล์จาก storage (best-effort — ไม่ raise ถ้าไม่เจอ)"""
    if not url:
        return
    if settings.STORAGE_BACKEND == "s3":
        await _delete_s3(url)
    else:
        await _delete_local(url)


# ── Internals ───────────────────────────────────────────────────

async def _validate_and_process(file: UploadFile) -> bytes:
    if file.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail="รองรับเฉพาะไฟล์ JPEG, PNG, WebP เท่านั้น",
        )
    raw = await file.read()
    if len(raw) > settings.max_upload_bytes:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"ไฟล์ใหญ่เกิน {settings.MAX_UPLOAD_SIZE_MB} MB",
        )
    return _process_image(raw)


def _process_image(raw: bytes) -> bytes:
    """Resize ถ้าใหญ่เกิน MAX_DIMENSION, แปลงเป็น JPEG"""
    img = Image.open(io.BytesIO(raw)).convert("RGB")
    if img.width > MAX_DIMENSION or img.height > MAX_DIMENSION:
        img.thumbnail((MAX_DIMENSION, MAX_DIMENSION), Image.LANCZOS)
    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=85, optimize=True)
    return buf.getvalue()


async def _store(data: bytes, key: str) -> str:
    """เลือก backend แล้ว store"""
    if settings.STORAGE_BACKEND == "s3":
        return await _upload_s3(data, key)
    return await _save_local(data, key)


async def _save_local(data: bytes, key: str) -> str:
    """Local storage: ./uploads/{key}"""
    dest = Path(settings.UPLOAD_DIR) / key
    dest.parent.mkdir(parents=True, exist_ok=True)
    async with aiofiles.open(dest, "wb") as f:
        await f.write(data)
    return f"/uploads/{key}"


async def _upload_s3(data: bytes, key: str) -> str:
    """Cloudflare R2 upload"""
    try:
        import boto3
        from botocore.client import Config

        def _do() -> str:
            s3 = boto3.client(
                "s3",
                endpoint_url=settings.S3_ENDPOINT_URL,
                aws_access_key_id=settings.S3_ACCESS_KEY,
                aws_secret_access_key=settings.S3_SECRET_KEY,
                config=Config(signature_version="s3v4"),
            )
            s3.put_object(
                Bucket=settings.S3_BUCKET_NAME,
                Key=key,
                Body=data,
                ContentType="image/jpeg",
            )
            return f"{settings.S3_PUBLIC_URL}/{key}"

        return await asyncio.to_thread(_do)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"อัพโหลดรูปล้มเหลว: {str(e)}")


async def _delete_local(url: str) -> None:
    """Local delete — ดึง relative path จาก URL"""
    if not url.startswith("/uploads/"):
        return
    rel = url.removeprefix("/uploads/")
    path = Path(settings.UPLOAD_DIR) / rel
    try:
        os.remove(path)
    except (FileNotFoundError, OSError):
        pass


async def _delete_s3(url: str) -> None:
    """R2 delete — ดึง key จาก public URL"""
    public_base = settings.S3_PUBLIC_URL.rstrip("/")
    if not url.startswith(public_base):
        return
    key = url[len(public_base) + 1:]
    if not key:
        return
    try:
        import boto3
        from botocore.client import Config

        def _do():
            s3 = boto3.client(
                "s3",
                endpoint_url=settings.S3_ENDPOINT_URL,
                aws_access_key_id=settings.S3_ACCESS_KEY,
                aws_secret_access_key=settings.S3_SECRET_KEY,
                config=Config(signature_version="s3v4"),
            )
            s3.delete_object(Bucket=settings.S3_BUCKET_NAME, Key=key)

        await asyncio.to_thread(_do)
    except Exception:
        pass  # best-effort
