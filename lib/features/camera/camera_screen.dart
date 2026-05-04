import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../places/places_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final String placeId;
  const CameraScreen({super.key, required this.placeId});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> with SingleTickerProviderStateMixin {
  bool _isFlashing = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Animation สำหรับจุดโฟกัสตรงกลาง (Pulsing Dot)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _takePicture() async {
    setState(() => _isFlashing = true);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _isFlashing = false);
    
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 1));
    
    // Update State (อัปเดตสถานะว่าทำภารกิจสำเร็จ)
    ref.read(placesProvider.notifier).completeMission(widget.placeId);
    
    // Pop back to success screen
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลสถานที่เพื่อมาแสดงชื่อ
    final places = ref.watch(placesProvider);
    final place = places.firstWhere(
      (p) => p.id == widget.placeId, 
      orElse: () => places.first, // Fallback
    );
    final currentIndex = places.indexOf(place);

    return Scaffold(
      backgroundColor: const Color(0xFF050302), // สีพื้นหลังเข้มสุด
      body: Column(
        children: [
          // 1. ส่วนช่องมองภาพกล้อง (Viewfinder)
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Mock Camera Feed (ภาพจากกล้อง)
                Image.network(
                  place.imageUrl.isNotEmpty 
                      ? place.imageUrl 
                      : 'https://images.unsplash.com/photo-1565551980860-90fb33767f4a?q=80&w=800&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),

                // เส้น Grid บางๆ สไตล์กล้อง
                CustomPaint(painter: _ViewfinderGridPainter()),

                // กรอบ Bracket สีทอง 4 มุม
                const Positioned(top: 80, left: 24, child: _CornerBracket(alignment: Alignment.topLeft)),
                const Positioned(top: 80, right: 24, child: _CornerBracket(alignment: Alignment.topRight)),
                const Positioned(bottom: 24, left: 24, child: _CornerBracket(alignment: Alignment.bottomLeft)),
                const Positioned(bottom: 24, right: 24, child: _CornerBracket(alignment: Alignment.bottomRight)),

                // จุด Focus กระพริบตรงกลาง
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Opacity(
                          opacity: 1.0 - ((_pulseAnimation.value - 1.0) / 0.6) * 0.5,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.gold.withOpacity(0.65), width: 1.5),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Top HUD (แถบข้อมูลด้านบน)
                Positioned(
                  top: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(top: 54, left: 20, right: 20, bottom: 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'กำลังถ่าย · SHOOTING',
                              style: TextStyle(
                                fontFamily: 'Cormorant Garamond',
                                fontSize: 10,
                                letterSpacing: 3,
                                color: Colors.white.withOpacity(0.45),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              place.name,
                              style: const TextStyle(
                                fontFamily: 'Noto Serif Thai',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.2),
                            border: Border.all(color: AppColors.gold.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            '${currentIndex + 1} / ${places.length}',
                            style: const TextStyle(
                              fontFamily: 'Cormorant Garamond',
                              fontSize: 10,
                              letterSpacing: 2,
                              color: AppColors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Flash Effect
                if (_isFlashing)
                  Container(color: Colors.white),
              ],
            ),
          ),

          // 2. ส่วนควบคุมด้านล่าง (Bottom Controls)
          Container(
            color: const Color(0xFF0A0704),
            padding: const EdgeInsets.only(top: 16, bottom: 40, left: 24, right: 24),
            child: Column(
              children: [
                // จุด Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(places.length, (index) {
                    bool isCur = index == currentIndex;
                    bool isDone = index < currentIndex;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isCur ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDone 
                            ? AppColors.sage 
                            : (isCur ? AppColors.gold : Colors.white.withOpacity(0.1)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                
                // คำใบ้
                Text(
                  'จัดเฟรมให้เห็นสถานที่แล้วกดถ่าย',
                  style: TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.3),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),

                // แถบปุ่มกด
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ปุ่มเปิดแฟลช
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.white.withOpacity(0.09)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.flash_on, color: Colors.white.withOpacity(0.7), size: 20),
                        onPressed: () {}, // TODO: Toggle Flash
                      ),
                    ),
                    
                    // ปุ่ม Shutter (Premium Style)
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 76,
                        height: 76,
                        padding: const EdgeInsets.all(4), // ระยะห่างวงใน
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.white.withOpacity(0.08), blurRadius: 20)
                          ],
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),

                    // ปุ่มปิด/กลับ
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                        border: Border.all(color: Colors.white.withOpacity(0.09)),
                      ),
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.white.withOpacity(0.7), size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

// ==========================================
// Widget วาดมุมกรอบโฟกัส (Brackets)
// ==========================================
class _CornerBracket extends StatelessWidget {
  final Alignment alignment;
  const _CornerBracket({required this.alignment});

  @override
  Widget build(BuildContext context) {
    const double size = 32;
    const double strokeWidth = 2.5;
    final color = AppColors.gold.withOpacity(0.7);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // เส้นแนวนอน
          Positioned(
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight) ? 0 : null,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight) ? 0 : null,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) ? 0 : null,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight) ? 0 : null,
            child: Container(width: size, height: strokeWidth, color: color),
          ),
          // เส้นแนวตั้ง
          Positioned(
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight) ? 0 : null,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight) ? 0 : null,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) ? 0 : null,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight) ? 0 : null,
            child: Container(width: strokeWidth, height: size, color: color),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// Painter สำหรับวาดลายเส้นแนวนอนบางๆ ในกล้อง
// ==========================================
class _ViewfinderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1.0;

    // วาดเส้นแนวนอนทุกๆ 4 pixels
    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}