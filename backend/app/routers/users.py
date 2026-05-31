from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, update

from app.database import get_db
from app.models.user import User
from app.models.photo import Photo
from app.schemas.user import UserPublic, UserUpdate, ChangePasswordRequest, SetPasswordRequest
from app.core.security import verify_password, hash_password
from app.core.dependencies import get_current_user
from app.services.file_service import save_photo, delete_photo_file

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserPublic)
async def get_my_profile(current_user: User = Depends(get_current_user)):
    return current_user


@router.patch("/me", response_model=UserPublic)
async def update_my_profile(
    body: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    values = body.model_dump(exclude_none=True)
    if values:
        await db.execute(update(User).where(User.id == current_user.id).values(**values))
        await db.commit()
        await db.refresh(current_user)
    return current_user


@router.post("/me/avatar", response_model=UserPublic)
async def upload_avatar(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    stored_filename, url, size = await save_photo(file, current_user.id)

    # ลบรูปเก่าถ้ามี
    if current_user.avatar_url and current_user.avatar_url.startswith("/uploads"):
        await delete_photo_file(current_user.avatar_url, current_user.id)

    await db.execute(update(User).where(User.id == current_user.id).values(avatar_url=url))
    db.add(Photo(
        user_id=current_user.id,
        place_id=None,
        original_filename=file.filename or "avatar.jpg",
        stored_filename=stored_filename,
        url=url,
        size_bytes=size,
    ))
    await db.commit()
    await db.refresh(current_user)
    return current_user


@router.put("/me/password", status_code=status.HTTP_204_NO_CONTENT)
async def change_password(
    body: ChangePasswordRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not current_user.password_hash:
        raise HTTPException(status_code=400, detail="บัญชี Google ไม่สามารถเปลี่ยนรหัสผ่านได้")
    if not verify_password(body.current_password, current_user.password_hash):
        raise HTTPException(status_code=400, detail="รหัสผ่านปัจจุบันไม่ถูกต้อง")
    await db.execute(
        update(User).where(User.id == current_user.id).values(password_hash=hash_password(body.new_password))
    )
    await db.commit()


@router.post("/me/set-password", status_code=status.HTTP_204_NO_CONTENT)
async def set_password(
    body: SetPasswordRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if current_user.password_hash:
        raise HTTPException(status_code=400, detail="บัญชีนี้มีรหัสผ่านแล้ว ใช้หน้าเปลี่ยนรหัสผ่านแทน")
    if body.new_password != body.confirm_password:
        raise HTTPException(status_code=400, detail="รหัสผ่านไม่ตรงกัน")
    await db.execute(
        update(User).where(User.id == current_user.id).values(password_hash=hash_password(body.new_password))
    )
    await db.commit()
