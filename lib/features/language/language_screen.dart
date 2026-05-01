import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import 'language_provider.dart';
import '../auth/auth_screen.dart'; // Uncomment เมื่อสร้างไฟล์ auth เสร็จ

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLang = ref.watch(languageProvider);
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo Animation Area
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: Column(
                  children: [
                    const Icon(Icons.auto_awesome, color: AppColors.gold, size: 80),
                    const SizedBox(height: 24),
                    Text(
                      l10n('app_name'),
                      style: const TextStyle(
                        fontSize: 32, 
                        color: AppColors.gold, 
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n('app_subtitle'),
                      style: const TextStyle(
                        fontSize: 14, 
                        color: AppColors.cream, 
                        letterSpacing: 4.0
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Language Selectors
              _LanguageOption(
                title: 'ภาษาไทย', 
                code: 'th', 
                isSelected: selectedLang == 'th', 
                delay: 200
              ),
              const SizedBox(height: 16),
              _LanguageOption(
                title: 'English', 
                code: 'en', 
                isSelected: selectedLang == 'en', 
                delay: 400
              ),
              
              const SizedBox(height: 80),
              
              // Action Button
              AnimatedOpacity(
                duration: const Duration(milliseconds: 500),
                opacity: selectedLang != null ? 1.0 : 0.0,
                child: IgnorePointer(
                  ignoring: selectedLang == null,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.ink,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 8,
                      shadowColor: AppColors.gold.withOpacity(0.4),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context, 
                        MaterialPageRoute(builder: (context) => const AuthScreen()),
                      );
                    },
                    child: Text(
                      l10n('continue_btn'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends ConsumerWidget {
  final String title;
  final String code;
  final bool isSelected;
  final int delay;

  const _LanguageOption({
    required this.title, 
    required this.code, 
    required this.isSelected,
    required this.delay
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          ref.read(languageProvider.notifier).selectLanguage(code);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold.withOpacity(0.15) : AppColors.espresso.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.gold : AppColors.mahogany,
              width: 1.5
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.gold : AppColors.cream,
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle, color: AppColors.gold),
            ],
          ),
        ),
      ),
    );
  }
}