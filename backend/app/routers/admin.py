import uuid
from datetime import datetime, timedelta, timezone
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, update, distinct

from app.database import get_db
from app.models.user import User
from app.models.mission import MissionCompletion
from app.models.photo import Photo
from app.schemas.user import UserAdminView, UserPublic
from app.schemas.admin import UserStats, AdminUserUpdate
from app.core.dependencies import get_admin_user

router = APIRouter(prefix="/admin", tags=["Admin"])


@router.get("/stats", response_model=UserStats)
async def get_stats(
    db: AsyncSession = Depends(get_db),
    _: User = Depends(get_admin_user),
):
    now = datetime.now(timezone.utc)

    total_users = (await db.execute(select(func.count(User.id)))).scalar_one()
    active_7d = (await db.execute(
        select(func.count(User.id)).where(User.last_active_at >= now - timedelta(days=7))
    )).scalar_one()
    active_30d = (await db.execute(
        select(func.count(User.id)).where(User.last_active_at >= now - timedelta(days=30))
    )).scalar_one()

    # ผู้ใช้ที่ทำภารกิจอย่างน้อย 1 สถานที่
    interactive_users = (await db.execute(
        select(func.count(distinct(MissionCompletion.user_id)))
    )).scalar_one()

    # ผู้ใช้ที่ทำครบ 6 สถานที่
    completed_all = (await db.execute(
        select(func.count()).select_from(
            select(MissionCompletion.user_id)
            .group_by(MissionCompletion.user_id)
            .having(func.count(MissionCompletion.place_id) >= 6)
            .subquery()
        )
    )).scalar_one()

    total_photos = (await db.execute(select(func.count(Photo.id)))).scalar_one()
    total_missions = (await db.execute(select(func.count(MissionCompletion.id)))).scalar_one()

    new_today = (await db.execute(
        select(func.count(User.id)).where(User.created_at >= now.replace(hour=0, minute=0, second=0, microsecond=0))
    )).scalar_one()
    new_7d = (await db.execute(
        select(func.count(User.id)).where(User.created_at >= now - timedelta(days=7))
    )).scalar_one()

    return UserStats(
        total_users=total_users,
        active_users_7d=active_7d,
        active_users_30d=active_30d,
        interactive_users=interactive_users,
        completed_all_users=completed_all,
        total_photos=total_photos,
        total_mission_completions=total_missions,
        new_users_today=new_today,
        new_users_7d=new_7d,
    )


@router.get("/users", response_model=list[UserAdminView])
async def list_users(
    page: int = Query(default=1, ge=1),
    page_size: int = Query(default=20, ge=1, le=100),
    search: str | None = Query(default=None),
    db: AsyncSession = Depends(get_db),
    _: User = Depends(get_admin_user),
):
    offset = (page - 1) * page_size
    q = select(User)
    if search:
        q = q.where(User.email.ilike(f"%{search}%") | User.username.ilike(f"%{search}%"))
    q = q.order_by(User.created_at.desc()).offset(offset).limit(page_size)

    result = await db.execute(q)
    users = result.scalars().all()

    out = []
    for u in users:
        mission_count = (await db.execute(
            select(func.count(MissionCompletion.id)).where(MissionCompletion.user_id == u.id)
        )).scalar_one()
        photo_count = (await db.execute(
            select(func.count(Photo.id)).where(Photo.user_id == u.id)
        )).scalar_one()
        out.append(UserAdminView(
            **UserPublic.model_validate(u).model_dump(),
            is_admin=u.is_admin,
            mission_count=mission_count,
            photo_count=photo_count,
        ))
    return out


@router.get("/users/{user_id}", response_model=UserAdminView)
async def get_user(
    user_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(get_admin_user),
):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="ไม่พบผู้ใช้")

    mission_count = (await db.execute(
        select(func.count(MissionCompletion.id)).where(MissionCompletion.user_id == user_id)
    )).scalar_one()
    photo_count = (await db.execute(
        select(func.count(Photo.id)).where(Photo.user_id == user_id)
    )).scalar_one()

    return UserAdminView(
        **UserPublic.model_validate(user).model_dump(),
        is_admin=user.is_admin,
        mission_count=mission_count,
        photo_count=photo_count,
    )


@router.patch("/users/{user_id}", response_model=UserAdminView)
async def update_user(
    user_id: uuid.UUID,
    body: AdminUserUpdate,
    db: AsyncSession = Depends(get_db),
    admin: User = Depends(get_admin_user),
):
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=404, detail="ไม่พบผู้ใช้")

    values = body.model_dump(exclude_none=True)
    if values:
        await db.execute(update(User).where(User.id == user_id).values(**values))
        await db.commit()
        await db.refresh(user)

    mission_count = (await db.execute(
        select(func.count(MissionCompletion.id)).where(MissionCompletion.user_id == user_id)
    )).scalar_one()
    photo_count = (await db.execute(
        select(func.count(Photo.id)).where(Photo.user_id == user_id)
    )).scalar_one()

    return UserAdminView(
        **UserPublic.model_validate(user).model_dump(),
        is_admin=user.is_admin,
        mission_count=mission_count,
        photo_count=photo_count,
    )


@router.delete("/users/{user_id}/missions", status_code=204)
async def admin_reset_user_missions(
    user_id: uuid.UUID,
    db: AsyncSession = Depends(get_db),
    _: User = Depends(get_admin_user),
):
    """Admin รีเซ็ต progress ของ user คนนั้น"""
    from sqlalchemy import delete
    await db.execute(delete(MissionCompletion).where(MissionCompletion.user_id == user_id))
    await db.commit()
