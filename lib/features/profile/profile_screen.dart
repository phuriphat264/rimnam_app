import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../../core/services/api_service.dart';
import '../places/places_provider.dart';
import '../places/place_model.dart';
import '../auth/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'help_screen.dart';
import '../language/language_screen.dart';
import '../share/share_screen.dart';
import '../history/history_screen.dart';
import '../../core/widgets/place_icon.dart';

final userProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  // watch authProvider เพื่อ refresh อัตโนมัติเมื่อ login/logout
  ref.watch(authProvider);
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
    final places = ref.watch(placesProvider);
    final totalPlaces = places.length;
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
            const SizedBox(height: 28),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.ink, width: 2),
                        ),
                        child: const Icon(Icons.edit, size: 12, color: AppColors.ink),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ชื่อ
            userAsync.isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                  )
                : Text(
                    user?['display_name'] ?? translations['profile_name'] ?? 'นักสำรวจนิรนาม',
                    style: const TextStyle(
                      fontFamily: 'Noto Serif Thai',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
            const SizedBox(height: 4),
            if ((user?['email'] ?? '').isNotEmpty)
              Text(
                user?['email'] ?? '',
                style: TextStyle(
                  fontFamily: 'Noto Serif Thai',
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.40),
                ),
              ),
            const SizedBox(height: 28),

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
            const SizedBox(height: 24),

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
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const HistoryScreen()),
                    ),
                    child: Container(
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
                        const Icon(Icons.chevron_right,
                            color: AppColors.gold),
                      ],
                    ),
                  ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Journey Photos ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        translations['profile_journey_photos'] ?? 'ภาพการเดินทาง',
                        style: const TextStyle(
                          fontFamily: 'Noto Serif Thai',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ShareScreen()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.gold.withOpacity(0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.share,
                                  color: AppColors.gold, size: 14),
                              const SizedBox(width: 5),
                              Text(
                                translations['share_to'] ?? 'แชร์',
                                style: const TextStyle(
                                  fontFamily: 'Noto Serif Thai',
                                  fontSize: 12,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: places.length,
                    itemBuilder: (ctx, i) {
                      final place = places[i];
                      final isDone = place.status == PlaceStatus.done;
                      final hasPhoto = place.capturedPhotoPath != null;
                      return _JourneyPhotoCell(
                        place: place,
                        isDone: isDone,
                        hasPhoto: hasPhoto,
                        index: i,
                        onTap: (isDone && hasPhoto)
                            ? () => Navigator.of(ctx).push(PageRouteBuilder(
                                  opaque: false,
                                  pageBuilder: (_, __, ___) =>
                                      _JourneyPhotoViewer(place: place),
                                  transitionsBuilder: (_, anim, __, child) =>
                                      FadeTransition(
                                          opacity: anim, child: child),
                                  transitionDuration:
                                      const Duration(milliseconds: 220),
                                ))
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Divider(color: Colors.white.withOpacity(0.08), height: 1),
            ),

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
                    icon: Icons.language,
                    title: translations['settings_language'] ?? 'เปลี่ยนภาษา',
                    trailing: _LangBadge(lang: lang),
                    onTap: () => _showLanguagePicker(context, ref, lang),
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
            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }
}

// ── Language picker bottom sheet ───────────────────────────────
void _showLanguagePicker(BuildContext context, WidgetRef ref, String currentLang) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _LanguagePickerSheet(currentLang: currentLang, ref: ref),
  );
}

class _LanguagePickerSheet extends StatelessWidget {
  final String currentLang;
  final WidgetRef ref;

  const _LanguagePickerSheet({required this.currentLang, required this.ref});

