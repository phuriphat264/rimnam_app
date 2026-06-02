import 'dart:io';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/place_icon.dart';
import '../../places/place_model.dart';

class GridCollageWidget extends StatelessWidget {
  final List<Place> places;

  const GridCollageWidget({super.key, required this.places});

  @override
  Widget build(BuildContext context) {
    final cells = List.generate(6, (i) => i < places.length ? places[i] : null);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.espresso,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.18),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          Expanded(
            child: Row(children: [
              _Cell(place: cells[0], index: 0),
              const SizedBox(width: 6),
              _Cell(place: cells[1], index: 1),
            ]),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(children: [
              _Cell(place: cells[2], index: 2),
              const SizedBox(width: 6),
              _Cell(place: cells[3], index: 3),
            ]),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Row(children: [
              _Cell(place: cells[4], index: 4),
              const SizedBox(width: 6),
              _Cell(place: cells[5], index: 5),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Cell ─────────────────────────────────────────────────────────
class _Cell extends StatelessWidget {
  final Place? place;
  final int index;

  const _Cell({required this.place, required this.index});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: Duration(milliseconds: 500 + index * 120),
        curve: Curves.easeOutQuart,
        builder: (_, value, child) => Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.92 + 0.08 * value, child: child),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // รูปภาพ / skeleton
              if (place == null)
                Container(color: AppColors.ink)
              else if (place!.capturedPhotoPath != null)
                Image.file(
                  File(place!.capturedPhotoPath!),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _PlaceIconCell(place: place!),
                )
              else
                _PlaceIconCell(place: place!),

              // gradient + ชื่อสถานที่
              if (place != null)
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.65),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Text(
                      place!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        fontSize: 9,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // เลขสถานที่ (top-left)
              Positioned(
                top: 5, left: 5,
                child: Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.45),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: AppColors.gold.withOpacity(0.5), width: 1),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 10,
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
    );
  }
}

// ── Place icon placeholder ────────────────────────────────────────
class _PlaceIconCell extends StatelessWidget {
  final Place place;
  const _PlaceIconCell({required this.place});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.espresso,
      child: Center(
        child: PlaceIcon(
          placeId: place.id,
          size: 44,
          color: AppColors.sienna,
        ),
      ),
    );
  }
}
