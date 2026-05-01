import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 1. สร้าง Provider เปล่าๆ ไว้รอรับค่าจากหน้า main.dart
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize this in main.dart');
});

// 2. สร้าง Provider สำหรับเรียกใช้งาน StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(ref.watch(sharedPreferencesProvider));
});

class StorageService {
  final SharedPreferences _prefs;
  StorageService(this._prefs);

  static const String _languageKey = 'app_language';

  // ฟังก์ชัน Save & Load ภาษา
  Future<void> saveLanguage(String langCode) async => await _prefs.setString(_languageKey, langCode);
  String? loadLanguage() => _prefs.getString(_languageKey);
}