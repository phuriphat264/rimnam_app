import uuid
from datetime import datetime
from pydantic import BaseModel


class PhotoOut(BaseModel):
    id: uuid.UUID
    user_id: uuid.UUID
    place_id: str | None
    url: str
    original_filename: str
    size_bytes: int
    created_at: datetime

    model_config = {"from_attributes": True}


class PhotoList(BaseModel):
    photos: list[PhotoOut]
    total: int
