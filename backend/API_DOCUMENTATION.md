# Rimnam Chanthabun — API Documentation
**Version:** 1.0.0  
**Base URL:** `https://api.rimnam.com/api/v1` (Production)  
**Dev URL:** `http://localhost:8000/api/v1`  
**Interactive Docs (Dev only):** `http://localhost:8000/docs`

---

## Authentication

ใช้ **JWT Bearer Token** ทุก endpoint ที่ต้องการ auth ต้องส่ง header:
```
Authorization: Bearer <access_token>
```

Access token อายุ **60 นาที** / Refresh token อายุ **30 วัน**

---

## 1. Auth Endpoints

### `POST /auth/register`
สมัครสมาชิกใหม่

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "rimnam_explorer",
  "display_name": "นักสำรวจ",
  "password": "Password123",
  "language": "th"
}
```

**Validation:**
- `username`: 3-50 ตัว, เฉพาะ a-z, 0-9, _
- `password`: ขั้นต่ำ 8 ตัว, ต้องมีตัวอักษรและตัวเลข
- `language`: "th" หรือ "en"

**Response 201:**
```json
{
  "access_token": "eyJ...",
  "refresh_token": "eyJ...",
  "token_type": "bearer",
  "expires_in": 3600
}
```

**Errors:** 409 (email/username ซ้ำ), 422 (validation)

---

### `POST /auth/login`
เข้าสู่ระบบ

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "Password123"
}
```

**Response 200:** (เหมือน register)

**Errors:** 401 (email/password ผิด), 403 (บัญชีถูกปิด)

---

### `POST /auth/refresh`
รับ access token ใหม่ด้วย refresh token (Token Rotation)

**Request Body:**
```json
{ "refresh_token": "eyJ..." }
```

**Response 200:** TokenPair ใหม่ (refresh token เดิมจะถูกยกเลิก)

**Errors:** 401 (refresh token ไม่ถูกต้อง/หมดอายุ)

---

### `POST /auth/logout`
ออกจากระบบ (revoke refresh token)

**Request Body:**
```json
{ "refresh_token": "eyJ..." }
```

**Response 204** (No Content)

---

## 2. User Endpoints

### `GET /users/me` 🔒
ดูโปรไฟล์ตัวเอง

**Response 200:**
```json
{
  "id": "uuid",
  "email": "user@example.com",
  "username": "rimnam_explorer",
  "display_name": "นักสำรวจ",
  "avatar_url": "/uploads/photos/uuid/avatar.jpg",
  "language": "th",
  "is_active": true,
  "created_at": "2026-01-01T00:00:00Z",
  "last_active_at": "2026-05-30T10:00:00Z"
}
```

---

### `PATCH /users/me` 🔒
แก้ไขโปรไฟล์ (ส่งเฉพาะ field ที่ต้องการเปลี่ยน)

**Request Body:**
```json
{
  "display_name": "ชื่อใหม่",
  "language": "en"
}
```

**Response 200:** UserPublic (ข้อมูลที่อัพเดทแล้ว)

---

### `POST /users/me/avatar` 🔒
อัพโหลดรูปโปรไฟล์

**Request:** `multipart/form-data`
- `file`: ไฟล์รูป (JPEG, PNG, WebP, ขนาดสูงสุด 10 MB)

**Response 200:** UserPublic (พร้อม avatar_url ใหม่)

**Note:** รูปจะถูก resize อัตโนมัติถ้าใหญ่กว่า 2048px และแปลงเป็น JPEG

---

### `PUT /users/me/password` 🔒
เปลี่ยนรหัสผ่าน

**Request Body:**
```json
{
  "current_password": "Password123",
  "new_password": "NewPassword456"
}
```

**Response 204**

**Errors:** 400 (รหัสผ่านปัจจุบันผิด)

---

## 3. Mission Endpoints

### `GET /missions/progress` 🔒
ดูความคืบหน้าภารกิจของตัวเอง

**Response 200:**
```json
{
  "completed_place_ids": ["1", "2", "3"],
  "completed_count": 3,
  "total_places": 6,
  "is_all_done": false
}
```

**Flutter integration:** เรียก endpoint นี้หลัง login เพื่อ sync progress จาก server แทน SharedPreferences

---

### `POST /missions/complete` 🔒
บันทึกว่าทำสถานที่สำเร็จ (เรียกหลัง camera_screen.dart ถ่ายรูปสำเร็จ)

