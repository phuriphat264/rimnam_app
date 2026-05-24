import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CityIllustration extends StatelessWidget {
  const CityIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.espresso.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.mahogany.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Night sky
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.espresso.withOpacity(0.8),
                  AppColors.mahogany.withOpacity(0.5),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
          ),

          // Stars
          const Positioned(top: 16, left: 30, child: _Star(size: 2)),
          const Positioned(top: 24, left: 70, child: _Star(size: 1.5)),
          const Positioned(top: 20, right: 40, child: _Star(size: 2)),
          const Positioned(top: 32, right: 80, child: _Star(size: 1)),

          // Buildings
          Positioned(bottom: 30, left: 20, child: _Building(width: 35, height: 60, windows: 4, color: AppColors.mahogany.withOpacity(0.8))),
          const Positioned(bottom: 25, left: 60, child: _Building(width: 32, height: 70, windows: 6, color: AppColors.mahogany)),
          Positioned(bottom: 20, left: 98, child: _Building(width: 35, height: 75, windows: 6, color: AppColors.mahogany.withOpacity(0.9))),
          Positioned(bottom: 15, left: 138, child: _Building(width: 32, height: 85, windows: 8, color: AppColors.mahogany.withOpacity(0.85))),
          Positioned(bottom: 25, left: 175, child: _Building(width: 35, height: 70, windows: 6, color: AppColors.mahogany.withOpacity(0.8))),
          const Positioned(bottom: 30, left: 215, child: _Building(width: 32, height: 60, windows: 4, color: AppColors.mahogany)),

          // Moon
          Positioned(
            top: 16,
            right: 20,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: AppColors.espresso,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.honey, width: 1.5),
              ),
            ),
          ),

          // River
          Container(
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.teal.withOpacity(0.7),
                  AppColors.teal.withOpacity(0.5),
                ],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Building extends StatelessWidget {
  final double width;
  final double height;
  final int windows;
  final Color color;

  const _Building({
    required this.width,
    required this.height,
    required this.windows,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(
            windows,
            (index) => Container(
              decoration: BoxDecoration(
                color: AppColors.honey.withOpacity(0.8),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Star extends StatelessWidget {
  final double size;
  const _Star({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.amber,
        shape: BoxShape.circle,
      ),
    );
  }
}