  static const _langs = [
    ('th', 'ภาษาไทย', 'THAI', '🇹🇭'),
    ('zh', '中文', 'CHINESE', '🇨🇳'),
    ('en', 'English', 'ENGLISH', '🇬🇧'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.espresso,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                const Icon(Icons.language, color: AppColors.gold, size: 18),
                const SizedBox(width: 10),
                const Text(
                  'เลือกภาษา  ·  LANGUAGE',
                  style: TextStyle(
                    fontFamily: 'Cormorant Garamond',
                    fontSize: 13,
                    letterSpacing: 2,
                    color: AppColors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ..._langs.map((item) {
            final (code, name, subtitle, flag) = item;
            final isSelected = currentLang == code;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  splashColor: AppColors.gold.withOpacity(0.1),
                  highlightColor: Colors.transparent,
                  onTap: () {
                    ref.read(languageProvider.notifier).state = code;
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gold.withOpacity(0.12)
                          : Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.gold.withOpacity(0.5)
                            : Colors.white.withOpacity(0.07),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(flag, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontFamily: 'Noto Serif Thai',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppColors.gold : Colors.white,
                                ),
                              ),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontFamily: 'Cormorant Garamond',
                                  fontSize: 11,
                                  letterSpacing: 2,
                                  color: Colors.white.withOpacity(0.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle,
                              color: AppColors.gold, size: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

// แสดง badge ภาษาปัจจุบันข้างๆ ปุ่มเปลี่ยนภาษา
class _LangBadge extends StatelessWidget {
  final String lang;
  const _LangBadge({required this.lang});

  static const _flags = {'th': '🇹🇭', 'zh': '🇨🇳', 'en': '🇬🇧'};
  static const _labels = {'th': 'ไทย', 'zh': '中文', 'en': 'EN'};

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(_flags[lang] ?? '🌐', style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 5),
        Text(
          _labels[lang] ?? lang,
          style: const TextStyle(
            fontFamily: 'Noto Serif Thai',
            fontSize: 12,
            color: AppColors.amber,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.chevron_right, color: Colors.white24, size: 18),
      ],
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

// ── Journey Photo Cell ─────────────────────────────────────────
class _JourneyPhotoCell extends StatelessWidget {
  final Place place;
  final bool isDone;
  final bool hasPhoto;
  final int index;
  final VoidCallback? onTap;

  const _JourneyPhotoCell({
    required this.place,
    required this.isDone,
    required this.hasPhoto,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── รูปภาพหลัก ──
          if (hasPhoto && isDone)
            Image.file(
              File(place.capturedPhotoPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _iconPlaceholder(isDone),
            )
          else
            _iconPlaceholder(isDone),

          // ── gradient + ชื่อสถานที่ สำหรับ done ──
          if (isDone)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.72),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  place.name,
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

          // ── check badge ──
          if (isDone)
            const Positioned(
              top: 4,
              right: 4,
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 8,
                child:
                    Icon(Icons.check_circle, color: AppColors.sage, size: 14),
              ),
            ),

          // ── border ──
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDone
                    ? AppColors.gold.withOpacity(0.4)
                    : Colors.white.withOpacity(0.06),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    ),  // ClipRRect
    );  // GestureDetector
  }

  Widget _iconPlaceholder(bool isDone) {
    return Container(
      color: AppColors.espresso,
      child: Center(
        child: PlaceIcon(
          placeId: place.id,
          size: 36,
          color: isDone
              ? AppColors.amber.withOpacity(0.7)
              : AppColors.mahogany.withOpacity(0.4),
        ),
      ),
    );
  }
}

// ── Journey Photo Fullscreen Viewer ───────────────────────────
class _JourneyPhotoViewer extends StatefulWidget {
  final Place place;
  const _JourneyPhotoViewer({required this.place});

  @override
  State<_JourneyPhotoViewer> createState() => _JourneyPhotoViewerState();
}

class _JourneyPhotoViewerState extends State<_JourneyPhotoViewer> {
  bool _isSaving = false;

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _snack('ไม่ได้รับสิทธิ์เข้าถึง Gallery');
          return;
        }
      }
      final bytes = await File(widget.place.capturedPhotoPath!).readAsBytes();
      await Gal.putImageBytes(bytes,
          name: 'chan_river_${DateTime.now().millisecondsSinceEpoch}');
      _snack('บันทึกรูปสำเร็จ', isSuccess: true);
    } catch (_) {
      _snack('บันทึกไม่สำเร็จ กรุณาลองใหม่');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _share() async {
    await Share.shareXFiles(
      [XFile(widget.place.capturedPhotoPath!, mimeType: 'image/jpeg')],
      text: widget.place.name,
    );
  }

  void _snack(String msg, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: const TextStyle(
              fontFamily: 'Noto Serif Thai', color: Colors.white)),
      backgroundColor: isSuccess ? AppColors.gold : AppColors.mahogany,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // รูปเต็มจอ
          InteractiveViewer(
            minScale: 0.9,
            maxScale: 4.0,
            child: Center(
              child: Image.file(
                File(widget.place.capturedPhotoPath!),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white24,
                    size: 64),
              ),
            ),
          ),

          // ปุ่มปิด
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.25)),
                    ),
                    child: const Icon(Icons.close,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ),
          ),

          // ชื่อสถานที่บนสุด
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 56, 0),
                child: Text(
                  widget.place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
                  ),
                ),
              ),
            ),
          ),

          // ปุ่ม save + share ด้านล่าง
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                  24, 32, 24, MediaQuery.of(context).padding.bottom + 24),
              child: Row(
                children: [
                  // Save
                  Expanded(
                    child: GestureDetector(
                      onTap: _isSaving ? null : _save,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (_isSaving)
                              const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            else
                              const Icon(Icons.save_alt_rounded,
                                  color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _isSaving ? 'กำลังบันทึก...' : 'บันทึก',
                              style: const TextStyle(
                                fontFamily: 'Noto Serif Thai',
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Share
                  Expanded(
                    child: GestureDetector(
                      onTap: _share,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.share_rounded,
                                color: AppColors.ink, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'แชร์',
                              style: TextStyle(
                                fontFamily: 'Noto Serif Thai',
                                fontSize: 14,
                                color: AppColors.ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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

// ── Settings Menu Item ─────────────────────────────────────────
class _SettingsMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _SettingsMenu({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
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
                // ถ้ามี trailing ใช้ trailing แทน chevron
                trailing ??
                    (isDestructive
                        ? const SizedBox.shrink()
                        : const Icon(Icons.chevron_right,
                            color: Colors.white24, size: 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
