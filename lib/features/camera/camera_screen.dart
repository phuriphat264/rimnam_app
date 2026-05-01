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

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _isFlashing = false;

  void _takePicture() async {
    setState(() => _isFlashing = true);
    await Future.delayed(const Duration(milliseconds: 100));
    setState(() => _isFlashing = false);
    
    // Simulate processing time
    await Future.delayed(const Duration(seconds: 1));
    
    // Update State
    ref.read(placesProvider.notifier).completeMission(widget.placeId);
    
    // Pop back to success
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Mock Camera Feed (Blurry background)
          Image.network(
            'https://images.unsplash.com/photo-1565551980860-90fb33767f4a?q=80&w=800&auto=format&fit=crop',
            fit: BoxFit.cover,
          ),
          
          // Guide Frame Overlay
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text('จัดองค์ประกอบภาพให้อยู่ในกรอบ', style: TextStyle(color: Colors.white, shadows: [Shadow(blurRadius: 4)])),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gold.withOpacity(0.7), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(Icons.add, color: AppColors.gold.withOpacity(0.5), size: 48),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120), // Space for button
              ],
            ),
          ),
          
          // Flash Effect
          if (_isFlashing)
            Container(color: Colors.white),

          // Bottom Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
                GestureDetector(
                  onTap: _takePicture,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 48), // Balance spacing
              ],
            ),
          )
        ],
      ),
    );
  }
}