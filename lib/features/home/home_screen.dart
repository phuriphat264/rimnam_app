import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../places/places_provider.dart';
import '../places/place_detail_screen.dart';
import 'dart:ui';
import '../places/place_model.dart';

class PlaceCardWidget extends StatefulWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceCardWidget({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  State<PlaceCardWidget> createState() => _PlaceCardWidgetState();
}

class _PlaceCardWidgetState extends State<PlaceCardWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.place.status == PlaceStatus.locked;
    final isDone = widget.place.status == PlaceStatus.done;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!isLocked) widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed && !isLocked ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.glassBackground,
            border: Border.all(
              color: isDone ? AppColors.gold : AppColors.glassBorder,
              width: isDone ? 1.5 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  // Image Part
                  SizedBox(
                    width: 120,
                    height: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'place_image_${widget.place.id}',
                          child: widget.place.imageUrl.startsWith('http')
                              ? Image.network(
                                  widget.place.imageUrl,
                                  fit: BoxFit.cover,
                                  color: isLocked ? Colors.grey : null,
                                  colorBlendMode: isLocked ? BlendMode.saturation : null,
                                  errorBuilder: (context, error, stackTrace) => Container(color: AppColors.mahogany),
                                )
                              : Image.asset(
                                  widget.place.imageUrl,
                                  fit: BoxFit.cover,
                                  color: isLocked ? Colors.grey : null,
                                  colorBlendMode: isLocked ? BlendMode.saturation : null,
                                  errorBuilder: (context, error, stackTrace) => Container(color: AppColors.mahogany),
                                ),
                        ),
                        if (isLocked)
                          Container(
                            color: AppColors.ink.withOpacity(0.5),
                            child: const Icon(Icons.lock, color: AppColors.cream),
                          ),
                      ],
                    ),
                  ),
                  
                  // Detail Part
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.place.name,
                            style: TextStyle(
                              color: isLocked ? AppColors.cream.withOpacity(0.5) : AppColors.gold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.place.description,
                            style: TextStyle(
                              color: isLocked ? AppColors.cream.withOpacity(0.3) : AppColors.cream.withOpacity(0.8),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Status Icon Part
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildStatusIcon(isLocked, isDone),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isLocked, bool isDone) {
    if (isDone) {
      return const Icon(Icons.check_circle, color: AppColors.gold, size: 28);
    } else if (isLocked) {
      return const SizedBox.shrink();
    } else {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 14),
      );
    }
  }
}
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    final translations = ref.watch(translationsProvider);
    final doneCount = places.where((p) => p.status == PlaceStatus.done).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD8),
      body: Column(
        children: [
          // ==========================================
          // HEADER SECTION
          // ==========================================
          Container(
            padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1C0E04), Color(0xFF2E1A0A)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'MISSION · RIMNAM',
                          style: TextStyle(
                            fontFamily: 'Cormorant Garamond',
                            fontSize: 10,
                            letterSpacing: 3,
                            color: AppColors.honey.withOpacity(0.4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          translations['home_mission_title'] ?? 'ภารกิจสำรวจ\nชุมชนริมน้ำ',
                          style: const TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.amber,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$doneCount / ${places.length} ✓',
                        style: const TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.amber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: List.generate(places.length, (index) {
                    final place = places[index];
                    final isDone = place.status == PlaceStatus.done;

                    return Expanded(
                      child: Container(
                        height: 3,
                        margin: EdgeInsets.only(right: index < places.length - 1 ? 4 : 0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          color: isDone
                              ? AppColors.gold
                              : AppColors.gold.withOpacity(0.5),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // ==========================================
          // PLACES LIST SECTION
          // ==========================================
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 120),
              physics: const BouncingScrollPhysics(),
              itemCount: places.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final place = places[index];
                return _PremiumPlaceCard(
                  place: place,
                  index: index + 1,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// PLACE CARD WIDGET
// ==========================================
class _PremiumPlaceCard extends ConsumerWidget {
  final Place place;
  final int index;

  const _PremiumPlaceCard({
    required this.place,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);
    final isDone = place.status == PlaceStatus.done;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(
              place: place,
              index: index,
            ),
          ),
        );
      },
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          children: [
            // ==========================================
            // LEFT: Image Section
            // ==========================================
            Container(
              width: 100,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  place.imageUrl.startsWith('http')
                      ? Image.network(
                          place.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(color: AppColors.espresso),
                        )
                      : Image.asset(
                          place.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) => Container(color: AppColors.espresso),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.3)
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // CENTER: Text Content Section
            // ==========================================
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spot Number
                    Text(
                      'SPOT · ${index.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 9,
                        letterSpacing: 2.5,
                        color: AppColors.mahogany.withOpacity(0.5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Place Name
                    Text(
                      translations['place_${place.id}_name'] ?? place.name,
                      style: const TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.espresso,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),

                    // Subtitle
                    Text(
                      translations['place_${place.id}_desc'] ?? (place.description ?? (translations['tap_to_view'] ?? 'แตะเพื่อดูรายละเอียด')),
                      style: TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        fontSize: 11,
                        color: AppColors.mahogany.withOpacity(0.5),
                        height: 1.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // RIGHT: Status Icon Section
            // ==========================================
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDone
                        ? [AppColors.gold, AppColors.honey]
                        : [
                            AppColors.gold.withOpacity(0.4),
                            AppColors.honey.withOpacity(0.3)
                          ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withOpacity(isDone ? 0.3 : 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Icon(
                  isDone ? Icons.check_rounded : Icons.arrow_forward_ios_rounded,
                  color: isDone ? AppColors.espresso : AppColors.mahogany,
                  size: isDone ? 20 : 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}