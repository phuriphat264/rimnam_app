from datetime import datetime
from pydantic import BaseModel


class UserStats(BaseModel):
    total_users: int
    active_users_7d: int
    active_users_30d: int
    interactive_users: int       # ทำภารกิจอย่างน้อย 1 สถานที่
    completed_all_users: int     # ทำครบ 6 สถานที่
    total_photos: int
    total_mission_completions: int
    new_users_today: int
    new_users_7d: int


class AdminUserUpdate(BaseModel):
    display_name: str | None = None
    is_active: bool | None = None
    is_admin: bool | None = None
    language: str | None = None
