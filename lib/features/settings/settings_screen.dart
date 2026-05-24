import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        title: Text(translations['settings_title'] ?? 'การตั้งค่า', style: const TextStyle(color: AppColors.gold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingItem(Icons.person_outline, translations['settings_profile'] ?? 'ข้อมูลส่วนตัว'),
          _buildSettingItem(Icons.language, translations['settings_language'] ?? 'เปลี่ยนภาษา'),
          _buildSettingItem(Icons.notifications_none, translations['settings_notifications'] ?? 'การแจ้งเตือน'),
          _buildSettingItem(Icons.help_outline, translations['settings_help'] ?? 'ความช่วยเหลือ'),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: Text(translations['settings_logout'] ?? 'ออกจากระบบ', style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppColors.gold),
      title: Text(title, style: const TextStyle(color: AppColors.cream)),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.mahogany, size: 16),
      onTap: () {},
    );
  }
}