**Request Body:**
```json
{
  "place_id": "1",
  "latitude": 12.6137,
  "longitude": 102.1129,
  "photo_url": "/uploads/photos/uuid/1_abc123.jpg"
}
```

**Response 201:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "place_id": "1",
  "completed_at": "2026-05-30T10:30:00Z",
  "latitude": 12.6137,
  "longitude": 102.1129,
  "photo_url": "/uploads/photos/uuid/1_abc123.jpg"
}
```

**Errors:** 409 (ทำสถานที่นี้ไปแล้ว)

---

### `DELETE /missions/reset` 🔒
รีเซ็ต progress ทั้งหมด

**Response 204**

---

## 4. Photo Endpoints

### `POST /photos/upload` 🔒
อัพโหลดรูปภาพที่ถ่ายจากกล้อง

**Request:** `multipart/form-data`
- `file`: ไฟล์รูป (JPEG, PNG, WebP, ขนาดสูงสุด 10 MB)
- `place_id` *(optional)*: รหัสสถานที่ "1"-"6"

**Response 201:**
```json
{
  "id": "uuid",
  "user_id": "uuid",
  "place_id": "1",
  "url": "/uploads/photos/uuid/1_abc123def456.jpg",
  "original_filename": "camera_capture.jpg",
  "size_bytes": 245760,
  "created_at": "2026-05-30T10:30:00Z"
}
```

**Flutter flow:**
1. ถ่ายรูปใน `camera_screen.dart`
2. POST รูปไปที่ endpoint นี้พร้อม `place_id`
3. ได้ `url` กลับมา
4. POST `/missions/complete` พร้อม `photo_url` นั้น

---

### `GET /photos/me` 🔒
ดูรูปทั้งหมดของตัวเอง

**Response 200:**
```json
{
  "photos": [
    {
      "id": "uuid",
      "place_id": "1",
      "url": "/uploads/photos/uuid/1_abc.jpg",
      "original_filename": "photo.jpg",
      "size_bytes": 245760,
      "created_at": "2026-05-30T10:30:00Z"
    }
  ],
  "total": 1
}
```

**Use case:** หน้า share_screen.dart ดึงรูปทั้ง 6 ใบมาทำ collage

---

### `DELETE /photos/{photo_id}` 🔒
ลบรูปภาพ

**Response 204**

---

## 5. Admin Endpoints

> **ต้องเป็น Admin เท่านั้น** (is_admin = true)

### `GET /admin/stats` 🔒🔑
สถิติภาพรวมระบบ

**Response 200:**
```json
{
  "total_users": 150,
  "active_users_7d": 45,
  "active_users_30d": 89,
  "interactive_users": 72,
  "completed_all_users": 18,
  "total_photos": 432,
  "total_mission_completions": 387,
  "new_users_today": 5,
  "new_users_7d": 23
}
```

**Definitions:**
- `interactive_users`: ผู้ใช้ที่ทำภารกิจอย่างน้อย 1 สถานที่
- `completed_all_users`: ผู้ใช้ที่ทำครบ 6 สถานที่
- `active_users_7d/30d`: ผู้ใช้ที่ใช้งานแอพภายใน 7/30 วัน

---

### `GET /admin/users` 🔒🔑
รายชื่อผู้ใช้ทั้งหมด (Pagination)

**Query Params:**
- `page` (default: 1)
- `page_size` (default: 20, max: 100)
- `search` (optional): ค้นหาด้วย email หรือ username

**Response 200:**
```json
[
  {
    "id": "uuid",
    "email": "user@example.com",
    "username": "explorer",
    "display_name": "นักสำรวจ",
    "avatar_url": null,
    "language": "th",
    "is_active": true,
    "is_admin": false,
    "mission_count": 4,
    "photo_count": 4,
    "created_at": "...",
    "last_active_at": "..."
  }
]
```

---

### `GET /admin/users/{user_id}` 🔒🔑
ดูข้อมูล user คนใดคนหนึ่ง

**Response 200:** UserAdminView

---

### `PATCH /admin/users/{user_id}` 🔒🔑
แก้ไขข้อมูล user

**Request Body:**
```json
{
  "display_name": "ชื่อใหม่",
  "is_active": false,
  "is_admin": false,
  "language": "en"
}
```

**Response 200:** UserAdminView

---

### `DELETE /admin/users/{user_id}/missions` 🔒🔑
รีเซ็ต mission progress ของ user คนใดคนหนึ่ง

**Response 204**

---

## Utility

### `GET /health`
Health check (ไม่ต้อง auth)

**Response 200:**
```json
{ "status": "ok", "version": "1.0.0" }
```

---

## Error Response Format

ทุก error response จะมีรูปแบบ:
```json
{ "detail": "ข้อความอธิบาย error เป็นภาษาไทย" }
```

**HTTP Status Codes:**
| Code | ความหมาย |
|------|-----------|
| 200 | สำเร็จ |
| 201 | สร้างสำเร็จ |
| 204 | สำเร็จ (ไม่มี response body) |
| 400 | Request ไม่ถูกต้อง |
| 401 | ไม่ได้ authenticate หรือ token หมดอายุ |
| 403 | ไม่มีสิทธิ์ |
| 404 | ไม่พบข้อมูล |
| 409 | ข้อมูลซ้ำ (email/username) |
| 413 | ไฟล์ใหญ่เกิน limit |
| 415 | ประเภทไฟล์ไม่รองรับ |
| 422 | Validation error |
| 429 | ส่ง request เร็วเกินไป (Rate limit) |
| 500 | Server error |

---

## Photo Storage Architecture

```
uploads/
└── photos/
    └── {user_id}/          ← แยกตาม user
        ├── avatar.jpg      ← รูปโปรไฟล์
        ├── 1_abc123.jpg    ← รูปสถานที่ 1
        ├── 2_def456.jpg    ← รูปสถานที่ 2
        └── ...
