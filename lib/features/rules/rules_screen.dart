import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.espresso, AppColors.ink],
                ),
              ),
            ),
          ),
          
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 0.9 + (0.1 * value),
                  child: Opacity(
                    opacity: value.clamp(0.0, 1.0),
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.glassBackground,
                        border: Border.all(color: AppColors.glassBorder),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.menu_book_rounded, color: AppColors.gold, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'กติกาการร่วมสนุก',
                            style: TextStyle(
                              fontSize: 24,
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          _buildRuleItem('1', 'เดินทางไปยังจุดที่กำหนดทั้ง 6 สถานที่'),
                          const SizedBox(height: 16),
                          _buildRuleItem('2', 'เปิดกล้องและถ่ายภาพให้ตรงกับ Frame ที่กำหนด'),
                          const SizedBox(height: 16),
                          _buildRuleItem('3', 'สะสมภาพให้ครบ 6 จุด เพื่อรับของรางวัลสุดพิเศษ'),
                          const SizedBox(height: 48),
                          
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.ink,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                // TODO: Navigate to Map / Mission
                              },
                              child: const Text(
                                'รับทราบและเริ่มทำภารกิจ',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.gold,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.cream, fontSize: 15, height: 1.4),
          ),
        ),
      ],
    );
  }
}