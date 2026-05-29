import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/l10n_provider.dart';
import '../../core/theme/app_colors.dart';
import '../main/main_screen.dart';

class RulesScreen extends ConsumerWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: Column(
        children: [
          // ── Top Section (dark) ──
          Container(
            color: AppColors.espresso,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Column(
                  children: [
                    // Eyebrow
                    Text(
                      translations['rules_eyebrow'] ?? '',
                      style: const TextStyle(
                        fontSize: 9,
                        letterSpacing: 5,
                        color: AppColors.honey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Title
                    Text(
                      translations['rules_title'] ?? '',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: AppColors.amber,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Flow Steps
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FlowStep(emoji: '🗺️', label: translations['rule_step_1'] ?? '', showArrow: true),
                        _FlowStep(emoji: '📍', label: translations['rule_step_2'] ?? '', showArrow: true),
                        _FlowStep(emoji: '📷', label: translations['rule_step_3'] ?? '', showArrow: true),
                        _FlowStep(emoji: '🏅', label: translations['rule_step_4'] ?? '', showArrow: false),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),

          // ── Body Section (linen) ──
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.linen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: Column(
                  children: [
                    // Pull pill
                    Center(
                      child: Container(
                        width: 36,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 18),
                        decoration: BoxDecoration(
                          color: AppColors.mahogany.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Rule Items
                    _RuleItem(
                      number: '1',
                      text: translations['rule_1_part1'] ?? '',
                      boldText: translations['rule_1_bold'] ?? '',
                      textSuffix: translations['rule_1_part2'] ?? '',
                    ),
                    _RuleItem(
                      number: '2',
                      text: translations['rule_2_part1'] ?? '',
                      boldText: translations['rule_2_bold'] ?? '',
                      textSuffix: translations['rule_2_part2'] ?? '',
                    ),
                    _RuleItem(
                      number: '3',
                      text: translations['rule_3_part1'] ?? '',
                      boldText: translations['rule_3_bold'] ?? '',
                      textSuffix: translations['rule_3_part2'] ?? '',
                      isLast: false,
                    ),
                    _RuleItem(
                      number: '4',
                      text: translations['rule_4_part1'] ?? '',
                      boldText: translations['rule_4_bold'] ?? '',
                      textSuffix: translations['rule_4_part2'] ?? '',
                      isLast: true,
                    ),

                    const SizedBox(height: 12),

                    // Reward hint box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withOpacity(0.08),
                            AppColors.sage.withOpacity(0.06),
                          ],
                        ),
                        border: Border.all(
                          color: AppColors.gold.withOpacity(0.18),
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🏫', style: TextStyle(fontSize: 22)),
                          const SizedBox(width: 11),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 11,
                                  height: 1.75,
                                  color: AppColors.sienna,
                                ),
                                children: [
                                  TextSpan(
                                    text: translations['reward_hint_bold'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.mahogany,
                                    ),
                                  ),
                                  TextSpan(
                                    text: translations['reward_hint_text'] ?? '',
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Start Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.espresso,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.gold.withOpacity(0.35),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MainScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              translations['start_mission_btn'] ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flow Step Widget ──
class _FlowStep extends StatelessWidget {
  final String emoji;
  final String label;
  final bool showArrow;

  const _FlowStep({
    required this.emoji,
    required this.label,
    required this.showArrow,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withOpacity(0.22),
                    ),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    letterSpacing: 1,
                    height: 1.3,
                    color: AppColors.honey.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          if (showArrow)
            Text(
              '›',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.gold.withOpacity(0.3),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Rule Item Widget ──
class _RuleItem extends StatelessWidget {
  final String number;
  final String text;
  final String boldText;
  final String textSuffix;
  final bool isLast;

  const _RuleItem({
    required this.number,
    required this.text,
    required this.boldText,
    required this.textSuffix,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: AppColors.mahogany.withOpacity(0.07),
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.espresso,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.8,
                  color: AppColors.mahogany,
                ),
                children: [
                  TextSpan(text: text),
                  TextSpan(
                    text: boldText,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.espresso,
                    ),
                  ),
                  TextSpan(text: textSuffix),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}