import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../../core/widgets/place_icon.dart';
import '../places/places_provider.dart';
import '../places/place_model.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    final translations = ref.watch(translationsProvider);
    final completedCount = places.where((p) => p.status == PlaceStatus.done).length;
    final isAllDone = completedCount >= 6;

    return Scaffold(
      backgroundColor: AppColors.espresso,
      body: Column(
        children: [
          // ── Hero ──
          SizedBox(
            height: 236,
            child: Stack(
              fit: StackFit.expand,
              children: [
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
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x401A0804), Colors.transparent, Color(0xE61A0804)],
                      stops: [0.0, 0.38, 1.0],
                    ),
                  ),
                ),
                // ── ปุ่มย้อนกลับ ──
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.15),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 14, left: 20, right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isAllDone
                              ? AppColors.gold.withOpacity(0.3)
                              : AppColors.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: isAllDone
                                ? AppColors.gold.withOpacity(0.7)
                                : AppColors.gold.withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAllDone) ...[
                              const Icon(Icons.verified_rounded,
                                  color: AppColors.gold, size: 13),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              isAllDone
                                  ? (translations['stamp_all_done_tag'] ?? 'ครบทุกสถานที่แล้ว!')
                                  : '$completedCount / 6  ${translations['history_tag']?.replaceAll('📍 จันทบุรี · ', '') ?? 'สถานที่สำเร็จ'}',
                              style: const TextStyle(
                                fontSize: 11,
                                letterSpacing: 1,
                                color: AppColors.amber,
                                fontFamily: 'Noto Serif Thai',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        translations['profile_stamp_book'] ?? 'สมุดสะสมตราประทับ',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.4,
                          fontFamily: 'Noto Serif Thai',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Body ──
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
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pull pill
                    Center(
                      child: Container(
                        width: 36, height: 4,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.mahogany.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Section header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          translations['history_section_title']
                                  ?.replaceAll('✦ ประวัติและความเป็นมา', '')
                                  .trim()
                                  .isEmpty == true
                              ? '✦  STAMP COLLECTION'
                              : '✦  STAMP COLLECTION',
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 3,
                            color: AppColors.caramel,
                            fontFamily: 'Cormorant Garamond',
                          ),
                        ),
                        const Spacer(),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAllDone
                                ? AppColors.gold.withOpacity(0.15)
                                : AppColors.mahogany.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isAllDone
                                  ? AppColors.gold.withOpacity(0.4)
                                  : AppColors.mahogany.withOpacity(0.15),
                            ),
                          ),
                          child: Text(
                            '$completedCount / 6',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isAllDone ? AppColors.gold : AppColors.sienna,
                              fontFamily: 'Cormorant Garamond',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Stamp grid — 3 columns × 2 rows
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: places.length,
                      itemBuilder: (_, i) => _StampCell(
                        place: places[i],
                        index: i + 1,
                        translations: translations,
                      ),
                    ),

                    // Reward card — only when all 6 done
                    if (isAllDone) ...[
                      const SizedBox(height: 28),
                      _RewardCard(translations: translations),
                    ],
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

// ──────────────────────────────────────────────
// Stamp cell
Widget _stampBg(String placeId, Color iconColor) => Container(
      color: AppColors.espresso,
      child: Center(
        child: PlaceIcon(placeId: placeId, size: 38, color: iconColor),
      ),
    );

// ──────────────────────────────────────────────
class _StampCell extends StatelessWidget {
  final Place place;
  final int index;
  final Map<String, String> translations;

