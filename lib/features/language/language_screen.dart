import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_translations.dart';
import '../../core/localization/l10n_provider.dart';
import '../auth/auth_screen.dart';

class LanguageScreenPremium extends ConsumerWidget {
  const LanguageScreenPremium({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLang = ref.watch(languageProvider);
    final currentLang = selectedLang ?? 'en';
    final translations = AppTranslations.strings[currentLang] ?? AppTranslations.strings['en']!;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final illustrationHeight = screenHeight * 0.18;
    final verticalPadding = screenHeight * 0.03;
    final titleFontSize = screenWidth * 0.08;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: verticalPadding),

                // City Illustration
                SizedBox(
                  height: illustrationHeight.clamp(100.0, 180.0),
                  child: const _CityIllustration(),
                ),

                SizedBox(height: verticalPadding),

                // App Title
                Text(
                  translations['app_name']!,
                  style: TextStyle(
                    fontSize: titleFontSize.clamp(24.0, 36.0),
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 4.0 : 8.0),
                Text(
                  translations['app_subtitle']!,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11.0 : 13.0,
                    color: AppColors.mahogany,
                    letterSpacing: 3.0,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Divider
                Padding(
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 12.0 : 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.rotate(
                        angle: 0.785,
                        child: Container(width: 6, height: 6, color: AppColors.gold),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),

                // Language Label
                Text(
                  'เลือกภาษา  LANGUAGE',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11.0 : 12.0,
                    color: AppColors.mahogany,
                    letterSpacing: 2.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isSmallScreen ? 12.0 : 20.0),

                // Language Options
                _LanguageOptionPremium(
                  title: 'ภาษาไทย',
                  subtitle: 'THAI',
                  code: 'th',
                  countryCode: 'TH',
                  isSelected: selectedLang == 'th',
                  delay: 200,
                ),
                SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                _LanguageOptionPremium(
                  title: '中文',
                  subtitle: 'CHINESE',
                  code: 'zh',
                  countryCode: 'CN',
                  isSelected: selectedLang == 'zh',
                  delay: 400,
                ),
                SizedBox(height: isSmallScreen ? 8.0 : 12.0),
                _LanguageOptionPremium(
                  title: 'English',
                  subtitle: 'ENGLISH',
                  code: 'en',
                  countryCode: 'GB',
                  isSelected: selectedLang == 'en',
                  delay: 600,
                ),

                SizedBox(height: isSmallScreen ? 16.0 : 24.0),

                // Button
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 500),
                  opacity: selectedLang != null ? 1.0 : 0.5,
                  child: IgnorePointer(
                    ignoring: selectedLang == null,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.ink,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 12.0 : 16.0,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.gold.withOpacity(0.5),
                      ),
                      onPressed: selectedLang != null
                          ? () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AuthScreen(),
                                ),
                              )
                          : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            translations['continue_btn']!,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14.0 : 16.0,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward,
                            size: isSmallScreen ? 16.0 : 18.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 16.0 : 32.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Language Option Widget
// ============================================================
class _LanguageOptionPremium extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String code;
  final String countryCode;
  final bool isSelected;
  final int delay;

  const _LanguageOptionPremium({
    required this.title,
    required this.subtitle,
    required this.code,
    required this.countryCode,
    required this.isSelected,
    required this.delay,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: GestureDetector(
        onTap: () => ref.read(languageProvider.notifier).selectLanguage(code),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.gold.withOpacity(0.15)
                    : AppColors.glassBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? AppColors.gold.withOpacity(0.6)
                      : AppColors.glassBorder,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Country Code Badge
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gold.withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? AppColors.gold : AppColors.mahogany,
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        countryCode,
                        style: TextStyle(
                          color: isSelected ? AppColors.gold : AppColors.mahogany,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Language Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: isSelected ? AppColors.gold : AppColors.cream,
                            fontSize: 16,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: AppColors.mahogany.withOpacity(0.7),
                            fontSize: 11,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Selection Indicator
                  if (isSelected)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: AppColors.ink,
                        size: 14,
                      ),
                    )
                  else
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.mahogany.withOpacity(0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// City Illustration Widget
// ============================================================
class _CityIllustration extends StatelessWidget {
  const _CityIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mahogany.withOpacity(0.3),
          width: 1,
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/7.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}