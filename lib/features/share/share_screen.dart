import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../places/places_provider.dart';
import '../places/place_model.dart';
import 'widgets/grid_collage_widget.dart';

class ShareScreen extends ConsumerWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // ── Grid collage ──
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
              child: GridCollageWidget(places: places),
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
                    fontFamily: lang == 'en' ? 'Cormorant Garamond' : 'Noto Serif Thai',
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
                      onTap: () => _share('facebook', places, lang),
                    ),
                    _SocialBtn(
                      svgPath: 'assets/icons/instagram.svg',
                      label: 'Instagram',
                      bgColor: const Color(0xFFE1306C),
                      onTap: () => _share('instagram', places, lang),
                    ),
                    _SocialBtn(
                      svgPath: 'assets/icons/line.svg',
                      label: 'LINE',
                      bgColor: const Color(0xFF06C755),
                      onTap: () => _share('line', places, lang),
                    ),
                    _SocialBtn(
                      svgPath: 'assets/icons/x.svg',
                      label: 'X',
                      bgColor: Colors.black,
                      onTap: () => _share('x', places, lang),
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
                    icon: const Icon(Icons.save_alt_rounded, size: 17),
                    label: Text(
                      translations['share_save'] ?? 'บันทึกลงเครื่อง',
                      style: TextStyle(
                        fontFamily: lang == 'en'
                            ? 'Cormorant Garamond'
                            : 'Noto Serif Thai',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            translations['share_save_success'] ??
                                'บันทึกรูปภาพสำเร็จ',
                            style: const TextStyle(
                              fontFamily: 'Noto Serif Thai',
                              color: AppColors.ink,
                            ),
                          ),
                          backgroundColor: AppColors.gold,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
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
    final placeList = done
        .map((p) => '• ${p.name}')
        .join('\n');
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
    final placeList = done
        .map((p) => '• ${p.name}')
        .join('\n');
    return '''✨ I just explored all ${done.length} historic sites at Chanthabun Riverside Community, Chanthaburi! 🏛️

📍 Places I visited:
$placeList

🎁 Claim your special reward after completing all 6 missions!
Show the mission-complete screen at the
Chanthabun Riverside Community Learning Center.

📱 Download the "Chanthabun" app
Discover a 300-year-old historic riverside community and
earn exclusive rewards by completing all 6 checkpoints!

#ChanthabunRiverside #Chanthaburi #ThailandTravel #VisitThailand''';
  }

  // Thai (default)
  final placeList = done
      .map((p) => '• ${p.name}')
      .join('\n');
  return '''✨ ฉันสำรวจครบทั้ง ${done.length} สถานที่ประวัติศาสตร์
ที่ "ชุมชนริมน้ำจันทบูร" จันทบุรีแล้ว! 🏛️

📍 สถานที่ที่ได้เยือน:
$placeList

🎁 สำรวจครบ 6 จุดรับของรางวัลพิเศษ!
แสดงหน้าจอภารกิจสำเร็จที่
ศูนย์การเรียนรู้ชุมชนริมน้ำจันทบูร
แล้วรับรางวัลได้เลย 🎉

📱 ดาวน์โหลดแอป "ริมน้ำจันทบูร"
สัมผัสย่านประวัติศาสตร์กว่า 300 ปี
ครบ 6 จุดแลกรับของรางวัลทันที!

#ริมน้ำจันทบูร #จันทบุรี #ท่องเที่ยวไทย
#ChanthabunRiverside #Chanthaburi''';
}

// ── URL launcher per platform ───────────────────────────────────
Future<void> _share(
    String platform, List<Place> places, String lang) async {
  final text = Uri.encodeComponent(_buildShareText(places, lang));

  final urls = {
    'line': 'https://social-plugins.line.me/lineit/share?text=$text',
    'x': 'https://twitter.com/intent/tweet?text=$text',
    'facebook':
        'https://www.facebook.com/sharer/sharer.php?quote=${Uri.encodeComponent(_buildShareText(places, lang))}',
    'instagram': 'instagram://',
  };

  final rawUrl = urls[platform] ?? '';
  if (rawUrl.isEmpty) return;
  final uri = Uri.parse(rawUrl);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
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
              shape: BoxShape.circle,
              border: border,
            ),
            child: Center(
              child: SvgPicture.asset(
                svgPath,
                width: 26,
                height: 26,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Noto Serif Thai',
              fontSize: 11,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
        ],
      ),
    );
  }
}
