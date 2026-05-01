import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../home/home_screen.dart';
import '../main/main_screen.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(l10nProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Stack(
        children: [
          // ✅ ส่วนแก้ไข: Background Image พร้อมระบบเช็ก Error
          Positioned(
            top: -_scrollOffset * 0.5,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 1.5,
            child: Image.network(
              'https://images.unsplash.com/photo-1528154291023-a6525fabe5b4?q=80&w=1200', // ลิงก์ใหม่
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.6),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.ink),
            ),
          ),

          CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),

              // Title Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'THE HERITAGE OF',
                        style: TextStyle(color: AppColors.gold, letterSpacing: 4, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n('app_name'),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 60)),

              // Story Sections
              _buildStorySection(
                context,
                'จุดเริ่มต้นแห่งศรัทธา',
                'ชุมชนริมน้ำจันทบูรมีประวัติศาสตร์ยาวนานกว่า 300 ปี เริ่มต้นจากการเป็นศูนย์กลางการค้าขายทางน้ำที่สำคัญของภาคตะวันออก',
                'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?q=80&w=800',
              ),

              _buildStorySection(
                context,
                'สถาปัตยกรรมข้ามกาลเวลา',
                'คุณจะได้พบกับบ้านเรือนไม้เก่าแก่สไตล์โคโลเนียลที่ตกแต่งด้วยลวดลายไม้ฉลุอันประณีตเคียงคู่ไปกับตึกแถวโบราณ',
                'https://images.unsplash.com/photo-1518005020951-eccb494ad742?q=80&w=800',
              ),

              // Button Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: AppColors.ink,
                        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        elevation: 10,
                      ),
                      onPressed: () {
                        // ✅ เชื่อมต่อไปหน้า MainScreen (ที่มี Bottom Nav)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainScreen()),
                        );
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('เข้าสู่การเดินทาง', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_ios, size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              const SliverToBoxAdapter(child: SizedBox(height: 60)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(BuildContext context, String title, String content, String imageUrl) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl, 
                height: 250, 
                width: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(height: 250, color: Colors.white10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(color: AppColors.gold, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: TextStyle(color: AppColors.cream.withOpacity(0.9), fontSize: 16, height: 1.8),
            ),
          ],
        ),
      ),
    );
  }
}