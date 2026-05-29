import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../places/places_provider.dart';
import '../places/place_model.dart';
import '../map/map_provider.dart';
import '../mission/completion_screen.dart';

class CameraScreen extends ConsumerStatefulWidget {
  final String placeId;
  const CameraScreen({super.key, required this.placeId});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraReady = false;
  bool _cameraError = false;
  bool _isFlashing = false;
  bool _isProcessing = false;

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
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        if (mounted) setState(() => _cameraError = true);
        return;
      }
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      _cameraController = controller;
      setState(() => _isCameraReady = true);
    } catch (_) {
      if (mounted) setState(() => _cameraError = true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (_isProcessing || !_isCameraReady || _cameraController == null) return;

    setState(() => _isFlashing = true);
    await Future.delayed(const Duration(milliseconds: 80));
    setState(() => _isFlashing = false);

    setState(() => _isProcessing = true);

    try {
      await _cameraController!.takePicture();
    } catch (_) {
      // ถ่ายไม่ได้ก็ยังนับว่าเสร็จภารกิจ
    }

    if (!mounted) return;

    setState(() => _isFlashing = true);
    await Future.delayed(const Duration(milliseconds: 150));
    setState(() => _isFlashing = false);
    await Future.delayed(const Duration(milliseconds: 400));

    ref.read(placesProvider.notifier).completeMission(widget.placeId);
    final places = ref.read(placesProvider);
    final isAllDone = places.every((p) => p.status == PlaceStatus.done);

    if (!mounted) return;
    setState(() => _isProcessing = false);

    if (isAllDone) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CompletionScreen()),
        (route) => false,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    final translations = ref.watch(translationsProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final userPos = locationAsync.valueOrNull;

    final place = places.firstWhere(
      (p) => p.id == widget.placeId,
      orElse: () => places.first,
    );
    final currentIndex = places.indexOf(place);
    final dist = distanceToStation(userPos, widget.placeId);
    final bool gpsLoading = locationAsync.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF050302),
      body: Column(
        children: [
          // ========== Viewfinder ==========
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                // กล้องจริง
                if (_isCameraReady && _cameraController != null)
                  CameraPreview(_cameraController!)
                else if (_cameraError)
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.camera_alt_outlined,
                            color: Colors.white30, size: 48),
                        SizedBox(height: 12),
                        Text(
                          'ไม่พบกล้อง\nกรุณาตรวจสอบสิทธิ์การใช้งาน',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white38,
                            fontFamily: 'Noto Serif Thai',
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation(Colors.white30),
                      strokeWidth: 1.5,
                    ),
                  ),

                // dim overlay
                if (_isCameraReady)
                  Container(color: Colors.black.withOpacity(0.10)),

                // เส้นกริด
                CustomPaint(painter: _ViewfinderGridPainter()),

                // กรอบมุม 4 ด้าน
                const Positioned(
                    top: 90,
                    left: 24,
                    child: _CornerBracket(alignment: Alignment.topLeft)),
                const Positioned(
                    top: 90,
                    right: 24,
                    child: _CornerBracket(alignment: Alignment.topRight)),
                const Positioned(
                    bottom: 24,
                    left: 24,
                    child:
                        _CornerBracket(alignment: Alignment.bottomLeft)),
                const Positioned(
                    bottom: 24,
                    right: 24,
                    child:
                        _CornerBracket(alignment: Alignment.bottomRight)),

                // จุดโฟกัสกระพริบ
                Center(
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) => Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Opacity(
                        opacity: 1.0 -
                            ((_pulseAnimation.value - 1.0) / 0.6) * 0.5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.65),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ========== HUD บน ==========
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.75),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    translations['camera_shooting'] ??
                                        'กำลังถ่าย · SHOOTING',
                                    style: const TextStyle(
                                      fontFamily: 'Cormorant Garamond',
                                      fontSize: 10,
                                      letterSpacing: 3,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    translations[
                                            'place_${place.id}_name'] ??
                                        place.name,
                                    style: const TextStyle(
                                      fontFamily: 'Noto Serif Thai',
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.2),
                                border: Border.all(
                                    color: AppColors.gold.withOpacity(0.4)),
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
                  ),
                ),

                // ========== GPS badge ==========
                Positioned(
                  left: 20,
                  bottom: 24,
                  child: _GpsBadge(gpsLoading: gpsLoading, distance: dist),
                ),

                // แฟลช
                if (_isFlashing)
                  Container(color: Colors.white.withOpacity(0.85)),

                // Processing overlay
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.6),
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation(AppColors.gold),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'กำลังบันทึกภารกิจ...',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontFamily: 'Noto Serif Thai',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ========== Controls ด้านล่าง ==========
          Container(
            color: const Color(0xFF0A0704),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(places.length, (i) {
                        final isCur = i == currentIndex;
                        final isDone =
                            places[i].status == PlaceStatus.done;
                        return Container(
                          margin:
                              const EdgeInsets.symmetric(horizontal: 3),
                          width: isCur ? 18 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isDone
                                ? AppColors.sage
                                : (isCur
                                    ? AppColors.gold
                                    : Colors.white10),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      translations['camera_instruction'] ??
                          'กดปุ่มเพื่อถ่ายภาพ ณ สถานที่นี้',
                      style: TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.4),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: gpsLoading
                          ? Text(
                              'กำลังค้นหาตำแหน่ง GPS...',
                              key: const ValueKey('loading'),
                              style: TextStyle(
                                fontFamily: 'Noto Serif Thai',
                                fontSize: 11,
                                color: AppColors.honey.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              dist != null
                                  ? 'ระยะทางถึงสถานที่ ${formatDistance(dist)}'
                                  : 'ไม่พบตำแหน่ง GPS',
                              key: ValueKey(dist),
                              style: TextStyle(
                                fontFamily: 'Noto Serif Thai',
                                fontSize: 11,
                                color: Colors.white.withOpacity(0.55),
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _ControlButton(
                          icon: Icons.close,
                          onTap: () => Navigator.pop(context),
                        ),
                        _ShutterButton(
                          onTap: (_isProcessing || !_isCameraReady)
                              ? null
                              : _takePicture,
                          isProcessing: _isProcessing,
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GPS badge
// ============================================================
class _GpsBadge extends StatelessWidget {
  final bool gpsLoading;
  final double? distance;

  const _GpsBadge({required this.gpsLoading, required this.distance});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final IconData icon;
    final String label;

    if (gpsLoading) {
      color = AppColors.honey;
      icon = Icons.gps_not_fixed;
      label = 'กำลังหาตำแหน่ง...';
    } else if (distance != null) {
      color = AppColors.teal;
      icon = Icons.gps_fixed;
      label = 'ห่าง ${formatDistance(distance!)}';
    } else {
      color = Colors.white38;
      icon = Icons.location_off;
      label = 'ไม่พบ GPS';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.6), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontFamily: 'Noto Serif Thai',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ปุ่มชัตเตอร์
// ============================================================
class _ShutterButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isProcessing;

  const _ShutterButton({required this.onTap, required this.isProcessing});

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
          border: Border.all(
            color: onTap == null ? Colors.white12 : Colors.white54,
            width: 2,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: onTap == null ? Colors.white24 : Colors.white,
            shape: BoxShape.circle,
          ),
          child: isProcessing
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(AppColors.gold),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }
}

// ============================================================
// ปุ่มควบคุม (ปิด)
// ============================================================
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.05),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}

// ============================================================
// กรอบมุม Viewfinder
// ============================================================
class _CornerBracket extends StatelessWidget {
  final Alignment alignment;

  const _CornerBracket({required this.alignment});

  @override
  Widget build(BuildContext context) {
    const double size = 32;
    const double strokeWidth = 2.5;
    final color = AppColors.gold.withOpacity(0.7);

    final isTop = alignment == Alignment.topLeft ||
        alignment == Alignment.topRight;
    final isLeft = alignment == Alignment.topLeft ||
        alignment == Alignment.bottomLeft;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(width: size, height: strokeWidth, color: color),
          ),
          Positioned(
            top: isTop ? 0 : null,
            bottom: isTop ? null : 0,
            left: isLeft ? 0 : null,
            right: isLeft ? null : 0,
            child: Container(width: strokeWidth, height: size, color: color),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// เส้น Grid Viewfinder
// ============================================================
class _ViewfinderGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;
    // เส้น 3x3 grid
    canvas.drawLine(
        Offset(size.width / 3, 0), Offset(size.width / 3, size.height), paint);
    canvas.drawLine(Offset(size.width * 2 / 3, 0),
        Offset(size.width * 2 / 3, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height / 3), Offset(size.width, size.height / 3), paint);
    canvas.drawLine(Offset(0, size.height * 2 / 3),
        Offset(size.width, size.height * 2 / 3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
