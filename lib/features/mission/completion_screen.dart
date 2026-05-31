import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../share/share_screen.dart';
import '../main/main_screen.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({super.key});

  @override
  ConsumerState<CompletionScreen> createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // แอนิเมชันเดิมของคุณ (เด้งดึ๋ง)
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
    final translations = ref.watch(translationsProvider);
    return Scaffold(
      backgroundColor: AppColors.ink, // ใช้ AppColors.ink เป็นพื้นหลัง
      body: Stack(
        children: [
          // ==========================================
          // 1. เส้นวงกลมประดับพื้นหลัง
          // ==========================================
          Positioned(
            top: -100,
            left: MediaQuery.of(context).size.width / 2 - 200,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.05), width: 1),
              ),
            ),
          ),
          Positioned(
            top: -200,
            left: MediaQuery.of(context).size.width / 2 - 300,
            child: Container(
              width: 600,
              height: 600,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.gold.withOpacity(0.03), width: 1),
              ),
            ),
          ),

          // ==========================================
          // 2. เนื้อหาหลัก
          // ==========================================
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  
                  // เหรียญรางวัล + แอนิเมชันเด้งดึ๋งของคุณ
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const RadialGradient(
                          colors: [AppColors.amber, AppColors.gold],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.2),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.gold.withOpacity(0.3),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                          ),
                          child: const Icon(
                            Icons.workspace_premium, 
                            size: 50,
                            color: AppColors.mahogany, 
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ส่วนเนื้อหาด้านล่าง + แอนิเมชัน Fade ลอยขึ้นมาของคุณ
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                    ),
                    child: Column(
                      children: [
                        // ข้อความแสดงความยินดี
                        Text(
                          translations['completion_title'] ?? 'ภารกิจสำเร็จ!',
                          style: const TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          translations['completion_desc'] ?? 'สำรวจครบทั้ง 6 สถานที่แล้ว\nชุมชนริมน้ำจันทบูร',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // กล่องติ๊กถูก 6 กล่อง
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(6, (index) {
                            return Container(
                              width: 46,
                              height: 46,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.mahogany.withOpacity(0.6),
                                    AppColors.ink.withOpacity(0.8),
                                  ],
                                ),
                                border: Border.all(
                                  color: AppColors.gold.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.check_circle,
                                        color: AppColors.sage, // ใช้ AppColors.sage สำหรับสีเขียว
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 32),

                        // การ์ดรับของรางวัล
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.mahogany.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 4,
                                height: 70,
                                decoration: BoxDecoration(
                                  color: AppColors.gold,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.storefront, color: AppColors.gold.withOpacity(0.8), size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          translations['completion_reward_at'] ?? 'รับของรางวัลที่',
                                          style: TextStyle(
                                            fontFamily: 'Noto Serif Thai',
                                            fontSize: 12,
                                            color: AppColors.gold.withOpacity(0.8),
                                            letterSpacing: 1.2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      translations['completion_reward_place'] ?? 'ศูนย์การเรียนรู้\nชุมชนริมน้ำจันทบูร',
                                      style: const TextStyle(
                                        fontFamily: 'Noto Serif Thai',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, color: AppColors.sienna, size: 14),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            translations['completion_reward_note'] ?? 'จันทบุรี - แสดงหน้าจอนี้แก่เจ้าหน้าที่',
                                            style: TextStyle(
                                              fontFamily: 'Noto Serif Thai',
                                              fontSize: 11,
                                              color: Colors.white.withOpacity(0.5),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),

                  // ==========================================
                  // 3. ปุ่มกดด้านล่าง (เอาแอนิเมชัน Fade มาครอบด้วย)
                  // ==========================================
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1000), 
                    builder: (context, value, child) => Opacity(
                      opacity: value,
                      child: Transform.translate(offset: Offset(0, 20 * (1 - value)), child: child),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gold, AppColors.caramel],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const MainScreen()),
                                  (route) => false,
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    translations['completion_route'] ?? 'ดูเส้นทาง',
                                    style: const TextStyle(
                                      fontFamily: 'Noto Serif Thai',
                                      color: AppColors.ink,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_right_alt, color: AppColors.ink),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppColors.mahogany.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.share, color: AppColors.gold),
                            onPressed: () {
                              // นำทางไปยังหน้า ShareScreen
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ShareScreen()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}