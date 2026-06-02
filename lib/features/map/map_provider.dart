import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'route_data.dart';

const _orsApiKey = String.fromEnvironment('ORS_API_KEY');

// ============================================================
// พิกัด GPS จริงของ 6 สถานที่ในชุมชนริมน้ำจันทบูร
// ============================================================
const Map<String, LatLng> stationCoordinates = {
  '1': LatLng(12.61370,  102.11315),   // วัดโบสถ์เมือง         (OSM verified)
  '2': LatLng(12.61267,  102.11326),   // ศาลเจ้าตั้วเล่าเอี๊ย   (OSM verified)
  '3': LatLng(12.61241,  102.11385),   // บ้านหลวงราชไมตรี       (OSM verified)
  '4': LatLng(12.60965,  102.11502),   // โรงเจเทียงเช็งตึ๊ง      (user GPS — ยืนยันด้วย right-click)
  '5': LatLng(12.60871,  102.11597),   // ศูนย์เรียนรู้ประจำชุมชน  (OSM Learning House)
  '6': LatLng(12.60924,  102.11865),   // อาสนวิหารพระนางมารีอา  (OSM verified)
};

// รัศมีสูงสุดที่อนุญาตให้ถ่ายรูปยืนยันภารกิจ (เมตร)
const Map<String, double> stationMaxDistance = {
  '6': 200.0, // อาสนวิหารฯ — พื้นที่กว้าง
};
const double _defaultMaxDistance = 50.0;

double maxDistanceForStation(String placeId) =>
    stationMaxDistance[placeId] ?? _defaultMaxDistance;

const LatLng chanthaburiCenter = LatLng(12.6112, 102.1153);
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

// ระยะทางตามถนนจริง (คำนวณจาก polyline ที่ได้จาก ORS/bundled)
final routeRoadDistanceProvider = Provider<double?>((ref) {
  final points = ref.watch(routePointsProvider);
  if (points.length < 2) return null;
  double total = 0;
  for (int i = 0; i < points.length - 1; i++) {
    total += Geolocator.distanceBetween(
      points[i].latitude, points[i].longitude,
      points[i + 1].latitude, points[i + 1].longitude,
    );
  }
  return total;
});

