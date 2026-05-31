import uuid
from fastapi import APIRouter, Depends, File, Form, UploadFile, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete, func

from app.database import get_db
from app.models.user import User
from app.models.photo import Photo
from app.models.mission import MissionCompletion
from app.schemas.photo import PhotoOut, PhotoList
from app.core.dependencies import get_current_user
from app.services.file_service import save_photo, delete_photo_file

router = APIRouter(prefix="/photos", tags=["Photos"])


@router.post("/upload", response_model=PhotoOut, status_code=status.HTTP_201_CREATED)
async def upload_photo(
    file: UploadFile = File(...),
    place_id: str | None = Form(default=None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    อัพโหลดรูปภาพที่ถ่ายจากกล้องในแอพ
    place_id: รหัสสถานที่ "1"-"6" (ส่งมาด้วยถ้าถ่ายที่สถานที่นั้น)
    ส่ง multipart/form-data: file + place_id
    """
    stored_filename, url, size = await save_photo(file, current_user.id, place_id)

    photo = Photo(
        user_id=current_user.id,
        place_id=place_id,
        original_filename=file.filename or "photo.jpg",
        stored_filename=stored_filename,
        url=url,
        size_bytes=size,
    )
    db.add(photo)

    # ถ้า place_id ส่งมา ให้อัพเดท photo_url ใน mission_completion ด้วย
    if place_id:
        result = await db.execute(
            select(MissionCompletion).where(
                MissionCompletion.user_id == current_user.id,
                MissionCompletion.place_id == place_id,
            )
        )
        mission = result.scalar_one_or_none()
        if mission:
            mission.photo_url = url

    await db.commit()
    await db.refresh(photo)
    return photo


@router.get("/me", response_model=PhotoList)
async def get_my_photos(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Photo)
        .where(Photo.user_id == current_user.id)
        .order_by(Photo.created_at.desc())
    )
    photos = result.scalars().all()
    return PhotoList(photos=photos, total=len(photos))


@router.delete("/{photo_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_my_photo(
    photo_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Photo).where(Photo.id == photo_id, Photo.user_id == current_user.id))
    photo = result.scalar_one_or_none()
    if not photo:
        raise HTTPException(status_code=404, detail="ไม่พบรูปภาพ")

    await delete_photo_file(photo.url, current_user.id)
    await db.delete(photo)
    await db.commit()
