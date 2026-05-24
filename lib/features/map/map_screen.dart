import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../places/places_provider.dart';
import 'map_provider.dart';
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
                          child: Image.network(
                            widget.place.imageUrl,
                            fit: BoxFit.cover,
                            color: isLocked ? Colors.grey : null,
                            colorBlendMode: isLocked ? BlendMode.saturation : null,
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
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    final selectedId = ref.watch(selectedMapPlaceIdProvider);
    final translations = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.espresso,
        elevation: 0,
        title: Text(
          translations['map_title'] ?? '🗺️ แผนที่ 6 สถานที่',
          style: const TextStyle(
            color: AppColors.gold,
            fontFamily: 'Noto Serif Thai',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: const SizedBox.shrink(),
      ),
      body: Stack(
        children: [
          // Map background
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            child: Stack(
              children: [
                // Map image
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: const NetworkImage(
                        'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1000&auto=format&fit=crop',
                      ),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        AppColors.ink.withOpacity(0.4),
                        BlendMode.overlay,
                      ),
                    ),
                  ),
                ),

                // Grid overlay
                CustomPaint(
                  painter: MapGridPainter(),
                  size: Size.infinite,
                ),

                // Render map pins
                ...places.asMap().entries.map((entry) {
                  final index = entry.key;
                  final place = entry.value;

                  // Mock positions for 6 points
                  final positions = [
                    const Offset(0.25, 0.35),
                    const Offset(0.55, 0.28),
                    const Offset(0.75, 0.42),
                    const Offset(0.65, 0.68),
                    const Offset(0.35, 0.75),
                    const Offset(0.15, 0.55),
                  ];
                  final pos = positions[index];

                  return Positioned(
                    left: MediaQuery.of(context).size.width * pos.dx,
                    top: MediaQuery.of(context).size.height *
                        (pos.dy - 0.1),
                    child: _MapPinWidget(
                      place: place,
                      index: index + 1,
                      isSelected: place.id == selectedId,
                      onTap: () => ref
                          .read(selectedMapPlaceIdProvider.notifier)
                          .state = place.id,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom card - place detail
          if (selectedId != null)
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(opacity: value, child: child),
                  );
                },
                child: _MapBottomCard(
                  place: places.firstWhere((p) => p.id == selectedId),
                  onClose: () => ref
                      .read(selectedMapPlaceIdProvider.notifier)
                      .state = null,
                ),
              ),
            ),

          // Legend
          const Positioned(
            top: 12,
            right: 16,
            child: _MapLegend(),
          ),
        ],
      ),
    );
  }
}

class _MapPinWidget extends ConsumerStatefulWidget {
  final Place place;
  final int index;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapPinWidget({
    required this.place,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  ConsumerState<_MapPinWidget> createState() => _MapPinWidgetState();
}

class _MapPinWidgetState extends ConsumerState<_MapPinWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(_MapPinWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _animationController.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translations = ref.watch(translationsProvider);
    final isActive = widget.place.status == PlaceStatus.active;
    final isDone = widget.place.status == PlaceStatus.done;
    final isLocked = widget.place.status == PlaceStatus.locked;

    return GestureDetector(
      onTap: () {
        widget.onTap();
        if (!widget.isSelected) {
          _animationController.forward();
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label - shows for active places
          if (isActive || widget.isSelected)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 200),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, -8 * (1 - value)),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Text(
                  isActive ? (translations['map_here'] ?? '📍 ที่นี่') : '${translations['map_place_num'] ?? 'สถานที่ #'}${widget.index}',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Noto Serif Thai',
                  ),
                ),
              ),
            ),

          const SizedBox(height: 6),

          // Pin circle
          ScaleTransition(
            scale: Tween<double>(begin: 1.0, end: 1.3)
                .animate(_animationController),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.gold
                    : (isActive ? AppColors.cream : AppColors.espresso),
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.isSelected ? AppColors.gold : AppColors.ink,
                  width: widget.isSelected ? 3 : 2,
                ),
                boxShadow: [
                  if (widget.isSelected || isActive)
                    BoxShadow(
                      color: AppColors.gold.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    )
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    isDone
                        ? Icons.check_circle
                        : (isLocked
                            ? Icons.lock
                            : Icons.location_on),
                    color: isDone || isActive
                        ? AppColors.ink
                        : AppColors.cream,
                    size: 24,
                  ),
                  if (isActive)
                    ScaleTransition(
                      scale: Tween<double>(begin: 1.0, end: 1.4)
                          .animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Curves.elasticOut,
                            ),
                          ),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold.withOpacity(
                              1 - (_animationController.value * 0.7),
                            ),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Status indicator
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDone
                  ? Colors.green.withOpacity(0.2)
                  : (isActive
                      ? AppColors.gold.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDone
                    ? Colors.green
                    : (isActive ? AppColors.gold : Colors.grey),
                width: 0.5,
              ),
            ),
            child: Text(
              isDone ? (translations['map_done'] ?? '✓ สำเร็จ') : (isActive ? (translations['map_unlocked'] ?? 'ปลดล็อก') : (translations['map_locked'] ?? '🔒 ล็อค')),
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: isDone
                    ? Colors.green
                    : (isActive ? AppColors.gold : Colors.grey),
                fontFamily: 'Noto Serif Thai',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapBottomCard extends ConsumerWidget {
  final Place place;
  final VoidCallback onClose;

  const _MapBottomCard({
    required this.place,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            border: Border.all(color: AppColors.glassBorder, width: 1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // Place image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  place.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),

              // Place info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translations['place_${place.id}_name'] ?? place.name,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: 'Noto Serif Thai',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      translations['map_distance_mock'] ?? '📍 ~150 เมตรจากคุณ',
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 11,
                        fontFamily: 'Noto Serif Thai',
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.navigation_rounded,
                      color: AppColors.gold, size: 20),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(translations['map_open_maps'] ?? 'เปิด Google Maps...'),
                        backgroundColor: AppColors.gold,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),

              // Close button
              Container(
                decoration: BoxDecoration(
                  color: AppColors.mahogany.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close,
                      color: AppColors.cream, size: 16),
                  onPressed: onClose,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLegend extends ConsumerWidget {
  const _MapLegend();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.espresso.withOpacity(0.9),
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _LegendItem(
                color: AppColors.cream,
                label: translations['map_unlocked'] ?? 'ปลดล็อก',
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: AppColors.gold,
                label: translations['map_done']?.replaceAll('✓ ', '') ?? 'สำเร็จ',
              ),
              const SizedBox(height: 8),
              _LegendItem(
                color: AppColors.espresso,
                label: translations['map_locked']?.replaceAll('🔒 ', '') ?? 'ล็อค',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.gold.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.cream,
            fontSize: 10,
            fontFamily: 'Noto Serif Thai',
          ),
        ),
      ],
    );
  }
}

class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.05)
      ..strokeWidth = 0.5;

    const gridSize = 40.0;

    // Vertical lines
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(MapGridPainter oldDelegate) => false;
}