// ============================================================
// สร้างข้อความนำทางภาษาไทยจาก OSRM maneuver
// ============================================================
String buildThaiInstruction(
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
// หาสถานีที่ใกล้ที่สุดจากตำแหน่งผู้ใช้ (ข้ามสถานีที่ระบุ)
// ============================================================
String _nearestStationId(LatLng pos, {String? exclude}) {
  String? nearest;
  double? minDist;
  for (final entry in stationCoordinates.entries) {
    if (entry.key == exclude) continue;
    final d = Geolocator.distanceBetween(
      pos.latitude, pos.longitude,
      entry.value.latitude, entry.value.longitude,
    );
    if (minDist == null || d < minDist) {
      minDist = d;
      nearest = entry.key;
    }
  }
  return nearest!;
}

// ============================================================
// ดึงเส้นทาง pre-bundled จากตำแหน่งผู้ใช้ → สถานีเป้าหมาย
// ============================================================
RouteResult getBundledRouteFromPosition(LatLng userPos, String targetId) {
  // ใช้ station ที่ใกล้ที่สุดที่ไม่ใช่ target เป็นจุดเริ่มของ route
  final fromId = _nearestStationId(userPos, exclude: targetId);

  final key = '${fromId}_$targetId';
  final pts = bundledRoutePoints[key];
  final stepData = bundledRouteSteps[key];
  if (pts == null || stepData == null || pts.isEmpty) return RouteResult.empty;

  final points = pts.map((p) => LatLng(p[0], p[1])).toList();
  final steps = stepData.map((s) => RouteStep(
    instruction: buildThaiInstruction(
      s[0] as String, s[1] as String, s[2] as String, s[3] as double,
    ),
    type: s[0] as String,
    modifier: s[1] as String,
    distanceToNext: s[3] as double,
    maneuverPoint: LatLng(s[4] as double, s[5] as double),
  )).toList();

  // ต่อเส้นตรงจากตำแหน่งผู้ใช้ถึงจุดเริ่มต้น route เสมอ
  // (ส่วนนี้จะสั้นมากถ้า user อยู่ในพื้นที่)
  final startCoord = stationCoordinates[fromId]!;
  final distToStart = Geolocator.distanceBetween(
    userPos.latitude, userPos.longitude,
    startCoord.latitude, startCoord.longitude,
  );
  if (distToStart > 15) {
    return RouteResult(points: [userPos, ...points], steps: steps);
  }
  return RouteResult(points: points, steps: steps);
}

// ============================================================
// GPS service status stream (on / off auto-detect)
// ============================================================
final gpsServiceStatusProvider = StreamProvider<bool>((ref) async* {
  yield await Geolocator.isLocationServiceEnabled();
  yield* Geolocator.getServiceStatusStream().map(
    (s) => s == ServiceStatus.enabled,
  );
});

// ============================================================
// GPS location stream
// ============================================================
final userLocationProvider = StreamProvider<Position?>((ref) async* {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) { yield null; return; }

    // ไม่ขออนุญาตเอง — main_screen จัดการ permission flow แล้ว
    final permission = await Geolocator.checkPermission();
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

// ============================================================
// OpenRouteService — auto-switch walking/driving by distance
// ============================================================
// < 500 ม. → foot-walking, ≥ 500 ม. → driving-car
Future<RouteResult> fetchOrsRoute(LatLng userPos, String targetId) async {
  if (_orsApiKey.isEmpty) throw Exception('ORS_API_KEY not set');

  final target = stationCoordinates[targetId];
  if (target == null) return RouteResult.empty;

  final distToTarget = Geolocator.distanceBetween(
    userPos.latitude, userPos.longitude,
    target.latitude, target.longitude,
  );
  final profile = distToTarget < 500 ? 'foot-walking' : 'driving-car';

  final url = Uri.parse(
    'https://api.openrouteservice.org/v2/directions/$profile/geojson',
  );

  final response = await http.post(
    url,
    headers: {
      'Authorization': _orsApiKey,
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json, application/geo+json',
    },
    body: jsonEncode({
      'coordinates': [
        [userPos.longitude, userPos.latitude],
        [target.longitude, target.latitude],
      ],
      'preference': 'shortest',
      'instructions': true,
      'units': 'm',
    }),
  ).timeout(const Duration(seconds: 10));

  if (response.statusCode != 200) {
    throw Exception('ORS ${response.statusCode}: ${response.body}');
  }

  final data = jsonDecode(response.body) as Map<String, dynamic>;
  final features = data['features'] as List<dynamic>;
  if (features.isEmpty) return RouteResult.empty;

  final feature = features[0] as Map<String, dynamic>;
  final coords = (feature['geometry']['coordinates'] as List<dynamic>)
      .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
      .toList();

  final steps = <RouteStep>[];
  for (final seg in feature['properties']['segments'] as List<dynamic>) {
    for (final step in seg['steps'] as List<dynamic>) {
      final type    = step['type'] as int;
      final name    = step['name'] as String? ?? '';
      final dist    = (step['distance'] as num).toDouble();
      final wpStart = (step['way_points'] as List<dynamic>)[0] as int;
      final pt      = coords[wpStart.clamp(0, coords.length - 1)];

      steps.add(RouteStep(
        instruction: _orsInstruction(type, name, dist),
        type: _orsType(type),
        modifier: _orsModifier(type),
        distanceToNext: dist,
        maneuverPoint: pt,
      ));
    }
  }

  return RouteResult(points: coords, steps: steps);
}

String _orsInstruction(int type, String name, double dist) {
  final d = dist < 1000
      ? '${dist.round()} ม.'
      : '${(dist / 1000).toStringAsFixed(1)} กม.';
  final s = name.isNotEmpty ? ' บน $name' : '';
  switch (type) {
    case 0:  return 'เลี้ยวซ้าย$s อีก $d';
    case 1:  return 'เลี้ยวขวา$s อีก $d';
    case 2:  return 'เลี้ยวซ้ายชัด$s อีก $d';
    case 3:  return 'เลี้ยวขวาชัด$s อีก $d';
    case 4:  return 'เบี่ยงซ้าย$s อีก $d';
    case 5:  return 'เบี่ยงขวา$s อีก $d';
    case 6:  return 'ตรงไป$s อีก $d';
    case 10: return 'ถึงจุดหมายแล้ว';
    case 11: return 'ออกเดินทาง$s';
    case 12: return 'เบี่ยงซ้าย$s อีก $d';
    case 13: return 'เบี่ยงขวา$s อีก $d';
    default: return 'ตรงไป$s อีก $d';
  }
}

String _orsType(int type) {
  if (type == 11) return 'depart';
  if (type == 10) return 'arrive';
  if (type == 6)  return 'continue';
  return 'turn';
}

String _orsModifier(int type) {
  switch (type) {
    case 0: case 12: return 'left';
    case 1: case 13: return 'right';
    case 2:          return 'sharp left';
    case 3:          return 'sharp right';
    case 4:          return 'slight left';
    case 5:          return 'slight right';
    default:         return 'straight';
  }
}

