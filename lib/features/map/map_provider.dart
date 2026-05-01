import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

// Mock User Position State
final currentLocationProvider = StateProvider<Point<double>>((ref) {
  return const Point<double>(50.0, 50.0); // X, Y percentage on custom map
});

// Selected Place on Map
final selectedMapPlaceIdProvider = StateProvider<String?>((ref) => null);

// Distance Calculation logic
final distanceProvider = Provider.family<double, String>((ref, placeId) {
  // ในโปรเจกต์จริง ใช้ LatLng และ Geolocator.distanceBetween
  // ตรงนี้ Mock ค่าระยะทางเพื่อให้ UI มีข้อมูลแสดงผล
  final random = Random(placeId.hashCode); 
  return 50.0 + random.nextInt(450); // 50m - 500m
});