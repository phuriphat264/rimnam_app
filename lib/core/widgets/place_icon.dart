import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Minimalist architectural icon for each of the 6 stations.
/// Drawn with CustomPaint — line-art style, fits any square size.
class PlaceIcon extends StatelessWidget {
  final String placeId;
  final double size;
  final Color color;

  const PlaceIcon({
    super.key,
    required this.placeId,
    this.size = 48,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PlaceIconPainter(placeId: placeId, color: color),
      ),
    );
  }
}

class _PlaceIconPainter extends CustomPainter {
  final String placeId;
  final Color color;
  const _PlaceIconPainter({required this.placeId, required this.color});

  Paint _pen(double sw) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = sw
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _dot => Paint()
    ..color = color
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size s) {
    final sw = s.width / 20;
    switch (placeId) {
      case '1': _pagoda(canvas, s, sw);     break;
      case '2': _chineseShrine(canvas, s, sw); break;
      case '3': _colonialHouse(canvas, s, sw); break;
      case '4': _chineseTemple(canvas, s, sw); break;
      case '5': _thaiHouse(canvas, s, sw);  break;
      case '6': _cathedral(canvas, s, sw);  break;
    }
  }

  // ── 1. Pagoda / เจดีย์ ───────────────────────────────────────
  void _pagoda(Canvas canvas, Size s, double sw) {
    final p = _pen(sw);
    final w = s.width; final h = s.height;

    // Spire tip
    canvas.drawLine(Offset(w*.5, h*.04), Offset(w*.5, h*.15), p);
    // Dot at top
    canvas.drawCircle(Offset(w*.5, h*.04), sw*.6, _dot);

    // Bell dome
    final dome = Path()
      ..moveTo(w*.30, h*.38)
      ..cubicTo(w*.28, h*.24, w*.72, h*.24, w*.70, h*.38)
      ..close();
    canvas.drawPath(dome, p);

    // Tier 1
    _roundedBar(canvas, p, Rect.fromLTWH(w*.22, h*.39, w*.56, h*.11), sw*.5);
    // Tier 2
    _roundedBar(canvas, p, Rect.fromLTWH(w*.14, h*.51, w*.72, h*.11), sw*.5);
    // Base
    _roundedBar(canvas, p, Rect.fromLTWH(w*.07, h*.63, w*.86, h*.10), sw*.5);

    // Ground
    canvas.drawLine(Offset(w*.05, h*.77), Offset(w*.95, h*.77), p);
  }

  // ── 2. Chinese Shrine / ศาลเจ้า ─────────────────────────────
  void _chineseShrine(Canvas canvas, Size s, double sw) {
    final p = _pen(sw);
    final w = s.width; final h = s.height;

    // Roof with upturned eaves
    final roof = Path()
      ..moveTo(w*.50, h*.06)              // peak
      ..lineTo(w*.88, h*.38)             // right slope
      ..quadraticBezierTo(w*.94, h*.42, w*.98, h*.36) // right eave upturn
      ..moveTo(w*.50, h*.06)
      ..lineTo(w*.12, h*.38)             // left slope
      ..quadraticBezierTo(w*.06, h*.42, w*.02, h*.36); // left eave upturn
    canvas.drawPath(roof, p);

    // Roof ridge cap
    canvas.drawLine(Offset(w*.35, h*.38), Offset(w*.65, h*.38), p);

    // Body
    canvas.drawRect(Rect.fromLTWH(w*.22, h*.38, w*.56, h*.36), p);

    // Center door arch
    _arch(canvas, p, Offset(w*.5, h*.74), w*.12, h*.20);

    // Side windows
    for (final cx in [w*.32, w*.68]) {
      canvas.drawRect(
        Rect.fromLTWH(cx - w*.06, h*.46, w*.12, h*.10),
        p,
      );
    }

    // Ground
    canvas.drawLine(Offset(w*.08, h*.77), Offset(w*.92, h*.77), p);
  }

  // ── 3. Colonial House / บ้านหลวงราชไมตรี ───────────────────
  void _colonialHouse(Canvas canvas, Size s, double sw) {
    final p = _pen(sw);
    final w = s.width; final h = s.height;

    // Pediment (triangular gable)
    final gable = Path()
      ..moveTo(w*.10, h*.40)
      ..lineTo(w*.50, h*.06)
      ..lineTo(w*.90, h*.40)
      ..close();
    canvas.drawPath(gable, p);

    // Body
    canvas.drawRect(Rect.fromLTWH(w*.14, h*.40, w*.72, h*.36), p);

    // 4 columns
    for (final x in [w*.24, w*.38, w*.62, w*.76]) {
      canvas.drawLine(Offset(x, h*.40), Offset(x, h*.76), p);
    }

    // 2 arched windows
    for (final cx in [w*.32, w*.68]) {
      _arch(canvas, p, Offset(cx, h*.60), w*.09, h*.14);
    }

    // Door (arched, center)
    _arch(canvas, p, Offset(w*.50, h*.76), w*.10, h*.18);

    // Ground
    canvas.drawLine(Offset(w*.05, h*.77), Offset(w*.95, h*.77), p);
  }

  // ── 4. Chinese Temple / โรงเจ ────────────────────────────────
  void _chineseTemple(Canvas canvas, Size s, double sw) {
    final p = _pen(sw);
    final w = s.width; final h = s.height;

    // Top small roof
    final topRoof = Path()
      ..moveTo(w*.50, h*.06)
      ..lineTo(w*.76, h*.26)
      ..quadraticBezierTo(w*.82, h*.30, w*.86, h*.25)
      ..moveTo(w*.50, h*.06)
      ..lineTo(w*.24, h*.26)
      ..quadraticBezierTo(w*.18, h*.30, w*.14, h*.25);
    canvas.drawPath(topRoof, p);
    canvas.drawLine(Offset(w*.34, h*.26), Offset(w*.66, h*.26), p);

    // Small upper body
    canvas.drawRect(Rect.fromLTWH(w*.36, h*.26, w*.28, h*.12), p);

    // Lower wider roof
    final botRoof = Path()
      ..moveTo(w*.50, h*.34)
      ..lineTo(w*.94, h*.50)
      ..quadraticBezierTo(w*.99, h*.54, w*.97, h*.60)
      ..moveTo(w*.50, h*.34)
      ..lineTo(w*.06, h*.50)
      ..quadraticBezierTo(w*.01, h*.54, w*.03, h*.60);
    canvas.drawPath(botRoof, p);
    canvas.drawLine(Offset(w*.16, h*.50), Offset(w*.84, h*.50), p);

    // Main body
    canvas.drawRect(Rect.fromLTWH(w*.20, h*.50, w*.60, h*.26), p);

    // Center door
    canvas.drawRect(Rect.fromLTWH(w*.41, h*.62, w*.18, h*.14), p);

    // Ground
    canvas.drawLine(Offset(w*.08, h*.77), Offset(w*.92, h*.77), p);
  }

  // ── 5. Thai House / ศูนย์เรียนรู้ ───────────────────────────
  void _thaiHouse(Canvas canvas, Size s, double sw) {
    final p = _pen(sw);
    final w = s.width; final h = s.height;

    // Roof — Thai style with slightly lifted finials
    final roof = Path()
      ..moveTo(w*.50, h*.06)
      ..lineTo(w*.90, h*.40)
      ..quadraticBezierTo(w*.96, h*.44, w*.94, h*.50)
      ..moveTo(w*.50, h*.06)
      ..lineTo(w*.10, h*.40)
      ..quadraticBezierTo(w*.04, h*.44, w*.06, h*.50);
    canvas.drawPath(roof, p);

    // Roof soffit line
    canvas.drawLine(Offset(w*.14, h*.44), Offset(w*.86, h*.44), p);

    // Body
    canvas.drawRect(Rect.fromLTWH(w*.20, h*.44, w*.60, h*.32), p);

    // Decorative lattice window left
    final wl = Rect.fromLTWH(w*.26, h*.50, w*.16, h*.14);
    canvas.drawRect(wl, p);
    canvas.drawLine(Offset(w*.34, h*.50), Offset(w*.34, h*.64), p);
    canvas.drawLine(Offset(w*.26, h*.57), Offset(w*.42, h*.57), p);

    // Decorative lattice window right
    final wr = Rect.fromLTWH(w*.58, h*.50, w*.16, h*.14);
    canvas.drawRect(wr, p);
    canvas.drawLine(Offset(w*.66, h*.50), Offset(w*.66, h*.64), p);
    canvas.drawLine(Offset(w*.58, h*.57), Offset(w*.74, h*.57), p);

    // Door (center, arched top)
    _arch(canvas, p, Offset(w*.50, h*.76), w*.10, h*.18);

    // Ground
    canvas.drawLine(Offset(w*.08, h*.77), Offset(w*.92, h*.77), p);
  }

  // ── 6. Gothic Cathedral / อาสนวิหาร ─────────────────────────
  void _cathedral(Canvas canvas, Size s, double sw) {
    final p = _pen(sw);
    final w = s.width; final h = s.height;

    // Left tower body
    canvas.drawRect(Rect.fromLTWH(w*.04, h*.30, w*.24, h*.46), p);
    // Left spire
    final ls = Path()
      ..moveTo(w*.04, h*.30)..lineTo(w*.16, h*.04)..lineTo(w*.28, h*.30);
    canvas.drawPath(ls, p);
    // Cross on left tower
    canvas.drawLine(Offset(w*.16, h*.36), Offset(w*.16, h*.50), p);
    canvas.drawLine(Offset(w*.09, h*.41), Offset(w*.23, h*.41), p);

    // Right tower body
    canvas.drawRect(Rect.fromLTWH(w*.72, h*.30, w*.24, h*.46), p);
    // Right spire
    final rs = Path()
      ..moveTo(w*.72, h*.30)..lineTo(w*.84, h*.04)..lineTo(w*.96, h*.30);
    canvas.drawPath(rs, p);

    // Central nave
    canvas.drawRect(Rect.fromLTWH(w*.28, h*.44, w*.44, h*.32), p);

    // Rose window
    canvas.drawCircle(Offset(w*.50, h*.36), w*.10, p);
    for (int i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      canvas.drawLine(
        Offset(w*.50, h*.36),
        Offset(w*.50 + math.cos(a)*w*.10, h*.36 + math.sin(a)*w*.10),
        p,
      );
    }

    // Central pointed arch door
    final door = Path()
      ..moveTo(w*.38, h*.76)
      ..lineTo(w*.38, h*.60)
      ..quadraticBezierTo(w*.38, h*.52, w*.50, h*.50)
      ..quadraticBezierTo(w*.62, h*.52, w*.62, h*.60)
      ..lineTo(w*.62, h*.76);
    canvas.drawPath(door, p);

    // Ground
    canvas.drawLine(Offset(w*.02, h*.77), Offset(w*.98, h*.77), p);
  }

  // ── Helpers ─────────────────────────────────────────────────
  void _arch(Canvas canvas, Paint p, Offset bottomCenter, double hw, double height) {
    final path = Path()
      ..moveTo(bottomCenter.dx - hw, bottomCenter.dy)
      ..lineTo(bottomCenter.dx - hw, bottomCenter.dy - height * .55)
      ..quadraticBezierTo(
        bottomCenter.dx - hw, bottomCenter.dy - height,
        bottomCenter.dx, bottomCenter.dy - height,
      )
      ..quadraticBezierTo(
        bottomCenter.dx + hw, bottomCenter.dy - height,
        bottomCenter.dx + hw, bottomCenter.dy - height * .55,
      )
      ..lineTo(bottomCenter.dx + hw, bottomCenter.dy);
    canvas.drawPath(path, p);
  }

  void _roundedBar(Canvas canvas, Paint p, Rect rect, double r) {
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(r)), p);
  }

  @override
  bool shouldRepaint(_PlaceIconPainter o) =>
      o.placeId != placeId || o.color != color;
}
