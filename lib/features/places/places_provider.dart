import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlaceStatus { locked, active, done }

class Place {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final PlaceStatus status;

  const Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.status = PlaceStatus.locked,
  });

  Place copyWith({PlaceStatus? status}) {
    return Place(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      status: status ?? this.status,
    );
  }
}

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((ref) {
  return PlacesNotifier();
});

class PlacesNotifier extends StateNotifier<List<Place>> {
  PlacesNotifier() : super(_initialPlaces);

  static final List<Place> _initialPlaces = [
    const Place(
      id: '1',
      name: 'อาสนวิหารพระนางมารีอา',
      description: 'โบสถ์คาทอลิกที่สวยที่สุดในภาคตะวันออก',
      imageUrl: 'https://images.unsplash.com/photo-1601614050212-921d7b1a201c?q=80&w=800&auto=format&fit=crop',
      status: PlaceStatus.active, // จุดแรกเริ่มเป็น Active
    ),
    const Place(
      id: '2',
      name: 'บ้านหลวงราชไมตรี',
      description: 'บ้านประวัติศาสตร์และพิพิธภัณฑ์',
      imageUrl: 'https://images.unsplash.com/photo-1552465011-b4e21bf6e79a?q=80&w=800&auto=format&fit=crop',
    ),
    const Place(
      id: '3',
      name: 'ชุมชนตลาดล่าง',
      description: 'วิถีชีวิตดั้งเดิมของชาวจันทบูร',
      imageUrl: 'https://images.unsplash.com/photo-1549488344-1f9b8d2bd1f3?q=80&w=800&auto=format&fit=crop',
    ),
    const Place(
      id: '4',
      name: 'ศาลเจ้าตั้วเล่าเอี้ย',
      description: 'ศูนย์รวมจิตใจชาวไทยเชื้อสายจีน',
      imageUrl: 'https://images.unsplash.com/photo-1555581938-16e5ce79860b?q=80&w=800&auto=format&fit=crop',
    ),
    const Place(
      id: '5',
      name: 'ตรอกกระจ่าง',
      description: 'มุมถ่ายภาพสตรีทอาร์ตสุดคลาสสิก',
      imageUrl: 'https://images.unsplash.com/photo-1518005020951-eccb494ad742?q=80&w=800&auto=format&fit=crop',
    ),
    const Place(
      id: '6',
      name: 'สะพานนิรมล',
      description: 'จุดชมวิวแม่น้ำจันทบูรที่สวยที่สุด',
      imageUrl: 'https://images.unsplash.com/photo-1565551980860-90fb33767f4a?q=80&w=800&auto=format&fit=crop',
    ),
  ];

  // Logic สำหรับอัปเดตสถานะเมื่อทำภารกิจสำเร็จ
  void completeMission(String id) {
    final index = state.indexWhere((p) => p.id == id);
    if (index != -1) {
      final newList = List<Place>.from(state);
      newList[index] = newList[index].copyWith(status: PlaceStatus.done);
      
      // ปลดล็อคจุดถัดไป
      if (index + 1 < newList.length) {
        newList[index + 1] = newList[index + 1].copyWith(status: PlaceStatus.active);
      }
      state = newList;
    }
  }
}