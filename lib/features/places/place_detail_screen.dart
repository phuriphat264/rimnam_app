import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../places/places_provider.dart';
import '../camera/camera_screen.dart';
import '../places/place_model.dart';
import '../map/map_provider.dart';
class PlaceDetailScreen extends ConsumerStatefulWidget {
  final Place place;
  final int index;

  const PlaceDetailScreen({
    super.key,
    required this.place,
    required this.index,
  });

  @override
  ConsumerState<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends ConsumerState<PlaceDetailScreen> {
  int _currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final place = widget.place;
    final index = widget.index;
    final places = ref.watch(placesProvider);
    final translations = ref.watch(translationsProvider);
    final totalPlaces = places.length;
    final isDone = place.status == PlaceStatus.done;

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD8),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // ==========================================
          // ELASTIC HEADER (SliverAppBar)
          // ==========================================
          SliverAppBar(
            stretch: true,
            pinned: true,
            expandedHeight: 350,
            backgroundColor: AppColors.ink,
            elevation: 0,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            // TOP BAR - ปุ่มกลับ + ข้อมูลภารกิจ (ปักหมุดไว้ด้านบนเสมอ)
            title: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          (translations['mission_progress'] ?? 'MISSION {index} / {total}')
                              .replaceAll('{index}', '$index')
                              .replaceAll('{total}', '$totalPlaces'),
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
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // รูปภาพแกลเลอรีแบบเลื่อนได้
                  PageView.builder(
                    itemCount: place.galleryImages.isNotEmpty
                        ? place.galleryImages.length
                        : 1,
                    onPageChanged: (idx) {
                      setState(() {
                        _currentImageIndex = idx;
                      });
                    },
                    itemBuilder: (context, idx) {
                      final imgUrl = place.galleryImages.isNotEmpty
                          ? place.galleryImages[idx]
                          : (place.imageUrl.isNotEmpty
                              ? place.imageUrl
                              : 'https://images.unsplash.com/photo-1548013146-72479768bbaa?q=80&w=800&auto=format&fit=crop');
                      return imgUrl.startsWith('http')
                          ? Image.network(
                              imgUrl,
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
                            )
                          : Image.asset(
                              imgUrl,
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
                            );
                    },
                  ),

                  // Gradient ทับรูปให้ข้อความอ่านง่าย
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                            const Color(0xFF0A0602).withOpacity(0.9),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // PLACE NAME - ด้านล่างของรูป
                  Positioned(
                    bottom: 24,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (translations['spot_progress'] ?? 'SPOT · {index} OF {total}')
                              .replaceAll('{index}', index.toString().padLeft(2, '0'))
                              .replaceAll('{total}', totalPlaces.toString().padLeft(2, '0')),
                          style: TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 10,
                            letterSpacing: 4,
                            color: AppColors.amber.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
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
                                  blurRadius: 6,
                                  offset: Offset(0, 3))
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          translations['place_${place.id}_loc'] ?? place.location,
                          style: TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        if (place.galleryImages.length > 1) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: List.generate(
                              place.galleryImages.length,
                              (idx) => Container(
                                margin: const EdgeInsets.only(right: 6),
                                width: _currentImageIndex == idx ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: _currentImageIndex == idx
                                      ? AppColors.amber
                                      : Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                        ],
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
          SliverToBoxAdapter(
            child: Padding(
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
                        Text(
                          translations['history'] ?? 'ประวัติศาสตร์',
                          style: const TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.mahogany,
                          ),
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
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mahogany.withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isDone
                                    ? (translations['mission_completed'] ?? 'คุณทำภารกิจจุดนี้สำเร็จแล้ว ยอดเยี่ยมมาก! 🎉')
                                    : (translations['place_${place.id}_hint'] ?? place.hint),
                                style: const TextStyle(
                                  fontFamily: 'Noto Serif Thai',
                                  fontSize: 12,
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
                        (translations['place_progress'] ?? 'สถานที่ {index} / {total}')
                            .replaceAll('{index}', '$index')
                            .replaceAll('{total}', '$totalPlaces'),
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
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () async {
                        if (isDone) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(translations['place_completed'] ?? 'คุณทำภารกิจสถานที่นี้เสร็จแล้ว 🎉'),
                              backgroundColor: AppColors.sage,
                            ),
                          );
                          return;
                        }

                        // ===== ตรวจสอบระยะห่าง GPS ก่อนเปิดกล้อง =====
                        final locationAsync = ref.read(userLocationProvider);
                        final userPos = locationAsync.valueOrNull;

                        if (userPos != null) {
                          final dist = distanceToStation(userPos, place.id);
                          if (dist != null && dist > 200) {
                            if (!context.mounted) return;
                            final goAnyway = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.espresso,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
                                ),
                                title: Text(
                                  translations['dialog_too_far_title'] ?? 'ยังอยู่ไกลเกินไป',
                                  style: const TextStyle(
                                    color: AppColors.gold,
                                    fontFamily: 'Noto Serif Thai',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: Text(
                                  '${translations['dialog_too_far_dist_prefix'] ?? 'คุณอยู่ห่างจากสถานที่นี้ประมาณ '}${formatDistance(dist)}${translations['dialog_too_far_dist_suffix'] ?? '\n\nกรุณาเดินทางไปยังสถานที่ก่อนถ่ายภาพ เพื่อให้ภารกิจถูกต้อง'}',
                                  style: const TextStyle(
                                    color: AppColors.cream,
                                    fontFamily: 'Noto Serif Thai',
                                    height: 1.6,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: Text(
                                      translations['dialog_back_to_map'] ?? 'กลับไปดูแผนที่',
                                      style: const TextStyle(color: AppColors.gold, fontFamily: 'Noto Serif Thai'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                            if (goAnyway != true) return;
                          }
                        }

                        if (!context.mounted) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraScreen(placeId: place.id),
                          ),
                        );
                      },
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1C0E04), Color(0xFF4A2010)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1C0E04).withOpacity(0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 16),
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