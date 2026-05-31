import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../places/places_provider.dart';
import '../camera/camera_screen.dart';
import '../places/place_model.dart';
import '../map/map_provider.dart';
class PlaceDetailScreen extends ConsumerWidget {
  final Place place;
  final int index;

  const PlaceDetailScreen({
    super.key,
    required this.place,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    final translations = ref.watch(translationsProvider);
    final totalPlaces = places.length;
    final isDone = place.status == PlaceStatus.done;

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD8),
      body: Column(
        children: [
          // ==========================================
          // HERO SECTION - รูปภาพด้านบน
          // ==========================================
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // รูปภาพเฉพาะของแต่ละสถานที่
                Image.asset(
                  place.imageUrl.isNotEmpty ? place.imageUrl : 'assets/images/1.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppColors.mahogany,
                      child: const Center(
                        child: Icon(Icons.image_not_supported, color: Colors.white),
                      ),
                    );
                  },
                ),

                // Gradient ทับรูปให้ข้อความอ่านง่าย
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.5),
                        Colors.transparent,
                        const Color(0xFF0A0602).withOpacity(0.85),
                      ],
                      stops: const [0.0, 0.4, 1.0],
                    ),
                  ),
                ),

                // ==========================================
                // TOP BAR - ปุ่มกลับ + ข้อมูลภารกิจ
                // ==========================================
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(22),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.arrow_back_ios_new,
                                          color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        translations['back_btn'] ?? 'กลับ',
                                        style: const TextStyle(
                                          fontFamily: 'Noto Serif Thai',
                                          fontSize: 12,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.22),
                                  border: Border.all(
                                      color: AppColors.gold.withOpacity(0.42)),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  (translations['mission_progress'] ?? 'MISSION {index} / {total}').replaceAll('{index}', '$index').replaceAll('{total}', '$totalPlaces'),
                                  style: const TextStyle(
                                    fontFamily: 'Cormorant Garamond',
                                    fontSize: 10,
                                    letterSpacing: 2,
                                    color: AppColors.amber,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ==========================================
                // PLACE NAME - ด้านล่างของรูป
                // ==========================================
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // ใช้ Double Quote ครอบรอบนอก เพื่อไม่ให้ชนกับ Single Quote ด้านใน
                        (translations['spot_progress'] ?? 'SPOT · {index} OF {total}').replaceAll('{index}', index.toString().padLeft(2, '0')).replaceAll('{total}', totalPlaces.toString().padLeft(2, '0')),
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 11,
                          letterSpacing: 4,
                          color: AppColors.amber.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        translations['place_${place.id}_name'] ?? place.name,
                        style: const TextStyle(
                          fontFamily: 'Noto Serif Thai',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        translations['place_${place.id}_loc'] ?? place.location,
                        style: TextStyle(
                          fontFamily: 'Noto Serif Thai',
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==========================================
          // CONTENT SECTION - เนื้อหาด้านล่าง
          // ==========================================
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ======== คำอธิบายสถานที่ ========
                  Text(
                    translations['place_${place.id}_long_desc'] ?? place.longDescription,
                    style: TextStyle(
                      fontFamily: 'Noto Serif Thai',
                      fontSize: 14,
                      height: 1.8,
                      color: AppColors.mahogany.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ======== ประวัติศาสตร์ ========
                  if (place.historicalBackground.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.mahogany,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              translations['history'] ?? 'ประวัติศาสตร์',
                              style: const TextStyle(
                                fontFamily: 'Noto Serif Thai',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.mahogany,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.mahogany.withOpacity(0.06),
                            border: Border(
                              left: BorderSide(
                              color: AppColors.mahogany.withOpacity(0.3),
                              width: 4,
                            ),
                            ),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            translations['place_${place.id}_history'] ?? place.historicalBackground,
                            style: TextStyle(
                              fontFamily: 'Noto Serif Thai',
                              fontSize: 13,
                              height: 1.7,
                              color: AppColors.mahogany.withOpacity(0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),

                  // ======== กล่องคำใบ้ ========
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withOpacity(0.08),
                          AppColors.gold.withOpacity(0.03),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📸', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translations['mission_hint'] ?? 'คำใบ้ภารกิจ',
                                style: TextStyle(
                                  fontFamily: 'Noto Serif Thai',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mahogany.withOpacity(0.85),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDone
                                    ? (translations['mission_completed'] ?? 'คุณทำภารกิจจุดนี้สำเร็จแล้ว ยอดเยี่ยมมาก! 🎉')
                                    : (translations['place_${place.id}_hint'] ?? place.hint),
                                style: const TextStyle(
                                  fontFamily: 'Noto Serif Thai',
                                  fontSize: 13,
                                  height: 1.6,
                                  color: AppColors.sienna,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ======== Progress Dots ========
                  Row(
                    children: [
                      ...List.generate(totalPlaces, (i) {
                        bool isCur = i == (index - 1);
                        bool isCompleted = i < (index - 1);
                        return Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: isCur ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.sage
                                : (isCur
                                    ? AppColors.gold
                                    : AppColors.mahogany.withOpacity(0.15)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                      const Spacer(),
                      Text(
                        (translations['place_progress'] ?? 'สถานที่ {index} / {total}').replaceAll('{index}', '$index').replaceAll('{total}', '$totalPlaces'),
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 11,
                          letterSpacing: 2,
                          color: AppColors.caramel.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ======== ปุ่มถ่ายภาพ ========
                  SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1C0E04), Color(0xFF4A2010)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          splashColor: AppColors.amber.withOpacity(0.15),
                          highlightColor: AppColors.amber.withOpacity(0.08),
                          onTap: () async {
                        if (isDone) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.amber, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      translations['place_completed'] ?? 'คุณทำภารกิจสถานที่นี้เสร็จแล้ว 🎉',
                                      style: const TextStyle(
                                        fontFamily: 'Noto Serif Thai',
                                        color: AppColors.cream,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.espresso,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: AppColors.gold.withOpacity(0.4),
                                ),
                              ),
                              behavior: SnackBarBehavior.floating,
                              margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                              elevation: 8,
                            ),
                          );
                          return;
                        }

                        // ===== ตรวจสอบ GPS ก่อนเปิดกล้อง =====
                        final locationAsync = ref.read(userLocationProvider);
                        final userPos = locationAsync.valueOrNull;

                        if (userPos == null) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.location_off_rounded,
                                      color: AppColors.amber, size: 18),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      translations['gps_required_photo'] ??
                                          'กรุณาเปิด GPS ก่อนถ่ายรูปยืนยันภารกิจ',
                                      style: const TextStyle(
                                        fontFamily: 'Noto Serif Thai',
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppColors.mahogany,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin:
                                  const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            ),
                          );
                          return;
                        }

                        final dist = distanceToStation(userPos, place.id);
                        if (dist != null && dist > 50) {
                            // อยู่ไกลเกิน 50 เมตร — แสดง dialog เตือน (ตรงกับ camera_screen)
                            if (!context.mounted) return;
                            final goAnyway = await showDialog<bool>(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.65),
                              builder: (ctx) => Dialog(
                                backgroundColor: Colors.transparent,
                                insetPadding: const EdgeInsets.symmetric(horizontal: 32),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                                    child: Container(
                                      padding: const EdgeInsets.all(28),
                                      decoration: BoxDecoration(
                                        color: AppColors.espresso.withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(
                                          color: AppColors.gold.withOpacity(0.35),
                                          width: 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            width: 56,
                                            height: 56,
                                            decoration: BoxDecoration(
                                              color: AppColors.mahogany.withOpacity(0.15),
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.mahogany.withOpacity(0.5),
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.location_off_rounded,
                                              color: AppColors.mahogany,
                                              size: 26,
                                            ),
                                          ),
                                          const SizedBox(height: 18),
                                          Text(
                                            translations['gps_too_far_title'] ?? 'ยังอยู่ไกลเกินไป',
                                            style: const TextStyle(
                                              color: AppColors.gold,
                                              fontFamily: 'Noto Serif Thai',
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Text(
                                            (translations['gps_too_far_body'] ??
                                                    'คุณอยู่ห่างจากสถานที่นี้ประมาณ {distance}\n\nกรุณาเดินทางไปยังสถานที่ก่อนถ่ายภาพ')
                                                .replaceAll('{distance}', formatDistance(dist)),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: AppColors.cream.withOpacity(0.8),
                                              fontFamily: 'Noto Serif Thai',
                                              fontSize: 13,
                                              height: 1.7,
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          GestureDetector(
                                            onTap: () => Navigator.pop(ctx, false),
                                            child: Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(vertical: 14),
                                              decoration: BoxDecoration(
                                                color: AppColors.gold.withOpacity(0.12),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: AppColors.gold.withOpacity(0.45),
                                                ),
                                              ),
                                              child: Text(
                                                translations['gps_back_to_map'] ?? 'กลับไปดูแผนที่',
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(
                                                  color: AppColors.gold,
                                                  fontFamily: 'Noto Serif Thai',
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
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
                            if (goAnyway != true) return;
                          }
                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraScreen(placeId: place.id),
                          ),
                        );
                      },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isDone ? Icons.check_circle : Icons.camera_alt,
                                  color: AppColors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isDone ? (translations['mission_done'] ?? 'ภารกิจเสร็จสิ้น') : (translations['take_photo'] ?? 'ถ่ายภาพ ณ สถานที่นี้'),
                                  style: const TextStyle(
                                    color: AppColors.amber,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Noto Serif Thai',
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}