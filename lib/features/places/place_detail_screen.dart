import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../places/places_provider.dart';
import '../camera/camera_screen.dart';
import '../places/place_model.dart';
import '../map/map_provider.dart';
import '../../core/widgets/fullscreen_image_viewer.dart';

// ============================================================
// Renders longDescription with emoji section headers bolded
// and bullet labels (text before first colon) bolded.
// ============================================================
bool _isHeaderLine(String line) {
  if (line.isEmpty) return false;
  // Section headers start with a common emoji character (code point > 0x1F000)
  final first = line.runes.first;
  return first > 0x1F000 || line.startsWith('✦') || line.startsWith('🏛');
}

Widget _buildLongDescription(String text) {
  const bodyColor = AppColors.mahogany;
  const bodyStyle = TextStyle(
    fontFamily: 'Noto Serif Thai',
    fontSize: 14,
    height: 1.8,
    color: bodyColor,
  );

  final lines = text.trim().split('\n');
  final widgets = <Widget>[];

  for (final raw in lines) {
    final line = raw.trim();

    if (line.isEmpty) {
      widgets.add(const SizedBox(height: 8));
      continue;
    }

    // Section header (emoji prefix)
    if (_isHeaderLine(line)) {
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 4),
        child: Text(
          line,
          style: bodyStyle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.mahogany,
            height: 1.5,
          ),
        ),
      ));
      continue;
    }

    // Bullet point
    if (line.startsWith('•')) {
      final content = line.substring(1).trim();
      final colonIdx = content.indexOf(':');
      // Bold the label before the first colon (e.g. "จุดเริ่มต้น:")
      final hasLabel = colonIdx > 0 && colonIdx <= 50;

      widgets.add(Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• ', style: bodyStyle.copyWith(fontWeight: FontWeight.bold)),
            Expanded(
              child: hasLabel
                  ? Text.rich(
                      TextSpan(
                        style: bodyStyle,
                        children: [
                          TextSpan(
                            text: content.substring(0, colonIdx + 1),
                            style: bodyStyle.copyWith(
                                fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: content.substring(colonIdx + 1)),
                        ],
                      ),
                    )
                  : Text(content, style: bodyStyle),
            ),
          ],
        ),
      ));
      continue;
    }

    widgets.add(Text(line, style: bodyStyle));
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: widgets,
  );
}

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
          // HERO SECTION - รูปภาพด้านบน (แตะเพื่อดูแกลเลอรีเต็มจอ)
          // GestureDetector ครอบนอกสุด เพื่อให้ชนะ hit test เหนือ gradient layer
          // ==========================================
          GestureDetector(
            onTap: () {
              final gallery = place.galleryImages.isNotEmpty
                  ? place.galleryImages
                  : [place.imageUrl];
              final imgs = place.capturedPhotoPath != null
                  ? [place.capturedPhotoPath!, ...gallery]
                  : gallery;
              FullScreenImageViewer.show(context, imgs);
            },
            child: SizedBox(
              height: 280,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // รูปภาพ
                  Image.asset(
                    place.imageUrl.isNotEmpty
                        ? place.imageUrl
                        : 'assets/images/1.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.mahogany,
                        child: const Center(
                          child: Icon(Icons.image_not_supported,
                              color: Colors.white),
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

                  // Gallery badge — จำนวนรูปทั้งหมด (วางเหนือข้อความชื่อสถานที่)
                  if (place.galleryImages.length > 1)
                    Positioned(
                      right: 14,
                      bottom: 100,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.photo_library,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${place.galleryImages.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontFamily: 'Cormorant Garamond',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      border: Border.all(
                                          color:
                                              Colors.white.withOpacity(0.1)),
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
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  (translations['spot_progress'] ??
                                          'SPOT · {index} OF {total}')
                                      .replaceAll('{index}',
                                          index.toString().padLeft(2, '0'))
                                      .replaceAll('{total}',
                                          totalPlaces.toString().padLeft(2, '0')),
                                  style: TextStyle(
                                    fontFamily: 'Cormorant Garamond',
                                    fontSize: 9,
                                    letterSpacing: 3,
                                    color: AppColors.amber.withOpacity(0.7),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(22),
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withOpacity(0.22),
                                        border: Border.all(
                                            color: AppColors.gold
                                                .withOpacity(0.42)),
                                        borderRadius:
                                            BorderRadius.circular(22),
                                      ),
                                      child: Text(
                                        (translations['mission_progress'] ??
                                                'MISSION {index} / {total}')
                                            .replaceAll('{index}', '$index')
                                            .replaceAll(
                                                '{total}', '$totalPlaces'),
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
                          translations['place_${place.id}_loc'] ??
                              place.location,
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
                  _buildLongDescription(
                    translations['place_${place.id}_long_desc'] ??
                        place.longDescription,
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
                          final gallery = place.galleryImages.isNotEmpty
                              ? place.galleryImages
                              : [place.imageUrl];
                          final imgs = place.capturedPhotoPath != null
                              ? [place.capturedPhotoPath!, ...gallery]
                              : gallery;
                          FullScreenImageViewer.show(context, imgs);
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
                        if (dist != null && dist > maxDistanceForStation(place.id)) {
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
                                  isDone
                                      ? Icons.photo_library
                                      : Icons.camera_alt,
                                  color: AppColors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  isDone
                                      ? (translations['mission_view_photos'] ??
                                          'ดูรูปภาพสถานที่')
                                      : (translations['take_photo'] ??
                                          'ถ่ายภาพ ณ สถานที่นี้'),
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