"""
บริการจัดการไฟล์ รองรับ 2 backend:
  - local: เก็บใน ./uploads/photos/{user_id}/ (Development)
  - s3: อัพโหลดไปยัง S3-compatible storage เช่น MinIO (Production)

โครงสร้างโฟลเดอร์ (local):
  uploads/
  └── photos/
      └── {user_id}/
          └── {place_id}_{uuid}.jpg
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


async def save_photo(file: UploadFile, user_id: uuid.UUID, place_id: str | None = None) -> tuple[str, str, int]:
    """
    บันทึกรูปภาพและคืน (stored_filename, public_url, size_bytes)
    """
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

    processed = _process_image(raw)

    ext = "jpg"
    prefix = f"{place_id}_" if place_id else ""
    stored_filename = f"{prefix}{uuid.uuid4().hex}.{ext}"

    if settings.STORAGE_BACKEND == "s3":
        url = await _upload_s3(processed, stored_filename, user_id)
    else:
        url = await _save_local(processed, stored_filename, user_id)

    return stored_filename, url, len(processed)


def _process_image(raw: bytes) -> bytes:
    """Resize ถ้าใหญ่เกิน MAX_DIMENSION, แปลงเป็น JPEG ลดขนาดไฟล์"""
    img = Image.open(io.BytesIO(raw))
    img = img.convert("RGB")

    if img.width > MAX_DIMENSION or img.height > MAX_DIMENSION:
        img.thumbnail((MAX_DIMENSION, MAX_DIMENSION), Image.LANCZOS)

    buf = io.BytesIO()
    img.save(buf, format="JPEG", quality=85, optimize=True)
    return buf.getvalue()


async def _save_local(data: bytes, filename: str, user_id: uuid.UUID) -> str:
    user_dir = Path(settings.UPLOAD_DIR) / "photos" / str(user_id)
    user_dir.mkdir(parents=True, exist_ok=True)

    dest = user_dir / filename
    async with aiofiles.open(dest, "wb") as f:
        await f.write(data)

    return f"/uploads/photos/{user_id}/{filename}"


async def _upload_s3(data: bytes, filename: str, user_id: uuid.UUID) -> str:
    try:
        import boto3
        from botocore.client import Config

        def _do_upload() -> str:
            s3 = boto3.client(
                "s3",
                endpoint_url=settings.S3_ENDPOINT_URL,
                aws_access_key_id=settings.S3_ACCESS_KEY,
                aws_secret_access_key=settings.S3_SECRET_KEY,
                config=Config(signature_version="s3v4"),
            )
            key = f"photos/{user_id}/{filename}"
            s3.put_object(
                Bucket=settings.S3_BUCKET_NAME,
                Key=key,
                Body=data,
                ContentType="image/jpeg",
            )
            return f"{settings.S3_PUBLIC_URL}/{key}"

        return await asyncio.to_thread(_do_upload)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"อัพโหลดรูปล้มเหลว: {str(e)}")


async def delete_photo_file(url: str, user_id: uuid.UUID) -> None:
    """ลบไฟล์จาก storage (best-effort ไม่ raise ถ้าไม่มีไฟล์)"""
    if settings.STORAGE_BACKEND == "local":
        filename = url.split("/")[-1]
        path = Path(settings.UPLOAD_DIR) / "photos" / str(user_id) / filename
        try:
            os.remove(path)
        except FileNotFoundError:
            pass
