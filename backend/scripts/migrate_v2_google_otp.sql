-- Migration v2: Add Google OAuth support + password reset tokens
-- รันครั้งเดียวบน DB ที่มีอยู่แล้ว
-- ถ้า DB ยังว่างอยู่ ไม่ต้องรัน (create_all จัดการให้อัตโนมัติ)

-- เพิ่ม google_id (nullable) ใน users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(255);
CREATE UNIQUE INDEX IF NOT EXISTS ix_users_google_id ON users(google_id) WHERE google_id IS NOT NULL;

-- ทำให้ password_hash เป็น nullable (สำหรับผู้ใช้ Google OAuth)
ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;

-- ตาราง password_reset_tokens จะถูกสร้างอัตโนมัติโดย SQLAlchemy create_all
-- เมื่อ restart backend
