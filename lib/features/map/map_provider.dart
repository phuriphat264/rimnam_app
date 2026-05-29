import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

// ============================================================
// พิกัด GPS จริงของ 6 สถานที่ในชุมชนริมน้ำจันทบูร
// ============================================================
const Map<String, LatLng> stationCoordinates = {
  '1': LatLng(12.6137, 102.1129),
  '2': LatLng(12.6124, 102.1138),
  '3': LatLng(12.6112, 102.1142),
  '4': LatLng(12.6100, 102.1144),
  '5': LatLng(12.6092, 102.1187),
  '6': LatLng(12.6082, 102.1145),
};

const LatLng chanthaburiCenter = LatLng(12.6108, 102.1148);
const double initialZoom = 15.5;

// ============================================================
// RouteStep — ขั้นตอนการนำทาง 1 จุด
// ============================================================
class RouteStep {
  final String instruction; // ข้อความภาษาไทย
  final String type;        // depart, turn, continue, arrive …
  final String modifier;    // left, right, straight, slight left …
  final double distanceToNext; // เมตรถึงจุดเลี้ยวถัดไป
  final LatLng maneuverPoint;  // พิกัดจุดเลี้ยว

  const RouteStep({
    required this.instruction,
    required this.type,
    required this.modifier,
    required this.distanceToNext,
    required this.maneuverPoint,
  });
}

// ============================================================
// RouteResult — ผลลัพธ์จาก OSRM
// ============================================================
class RouteResult {
  final List<LatLng> points;
  final List<RouteStep> steps;
  const RouteResult({required this.points, required this.steps});
  static const empty = RouteResult(points: [], steps: []);
}

// ============================================================
// Providers
// ============================================================
final selectedMapPlaceIdProvider = StateProvider<String?>((ref) => null);
final routePointsProvider = StateProvider<List<LatLng>>((ref) => const []);
final routeLoadingProvider = StateProvider<bool>((ref) => false);
final routeStepsProvider = StateProvider<List<RouteStep>>((ref) => const []);
final activeStepIndexProvider = StateProvider<int>((ref) => 0);
final isNavigatingProvider = StateProvider<bool>((ref) => false);

// ============================================================
// สร้างข้อความนำทางภาษาไทยจาก OSRM maneuver
// ============================================================
String _buildThaiInstruction(
    String type, String modifier, String streetName, double distance) {
  final distStr = distance < 1000
      ? '${distance.round()} ม.'
      : '${(distance / 1000).toStringAsFixed(1)} กม.';
  final street = streetName.isNotEmpty ? ' บน $streetName' : '';

  switch (type) {
    case 'depart':
      return 'ออกเดินทาง$street';
    case 'arrive':
      return 'ถึงจุดหมายแล้ว';
    case 'turn':
    case 'fork':
      switch (modifier) {
        case 'left':
        case 'sharp left':
          return 'เลี้ยวซ้าย อีก $distStr';
        case 'right':
        case 'sharp right':
          return 'เลี้ยวขวา อีก $distStr';
        case 'slight left':
          return 'เบี่ยงซ้าย อีก $distStr';
        case 'slight right':
          return 'เบี่ยงขวา อีก $distStr';
        default:
          return 'ตรงไป อีก $distStr';
      }
    case 'new name':
    case 'continue':
      return 'ตรงไป$street อีก $distStr';
    case 'roundabout':
    case 'rotary':
      return 'เข้าวงเวียน อีก $distStr';
    case 'merge':
      return 'รวมเลน อีก $distStr';
    default:
      return 'ตรงไป อีก $distStr';
  }
}

// ============================================================
// ดึงเส้นทาง + ขั้นตอนนำทางจาก OSRM
// ============================================================
Future<RouteResult> fetchWalkingRoute(LatLng from, LatLng to) async {
  try {
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/foot/'
      '${from.longitude},${from.latitude};'
      '${to.longitude},${to.latitude}'
      '?overview=full&geometries=geojson&steps=true',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return RouteResult.empty;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['code'] != 'Ok') return RouteResult.empty;

    final routes = data['routes'] as List;
    if (routes.isEmpty) return RouteResult.empty;

    // เส้นทางรวม (polyline)
    final coords = routes[0]['geometry']['coordinates'] as List;
    final points = coords
        .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
        .toList();

    // ขั้นตอนการนำทาง
    final legs = routes[0]['legs'] as List;
    final steps = <RouteStep>[];
    for (final leg in legs) {
      for (final step in leg['steps'] as List) {
        final maneuver = step['maneuver'] as Map<String, dynamic>;
        final type = maneuver['type'] as String? ?? '';
        final modifier = maneuver['modifier'] as String? ?? 'straight';
        final name = step['name'] as String? ?? '';
        final distance = (step['distance'] as num).toDouble();
        final loc = maneuver['location'] as List;
        steps.add(RouteStep(
          instruction: _buildThaiInstruction(type, modifier, name, distance),
          type: type,
          modifier: modifier,
          distanceToNext: distance,
          maneuverPoint: LatLng(
            (loc[1] as num).toDouble(),
            (loc[0] as num).toDouble(),
          ),
        ));
      }
    }

    return RouteResult(points: points, steps: steps);
  } catch (_) {
    return RouteResult.empty;
  }
}

// ============================================================
// GPS location stream
// ============================================================
final userLocationProvider = StreamProvider<Position?>((ref) async* {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) { yield null; return; }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      yield null;
      return;
    }

    try {
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      yield current;
    } catch (_) {
      yield null;
    }

    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  } catch (_) {
    yield null;
  }
});

// ============================================================
// Distance helpers
// ============================================================
double? distanceToStation(Position? userPos, String placeId) {
  if (userPos == null) return null;
  final coord = stationCoordinates[placeId];
  if (coord == null) return null;
  return Geolocator.distanceBetween(
    userPos.latitude, userPos.longitude,
    coord.latitude, coord.longitude,
  );
}

String? findNearestPlaceId(Position userPos, List<String> placeIds) {
  double? minDist;
  String? nearestId;
  for (final id in placeIds) {
    final coord = stationCoordinates[id];
    if (coord == null) continue;
    final dist = Geolocator.distanceBetween(
      userPos.latitude, userPos.longitude,
      coord.latitude, coord.longitude,
    );
    if (minDist == null || dist < minDist) {
      minDist = dist;
      nearestId = id;
    }
  }
  return nearestId;
}

String formatDistance(double meters) {
  if (meters < 1000) return '${meters.round()} ม.';
  return '${(meters / 1000).toStringAsFixed(1)} กม.';
}