  const _StampCell({
    required this.place,
    required this.index,
    required this.translations,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = place.status == PlaceStatus.done;
    final isLocked = place.status == PlaceStatus.locked;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Stamp circle ──
        Expanded(
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Outer glow (done only)
                if (isDone)
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gold.withOpacity(0.25),
                          blurRadius: 14,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                  ),

                // Border ring
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDone
                          ? AppColors.gold
                          : isLocked
                              ? AppColors.mahogany.withOpacity(0.18)
                              : AppColors.caramel.withOpacity(0.45),
                      width: isDone ? 2.5 : 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: isLocked
                        ? _stampBg(place.id,
                            AppColors.mahogany.withOpacity(0.28))
                        : isDone && place.capturedPhotoPath != null
                            ? Image.file(
                                File(place.capturedPhotoPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _stampBg(place.id, AppColors.gold),
                              )
                            : _stampBg(
                                place.id,
                                isDone
                                    ? AppColors.gold
                                    : AppColors.caramel.withOpacity(0.45),
                              ),
                  ),
                ),

                // Golden overlay wash (done)
                if (isDone)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.gold.withOpacity(0.12),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ✓ badge (done)
                if (isDone)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.linen, width: 2),
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 11),
                    ),
                  ),

                // Station number badge (not done, not locked)
                if (!isDone && !isLocked)
                  Positioned(
                    right: 1,
                    bottom: 1,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppColors.caramel.withOpacity(0.85),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.linen, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cormorant Garamond',
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 6),

        // ── Name ──
        Text(
          place.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 10,
            fontFamily: 'Noto Serif Thai',
            color: isDone
                ? AppColors.espresso
                : isLocked
                    ? AppColors.mahogany.withOpacity(0.28)
                    : AppColors.sienna,
            fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
            height: 1.3,
          ),
        ),

        // ── Status label ──
        const SizedBox(height: 2),
        Text(
          isDone
              ? (translations['map_done'] ?? '✓ สำเร็จ')
              : isLocked
                  ? (translations['map_locked'] ?? '🔒 ล็อค')
                  : (translations['map_unlocked'] ?? 'รอตราประทับ'),
          style: TextStyle(
            fontSize: 9,
            fontFamily: 'Noto Serif Thai',
            fontWeight: FontWeight.bold,
            color: isDone
                ? AppColors.gold
                : isLocked
                    ? AppColors.mahogany.withOpacity(0.25)
                    : AppColors.caramel,
          ),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────
// Reward card — shown when all 6 complete
// ──────────────────────────────────────────────
class _RewardCard extends StatelessWidget {
  final Map<String, String> translations;
  const _RewardCard({required this.translations});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.espresso, AppColors.mahogany],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.55),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Seal icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gold.withOpacity(0.15),
              border: Border.all(color: AppColors.gold, width: 2),
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: AppColors.gold,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            translations['completion_title'] ?? 'ภารกิจสำเร็จ!',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.cream,
              fontFamily: 'Noto Serif Thai',
            ),
          ),
          const SizedBox(height: 6),

          Text(
            translations['completion_desc'] ?? 'สำรวจครบทั้ง 6 สถานที่แล้ว\nชุมชนริมน้ำจันทบูร',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.cream.withOpacity(0.7),
              fontFamily: 'Noto Serif Thai',
              height: 1.7,
            ),
          ),
          const SizedBox(height: 18),

          // Divider
          Container(
            height: 1,
            color: AppColors.gold.withOpacity(0.2),
          ),
          const SizedBox(height: 16),

          // Instruction
          Text(
            translations['completion_reward_at'] ?? 'รับของรางวัลที่',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              color: AppColors.amber.withOpacity(0.7),
              fontFamily: 'Cormorant Garamond',
            ),
          ),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.gold.withOpacity(0.35),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_rounded,
                    color: AppColors.gold, size: 16),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        translations['completion_reward_place'] ??
                            'ศูนย์การเรียนรู้\nชุมชนริมน้ำจันทบูร',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.amber,
                          fontFamily: 'Noto Serif Thai',
                          height: 1.4,
                        ),
                      ),
                      Text(
                        translations['completion_reward_note'] ??
                            'บ้านเลขที่ 69 — แสดงหน้าจอนี้แก่เจ้าหน้าที่',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.cream.withOpacity(0.55),
                          fontFamily: 'Noto Serif Thai',
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ──────────────────────────────────────────────
// Night City Illustration (Hero background)
// ──────────────────────────────────────────────
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

    final skyPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF040810), Color(0xFF0E1C2A)],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    final moonGlow = Paint()
      ..color = AppColors.gold.withOpacity(0.06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(Offset(w * 0.78, h * 0.16), 26, moonGlow);
    final moonPaint = Paint()
      ..color = const Color(0xFFD4C878).withOpacity(0.55);
    canvas.drawCircle(Offset(w * 0.78, h * 0.16), 8, moonPaint);

    final starPaint = Paint()..color = Colors.white.withOpacity(0.35);
    for (final s in [
      [0.06, 0.09],
      [0.16, 0.04],
      [0.25, 0.08],
      [0.37, 0.03],
    ]) {
      canvas.drawCircle(Offset(w * s[0], h * s[1]), 1, starPaint);
    }

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

      final winPaint = Paint()..color = AppColors.gold.withOpacity(0.38);
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 2; col++) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(
                w * b[0] + 4 + col * 12,
                h * b[1] + 8 + row * 14,
                7, 7,
              ),
              const Radius.circular(1),
            ),
            winPaint,
          );
        }
      }
    }

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

    final boatPaint = Paint()
      ..color = const Color(0xFF2E1A0A).withOpacity(0.85);
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
