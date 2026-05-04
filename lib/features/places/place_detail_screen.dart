import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../places/places_provider.dart';
// แก้ไข path ให้ชี้ไปหน้า CameraScreen ของคุณ
import '../camera/camera_screen.dart'; 

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
    final totalPlaces = places.length;
    final isDone = place.status == PlaceStatus.done;

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD8), // สีพื้นหลัง Linen Premium
      body: Column(
        children: [
          // 1. ส่วนภาพ Cover ด้านบน (Hero Section)
          SizedBox(
            height: 280,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  place.imageUrl.isNotEmpty 
                      ? place.imageUrl 
                      : 'https://images.unsplash.com/photo-1548013146-72479768bbaa?q=80&w=800&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),
                
                // Gradient ทับรูปภาพให้ตัวหนังสืออ่านง่าย
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

                // แถบเมนูด้านบน (ปุ่มกลับ + ป้าย Mission)
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
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.35),
                                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'กลับ',
                                        style: TextStyle(
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
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withOpacity(0.22),
                                  border: Border.all(color: AppColors.gold.withOpacity(0.42)),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Text(
                                  'MISSION $index / $totalPlaces',
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

                // ข้อความชื่อสถานที่ด้านล่างของรูป
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SPOT · ${index.toString().padLeft(2, '0')} OF ${totalPlaces.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontFamily: 'Cormorant Garamond',
                          fontSize: 10,
                          letterSpacing: 4,
                          color: AppColors.amber.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        place.name,
                        style: const TextStyle(
                          fontFamily: 'Noto Serif Thai',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2))],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. ส่วนเนื้อหาด้านล่าง
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // รายละเอียดสถานที่
                  Text(
                    'สถานที่สำคัญในชุมชนริมน้ำจันทบูร เป็นจุดเช็คอินที่คุณต้องค้นหาและบันทึกภาพเพื่อปลดล็อกเรื่องราวทางประวัติศาสตร์ที่ซ่อนอยู่...', 
                    style: TextStyle(
                      fontFamily: 'Noto Serif Thai',
                      fontSize: 14,
                      height: 1.8,
                      color: AppColors.mahogany.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // กล่องคำใบ้ (Hint Box)
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
                                'คำใบ้ภารกิจ',
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
                                  ? 'คุณทำภารกิจจุดนี้สำเร็จแล้ว ยอดเยี่ยมมาก!'
                                  : 'ถ่ายรูปให้เห็นจุดสังเกตสำคัญของสถานที่นี้อย่างชัดเจน เพื่อยืนยันการสำรวจ',
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

                  // จุดไข่ปลาบอกความคืบหน้าภารกิจ (Step Row)
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
                                : (isCur ? AppColors.gold : AppColors.mahogany.withOpacity(0.15)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                      const Spacer(),
                      Text(
                        'สถานที่ $index / $totalPlaces',
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

                  // ปุ่มเปิดกล้อง (Camera Button)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.transparent, 
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ).copyWith(elevation: WidgetStateProperty.all(0)),
                      onPressed: () {
                        if (isDone) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('คุณทำภารกิจสถานที่นี้เสร็จแล้ว 🎉'), backgroundColor: AppColors.sage)
                          );
                          return;
                        }
                        
                        // นำทางไปหน้ากล้อง
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
                            BoxShadow(color: const Color(0xFF1C0E04).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(isDone ? Icons.check_circle : Icons.camera_alt, color: AppColors.amber, size: 20),
                              const SizedBox(width: 10),
                              Text(
                                isDone ? 'ภารกิจเสร็จสิ้น' : 'ถ่ายภาพ ณ สถานที่นี้',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}