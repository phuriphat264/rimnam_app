import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../places/places_provider.dart';
import '../places/place_model.dart';
import 'widgets/grid_collage_widget.dart';

class ShareScreen extends ConsumerStatefulWidget {
  const ShareScreen({super.key});

  @override
  ConsumerState<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends ConsumerState<ShareScreen> {
  final _repaintKey = GlobalKey();
  bool _isSaving = false;
  bool _isSavingSingle = false;

  // ── Capture widget เป็น PNG bytes ──────────────────────────────
  Future<Uint8List?> _captureImage() async {
    try {
      final boundary =
          _repaintKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      // รอให้ frame render เสร็จก่อน capture
      await Future.delayed(const Duration(milliseconds: 50));
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  // ── บันทึกลง Gallery ──────────────────────────────────────────
  Future<void> _saveToGallery() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    final translations = ref.read(translationsProvider);

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _showSnackBar(
            'ไม่ได้รับสิทธิ์เข้าถึง Gallery กรุณาเปิดใน Settings',
            AppColors.mahogany,
          );
          return;
        }
      }

      final bytes = await _captureImage();
      if (bytes == null) throw Exception('capture failed');

      await Gal.putImageBytes(
        bytes,
        name: 'rimnam_${DateTime.now().millisecondsSinceEpoch}',
      );

      _showSnackBar(
        translations['share_save_success'] ?? 'บันทึกรูปภาพสำเร็จ',
        AppColors.gold,
        textColor: AppColors.ink,
      );
    } catch (_) {
      _showSnackBar('บันทึกไม่สำเร็จ กรุณาลองใหม่', AppColors.mahogany);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── บันทึกรูปเดี่ยว ───────────────────────────────────────────────
  Future<void> _saveSinglePhoto(String filePath, String placeName) async {
    if (_isSavingSingle) return;
    setState(() => _isSavingSingle = true);
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) {
          _showSnackBar('ไม่ได้รับสิทธิ์เข้าถึง Gallery', AppColors.mahogany);
          return;
        }
      }
      final bytes = await File(filePath).readAsBytes();
      await Gal.putImageBytes(bytes,
          name: 'chan_river_${DateTime.now().millisecondsSinceEpoch}');
      _showSnackBar('บันทึกรูป "$placeName" สำเร็จ', AppColors.gold,
          textColor: AppColors.ink);
    } catch (_) {
      _showSnackBar('บันทึกไม่สำเร็จ กรุณาลองใหม่', AppColors.mahogany);
    } finally {
      if (mounted) setState(() => _isSavingSingle = false);
    }
  }

  // ── แชร์รูปเดี่ยว ─────────────────────────────────────────────────
  Future<void> _shareSinglePhoto(String filePath, String placeName) async {
    await Share.shareXFiles(
      [XFile(filePath, mimeType: 'image/jpeg')],
      text: placeName,
    );
  }

  // ── แสดง bottom sheet ตัวเลือกสำหรับรูปเดี่ยว ─────────────────────
  void _showPhotoOptions(
      BuildContext ctx, String filePath, String placeName) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.espresso,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.mahogany,
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 14),
              Text(placeName,
                  style: const TextStyle(
                      fontFamily: 'Noto Serif Thai',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.cream)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.save_alt_rounded,
                    color: AppColors.gold),
                title: const Text('บันทึกลงเครื่อง',
                    style: TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        color: AppColors.cream)),
                onTap: () {
                  Navigator.pop(ctx);
                  _saveSinglePhoto(filePath, placeName);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.share_rounded,
                    color: AppColors.gold),
                title: const Text('แชร์รูปนี้',
                    style: TextStyle(
                        fontFamily: 'Noto Serif Thai',
                        color: AppColors.cream)),
                onTap: () {
                  Navigator.pop(ctx);
                  _shareSinglePhoto(filePath, placeName);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── แชร์รูป + ข้อความผ่าน native share sheet (Instagram, Facebook) ──
  Future<void> _shareWithImage(List<Place> places, String lang) async {
    final bytes = await _captureImage();
    if (bytes == null) return;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/rimnam_share_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'image/png')],
      text: _buildShareText(places, lang),
    );
  }

  // ── แชร์ผ่าน URL (LINE, X) ─────────────────────────────────────
  Future<void> _shareUrl(String platform, List<Place> places, String lang) async {
    final text = Uri.encodeComponent(_buildShareText(places, lang));
    final urls = {
      'line': 'https://social-plugins.line.me/lineit/share?text=$text',
      'x': 'https://twitter.com/intent/tweet?text=$text',
    };
    final rawUrl = urls[platform] ?? '';
    if (rawUrl.isEmpty) return;
    final uri = Uri.parse(rawUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSnackBar(String message, Color bg, {Color textColor = Colors.white}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontFamily: 'Noto Serif Thai', color: textColor),
        ),
        backgroundColor: bg,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    final translations = ref.watch(translationsProvider);
    final lang = ref.watch(languageProvider) ?? 'th';
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.espresso,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.gold),
        title: Text(
          translations['share_title'] ?? 'ความทรงจำริมน้ำจันทบูร',
          style: TextStyle(
            fontFamily: lang == 'en' ? 'Cormorant Garamond' : 'Noto Serif Thai',
            fontSize: lang == 'en' ? 14 : 18,
            letterSpacing: lang == 'en' ? 4 : 1,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Grid collage (wrapped ใน RepaintBoundary เพื่อ capture) ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: RepaintBoundary(
                key: _repaintKey,
                child: GridCollageWidget(places: places),
              ),
            ),
          ),

          // ── Mission photo strip ──────────────────────────────────
          _MissionPhotoStrip(
            places: places.where((p) =>
                p.status == PlaceStatus.done &&
                p.capturedPhotoPath != null).toList(),
            onTap: (place) => _showPhotoOptions(
              context,
              place.capturedPhotoPath!,
              place.name,
            ),
          ),

          // ── Share panel (fixed) ──
          Container(
            decoration: BoxDecoration(
              color: AppColors.espresso,
              border: Border(
                top: BorderSide(
                    color: AppColors.gold.withOpacity(0.15), width: 1),
              ),
            ),
            padding: EdgeInsets.fromLTRB(24, 14, 24, bottom + 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  translations['share_to'] ?? 'แชร์ไปยัง',
                  style: TextStyle(
                    fontFamily:
                        lang == 'en' ? 'Cormorant Garamond' : 'Noto Serif Thai',
                    fontSize: 11,
                    letterSpacing: lang == 'en' ? 3 : 1,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
                const SizedBox(height: 12),

                // Social icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SocialBtn(
                      svgPath: 'assets/icons/facebook.svg',
                      label: 'Facebook',
                      bgColor: const Color(0xFF1877F2),
                      onTap: () => _shareWithImage(places, lang),
                    ),
                    _SocialBtn(
                      svgPath: 'assets/icons/instagram.svg',
                      label: 'Instagram',
                      bgColor: const Color(0xFFE1306C),
                      onTap: () => _shareWithImage(places, lang),
                    ),
                    _SocialBtn(
                      svgPath: 'assets/icons/line.svg',
                      label: 'LINE',
                      bgColor: const Color(0xFF06C755),
                      onTap: () => _shareUrl('line', places, lang),
                    ),
                    _SocialBtn(
                      svgPath: 'assets/icons/x.svg',
                      label: 'X',
                      bgColor: Colors.black,
                      onTap: () => _shareUrl('x', places, lang),
                      border: Border.all(color: Colors.white24),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      side: const BorderSide(color: AppColors.gold, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.gold,
                            ),
                          )
                        : const Icon(Icons.save_alt_rounded, size: 17),
                    label: Text(
                      _isSaving
                          ? 'กำลังบันทึก...'
                          : (translations['share_save'] ?? 'บันทึกลงเครื่อง'),
                      style: TextStyle(
                        fontFamily: lang == 'en'
                            ? 'Cormorant Garamond'
                            : 'Noto Serif Thai',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _isSaving ? null : _saveToGallery,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Share text builder ──────────────────────────────────────────
String _buildShareText(List<Place> places, String lang) {
  final done = places.where((p) => p.status == PlaceStatus.done).toList();

  if (lang == 'zh') {
    final placeList = done.map((p) => '• ${p.name}').join('\n');
    return '''✨ 我已探索完尖竹汶河畔社区的全部 ${done.length} 处历史遗址！🏛️

📍 到访地点：
$placeList

🎁 完成全部任务后可领取特别奖励！
请前往尖竹汶河畔社区学习中心，
向工作人员出示任务完成屏幕领取。

📱 下载「尖竹汶河畔」应用程序
探索这个拥有超过 300 年历史的古老河畔社区，
完成全部 6 个打卡点即可获得奖励！

#尖竹汶 #泰国旅游 #ChanthabunRiverside''';
  }

  if (lang == 'en') {
    final placeList = done.map((p) => '• ${p.name}').join('\n');
    return '''✨ I just explored all ${done.length} historic sites at Chanthabun Riverside Community, Chanthaburi! 🏛️

📍 Places I visited:
$placeList

🎁 Claim your special reward after completing all 6 missions!
Show the mission-complete screen at the
No. 69 Khun Anusorn Sombat, Community Learning House.

📱 Download the "Chanthabun" app
Discover a 300-year-old historic riverside community and
earn exclusive rewards by completing all 6 checkpoints!

#ChanthabunRiverside #Chanthaburi #ThailandTravel #VisitThailand''';
  }

  // Thai (default)
  final placeList = done.map((p) => '• ${p.name}').join('\n');
  return '''✨ ฉันสำรวจครบทั้ง ${done.length} สถานที่ประวัติศาสตร์
ที่ "ชุมชนริมน้ำจันทบูร" จันทบุรีแล้ว! 🏛️

📍 สถานที่ที่ได้เยือน:
$placeList

🎁 สำรวจครบ 6 จุดรับของรางวัลพิเศษ!
แสดงหน้าจอภารกิจสำเร็จที่
บ้านเลขที่ 69 ขุนอนุสรสมบัติ บ้านเรียนรู้ชุมชน ริมน้ำจันทบูร
แล้วรับรางวัลได้เลย 🎉

📱 ดาวน์โหลดแอป "CHAN RIVER GUIDE"
สัมผัสย่านประวัติศาสตร์กว่า 300 ปี
ครบ 6 จุดแลกรับของรางวัลทันที!

#ริมน้ำจันทบูร #จันทบุรี #ท่องเที่ยวไทย
#ChanthabunRiverside #Chanthaburi''';
}

// ── Mission photo strip ─────────────────────────────────────────
class _MissionPhotoStrip extends StatelessWidget {
  final List<Place> places;
  final void Function(Place) onTap;

  const _MissionPhotoStrip({required this.places, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();
    return Container(
      height: 80,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'รูปของฉัน',
            style: TextStyle(
              fontFamily: 'Noto Serif Thai',
              fontSize: 10,
              letterSpacing: 1,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: places.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final place = places[i];
                return GestureDetector(
                  onTap: () => onTap(place),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          File(place.capturedPhotoPath!),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56, height: 56,
                            decoration: BoxDecoration(
                              color: AppColors.mahogany.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.image_not_supported,
                                color: AppColors.sienna, size: 20),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 3, bottom: 3,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.more_horiz,
                              color: Colors.white, size: 10),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Social icon button ──────────────────────────────────────────
class _SocialBtn extends StatelessWidget {
  final String svgPath;
  final String label;
  final Color bgColor;
  final VoidCallback onTap;
  final BoxBorder? border;

  const _SocialBtn({
    required this.svgPath,
    required this.label,
    required this.bgColor,
    required this.onTap,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(14),
              border: border,
            ),
            child: Center(
              child: SvgPicture.asset(svgPath, width: 26, height: 26,
                  colorFilter: const ColorFilter.mode(
                      Colors.white, BlendMode.srcIn)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Noto Serif Thai',
              fontSize: 10,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
