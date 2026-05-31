# Rimnam Chanthabun — Code Guidelines

## Theme System

สีหลักทั้งหมดอยู่ใน `lib/core/theme/app_colors.dart`  
ห้ามใช้ `Colors.xxx` โดยตรง ยกเว้น `Colors.white`, `Colors.transparent`, `Colors.black`

### Color Palette (ลำดับความสว่าง มืด → สว่าง)

```
AppColors.ink        #1C1208  ← background หลัก (dark screens)
AppColors.espresso   #2E1A0A  ← background รอง / section ที่ 2
AppColors.mahogany   #5C3218  ← borders, dividers, SnackBar bg
AppColors.sienna     #8B5230  ← muted text บน dark bg
AppColors.caramel    #B87A44  ← secondary text / links
AppColors.gold       #C8942C  ← primary accent, icons
AppColors.honey      #D4A55A  ← gold lighter
AppColors.amber      #E8C878  ← labels / field hints บน dark bg
AppColors.cream      #F8F0DC  ← primary text บน dark bg
AppColors.parchment  #EDE0C0  ← secondary light text
AppColors.linen      #F5ECD8  ← light section background
```

### Dark Screen Rules (profile, map, history, camera)
- `Scaffold` bg → `AppColors.ink`
- Primary text → `Colors.white` หรือ `AppColors.cream`
- Secondary text → `AppColors.amber` หรือ `Colors.white.withOpacity(0.5)`
- Field labels (uppercase) → `AppColors.amber`
- Input fields → glass style: `Colors.white.withOpacity(0.06)` bg + `AppColors.gold.withOpacity(0.25)` border
- Input text → `Colors.white`
- Input hint → `Colors.white.withOpacity(0.3)`
- Accent / icons → `AppColors.gold`
- SnackBar → bg: `AppColors.mahogany`, text: `Colors.white` (ระบุชัด)

### Light Section Rules (ถ้าจำเป็น)
- bg → `AppColors.linen`
- Primary text → `AppColors.espresso`
- Secondary text → `AppColors.sienna`

## Font Families

- **Noto Serif Thai** → ข้อความภาษาไทยทั่วไป, body text
- **Cormorant Garamond** → ตัวเลข, headlines ภาษาอังกฤษ, ชื่อหน้า (CAPS)
- ห้ามใช้ font อื่นนอกจากนี้

## API & Backend

- Base URL อยู่ใน `dart_defines.json` (ไม่อยู่ใน git)
- ตัวอย่างใน `dart_defines.example.json`
- รันด้วย: `flutter run --dart-define-from-file=dart_defines.json`
- Android emulator → `http://10.0.2.2:8000/api/v1`
- Physical device (same WiFi) → `http://192.168.1.5:8000/api/v1`
- iOS simulator → `http://localhost:8000/api/v1`
- `ApiService` เป็น singleton — ใช้ `ApiService()` ตรงๆ ได้เลย

## State Management

- ใช้ Riverpod (`flutter_riverpod`)
- Provider naming: `xxxProvider` สำหรับ read-only, `xxxNotifier` สำหรับ StateNotifier
- ทุก API call ที่มี side effect ใส่ไว้ใน Notifier — ห้ามเรียก ApiService โดยตรงใน widget

## File Structure

```
lib/
  core/
    services/api_service.dart     ← HTTP client + JWT management
    theme/app_colors.dart         ← สีทั้งหมด
    localization/                 ← TH/EN translations
    widgets/                      ← shared widgets
  features/
    auth/                         ← login, register
    places/                       ← mission list + model
    map/                          ← map screen
    camera/                       ← camera + mission complete
    profile/                      ← profile + sub-screens
    history/                      ← stamp book / history
```

## Platform Notes

- Run command: `flutter run --dart-define-from-file=dart_defines.json`
- Backend: `cd backend && docker compose up -d`
- Backend logs: `docker compose logs -f api`
