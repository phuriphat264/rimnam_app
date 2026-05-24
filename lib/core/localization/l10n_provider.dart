import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_translations.dart';

final languageProvider = StateNotifierProvider<LanguageNotifier, String?>((ref) {
  return LanguageNotifier();
});

// ✅ เพิ่ม translationsProvider
final translationsProvider = Provider<Map<String, String>>((ref) {
  final lang = ref.watch(languageProvider) ?? 'th';
  return AppTranslations.strings[lang] ?? AppTranslations.strings['th']!;
});

class LanguageNotifier extends StateNotifier<String?> {
  LanguageNotifier() : super(null);

  void selectLanguage(String code) {
    if (state == code) return;
    if (!AppTranslations.strings.containsKey(code)) return;
    state = code;
  }

  bool get hasSelected => state != null;
  static List<String> get supportedLanguages => AppTranslations.strings.keys.toList();
}