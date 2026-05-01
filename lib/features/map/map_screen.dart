import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../places/places_provider.dart';
import '../places/place_detail_screen.dart';
import 'map_provider.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);
    final selectedId = ref.watch(selectedMapPlaceIdProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // Custom Interactive Map
          InteractiveViewer(
            minScale: 1.0,
            maxScale: 3.0,
            child: Stack(
              children: [
                // Map Background (Mock with dark grid/image)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1000&auto=format&fit=crop'), // Map texture
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(AppColors.ink, BlendMode.overlay),
                    ),
                  ),
                ),
                
                // Render Pins
                ...places.asMap().entries.map((entry) {
                  final index = entry.key;
                  final place = entry.value;
                  // Mock positions for 6 points
                  final positions = [
                    const Offset(0.3, 0.4), const Offset(0.5, 0.3), const Offset(0.7, 0.5),
                    const Offset(0.6, 0.7), const Offset(0.4, 0.8), const Offset(0.2, 0.6)
                  ];
                  final pos = positions[index];

                  return Positioned(
                    left: MediaQuery.of(context).size.width * pos.dx,
                    top: MediaQuery.of(context).size.height * pos.dy,
                    child: _MapPinWidget(
                      place: place,
                      isSelected: place.id == selectedId,
                      onTap: () => ref.read(selectedMapPlaceIdProvider.notifier).state = place.id,
                    ),
                  );
                }),
              ],
            ),
          ),

          // Bottom Place Detail Card (Glassmorphism)
          if (selectedId != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 40,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.translate(
                    offset: Offset(0, 50 * (1 - value)),
                    child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                  );
                },
                child: _MapBottomCard(
                  place: places.firstWhere((p) => p.id == selectedId),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MapPinWidget extends StatelessWidget {
  final Place place;
  final bool isSelected;
  final VoidCallback onTap;

  const _MapPinWidget({required this.place, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = place.status == PlaceStatus.active;
    final isDone = place.status == PlaceStatus.done;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isSelected ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Column(
          children: [
            if (isActive) ...[
              const Text('📍 ที่นี่', style: TextStyle(color: AppColors.gold, fontSize: 10, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
            ],
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isDone ? AppColors.gold : (isActive ? AppColors.cream : AppColors.espresso),
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? AppColors.gold : AppColors.ink, width: 2),
                boxShadow: isSelected || isActive ? [BoxShadow(color: AppColors.gold.withOpacity(0.5), blurRadius: 10)] : [],
              ),
              child: Icon(
                isDone ? Icons.check : Icons.location_on,
                color: isDone || isActive ? AppColors.ink : AppColors.cream,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapBottomCard extends ConsumerWidget {
  final Place place;

  const _MapBottomCard({required this.place});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final distance = ref.watch(distanceProvider(place.id));
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            border: Border.all(color: AppColors.glassBorder),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(place.imageUrl, width: 60, height: 60, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name, style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${distance.toInt()} เมตรจากคุณ', style: const TextStyle(color: AppColors.cream, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.navigation_rounded, color: AppColors.gold),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailScreen(place: place),
                    ),
                  );
                }, // Navigate to detail
              )
            ],
          ),
        ),
      ),
    );
  }
}