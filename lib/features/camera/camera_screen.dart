import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../places/places_provider.dart';
import '../places/place_model.dart'; 

// เชื่อมต่อไฟล์หน้าความสำเร็จ
import '../mission/completion_screen.dart' ;

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

  // ==========================================
  // ฟังก์ชันถ่ายภาพและเช็คเงื่อนไขการไปหน้า Completion
  // ==========================================
  void _takePicture() async {
    setState(() => _isFlashing = true);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _isFlashing = false);
    
    // จำลองช่วงเวลาการประมวลผล (Processing)
    await Future.delayed(const Duration(seconds: 1));
    
    // 1. อัปเดตสถานะใน Provider ว่าด่านนี้สำเร็จแล้ว
    ref.read(placesProvider.notifier).completeMission(widget.placeId);
    
    // 2. ตรวจสอบว่าทำครบทุกด่าน (6/6) หรือยัง
    final places = ref.read(placesProvider);
    final isAllDone = places.every((p) => p.status == PlaceStatus.done);

    if (mounted) {
      if (isAllDone) {
        // ถ้าครบทุกด่าน: นำทางไปหน้า CompletionScreen
        // ใช้ pushAndRemoveUntil เพื่อล้าง stack ไม่ให้กดย้อนกลับมาหน้ากล้องได้
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const CompletionScreen()),
          (route) => false, 
        );
      } else {
        // ถ้ายังไม่ครบ: กลับไปหน้าก่อนหน้า (Detail) ปกติ
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงข้อมูลสถานที่ทั้งหมดจาก Provider
    final places = ref.watch(placesProvider);
    
    // ค้นหาสถานที่ปัจจุบันจาก ID
    final place = places.firstWhere(
      (p) => p.id == widget.placeId, 
      orElse: () => places.first,
    );
    
    // หาตำแหน่ง Index ของสถานที่นี้
    final currentIndex = places.indexOf(place);

    return Scaffold(
      backgroundColor: const Color(0xFF050302),
      body: Column(
        children: [
          // ส่วน Viewfinder (ช่องมองภาพ)
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // แสดงภาพจำลองจากสถานที่
                Image.network(
                  place.imageUrl.isNotEmpty 
                      ? place.imageUrl 
                      : 'https://images.unsplash.com/photo-1565551980860-90fb33767f4a?q=80&w=800&auto=format&fit=crop',
                  fit: BoxFit.cover,
                ),

                // เส้นกริดของกล้อง
                CustomPaint(painter: _ViewfinderGridPainter()),

                // กรอบมุมทั้ง 4 ด้าน
                const Positioned(top: 80, left: 24, child: _CornerBracket(alignment: Alignment.topLeft)),
                const Positioned(top: 80, right: 24, child: _CornerBracket(alignment: Alignment.topRight)),
                const Positioned(bottom: 24, left: 24, child: _CornerBracket(alignment: Alignment.bottomLeft)),
                const Positioned(bottom: 24, right: 24, child: _CornerBracket(alignment: Alignment.bottomRight)),

                // จุดโฟกัสกระพริบตรงกลาง
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

                // ส่วน HUD ด้านบน (แสดงชื่อสถานที่และจำนวนด่าน)
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
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'กำลังถ่าย · SHOOTING',
                              style: TextStyle(
                                fontFamily: 'Cormorant Garamond',
                                fontSize: 10,
                                letterSpacing: 3,
                                color: Colors.white70,
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
                              color: AppColors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // เอฟเฟกต์แฟลชเมื่อกดถ่าย
                if (_isFlashing) Container(color: Colors.white),
              ],
            ),
          ),

          // ส่วนควบคุมด้านล่าง (Bottom Controls)
          Container(
            color: const Color(0xFF0A0704),
            padding: const EdgeInsets.only(top: 16, bottom: 40, left: 24, right: 24),
            child: Column(
              children: [
                // แสดงจุด Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(places.length, (index) {
                    bool isCur = index == currentIndex;
                    bool isDone = places[index].status == PlaceStatus.done;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: isCur ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: isDone 
                            ? AppColors.sage 
                            : (isCur ? AppColors.gold : Colors.white10),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  'จัดเฟรมให้เห็นสถานที่แล้วกดถ่าย',
                  style: TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
                const SizedBox(height: 24),
                // แถบปุ่มกดแฟลช, ชัตเตอร์ และปุ่มปิด
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ControlButton(icon: Icons.flash_on, onTap: () {}),
                    _ShutterButton(onTap: _takePicture),
                    _ControlButton(icon: Icons.close, onTap: () => Navigator.pop(context)),
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

// Widget ปุ่มชัตเตอร์
class _ShutterButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ShutterButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        height: 76,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 2),
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

// Widget ปุ่มควบคุมจิปาถะ (แฟลช, ปิด)
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white10),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white70, size: 20),
        onPressed: onTap,
      ),
    );
  }
}

// Widget วาดมุมกรอบในกล้อง
class _CornerBracket extends StatelessWidget {
  final Alignment alignment;
  const _CornerBracket({required this.alignment});

  @override
  Widget build(BuildContext context) {
    const double size = 32;
    const double strokeWidth = 2.5;
    final color = AppColors.gold.withOpacity(0.7);

    return SizedBox(
      width: size, height: size,
      child: Stack(
        children: [
          Positioned(
            top: (alignment == Alignment.topLeft || alignment == Alignment.topRight) ? 0 : null,
            bottom: (alignment == Alignment.bottomLeft || alignment == Alignment.bottomRight) ? 0 : null,
            left: (alignment == Alignment.topLeft || alignment == Alignment.bottomLeft) ? 0 : null,
            right: (alignment == Alignment.topRight || alignment == Alignment.bottomRight) ? 0 : null,
            child: Container(width: size, height: strokeWidth, color: color),
          ),
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

// Painter สำหรับวาดลายเส้นเส้น Grid
class _ViewfinderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.06)
      ..strokeWidth = 1.0;
    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}