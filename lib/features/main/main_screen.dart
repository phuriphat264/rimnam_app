import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import 'main_provider.dart';

// นำเข้าหน้าต่างๆ
import '../home/home_screen.dart';
import '../map/map_screen.dart';
// import '../profile/profile_screen.dart'; 

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // อ่านค่า Index ปัจจุบันจาก Provider
    final currentIndex = ref.watch(bottomNavIndexProvider);

    // ลบ CameraScreen ออก และเหลือแค่ 3 หน้า
    final List<Widget> screens = [
      const HomeScreen(), // Index 0
      const MapScreen(),  // Index 1
      const Center(child: Text('Profile Screen', style: TextStyle(color: AppColors.cream))), // Index 2 (Mock Profile)
    ];

    // ป้องกัน Error กรณีที่ state ของ bottomNavIndexProvider เคยจำค่า Index 3 เอาไว้
    final safeIndex = currentIndex >= screens.length ? 0 : currentIndex;

    return Scaffold(
      backgroundColor: AppColors.ink,
      extendBody: true, // สำคัญมาก เพื่อให้เนื้อหาทะลุลงไปใต้ Bottom Nav แบบ Floating
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 32),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                // เปลี่ยนเป็นสีน้ำตาลเข้ม (Espresso) กึ่งโปร่งแสง เพื่อให้ตัดกับพื้นหลังสีอ่อน
                color: AppColors.espresso.withOpacity(0.85), 
                // เปลี่ยนสีกรอบให้เข้ากับธีมน้ำตาลทอง
                border: Border.all(color: AppColors.gold.withOpacity(0.2)), 
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25), // ปรับเงาให้ดูมีมิติยกขึ้นมา
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // เหลือแค่ 3 แท็บ (0, 1, 2)
                  const _NavItem(index: 0, icon: Icons.home_rounded, label: 'หน้าแรก'),
                  const _NavItem(index: 1, icon: Icons.map_rounded, label: 'แผนที่'),
                  const _NavItem(index: 2, icon: Icons.person_rounded, label: 'โปรไฟล์'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends ConsumerWidget {
  final int index;
  final IconData icon;
  final String label;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.gold : AppColors.cream.withOpacity(0.6), // ไอคอนไม่ได้เลือกเป็นสีครีม
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutQuint,
              child: isSelected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}