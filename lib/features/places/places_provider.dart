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
  static const _photoKeyPrefix = 'photo_path_';

  PlacesNotifier(this._prefs) : super(_buildInitialState(_prefs));

  static List<Place> _buildInitialState(SharedPreferences prefs) {
    final completedIds = prefs.getStringList(_completedKey) ?? [];
    return mockPlaces.map((p) {
      final status = completedIds.contains(p.id) ? PlaceStatus.done : p.status;
      final photoPath = prefs.getString('$_photoKeyPrefix${p.id}');
      return p.copyWith(status: status, capturedPhotoPath: photoPath);
    }).toList();
  }

  Future<void> syncFromServer() async {
    try {
      final data = await _api.get('/missions/progress');
      final ids = List<String>.from(data['completed_place_ids'] ?? []);
      _applyCompletedIds(ids);
    } catch (_) {}
  }

  /// ล้างข้อมูล local ทิ้งก่อน แล้ว sync จาก server ใหม่ทั้งหมด
  /// ใช้หลัง login เพื่อป้องกันข้อมูลค้างจาก user คนก่อน
  Future<void> resetAndSyncFromServer() async {
    // ลบ local cache ทั้งหมด
    for (final p in state) {
      _prefs.remove('$_photoKeyPrefix${p.id}');
    }
    _prefs.remove(_completedKey);

    // reset state เป็น fresh (สถานที่ 1 active, ที่เหลือ locked)
    state = mockPlaces.asMap().entries.map((e) {
      return e.value.copyWith(
        status: e.key == 0 ? PlaceStatus.active : PlaceStatus.locked,
      );
    }).toList();

    // ดึงข้อมูลจาก server แล้ว apply โดยไม่ merge กับ local
    try {
      final data = await _api.get('/missions/progress');
      final ids = List<String>.from(data['completed_place_ids'] ?? []);
      if (ids.isNotEmpty) _applyServerIds(ids);
    } catch (_) {}
  }

  void _applyServerIds(List<String> serverIds) {
    final newList = mockPlaces.map((p) {
      final isDone = serverIds.contains(p.id);
      final photoPath = _prefs.getString('$_photoKeyPrefix${p.id}');
      return p.copyWith(
        status: isDone ? PlaceStatus.done : p.status,
        capturedPhotoPath: photoPath,
      );
    }).toList();

    // unlock sequential: หา index สุดท้ายที่ done แล้ว unlock ถัดไป
    final lastDoneIdx = newList.lastIndexWhere(
        (p) => p.status == PlaceStatus.done);
    final nextIdx = lastDoneIdx + 1;
    if (nextIdx < newList.length &&
        newList[nextIdx].status == PlaceStatus.locked) {
      newList[nextIdx] = newList[nextIdx].copyWith(status: PlaceStatus.active);
    } else if (lastDoneIdx == -1) {
      // ยังไม่ done เลย — unlock สถานที่แรก
      newList[0] = newList[0].copyWith(status: PlaceStatus.active);
    }

    state = newList;
    _prefs.setStringList(_completedKey, serverIds);
  }

  void _applyCompletedIds(List<String> serverIds) {
    // Merge server + local — ไม่ลบ progress ที่บันทึกไว้แล้ว
    // กรณี server ส่ง [] มา (JWT หมดอายุ / backend ไม่มีข้อมูล) จะไม่ reset local
    final localIds = _prefs.getStringList(_completedKey) ?? [];
    final mergedIds = <String>{...localIds, ...serverIds}.toList();

    final newList = mockPlaces.map((p) {
      final status = mergedIds.contains(p.id) ? PlaceStatus.done : p.status;
      final photoPath = _prefs.getString('$_photoKeyPrefix${p.id}');
      return p.copyWith(status: status, capturedPhotoPath: photoPath);
    }).toList();
    state = newList;
    if (mergedIds.isNotEmpty) {
      _prefs.setStringList(_completedKey, mergedIds);
    }
  }

  Future<void> completeMission(
    String id, {
    String? photoUrl,
    String? localPhotoPath,
    double? lat,
    double? lng,
  }) async {
    final index = state.indexWhere((p) => p.id == id);
    if (index == -1) return;

    final newList = List<Place>.from(state);
    newList[index] = newList[index].copyWith(
      status: PlaceStatus.done,
      capturedPhotoPath: localPhotoPath,
    );
    if (index + 1 < newList.length &&
        newList[index + 1].status == PlaceStatus.locked) {
      newList[index + 1] = newList[index + 1].copyWith(status: PlaceStatus.active);
    }
    state = newList;

    final completedIds =
        state.where((p) => p.status == PlaceStatus.done).map((p) => p.id).toList();
    _prefs.setStringList(_completedKey, completedIds);
    if (localPhotoPath != null) {
      _prefs.setString('$_photoKeyPrefix$id', localPhotoPath);
    }

    try {
      await _api.post('/missions/complete', {
        'place_id': id,
        if (lat != null) 'latitude': lat,
        if (lng != null) 'longitude': lng,
        if (photoUrl != null) 'photo_url': photoUrl,
      });
    } catch (_) {}
  }

  void resetProgress() {
    for (final p in state) {
      _prefs.remove('$_photoKeyPrefix${p.id}');
    }
    state = mockPlaces.asMap().entries.map((e) {
      return e.value.copyWith(
        status: e.key == 0 ? PlaceStatus.active : PlaceStatus.locked,
      );
    }).toList();
    _prefs.remove(_completedKey);
    _api.delete('/missions/reset').catchError((_) {});
  }
}
