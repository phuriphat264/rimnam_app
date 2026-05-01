import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/language/language_provider.dart';
import 'app_translations.dart';

// Extension เพื่อให้เรียกใช้งานได้สั้นๆ เช่น l10n('login_title')
typedef L10nFunction = String Function(String key);

final l10nProvider = Provider<L10nFunction>((ref) {
  // ติดตามสถานะภาษา ถ้าไม่มีค่าเริ่มต้นให้เป็น 'th'
  final currentLang = ref.watch(languageProvider) ?? 'th';
  
  // ดึงชุดข้อความตามภาษา
  final dictionary = AppTranslations.strings[currentLang] ?? AppTranslations.strings['th']!;

  // Return ฟังก์ชันสำหรับดึงข้อความออกไปใช้งาน
  return (String key) {
    return dictionary[key] ?? key; // ถ้าหาคีย์ไม่เจอ ให้ return ชื่อคีย์ออกไปเลย (ช่วยเตือนนักพัฒนา)
  };
});