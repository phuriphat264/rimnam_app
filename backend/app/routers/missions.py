from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, delete

from app.database import get_db
from app.models.user import User
from app.models.mission import MissionCompletion
from app.schemas.mission import MissionComplete, MissionCompletionOut, UserProgress
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/missions", tags=["Missions"])

TOTAL_PLACES = 6


@router.get("/progress", response_model=UserProgress)
async def get_my_progress(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(MissionCompletion).where(MissionCompletion.user_id == current_user.id)
    )
    completions = result.scalars().all()
    completed_ids = [c.place_id for c in completions]

    return UserProgress(
        completed_place_ids=completed_ids,
        completed_count=len(completed_ids),
        is_all_done=len(completed_ids) >= TOTAL_PLACES,
    )


@router.post("/complete", response_model=MissionCompletionOut, status_code=status.HTTP_201_CREATED)
async def complete_mission(
    body: MissionComplete,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # เช็คว่าทำสถานที่นี้ไปแล้วหรือยัง
    result = await db.execute(
        select(MissionCompletion).where(
            MissionCompletion.user_id == current_user.id,
            MissionCompletion.place_id == body.place_id,
        )
    )
    if result.scalar_one_or_none():
        raise HTTPException(status_code=409, detail=f"สถานที่ {body.place_id} ทำเสร็จแล้ว")

    completion = MissionCompletion(
        user_id=current_user.id,
        place_id=body.place_id,
        latitude=body.latitude,
        longitude=body.longitude,
        photo_url=body.photo_url,
    )
    db.add(completion)
    await db.commit()
    await db.refresh(completion)
    return completion


@router.delete("/reset", status_code=status.HTTP_204_NO_CONTENT)
async def reset_my_progress(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    await db.execute(delete(MissionCompletion).where(MissionCompletion.user_id == current_user.id))
    await db.commit()
