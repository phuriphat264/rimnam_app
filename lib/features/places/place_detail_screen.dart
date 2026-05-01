import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'places_provider.dart';

class PlaceDetailScreen extends StatelessWidget {
  final Place place;

  const PlaceDetailScreen({super.key, required this.place});

  @override
  Widget build(BuildContext context) {
    final isLocked = place.status == PlaceStatus.locked;
    final isDone = place.status == PlaceStatus.done;

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: AppColors.ink,
            iconTheme: const IconThemeData(color: AppColors.gold),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'place_image_${place.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(place.imageUrl, fit: BoxFit.cover),
                    // Gradient overlay for smooth transition to background
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, AppColors.ink],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.name,
                    style: const TextStyle(fontSize: 28, color: AppColors.gold, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    place.description * 3, // Mock long description
                    style: const TextStyle(fontSize: 15, color: AppColors.cream, height: 1.6),
                  ),
                  const SizedBox(height: 48),

                  // Mission Hint Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.espresso.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.mahogany),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppColors.amber),
                            SizedBox(width: 8),
                            Text('คำใบ้ภารกิจ', style: TextStyle(color: AppColors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isLocked 
                            ? 'กรุณาทำภารกิจก่อนหน้าให้สำเร็จเพื่อดูคำใบ้'
                            : 'หามุมถ่ายภาพที่มีสะพานอยู่ฉากหลัง และมีแสงแดดตกกระทบแม่น้ำ',
                          style: const TextStyle(color: AppColors.cream),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),

                  // Action Button
                  if (!isLocked && !isDone)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.ink,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 10,
                          shadowColor: AppColors.gold.withOpacity(0.5),
                        ),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('เปิดกล้องถ่ายภาพ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          // TODO: Navigate to CameraScreen
                        },
                      ),
                    ),
                    
                  if (isDone)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        decoration: BoxDecoration(
                          color: AppColors.sage.withOpacity(0.2), // Optional success color
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.green),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 8),
                            Text('ทำภารกิจนี้สำเร็จแล้ว', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}