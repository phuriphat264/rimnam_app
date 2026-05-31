import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      q: 'ภารกิจคืออะไร?',
      a: 'ภารกิจคือการเดินทางไปยังสถานที่ต่างๆ ริมน้ำจันทบูร ถ่ายรูป และสแกนยืนยันการเยี่ยมชม เมื่อเสร็จครบทุกสถานที่จะได้รับตราประทับพิเศษ',
    ),
    (
      q: 'GPS ต้องแม่นยำแค่ไหน?',
      a: 'แอพจะยืนยันว่าคุณอยู่ในรัศมี 100 เมตรจากสถานที่นั้นๆ ถ้า GPS ไม่แม่น ลองออกมาบริเวณโล่งแจ้งและรอสักครู่',
    ),
    (
      q: 'ถ้าไม่มีอินเตอร์เน็ตจะใช้งานได้ไหม?',
      a: 'ความคืบหน้าภารกิจจะบันทึกในเครื่องก่อน และจะ sync ขึ้น server อัตโนมัติเมื่อมีสัญญาณอินเตอร์เน็ต',
    ),
    (
      q: 'รูปที่ถ่ายจะเก็บไว้ที่ไหน?',
      a: 'รูปจะถูกอัปโหลดไปยัง server อย่างปลอดภัย และใช้สำหรับยืนยันการเยี่ยมชมสถานที่เท่านั้น',
    ),
    (
      q: 'ลืมรหัสผ่านทำอย่างไร?',
      a: 'กด "ลืมรหัสผ่าน?" บนหน้าเข้าสู่ระบบ แล้วกรอก email เพื่อรับรหัส OTP สำหรับรีเซ็ตรหัสผ่าน',
    ),
    (
      q: 'ย้ายเครื่องหรือลบแอพจะเสียความคืบหน้าไหม?',
      a: 'ไม่เสียครับ เพราะความคืบหน้าถูกบันทึกใน server แค่ login ด้วย account เดิมก็จะได้ข้อมูลกลับมา',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translations = ref.watch(translationsProvider);
    final lang = ref.watch(languageProvider) ?? 'th';
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.espresso,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.gold, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          translations['appbar_help'] ?? 'ศูนย์ช่วยเหลือ',
          style: TextStyle(
            fontFamily: lang == 'en' ? 'Cormorant Garamond' : 'Noto Serif Thai',
            fontSize: lang == 'en' ? 14 : 16,
            letterSpacing: lang == 'en' ? 4 : 1,
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ── FAQ ───────────────────────────────────────────────
          Text(
            translations['help_faq_title'] ?? 'คำถามที่พบบ่อย',
            style: const TextStyle(
              fontFamily: 'Noto Serif Thai',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 16),

          ..._faqs.map((faq) => _FaqTile(question: faq.q, answer: faq.a)),

          const SizedBox(height: 32),

          // ── ติดต่อ ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.mahogany.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.gold.withOpacity(0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translations['help_contact_title'] ?? 'ติดต่อเรา',
                  style: const TextStyle(
                    fontFamily: 'Noto Serif Thai',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                _ContactRow(icon: Icons.email_outlined, text: 'chanthaboonriversid@gmail.com'),
                const SizedBox(height: 8),
                _ContactRow(icon: Icons.location_on_outlined, text: 'ชุมชนริมน้ำจันทบูร จ.จันทบุรี'),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ── App version ───────────────────────────────────────
          Center(
            child: Text(
              'Rimnam Chanthabun v1.0.0',
              style: TextStyle(
                fontFamily: 'Cormorant Garamond',
                fontSize: 12,
                color: Colors.white.withOpacity(0.25),
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => setState(() => _open = !_open),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: _open ? AppColors.espresso : Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _open ? AppColors.gold.withOpacity(0.3) : Colors.white.withOpacity(0.07),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 15, 12, 15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        widget.question,
                        style: TextStyle(
                          fontFamily: 'Noto Serif Thai',
                          fontSize: 15,
                          color: _open ? AppColors.amber : Colors.white,
                          fontWeight: _open ? FontWeight.w600 : FontWeight.normal,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: AppColors.gold.withOpacity(0.7),
                      size: 22,
                    ),
                  ],
                ),
              ),
              if (_open)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                  child: Text(
                    widget.answer,
                    style: TextStyle(
                      fontFamily: 'Noto Serif Thai',
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.65),
                      height: 1.75,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ContactRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: AppColors.gold.withOpacity(0.6), size: 17),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Noto Serif Thai',
              fontSize: 14,
              color: Colors.white.withOpacity(0.55),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
