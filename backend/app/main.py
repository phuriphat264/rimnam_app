import asyncio
from contextlib import asynccontextmanager
from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

from app.config import settings
from app.database import engine, Base
from app.routers import auth, users, missions, photos, admin


async def _init_db(retries: int = 5, delay: float = 2.0) -> None:
    for attempt in range(1, retries + 1):
        try:
            async with engine.begin() as conn:
                await conn.run_sync(Base.metadata.create_all)
            print(f"[DB] ready on attempt {attempt}")
            return
        except Exception as e:
            print(f"[DB] attempt {attempt}/{retries} failed: {e}")
            if attempt < retries:
                await asyncio.sleep(delay)
    print("[DB] WARNING: could not connect — app will start anyway")


@asynccontextmanager
async def lifespan(app: FastAPI):
    await _init_db()  # ไม่ crash ถ้า DB ยังไม่พร้อม

    Path(settings.UPLOAD_DIR).mkdir(parents=True, exist_ok=True)
    (Path(settings.UPLOAD_DIR) / "photos").mkdir(exist_ok=True)

    yield

    await engine.dispose()


limiter = Limiter(key_func=get_remote_address)

app = FastAPI(
    title=settings.APP_NAME,
    version="1.0.0",
    docs_url="/docs" if settings.DEBUG else None,
    redoc_url="/redoc" if settings.DEBUG else None,
    lifespan=lifespan,
)

app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Static files (รูปภาพที่อัพโหลด)
upload_path = Path(settings.UPLOAD_DIR)
upload_path.mkdir(parents=True, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=str(upload_path)), name="uploads")

# Routers
PREFIX = f"/api/{settings.API_VERSION}"
app.include_router(auth.router, prefix=PREFIX)
app.include_router(users.router, prefix=PREFIX)
app.include_router(missions.router, prefix=PREFIX)
app.include_router(photos.router, prefix=PREFIX)
app.include_router(admin.router, prefix=PREFIX)


@app.get("/health")
async def health():
    return {"status": "ok", "version": "1.0.0"}
