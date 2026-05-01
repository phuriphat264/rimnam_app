import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../places/places_provider.dart';
import 'widgets/grid_collage_widget.dart';

class ShareScreen extends ConsumerWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ในการใช้งานจริง จะกรองเอาเฉพาะ Place ที่สถานะเป็น Done
    final places = ref.watch(placesProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gold),
        title: const Text(
          'ความทรงจำริมน้ำจันทบูร',
          style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Frame โชว์รูปภาพ
            GridCollageWidget(places: places),
            
            const SizedBox(height: 48),
            
            // Share Panel
            const Text(
              'แชร์ไปยัง',
              style: TextStyle(fontSize: 18, color: AppColors.cream, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialIcon(Icons.facebook, 'Facebook', Colors.blueAccent),
                _buildSocialIcon(Icons.camera_alt, 'Instagram', Colors.pinkAccent),
                _buildSocialIcon(Icons.chat_bubble, 'LINE', Colors.green),
                _buildSocialIcon(Icons.close, 'X', Colors.white),
              ],
            ),
            
            const SizedBox(height: 48),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gold,
                  side: const BorderSide(color: AppColors.gold, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.save_alt_rounded),
                label: const Text('บันทึกลงเครื่อง', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  // TODO: Save to Gallery logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('บันทึกรูปภาพสำเร็จ', style: TextStyle(color: AppColors.ink)),
                      backgroundColor: AppColors.gold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: AppColors.cream, fontSize: 12)),
      ],
    );
  }
}