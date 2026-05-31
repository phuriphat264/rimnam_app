import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _missionNotif = true;
  bool _updateNotif = false;
  bool _loading = true;

  static const _keyMission = 'notif_mission';
  static const _keyUpdate = 'notif_update';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _missionNotif = prefs.getBool(_keyMission) ?? true;
      _updateNotif = prefs.getBool(_keyUpdate) ?? false;
      _loading = false;
    });
  }

  Future<void> _setMission(bool v) async {
    setState(() => _missionNotif = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMission, v);
  }

  Future<void> _setUpdate(bool v) async {
    setState(() => _updateNotif = v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUpdate, v);
  }

  @override
  Widget build(BuildContext context) {
    final translations = ref.watch(translationsProvider);
    final lang = ref.watch(languageProvider) ?? 'th';

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.espresso,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          translations['appbar_notifications'] ?? 'การแจ้งเตือน',
          style: TextStyle(
            fontFamily: lang == 'en' ? 'Cormorant Garamond' : 'Noto Serif Thai',
            fontSize: lang == 'en' ? 14 : 16,
            letterSpacing: lang == 'en' ? 4 : 1,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  translations['notif_title'] ?? 'การแจ้งเตือน',
                  style: const TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 16),

                _NotifTile(
                  icon: Icons.flag_outlined,
                  title: translations['notif_mission_name'] ?? 'ภารกิจและสถานที่',
                  subtitle: translations['notif_mission_desc'] ?? 'แจ้งเตือนเมื่อมีภารกิจใหม่หรืออัปเดตสถานที่',
                  value: _missionNotif,
                  onChanged: _setMission,
                ),
                const SizedBox(height: 12),
                _NotifTile(
                  icon: Icons.system_update_outlined,
                  title: translations['notif_app_update'] ?? 'อัปเดตแอพพลิเคชัน',
                  subtitle: translations['notif_app_update_desc'] ?? 'แจ้งเตือนเมื่อมีเวอร์ชันใหม่',
                  value: _updateNotif,
                  onChanged: _setUpdate,
                ),

                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.06)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.amber.withOpacity(0.6), size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          translations['notif_push_note'] ?? 'การแจ้งเตือน push notification จะเปิดใช้งานในเวอร์ชันถัดไป',
                          style: TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.4),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.gold, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.gold,
            activeTrackColor: AppColors.gold.withOpacity(0.3),
            inactiveThumbColor: Colors.white24,
            inactiveTrackColor: Colors.white10,
          ),
        ],
      ),
    );
  }
}
