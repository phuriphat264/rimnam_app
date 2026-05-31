import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../rules/rules_screen.dart'; // เพิ่ม import
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: Column(
        children: [
          // ── Hero Section ──
          SizedBox(
            height: 236,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // City Illustration (SVG-style dark)
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF040810), Color(0xFF0E1C2A)],
                    ),
                  ),
                  child: const _NightCityIllustration(),
                ),

                // Gradient overlay bottom
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x401A0804),
                        Colors.transparent,
                        Color(0xE61A0804),
                      ],
                      stops: [0.0, 0.38, 1.0],
                    ),
                  ),
                ),


                // Bottom content
                Positioned(
                  bottom: 14,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          translations['history_tag'] ?? '',
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1,
                            color: AppColors.amber,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        translations['history_title'] ?? '',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body Section ──
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
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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

                    // Section head
                    Text(
                      translations['history_section_title'] ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        letterSpacing: 4,
                        color: AppColors.caramel,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Body text
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13,
                          height: 2,
                          color: AppColors.mahogany,
                        ),
                        children: [
                          TextSpan(
                            text: translations['history_desc_part1'] ?? '',
                          ),
                          TextSpan(
                            text: translations['history_desc_bold'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: translations['history_desc_part2'] ?? '',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Stat Row
                    Row(
                      children: [
                        _StatCard(number: '300+', label: translations['stat_years'] ?? ''),
                        const SizedBox(width: 8),
                        _StatCard(number: '6', label: translations['stat_spots'] ?? ''),
                        const SizedBox(width: 8),
                        _StatCard(number: '3', label: translations['stat_cultures'] ?? ''),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.sienna,
                          foregroundColor: AppColors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.sienna.withOpacity(0.35),
                        ),
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const RulesScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              translations['start_explore'] ?? '',
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

// ── Stat Card ──
class _StatCard extends StatelessWidget {
  final String number;
  final String label;

  const _StatCard({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mahogany.withOpacity(0.08)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              number,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.mahogany,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.caramel,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Night City Illustration (Hero) ──
class _NightCityIllustration extends StatelessWidget {
  const _NightCityIllustration();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _NightCityPainter());
  }
}

class _NightCityPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky
    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF040810), Color(0xFF0E1C2A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Moon
    final moonGlow = Paint()
      ..color = AppColors.gold.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(w * 0.78, h * 0.16), 26, moonGlow);
    final moonPaint = Paint()..color = const Color(0xFFD4C878).withOpacity(0.55);
    canvas.drawCircle(Offset(w * 0.78, h * 0.16), 8, moonPaint);

    // Stars
    final starPaint = Paint()..color = Colors.white.withOpacity(0.35);
    for (final s in [
      [0.06, 0.09],
      [0.16, 0.04],
      [0.25, 0.08],
      [0.37, 0.03],
    ]) {
      canvas.drawCircle(Offset(w * s[0], h * s[1]), 1, starPaint);
    }

    // Buildings
    final buildingColors = [
      const Color(0xFF2E1A0A),
      const Color(0xFF3A2010),
      const Color(0xFF2E1A0A),
      const Color(0xFF3A2010),
      const Color(0xFF2E1A0A),
      const Color(0xFF3A2010),
      const Color(0xFF2E1A0A),
    ];
    final buildings = [
      [0.0, 0.24, 0.115, 0.5],
      [0.128, 0.29, 0.095, 0.45],
      [0.236, 0.20, 0.155, 0.55],
      [0.405, 0.26, 0.108, 0.48],
      [0.527, 0.22, 0.142, 0.52],
      [0.682, 0.28, 0.108, 0.46],
      [0.804, 0.24, 0.196, 0.5],
    ];

    for (int i = 0; i < buildings.length; i++) {
      final b = buildings[i];
      final paint = Paint()..color = buildingColors[i % buildingColors.length];
      final rect = RRect.fromRectAndCorners(
        Rect.fromLTWH(w * b[0], h * b[1], w * b[2], h * b[3]),
        topLeft: const Radius.circular(3),
        topRight: const Radius.circular(3),
      );
      canvas.drawRRect(rect, paint);

      // Windows
      final winPaint = Paint()..color = AppColors.gold.withOpacity(0.38);
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 2; col++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                w * b[0] + 4 + col * 12,
                h * b[1] + 8 + row * 14,
                7,
                7,
              ),
              const Radius.circular(1),
            ),
            winPaint,
          );
        }
      }
    }

    // River
    final riverPaint = Paint()..color = const Color(0xFF0A1620);
    canvas.drawRect(Rect.fromLTWH(0, h * 0.72, w, h * 0.28), riverPaint);

    final wavePath = Path()
      ..moveTo(0, h * 0.73)
      ..quadraticBezierTo(w * 0.25, h * 0.70, w * 0.5, h * 0.73)
      ..quadraticBezierTo(w * 0.75, h * 0.76, w, h * 0.73)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final wavePaint = Paint()
      ..color = const Color(0xFF112030).withOpacity(0.8);
    canvas.drawPath(wavePath, wavePaint);

    // Boat
    final boatPaint = Paint()..color = const Color(0xFF2E1A0A).withOpacity(0.85);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.64, h * 0.75), width: 64, height: 11),
      boatPaint,
    );
    final mastPaint = Paint()
      ..color = const Color(0xFF1A0E04)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(w * 0.64, h * 0.725),
      Offset(w * 0.64, h * 0.60),
      mastPaint,
    );
    final sailPaint = Paint()..color = AppColors.gold.withOpacity(0.48);
    final sailPath = Path()
      ..moveTo(w * 0.64, h * 0.60)
      ..lineTo(w * 0.71, h * 0.66)
      ..lineTo(w * 0.64, h * 0.68)
      ..close();
    canvas.drawPath(sailPath, sailPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}