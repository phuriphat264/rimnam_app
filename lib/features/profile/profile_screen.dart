import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../../core/services/api_service.dart';
import '../places/places_provider.dart';
import '../auth/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'help_screen.dart';
import '../language/language_screen.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  try {
    return await ApiService().get('/users/me');
  } catch (_) {
    return null;
  }
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedCount = ref.watch(completedCountProvider);
    final totalPlaces = ref.watch(placesProvider).length;
    final isAllDone = completedCount == totalPlaces;
    final translations = ref.watch(translationsProvider);
    final lang = ref.watch(languageProvider) ?? 'th';
    final userAsync = ref.watch(userProfileProvider);
    final user = userAsync.valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.espresso,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          translations['appbar_profile'] ?? 'โปรไฟล์',
          style: TextStyle(
            fontFamily: lang == 'en' ? 'Cormorant Garamond' : 'Noto Serif Thai',
            fontSize: lang == 'en' ? 14 : 18,
            letterSpacing: lang == 'en' ? 4 : 1,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── User Info ──────────────────────────────────────
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 2),
                    ),
                    child: ClipOval(
                      child: user?['avatar_url'] != null
                          ? Image.network(
                              (user!['avatar_url'] as String).startsWith('http')
                                  ? user['avatar_url']
                                  : '${kBaseUrl.replaceAll('/api/v1', '')}${user['avatar_url']}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _defaultAvatar(),
                            )
                          : _defaultAvatar(),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      ).then((_) => ref.invalidate(userProfileProvider)),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 13, color: AppColors.ink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ชื่อ
            userAsync.isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  )
                : Text(
                    user?['display_name'] ?? translations['profile_name'] ?? 'นักสำรวจนิรนาม',
                    style: const TextStyle(
                      fontFamily: 'Noto Serif Thai',
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            const SizedBox(height: 4),
            Text(
              user?['email'] ?? '',
              style: TextStyle(
                fontFamily: 'Noto Serif Thai',
                fontSize: 12,
                color: Colors.white.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 30),

            // ── Travel Stats ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  _StatBox(
                    title: translations['profile_places_visited'] ?? 'สถานที่ที่ไปแล้ว',
                    value: '$completedCount',
                    icon: Icons.location_on,
                  ),
                  const SizedBox(width: 14),
                  _StatBox(
                    title: translations['profile_total_missions'] ?? 'ภารกิจทั้งหมด',
                    value: '$totalPlaces',
                    icon: Icons.flag,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ── Stamp Book ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    translations['profile_stamp_book'] ?? 'สมุดสะสมตราประทับ',
                    style: const TextStyle(
                      fontFamily: 'Noto Serif Thai',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isAllDone
                          ? AppColors.mahogany.withOpacity(0.3)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAllDone
                            ? AppColors.gold.withOpacity(0.5)
                            : Colors.white.withOpacity(0.07),
                      ),
                    ),
                    child: Row(
                      children: [
                        Opacity(
                          opacity: isAllDone ? 1.0 : 0.3,
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isAllDone
                                  ? AppColors.gold.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.1),
                            ),
                            child: Icon(
                              isAllDone ? Icons.workspace_premium : Icons.lock,
                              color: isAllDone ? AppColors.gold : Colors.white54,
                              size: 28,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                translations['profile_mission_name'] ?? 'ภารกิจชุมชนริมน้ำจันทบูร',
                                style: TextStyle(
                                  fontFamily: 'Noto Serif Thai',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: isAllDone ? Colors.white : Colors.white54,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAllDone
                                    ? (translations['profile_completed_today'] ?? 'สำเร็จแล้ว!')
                                    : '${translations['profile_progress'] ?? 'ความคืบหน้า: '}$completedCount/$totalPlaces',
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
                ],
              ),
            ),
            const SizedBox(height: 30),

            // ── Settings ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _SettingsMenu(
                    icon: Icons.person_outline,
                    title: translations['profile_edit'] ?? 'แก้ไขข้อมูลส่วนตัว',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    ).then((_) => ref.invalidate(userProfileProvider)),
                  ),
                  _SettingsMenu(
                    icon: Icons.notifications_none,
                    title: translations['profile_notifications'] ?? 'การแจ้งเตือน',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                  ),
                  _SettingsMenu(
                    icon: Icons.help_outline,
                    title: translations['profile_help'] ?? 'ศูนย์ช่วยเหลือ',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HelpScreen()),
                    ),
                  ),
                  Divider(color: Colors.white.withOpacity(0.08), height: 32),
                  _SettingsMenu(
                    icon: Icons.logout,
                    title: translations['profile_logout'] ?? 'ออกจากระบบ',
                    isDestructive: true,
                    onTap: () async {
                      await ref.read(authProvider.notifier).logout();
                      ref.invalidate(placesProvider);
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const LanguageScreenPremium()),
                          (r) => false,
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 110),
          ],
        ),
      ),
    );
  }
}

Widget _defaultAvatar() => Container(
      color: AppColors.espresso,
      child: const Icon(Icons.person, color: AppColors.gold, size: 40),
    );

// ── Stat Box ───────────────────────────────────────────────────
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
          border: Border.all(color: Colors.white.withOpacity(0.06)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.gold.withOpacity(0.7), size: 22),
            const SizedBox(height: 10),
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
                fontSize: 12,
                color: Colors.white.withOpacity(0.45),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Settings Menu Item ─────────────────────────────────────────
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: isDestructive
              ? Colors.red.withOpacity(0.1)
              : AppColors.gold.withOpacity(0.08),
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.redAccent : Colors.white70,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Noto Serif Thai',
                      fontSize: 14,
                      color: isDestructive ? Colors.redAccent : Colors.white,
                    ),
                  ),
                ),
                if (!isDestructive)
                  const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
