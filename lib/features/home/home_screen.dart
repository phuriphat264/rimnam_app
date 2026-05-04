import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
// TODO: แก้ไข Path ตรงนี้ให้ชี้ไปยังไฟล์ places_provider.dart ของคุณให้ถูกต้อง
import '../places/places_provider.dart'; 
import '../places/place_detail_screen.dart'; // ดึงหน้า Detail เข้ามาใช้งาน

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ดึงข้อมูล 6 สถานที่จาก Provider ของคุณ
    final places = ref.watch(placesProvider);
    
    // นับจำนวนสถานที่ที่ทำสำเร็จแล้ว
    final doneCount = places.where((p) => p.status == PlaceStatus.done).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5ECD8), // สีพื้นหลัง Linen สไตล์พรีเมียม
      body: Column(
        children: [
          // 1. ส่วน Header ด้านบน (แถบสีเข้ม)
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
                        const Text(
                          'ภารกิจสำรวจ\nชุมชนริมน้ำ',
                          style: TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.amber,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                    // ป้ายบอกความคืบหน้า (เช่น 0 / 6)
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
                // แถบ Progress Track ด้านล่าง Header (ปลดล็อกให้ Active ทั้งหมดที่ยังไม่เสร็จ)
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
                              : AppColors.gold.withOpacity(0.5), // เป็นสีทองอ่อนเสมอเพราะพร้อมให้ทำแล้ว
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // 2. ส่วนรายการสถานที่ 6 จุด
          Expanded(
            child: ListView.separated(
              // เผื่อพื้นที่ด้านล่าง 120 ให้ Bottom Nav ไม่บังรายการสุดท้าย
              padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 120), 
              physics: const BouncingScrollPhysics(),
              itemCount: places.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final place = places[index];
                return _PremiumPlaceCard(place: place, index: index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// Widget ย่อยสำหรับการ์ดสถานที่แต่ละใบ (ปลดล็อกทั้งหมด)
// ==========================================
class _PremiumPlaceCard extends StatelessWidget {
  final Place place; 
  final int index;

  const _PremiumPlaceCard({required this.place, required this.index});

  @override
  Widget build(BuildContext context) {
    // เช็คแค่ว่าทำภารกิจเสร็จหรือยัง (ไม่ต้องเช็ค isLocked แล้ว)
    final isDone = place.status == PlaceStatus.done;

    return GestureDetector(
      onTap: () {
        // กดปุ๊บ ไปหน้า Detail ทันที ไม่ต้องมีเงื่อนไขล็อค
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PlaceDetailScreen(place: place, index: index),
          ),
        );
      },
      child: Container(
        height: 94,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.gold.withOpacity(0.4), // กรอบสีทองสว่างเสมอ
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            // 2.1 ส่วนรูปภาพด้านซ้าย
            Container(
              width: 90,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(place.imageUrl, fit: BoxFit.cover),
                  // Gradient สีดำจางๆ ไล่จากขวามาซ้าย เพื่อให้ข้อความตรงกลางอ่านง่ายขึ้น
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 2.2 ส่วนข้อความตรงกลาง
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SPOT · ${index.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontFamily: 'Cormorant Garamond',
                        fontSize: 10,
                        letterSpacing: 2,
                        color: AppColors.mahogany.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      place.name,
                      style: const TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.espresso, // สีเข้มปกติ (ไม่เทา)
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'แตะเพื่อดูคำใบ้และทำภารกิจ', // ข้อความแจ้งเตือนว่าพร้อมกดเสมอ
                      style: TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        fontSize: 11,
                        color: AppColors.mahogany.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),

            // 2.3 ไอคอนสถานะด้านขวา
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.gold, AppColors.honey]),
                boxShadow: [
                  BoxShadow(color: AppColors.gold.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 2))
                ],
              ),
              child: Icon(
                // ถ้าเสร็จแล้วโชว์ติ๊กถูก ถ้ายังโชว์ลูกศร (ตัดแม่กุญแจออก)
                isDone ? Icons.check_rounded : Icons.arrow_forward_rounded,
                color: AppColors.espresso,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}