```

**URL Pattern:** `/uploads/photos/{user_id}/{filename}`

**Image Processing (อัตโนมัติ):**
- Resize: ลด resolution ถ้าใหญ่กว่า 2048×2048 px
- Format: แปลงเป็น JPEG เสมอ
- Quality: 85% (สมดุลระหว่างขนาดและคุณภาพ)

**Production:** เปลี่ยน `STORAGE_BACKEND=s3` ใน .env เพื่อใช้ MinIO/AWS S3

---

## Flutter Integration Guide

### 1. เก็บ token ใน Flutter
```dart
// ใช้ flutter_secure_storage แทน SharedPreferences สำหรับ token
final storage = FlutterSecureStorage();
await storage.write(key: 'access_token', value: tokenPair.accessToken);
await storage.write(key: 'refresh_token', value: tokenPair.refreshToken);
```

### 2. HTTP Client พร้อม Auto-refresh
```dart
// ใช้ http interceptor ที่ refresh token อัตโนมัติเมื่อได้ 401
// แนะนำ: package dio + dio_smart_retry
```

### 3. Sync Mission Progress
```dart
// หลัง login: ดึง progress จาก server
// GET /missions/progress → อัพเดท PlacesProvider
// แทนการอ่านจาก SharedPreferences เพียงอย่างเดียว
```

### 4. Camera → Upload Flow
```dart
// camera_screen.dart (หลัง takePicture สำเร็จ)
final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/photos/upload'));
request.headers['Authorization'] = 'Bearer $token';
request.files.add(await http.MultipartFile.fromPath('file', imagePath));
request.fields['place_id'] = currentPlaceId;
final response = await request.send();
final photo = PhotoOut.fromJson(json.decode(await response.stream.bytesToString()));

// แล้ว complete mission
await api.post('/missions/complete', {
  'place_id': currentPlaceId,
  'latitude': gps.latitude,
  'longitude': gps.longitude,
  'photo_url': photo.url,
});
```

---

## Security Summary

| Feature | Implementation |
|---------|----------------|
| Password Hashing | bcrypt (cost factor 12) |
| Token Auth | JWT HS256, access 60 min, refresh 30 วัน |
| Token Rotation | Refresh token ใช้ได้ครั้งเดียว (Rotate on use) |
| Rate Limiting | slowapi (IP-based) |
| CORS | Whitelist origin จาก .env |
| File Validation | ตรวจ MIME type + ขนาดก่อน save |
| SQL Injection | SQLAlchemy ORM (parameterized queries) |
| Admin Access | is_admin flag + dependency guard |
| Inactive User | is_active=false จะ reject ทุก request |

---

## Running the Backend

### Development
```bash
cd backend
cp .env.example .env        # แก้ไข config
docker compose up db -d     # เริ่ม PostgreSQL
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Production (Docker)
```bash
docker compose up -d
```

### Database Migrations
```bash
# สร้าง migration ใหม่
alembic revision --autogenerate -m "description"

# รัน migration
alembic upgrade head
```
