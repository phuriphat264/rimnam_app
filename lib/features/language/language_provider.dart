import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_translations.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, String?>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String?> {
  LanguageNotifier() : super(null); // null = ยังไม่ได้เลือก

  void selectLanguage(String code) {
    if (state == code) return;
    if (!AppTranslations.strings.containsKey(code)) return;
    state = code;
  }

  bool get hasSelected => state != null;

  // ภาษาที่รองรับ
  static List<String> get supportedLanguages => AppTranslations.strings.keys.toList();
}