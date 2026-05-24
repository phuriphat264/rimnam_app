import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../places/places_provider.dart';
// import 'share_screen.dart'; // เปิดคอมเมนต์ถ้าต้องการให้กดที่เหรียญแล้วไปหน้าแชร์

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ดึงจำนวนสถานที่ที่ทำสำเร็จแล้วมาแสดงเป็นสถิติ
    final completedCount = ref.watch(completedCountProvider);
    final totalPlaces = ref.watch(placesProvider).length;
    final isAllDone = completedCount == totalPlaces;
    final translations = ref.watch(translationsProvider);

    return Scaffold(
      backgroundColor: AppColors.ink, // พื้นหลังสีน้ำตาลเข้ม
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'PROFILES',
          style: TextStyle(
            fontFamily: 'Cormorant Garamond',
            fontSize: 14,
            letterSpacing: 4,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ==========================================
            // 1. ส่วนข้อมูลผู้ใช้ (User Info)
            // ==========================================
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2),
                      image: const DecorationImage(
                        // ใช้รูป Placeholder ไปก่อน สามารถเปลี่ยนเป็นรูป User จริงได้
                        image: NetworkImage('https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.gold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit, size: 14, color: AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              translations['profile_name'] ?? 'นักสำรวจนิรนาม',
              style: const TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'explorer@chanthaburi.com',
              style: TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 2. สถิติการเดินทาง (Travel Stats)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _StatBox(
                    title: translations['profile_places_visited'] ?? 'สถานที่ที่ไปแล้ว',
                    value: '$completedCount',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(width: 16),
                  _StatBox(
                    title: translations['profile_total_missions'] ?? 'ภารกิจทั้งหมด',
                    value: '1',
                    icon: Icons.flag,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 3. หอเกียรติยศ / ตราประทับ (Achievements)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations['profile_stamp_book'] ?? 'สมุดสะสมตราประทับ',
                    style: const TextStyle(
                      fontFamily: 'Noto Serif Thai',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // กล่องตราประทับ (ถ้าทำภารกิจเสร็จจะสว่าง ถ้ายังจะมืดๆ)
                  GestureDetector(
                    onTap: () {
                      // ถ้าต้องการให้กดแล้วไปหน้าแชร์รูป
                      // if (isAllDone) Navigator.push(context, MaterialPageRoute(builder: (_) => const ShareScreen()));
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isAllDone ? AppColors.mahogany.withOpacity(0.3) : AppColors.mahogany.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAllDone ? AppColors.gold.withOpacity(0.5) : Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          // ไอคอนเหรียญ
                          Opacity(
                            opacity: isAllDone ? 1.0 : 0.3,
                            child: Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isAllDone ? AppColors.gold.withOpacity(0.2) : Colors.white.withOpacity(0.1),
                              ),
                              child: Icon(
                                isAllDone ? Icons.workspace_premium : Icons.lock,
                                color: isAllDone ? AppColors.gold : Colors.white54,
                                size: 30,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // ข้อความอธิบาย
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  translations['profile_mission_name'] ?? 'ภารกิจชุมชนริมน้ำจันทบูร',
                                  style: TextStyle(
                                    fontFamily: 'Noto Serif Thai',
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isAllDone ? Colors.white : Colors.white54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isAllDone ? (translations['profile_completed_today'] ?? 'สำเร็จเมื่อ: วันนี้') : '${translations['profile_progress'] ?? 'ความคืบหน้า: '}$completedCount/$totalPlaces',
                                  style: TextStyle(
                                    fontFamily: 'Noto Serif Thai',
                                    fontSize: 12,
                                    color: isAllDone ? AppColors.sage : AppColors.amber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isAllDone)
                            const Icon(Icons.chevron_right, color: AppColors.gold),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 4. เมนูตั้งค่าทั่วไป (General Settings)
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _SettingsMenu(icon: Icons.person_outline, title: translations['profile_edit'] ?? 'แก้ไขข้อมูลส่วนตัว', onTap: () {}),
                  _SettingsMenu(icon: Icons.notifications_none, title: translations['profile_notifications'] ?? 'การแจ้งเตือน', onTap: () {}),
                  _SettingsMenu(icon: Icons.help_outline, title: translations['profile_help'] ?? 'ศูนย์ช่วยเหลือ', onTap: () {}),
                  const Divider(color: Colors.white10, height: 32),
                  _SettingsMenu(icon: Icons.logout, title: translations['profile_logout'] ?? 'ออกจากระบบ', isDestructive: true, onTap: () {}),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// Widgets ย่อยสำหรับใช้ในหน้านี้
// ----------------------------------------------------

class _StatBox extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatBox({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold.withOpacity(0.7), size: 24),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SettingsMenu({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDestructive ? Colors.red.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isDestructive ? Colors.redAccent : Colors.white70,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Noto Serif Thai',
          fontSize: 14,
          color: isDestructive ? Colors.redAccent : Colors.white,
        ),
      ),
      trailing: isDestructive ? null : const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
      onTap: onTap,
    );
  }
}