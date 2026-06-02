import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class FullScreenImageViewer extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
  });

  static void show(
    BuildContext context,
    List<String> images, {
    int initialIndex = 0,
  }) {
    if (images.isEmpty) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        pageBuilder: (_, __, ___) => FullScreenImageViewer(
          images: images,
          initialIndex: initialIndex.clamp(0, images.length - 1),
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 220),
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late final PageController _pageController;
  late int _currentIndex;

  // swipe-down dismiss state
  double _dragOffsetY = 0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails d) {
    if (_isDismissing) return;
    setState(() => _dragOffsetY += d.delta.dy);
  }

  void _onVerticalDragEnd(DragEndDetails d) {
    if (_isDismissing) return;
    final vel = d.velocity.pixelsPerSecond.dy;
    if (_dragOffsetY > 110 || vel > 600) {
      setState(() => _isDismissing = true);
      Navigator.of(context).pop();
    } else {
      setState(() => _dragOffsetY = 0);
    }
  }

  double get _bgOpacity => (1.0 - (_dragOffsetY.abs() / 350).clamp(0.0, 0.85));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(_bgOpacity),
      body: GestureDetector(
        // Only track vertical drags for dismiss (horizontal handled by PageView)
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            // ===== Image PageView =====
            Transform.translate(
              offset: Offset(0, _dragOffsetY),
              child: PageView.builder(
                controller: _pageController,
                itemCount: widget.images.length,
                onPageChanged: (i) => setState(() => _currentIndex = i),
                itemBuilder: (_, i) => InteractiveViewer(
                  minScale: 0.9,
                  maxScale: 4.0,
                  child: Center(
                    child: Image.asset(
                      widget.images[i],
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.sienna,
                            size: 72,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'ไม่พบรูปภาพ',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontFamily: 'Noto Serif Thai',
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ===== Top bar (counter + close) =====
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (widget.images.length > 1)
                      _pill('${_currentIndex + 1} / ${widget.images.length}')
                    else
                      const SizedBox.shrink(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.25)),
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===== Dots indicator =====
            if (widget.images.length > 1)
              Positioned(
                bottom: 44,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(widget.images.length, (i) {
                    final active = _currentIndex == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: active ? 20 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.gold
                            : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              ),

            // ===== Swipe-down hint arrow =====
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white.withOpacity(0.2),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Cormorant Garamond',
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      );
}
