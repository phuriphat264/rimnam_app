import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CompletionScreen extends StatefulWidget {
  const CompletionScreen({super.key});

  @override
  State<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends State<CompletionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..forward();
    _scaleAnimation = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold.withOpacity(0.1),
                    border: Border.all(color: AppColors.gold, width: 2),
                  ),
                  child: const Icon(Icons.emoji_events_rounded, size: 80, color: AppColors.gold),
                ),
              ),
              const SizedBox(height: 40),
              
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                ),
                child: const Column(
                  children: [
                    Text(
                      'ภารกิจสำเร็จ!',
                      style: TextStyle(fontSize: 32, color: AppColors.gold, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'คุณได้เก็บภาพความทรงจำชุมชนริมน้ำจันทบูรครบทั้ง 6 จุดแล้ว',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.cream, height: 1.5),
                    ),
                    SizedBox(height: 32),
                    Text(
                      '👉 กรุณาแสดงหน้านี้ที่ "ร้านรำไพ"\nเพื่อรับของที่ระลึกสุดพิเศษ',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, color: AppColors.amber, fontWeight: FontWeight.bold, height: 1.5),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 64),
              
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.share_rounded),
                label: const Text('แชร์ภาพถ่ายของคุณ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                onPressed: () {
                  // TODO: Navigate to Share Screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}