import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'place_model.dart';
import '../../core/storage/storage_service.dart';
import '../../core/services/api_service.dart';

final placesProvider = StateNotifierProvider<PlacesNotifier, List<Place>>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PlacesNotifier(prefs);
});

final placeByIdProvider = Provider.family<Place?, String>((ref, placeId) {
  final places = ref.watch(placesProvider);
  try {
    return places.firstWhere((place) => place.id == placeId);
  } catch (e) {
    return null;
  }
});

final completedCountProvider = Provider<int>((ref) {
  final places = ref.watch(placesProvider);
  return places.where((p) => p.status == PlaceStatus.done).length;
});

class PlacesNotifier extends StateNotifier<List<Place>> {
  final SharedPreferences _prefs;
  final _api = ApiService();
  static const _completedKey = 'completed_places';

  PlacesNotifier(this._prefs) : super(_buildInitialState(_prefs));

  static List<Place> _buildInitialState(SharedPreferences prefs) {
    final completedIds = prefs.getStringList(_completedKey) ?? [];
    return _applyIds(completedIds);
  }

  static List<Place> _applyIds(List<String> completedIds) {
    return mockPlaces.map((p) {
      if (completedIds.contains(p.id)) return p.copyWith(status: PlaceStatus.done);
      return p;
    }).toList();
  }

  // sync ความคืบหน้าจาก server (เรียกหลัง login)
  Future<void> syncFromServer() async {
    try {
      final data = await _api.get('/missions/progress');
      final ids = List<String>.from(data['completed_place_ids'] ?? []);
      _applyCompletedIds(ids);
    } catch (_) {
      // offline: ใช้ local data ต่อ
    }
  }

  void _applyCompletedIds(List<String> completedIds) {
    final newList = mockPlaces.map((p) {
      if (completedIds.contains(p.id)) return p.copyWith(status: PlaceStatus.done);
      return p;
    }).toList();
    state = newList;
    _prefs.setStringList(_completedKey, completedIds);
  }

  Future<void> completeMission(String id, {String? photoUrl, double? lat, double? lng}) async {
    // อัพเดท local state ทันที
    final index = state.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final newList = List<Place>.from(state);
    newList[index] = newList[index].copyWith(status: PlaceStatus.done);
    if (index + 1 < newList.length && newList[index + 1].status == PlaceStatus.locked) {
      newList[index + 1] = newList[index + 1].copyWith(status: PlaceStatus.active);
    }
    state = newList;

    final completedIds = state.where((p) => p.status == PlaceStatus.done).map((p) => p.id).toList();
    _prefs.setStringList(_completedKey, completedIds);

    // sync ไป server (background)
    try {
      await _api.post('/missions/complete', {
        'place_id': id,
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
        if (photoUrl != null) 'photo_url': photoUrl,
      });
    } catch (_) {
      // ไม่ออนไลน์: local state บันทึกแล้ว จะ sync ครั้งหน้าที่ login
    }
  }

  void resetProgress() {
    state = [
      for (int i = 0; i < state.length; i++)
        state[i].copyWith(status: i == 0 ? PlaceStatus.active : PlaceStatus.locked)
    ];
    _prefs.remove(_completedKey);
    // reset บน server ด้วย (background)
    _api.delete('/missions/reset').catchError((_) {});
  }
}
