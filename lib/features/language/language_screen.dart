import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../core/theme/app_colors.dart';
import '../../core/localization/app_translations.dart';
import 'language_provider.dart';
import '../auth/auth_screen.dart';

class LanguageScreenPremium extends ConsumerWidget {
  const LanguageScreenPremium({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedLang = ref.watch(languageProvider);
    final currentLang = selectedLang ?? 'en';
    final translations = AppTranslations.strings[currentLang] ?? AppTranslations.strings['en']!;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            // City Illustration at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: _CityIllustration(),
            ),
            
            // Main content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // App Title & Subtitle
                    Text(
                      translations['app_name']!,
                      style: const TextStyle(
                        fontSize: 32,
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      translations['app_subtitle']!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.mahogany,
                        letterSpacing: 3.0,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Divider with diamond
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Transform.rotate(
                            angle: 0.785, // 45 degrees
                            child: Container(
                              width: 6,
                              height: 6,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
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
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mahogany,
                        letterSpacing: 2.0,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    // Language Selectors (with Glassmorphism)
                    _LanguageOptionPremium(
                      title: 'ภาษาไทย',
                      subtitle: 'THAI',
                      code: 'th',
                      countryCode: 'TH',
                      isSelected: selectedLang == 'th',
                      delay: 200,
                    ),
                    const SizedBox(height: 12),
                    _LanguageOptionPremium(
                      title: '中文',
                      subtitle: 'CHINESE',
                      code: 'zh',
                      countryCode: 'CN',
                      isSelected: selectedLang == 'zh',
                      delay: 400,
                    ),
                    const SizedBox(height: 12),
                    _LanguageOptionPremium(
                      title: 'English',
                      subtitle: 'ENGLISH',
                      code: 'en',
                      countryCode: 'GB',
                      isSelected: selectedLang == 'en',
                      delay: 600,
                    ),

                    const Spacer(),

                    // Action Button
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: selectedLang != null ? 1.0 : 0.5,
                      child: IgnorePointer(
                        ignoring: selectedLang == null,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.gold,
                            foregroundColor: AppColors.ink,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: AppColors.gold.withOpacity(0.5),
                          ),
                          onPressed: selectedLang != null
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const AuthScreen(),
                                    ),
                                  );
                                }
                              : null,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                translations['continue_btn']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
        onTap: () {
          ref.read(languageProvider.notifier).selectLanguage(code);
        },
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
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
                      decoration: BoxDecoration(
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
                        color: Colors.transparent,
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

// City Illustration Widget
class _CityIllustration extends StatelessWidget {
  const _CityIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.espresso.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mahogany.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Night sky
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.espresso.withOpacity(0.8),
                  AppColors.mahogany.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Stars
          Positioned(
            top: 16,
            left: 30,
            child: _Star(size: 2),
          ),
          Positioned(
            top: 24,
            left: 70,
            child: _Star(size: 1.5),
          ),
          Positioned(
            top: 20,
            right: 40,
            child: _Star(size: 2),
          ),
          Positioned(
            top: 32,
            right: 80,
            child: _Star(size: 1),
          ),

          // Buildings
          Positioned(
            bottom: 30,
            left: 20,
            child: _Building(
              width: 35,
              height: 60,
              windows: 4,
              color: AppColors.mahogany.withOpacity(0.8),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 60,
            child: _Building(
              width: 32,
              height: 70,
              windows: 6,
              color: AppColors.mahogany,
            ),
          ),
          Positioned(
            bottom: 20,
            left: 98,
            child: _Building(
              width: 35,
              height: 75,
              windows: 6,
              color: AppColors.mahogany.withOpacity(0.9),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 138,
            child: _Building(
              width: 32,
              height: 85,
              windows: 8,
              color: AppColors.mahogany.withOpacity(0.85),
            ),
          ),
          Positioned(
            bottom: 25,
            left: 175,
            child: _Building(
              width: 35,
              height: 70,
              windows: 6,
              color: AppColors.mahogany.withOpacity(0.8),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 215,
            child: _Building(
              width: 32,
              height: 60,
              windows: 4,
              color: AppColors.mahogany,
            ),
          ),

          // Moon
          Positioned(
            top: 16,
            right: 20,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.espresso,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.honey,
                  width: 1.5,
                ),
              ),
            ),
          ),

          // River/Water at bottom
          Container(
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.teal.withOpacity(0.7),
                  AppColors.teal.withOpacity(0.5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Building extends StatelessWidget {
  final double width;
  final double height;
  final int windows;
  final Color color;

  const _Building({
    required this.width,
    required this.height,
    required this.windows,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                windows,
                (index) => Container(
                  decoration: BoxDecoration(
                    color: AppColors.honey.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Star extends StatelessWidget {
  final double size;

  const _Star({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.amber,
        shape: BoxShape.circle,
      ),
    );
  }
}