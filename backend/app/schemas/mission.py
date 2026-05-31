import uuid
from datetime import datetime
from pydantic import BaseModel, Field


class MissionComplete(BaseModel):
    place_id: str = Field(pattern=r"^[1-6]$", description="รหัสสถานที่ 1-6")
    latitude: float | None = None
    longitude: float | None = None
    photo_url: str | None = None


class MissionCompletionOut(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    place_id: str
    completed_at: datetime
    latitude: float | None
    longitude: float | None
    photo_url: str | None

    model_config = {"from_attributes": True}


class UserProgress(BaseModel):
    completed_place_ids: list[str]
    completed_count: int
    total_places: int = 6
    is_all_done: bool
