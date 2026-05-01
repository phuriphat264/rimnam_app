import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.ink,
        title: const Text('การตั้งค่า', style: TextStyle(color: AppColors.gold)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildSettingItem(Icons.person_outline, 'ข้อมูลส่วนตัว'),
          _buildSettingItem(Icons.language, 'เปลี่ยนภาษา'),
          _buildSettingItem(Icons.notifications_none, 'การแจ้งเตือน'),
          _buildSettingItem(Icons.help_outline, 'ความช่วยเหลือ'),
          const SizedBox(height: 32),
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('ออกจากระบบ', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
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
