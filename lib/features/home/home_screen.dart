import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../main/main_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;
  late Animation<double> _bgScale;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this, 
      duration: const Duration(seconds: 15)
    )..repeat(reverse: true);
    
    _bgScale = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _bgController, curve: Curves.linear)
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Ken Burns Effect Background
          AnimatedBuilder(
            animation: _bgScale,
            builder: (context, child) {
              return Transform.scale(
                scale: _bgScale.value,
                child: Image.network(
                  'https://images.unsplash.com/photo-1548013146-72479768bbaa?q=80&w=1200',
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
          
          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.2),
                  AppColors.ink.withOpacity(0.8),
                  AppColors.ink,
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Text Content with Animation
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 40 * (1 - value)),
                        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n('welcome').toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.gold, 
                            fontSize: 16, 
                            letterSpacing: 4,
                            fontWeight: FontWeight.w600
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n('app_name'),
                          style: const TextStyle(
                            color: Colors.white, 
                            fontSize: 44, 
                            fontWeight: FontWeight.bold, 
                            height: 1.1,
                            fontFamily: 'Playfair Display'
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n('home_desc'),
                          style: TextStyle(
                            color: AppColors.cream.withOpacity(0.7), 
                            fontSize: 16, 
                            height: 1.6
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 12,
                        shadowColor: AppColors.gold.withOpacity(0.5),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.espresso,
                            title: const Text('📜 กติกาภารกิจ', style: TextStyle(color: AppColors.gold)),
                            content: const Text(
                              'ตามหาสถานที่สำคัญในชุมชนริมน้ำจันทบูร และถ่ายภาพเพื่อปลดล็อกเรื่องราวและรับของรางวัล!',
                              style: TextStyle(color: AppColors.cream),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // ปิด Popup
            
                                  // สลับไปยัง Tab แผนที่ (Index 1)
                                  ref.read(bottomNavIndexProvider.notifier).state = 1;
                                },
          child: const Text('เริ่มเลย!', style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
},
                      child: Text(
                        l10n('start_journey').toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          letterSpacing: 2
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}