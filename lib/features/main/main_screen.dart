import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import 'main_provider.dart';
import '../map/map_provider.dart';

import '../home/home_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import '../places/places_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _handleGpsPermission();
      try {
        await ref.read(placesProvider.notifier).syncFromServer();
      } catch (_) {}
    });
  }

  /// เรียกครั้งเดียวตอนเปิดแอพ — เป็น single authority สำหรับขออนุญาต GPS
  Future<void> _handleGpsPermission() async {
    if (!mounted) return;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      if (!mounted) return;
      final translations = ref.read(translationsProvider);
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _GpsPermissionDialog(translations: translations),
      );
      if (!mounted) return;
      if (confirmed == true) {
        permission = await Geolocator.requestPermission();
        // restart location stream ด้วย permission ใหม่
        if (mounted) ref.invalidate(userLocationProvider);
      }
    }

    if (permission == LocationPermission.deniedForever && mounted) {
      _showSettingsSnack();
    }
  }

  void _showSettingsSnack() {
    final translations = ref.read(translationsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          translations['gps_settings_snack'] ?? 'กรุณาเปิดสิทธิ์ตำแหน่งในการตั้งค่าเพื่อใช้ฟีเจอร์แผนที่',
          style: const TextStyle(fontFamily: 'Noto Serif Thai', color: Colors.white),
        ),
        backgroundColor: AppColors.mahogany,
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: translations['gps_go_settings'] ?? 'ไปตั้งค่า',
          textColor: AppColors.gold,
          onPressed: Geolocator.openAppSettings,
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final gpsStatusAsync = ref.watch(gpsServiceStatusProvider);
    final isGpsOff = gpsStatusAsync.valueOrNull == false;
    final translations = ref.watch(translationsProvider);

    // เมื่อ GPS เปิดกลับมา → restart location stream อัตโนมัติ
    ref.listen<AsyncValue<bool>>(gpsServiceStatusProvider, (prev, next) {
      final wasOff = prev?.valueOrNull == false;
      final isNowOn = next.valueOrNull == true;
      if (wasOff && isNowOn) {
        ref.invalidate(userLocationProvider);
      }
    });

    final List<Widget> screens = [
      const HomeScreen(),
      const MapScreen(),
      const ProfileScreen(),
    ];

    final safeIndex = currentIndex >= screens.length ? 0 : currentIndex;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.espresso,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(
              translations['exit_app_title'] ?? 'ออกจากแอพ',
              style: const TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            content: Text(
              translations['exit_app_body'] ?? 'ต้องการออกจากแอพไหม?',
              style: TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 14,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(
                  translations['exit_cancel'] ?? 'ยกเลิก',
                  style: const TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    color: AppColors.caramel,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  translations['exit_confirm'] ?? 'ออกจากแอพ',
                  style: const TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
        if (shouldExit == true) SystemNavigator.pop();
      },
      child: Scaffold(
      backgroundColor: AppColors.ink,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: safeIndex,
            children: screens,
          ),
          if (isGpsOff)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: _GpsOffBanner(),
            ),
        ],
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
                color: AppColors.espresso.withOpacity(0.96),
                border: Border.all(color: AppColors.gold.withOpacity(0.28)),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _NavItem(index: 0, icon: Icons.home_rounded, labelKey: 'nav_home'),
                  _NavItem(index: 1, icon: Icons.map_rounded, labelKey: 'nav_map'),
                  _NavItem(index: 2, icon: Icons.person_rounded, labelKey: 'nav_profile'),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}

// ── GPS off banner ─────────────────────────────────────────────
class _GpsOffBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.mahogany.withOpacity(0.95),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.location_off, color: AppColors.gold, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                translations['gps_off_banner'] ?? 'GPS ปิดอยู่ — เปิดเพื่อใช้งานแผนที่และนำทาง',
                style: const TextStyle(
                  fontFamily: 'Noto Serif Thai',
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            GestureDetector(
              onTap: Geolocator.openLocationSettings,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                ),
                child: Text(
                  translations['gps_open'] ?? 'เปิด GPS',
                  style: const TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontSize: 11,
                    color: AppColors.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── GPS permission explanation dialog ─────────────────────────
class _GpsPermissionDialog extends StatelessWidget {
  final Map<String, String> translations;
  const _GpsPermissionDialog({required this.translations});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.espresso,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.location_on, color: AppColors.gold, size: 36),
            ),
            const SizedBox(height: 20),
            Text(
              translations['gps_permission_title'] ?? 'แอปนี้ต้องการตำแหน่ง GPS',
              style: const TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              translations['gps_permission_desc'] ??
                  'ฟีเจอร์หลักของแอปคือการนำทางไปยัง 6 สถานที่ริมน้ำจันทบูร GPS จำเป็นสำหรับแสดงตำแหน่งของคุณบนแผนที่และวัดระยะทาง',
              style: TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 13,
                color: Colors.white.withOpacity(0.7),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.espresso,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(
                  translations['gps_allow'] ?? 'อนุญาตการเข้าถึงตำแหน่ง',
                  style: const TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                translations['gps_skip_now'] ?? 'ข้ามตอนนี้',
                style: TextStyle(
                  fontFamily: 'Noto Serif Thai',
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.45),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nav item ───────────────────────────────────────────────────
class _NavItem extends ConsumerWidget {
  final int index;
  final IconData icon;
  final String labelKey;

  const _NavItem({
    required this.index,
    required this.icon,
    required this.labelKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isSelected = currentIndex == index;
    final translations = ref.watch(translationsProvider);
    final label = translations[labelKey] ?? labelKey;

    return GestureDetector(
      onTap: () => ref.read(bottomNavIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutQuint,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold.withOpacity(0.18) : Colors.transparent,
          border: isSelected
              ? Border.all(color: AppColors.gold.withOpacity(0.35), width: 1)
              : null,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.gold : Colors.white.withOpacity(0.38),
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
                          fontFamily: 'Noto Serif Thai',
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
