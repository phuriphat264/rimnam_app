import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'place_model.dart';
import '../../core/storage/storage_service.dart';

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
  static const _completedKey = 'completed_places';

  PlacesNotifier(this._prefs) : super(_buildInitialState(_prefs));

  static List<Place> _buildInitialState(SharedPreferences prefs) {
    final completedIds = prefs.getStringList(_completedKey) ?? [];
    return mockPlaces.map((p) {
      if (completedIds.contains(p.id)) {
        return p.copyWith(status: PlaceStatus.done);
      }
      return p;
    }).toList();
  }

  void completeMission(String id) {
    final index = state.indexWhere((p) => p.id == id);
    if (index != -1) {
      final newList = List<Place>.from(state);
      newList[index] = newList[index].copyWith(status: PlaceStatus.done);
      state = newList;
      final completedIds = state
          .where((p) => p.status == PlaceStatus.done)
          .map((p) => p.id)
          .toList();
      _prefs.setStringList(_completedKey, completedIds);
    }
  }

  void resetProgress() {
    state = [for (final place in state) place.copyWith(status: PlaceStatus.active)];
    _prefs.remove(_completedKey);
  }
}
