import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'places_provider.dart';
import 'place_detail_screen.dart';
import 'widgets/place_card_widget.dart';

class PlacesScreen extends ConsumerWidget {
  const PlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(placesProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.ink,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: const FlexibleSpaceBar(
              titlePadding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              title: Text(
                'ภารกิจ 6 สถานที่',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final place = places[index];
                  
                  // Staggered Animation
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: Duration(milliseconds: 400 + (index * 150)),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: PlaceCardWidget(
                      place: place,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailScreen(place: place),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: places.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for bottom nav
        ],
      ),
    );
  }
}