import 'package:flutter_riverpod/flutter_riverpod.dart';
// แก้ไขบรรทัดนี้ เอาตัว s ออกให้ตรงกับชื่อไฟล์ของคุณ
import 'place_model.dart'; 

// Provider หลัก
final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((ref) {
  return PlacesNotifier();
});

// Provider สำหรับดึงข้อมูลรายตัว
final placeByIdProvider = Provider.family<Place?, String>((ref, placeId) {
  final places = ref.watch(placesProvider);
  try {
    return places.firstWhere((place) => place.id == placeId);
  } catch (e) {
    return null;
  }
});

// Provider สำหรับนับจำนวนความสำเร็จ
final completedCountProvider = Provider<int>((ref) {
  final places = ref.watch(placesProvider);
  return places.where((p) => p.status == PlaceStatus.done).length;
});

// Notifier ควบคุม Logic
class PlacesNotifier extends StateNotifier<List<Place>> {
  // ดึง mockPlaces จาก place_model.dart มาเป็นค่าเริ่มต้น
  PlacesNotifier() : super(mockPlaces);

  void completeMission(String id) {
    final index = state.indexWhere((p) => p.id == id);
    if (index != -1) {
      final newList = List<Place>.from(state);
      
      newList[index] = newList[index].copyWith(status: PlaceStatus.done);
      
      if (index + 1 < newList.length) {
        if (newList[index + 1].status == PlaceStatus.locked) {
          newList[index + 1] = newList[index + 1].copyWith(status: PlaceStatus.active);
        }
      }
      
      state = newList;
    }
  }

  void resetProgress() {
    state = [
      for (int i = 0; i < state.length; i++)
        state[i].copyWith(status: i == 0 ? PlaceStatus.active : PlaceStatus.locked)
    ];
  }
}