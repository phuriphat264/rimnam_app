import 'dart:async' show StreamSubscription, unawaited;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../core/localization/l10n_provider.dart';
import '../../core/storage/storage_service.dart';
import '../places/places_provider.dart';
import 'map_provider.dart';
import '../places/place_model.dart';
import '../places/place_detail_screen.dart';
import '../camera/camera_screen.dart';

// Nav bar total height: 70px container + 32px bottom padding
const _kNavBarHeight = 102.0;

// ============================================================
// PlaceCardWidget — used by places list screen
// ============================================================
class PlaceCardWidget extends StatefulWidget {
  final Place place;
  final VoidCallback onTap;

  const PlaceCardWidget({
    super.key,
    required this.place,
    required this.onTap,
  });

  @override
  State<PlaceCardWidget> createState() => _PlaceCardWidgetState();
}

class _PlaceCardWidgetState extends State<PlaceCardWidget> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.place.status == PlaceStatus.locked;
    final isDone = widget.place.status == PlaceStatus.done;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        if (!isLocked) widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed && !isLocked ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.glassBackground,
            border: Border.all(
              color: isDone ? AppColors.gold : AppColors.glassBorder,
              width: isDone ? 1.5 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 120,
                    height: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'place_image_${widget.place.id}',
                          child: Image.asset(
                            widget.place.imageUrl,
                            fit: BoxFit.cover,
                            color: isLocked ? Colors.grey : null,
                            colorBlendMode:
                                isLocked ? BlendMode.saturation : null,
                          ),
                        ),
                        if (isLocked)
                          Container(
                            color: AppColors.ink.withOpacity(0.5),
                            child: const Icon(Icons.lock, color: AppColors.cream),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            widget.place.name,
                            style: TextStyle(
                              color: isLocked
                                  ? AppColors.cream.withOpacity(0.5)
                                  : AppColors.gold,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.place.description,
                            style: TextStyle(
                              color: isLocked
                                  ? AppColors.cream.withOpacity(0.3)
                                  : AppColors.cream.withOpacity(0.8),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildStatusIcon(isLocked, isDone),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(bool isLocked, bool isDone) {
    if (isDone) {
      return const Icon(Icons.check_circle, color: AppColors.gold, size: 28);
    } else if (isLocked) {
      return const SizedBox.shrink();
    } else {
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 14),
      );
    }
  }
}

// ============================================================
// MapScreen — แผนที่ OSM จริงพร้อม GPS + นำทาง
// ============================================================
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  late final AnimationController _pulseController;

  // FMTC tile provider — constructed once, reused every build
  final _tileProvider = FMTCTileProvider(
    stores: const {'chanthaburi': BrowseStoreStrategy.readUpdateCreate},
  );

  double? _downloadProgress; // null = ไม่มี / 0.0–1.0 = กำลัง download
  StreamSubscription<DownloadProgress>? _downloadSub;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initTileCache();
  }

  @override
  void dispose() {
    _downloadSub?.cancel();
    _mapController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // Download tiles สำหรับพื้นที่ชุมชนริมน้ำจันทบูร (ครั้งแรกเท่านั้น)
  Future<void> _initTileCache() async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (prefs.getBool('tiles_downloaded') ?? false) return;

    final downloadBounds = LatLngBounds(
      const LatLng(12.602, 102.107),
      const LatLng(12.620, 102.125),
    );
    final region = RectangleRegion(downloadBounds).toDownloadable(
      minZoom: 14,
      maxZoom: 18,
      options: TileLayer(
        urlTemplate: 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.rimnam.chanthabun',
      ),
    );

    if (mounted) setState(() => _downloadProgress = 0.0);

    final streams = FMTCStore('chanthaburi').download.startForeground(
      region: region,
      parallelThreads: 3,
      skipExistingTiles: true,
      skipSeaTiles: true,
      rateLimit: 10,
    );

    _downloadSub = streams.downloadProgress.listen(
      (p) {
        if (mounted) setState(() => _downloadProgress = p.percentageProgress / 100);
      },
      onDone: () async {
        await prefs.setBool('tiles_downloaded', true);
        if (mounted) setState(() => _downloadProgress = null);
      },
    );
  }

  void _goToMyLocation() {
    final position = ref.read(userLocationProvider).valueOrNull;
    if (position == null) {
      _showSnackBar('ไม่พบตำแหน่ง GPS', isError: true);
      return;
    }
    _mapController.move(LatLng(position.latitude, position.longitude), 17.0);
  }

  void _zoomIn() {
    final zoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (zoom + 1).clamp(13.0, 19.0));
  }

  void _zoomOut() {
    final zoom = _mapController.camera.zoom;
    _mapController.move(_mapController.camera.center, (zoom - 1).clamp(13.0, 19.0));
  }

  // โหลดเส้นทาง: ลอง ORS ก่อน (ตามถนนจริง) fallback → bundled
  Future<void> _loadRoute(LatLng userPos, String targetStationId) async {
    ref.read(routePointsProvider.notifier).state = const [];
    ref.read(routeStepsProvider.notifier).state = const [];
    ref.read(activeStepIndexProvider.notifier).state = 0;
    ref.read(routeLoadingProvider.notifier).state = true;

    RouteResult? orsResult;
    try {
      orsResult = await fetchOrsRoute(userPos, targetStationId);
    } catch (_) {
      // silent — fallback to bundled route
    }

    if (!mounted) return;

    if (orsResult != null && orsResult.points.length >= 2) {
      ref.read(routePointsProvider.notifier).state = orsResult.points;
      ref.read(routeStepsProvider.notifier).state = orsResult.steps;
      ref.read(routeLoadingProvider.notifier).state = false;
      _fitRouteCamera([userPos, ...orsResult.points]);
      return;
    }

    final fallback = getBundledRouteFromPosition(userPos, targetStationId);
    ref.read(routePointsProvider.notifier).state = fallback.points;
    ref.read(routeStepsProvider.notifier).state = fallback.steps;
    ref.read(routeLoadingProvider.notifier).state = false;
    if (fallback.points.length >= 2) {
      _fitRouteCamera([userPos, ...fallback.points]);
    }
  }

  void _fitRouteCamera(List<LatLng> allPoints) {
    if (allPoints.isEmpty) return;
    var minLat = allPoints.first.latitude;
    var maxLat = allPoints.first.latitude;
    var minLng = allPoints.first.longitude;
    var maxLng = allPoints.first.longitude;
    for (final p in allPoints.skip(1)) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds(
          LatLng(minLat, minLng),
          LatLng(maxLat, maxLng),
        ),
        padding: const EdgeInsets.fromLTRB(48, 48, 48, _kNavBarHeight + 80),
        maxZoom: 17.0,
      ),
    );
  }

  void _stopNavigation() {
    final selectedId = ref.read(selectedMapPlaceIdProvider);
    ref.read(isNavigatingProvider.notifier).state = false;
    ref.read(activeStepIndexProvider.notifier).state = 0;
    if (selectedId != null) {
      final coord = stationCoordinates[selectedId];
      if (coord != null) _mapController.move(coord, 17.0);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Noto Serif Thai', color: AppColors.cream),
        ),
        backgroundColor: isError ? AppColors.mahogany : AppColors.espresso,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(placesProvider);
    final selectedId = ref.watch(selectedMapPlaceIdProvider);
    final translations = ref.watch(translationsProvider);
    final locationAsync = ref.watch(userLocationProvider);
    final userPosition = locationAsync.valueOrNull;
    final routePoints = ref.watch(routePointsProvider);
    final routeSteps = ref.watch(routeStepsProvider);
    final activeStep = ref.watch(activeStepIndexProvider);
    final isNavigating = ref.watch(isNavigatingProvider);
    final routeLoading = ref.watch(routeLoadingProvider);

    // อัปเดตขั้นตอนนำทางตาม GPS อัตโนมัติ
    ref.listen<AsyncValue<Position?>>(userLocationProvider, (_, next) {
      final pos = next.valueOrNull;
      if (pos == null) return;
      if (!ref.read(isNavigatingProvider)) return;

      final steps = ref.read(routeStepsProvider);
      final idx = ref.read(activeStepIndexProvider);
      if (idx >= steps.length - 1) return;

      // auto-center map ตามผู้ใช้ขณะนำทาง
      _mapController.move(LatLng(pos.latitude, pos.longitude),
          _mapController.camera.zoom);

      // advance step เมื่อเข้าใกล้ 20 เมตร
      final next_ = steps[idx + 1];
      final dist = Geolocator.distanceBetween(
        pos.latitude, pos.longitude,
        next_.maneuverPoint.latitude, next_.maneuverPoint.longitude,
      );
      if (dist < 20) {
        ref.read(activeStepIndexProvider.notifier).state = idx + 1;
      }
    });

    final markers = <Marker>[
      for (final place in places)
        if (stationCoordinates[place.id] != null)
          Marker(
            point: stationCoordinates[place.id]!,
            width: selectedId == place.id ? 56 : 44,
            height: selectedId == place.id ? 76 : 62,
            alignment: Alignment.bottomCenter,
            child: _StationMarker(
              place: place,
              isSelected: place.id == selectedId,
              onTap: () {
                if (place.id == selectedId) {
                  ref.read(selectedMapPlaceIdProvider.notifier).state = null;
                  ref.read(routePointsProvider.notifier).state = const [];
                  ref.read(routeStepsProvider.notifier).state = const [];
                } else {
                  ref.read(selectedMapPlaceIdProvider.notifier).state = place.id;
                }
              },
            ),
          ),
      if (userPosition != null)
        Marker(
          point: LatLng(userPosition.latitude, userPosition.longitude),
          width: 52,
          height: 52,
          alignment: Alignment.center,
          child: _UserLocationMarker(animation: _pulseController),
        ),
    ];

    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: AppColors.espresso,
        elevation: 0,
        title: Text(
          translations['map_title'] ?? 'แผนที่ 6 สถานที่',
          style: const TextStyle(
            color: AppColors.gold,
            fontFamily: 'Noto Serif Thai',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: const SizedBox.shrink(),
      ),
      body: Stack(
        children: [
          // ====== แผนที่ OSM ======
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: chanthaburiCenter,
              initialZoom: initialZoom,
              minZoom: 13.0,
              maxZoom: 19.0,
              onTap: (_, __) {
                if (ref.read(isNavigatingProvider)) return;
                ref.read(selectedMapPlaceIdProvider.notifier).state = null;
                ref.read(routePointsProvider.notifier).state = const [];
                ref.read(routeStepsProvider.notifier).state = const [];
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.rimnam.chanthabun',
                maxZoom: 19,
                tileProvider: _tileProvider,
              ),
              // เส้นทาง OSRM จริง (ถ้าโหลดแล้ว)
              if (routePoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: AppColors.teal,
                      strokeWidth: 4.0,
                    ),
                  ],
                )
              // เส้นตรงชั่วคราว (ขณะโหลด หรือ GPS ไม่มี)
              else if (selectedId != null &&
                  userPosition != null &&
                  stationCoordinates[selectedId] != null)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        LatLng(userPosition.latitude, userPosition.longitude),
                        stationCoordinates[selectedId]!,
                      ],
                      color: AppColors.teal.withOpacity(0.4),
                      strokeWidth: 2.0,
                    ),
                  ],
                ),
              MarkerLayer(markers: markers, rotate: false),
            ],
          ),

          // ====== Navigation Panel — แสดงเมื่อนำทาง ======
          if (isNavigating)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: routeLoading || routeSteps.isEmpty
                  ? _NavigationLoadingPanel(onStop: _stopNavigation)
                  : _NavigationPanel(
                      step: routeSteps[activeStep.clamp(0, routeSteps.length - 1)],
                      stepIndex: activeStep,
                      totalSteps: routeSteps.length,
                      onStop: _stopNavigation,
                    ),
            ),

          // ====== Legend บนขวา (ซ่อนเมื่อนำทาง) ======
          if (!isNavigating)
            Positioned(
              top: 12,
              right: 16,
              child: _MapLegend(translations: translations),
            ),

          // ====== GPS chip บนซ้าย (ซ่อนเมื่อนำทาง) ======
          if (!isNavigating)
            Positioned(
              top: 12,
              left: 16,
              child: _LocationChip(locationAsync: locationAsync),
            ),

          // ====== Download progress banner (แสดงครั้งแรกที่เปิดแมพ) ======
          if (_downloadProgress != null && !isNavigating)
            Positioned(
              top: 50,
              left: 16,
              child: _TileDownloadBanner(progress: _downloadProgress!),
            ),

          // ====== Bottom card เมื่อเลือกสถานที่ — centered ======
          if (selectedId != null && !isNavigating)
            Positioned(
              left: 0,
              right: 0,
              bottom: _kNavBarHeight + 8,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _MapBottomCard(
                      key: ValueKey(selectedId),
                      place: places.firstWhere((p) => p.id == selectedId),
                      userPosition: userPosition,
                      translations: translations,
                      isNavigating: isNavigating,
                      onClose: () {
                        ref.read(selectedMapPlaceIdProvider.notifier).state = null;
                        ref.read(routePointsProvider.notifier).state = const [];
                        ref.read(routeStepsProvider.notifier).state = const [];
                        _stopNavigation();
                      },
                      onNavigate: () async {
                        if (isNavigating) {
                          _stopNavigation();
                          return;
                        }
                        if (userPosition == null) {
                          final open = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.espresso,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              title: const Text(
                                'ต้องการ GPS',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontFamily: 'Noto Serif Thai',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              content: const Text(
                                'กรุณาเปิด GPS เพื่อใช้งานการนำทาง',
                                style: TextStyle(
                                  color: AppColors.cream,
                                  fontFamily: 'Noto Serif Thai',
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('ยกเลิก',
                                      style:
                                          TextStyle(color: AppColors.cream)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('เปิดการตั้งค่า',
                                      style: TextStyle(color: AppColors.gold)),
                                ),
                              ],
                            ),
                          );
                          if (!mounted) return;
                          if (open == true) {
                            await Geolocator.openLocationSettings();
                            if (mounted) ref.invalidate(userLocationProvider);
                          }
                          return;
                        }
                        final userLatLng = LatLng(
                            userPosition.latitude, userPosition.longitude);
                        ref.read(isNavigatingProvider.notifier).state = true;
                        _mapController.move(userLatLng, 17.0);
                        unawaited(_loadRoute(userLatLng, selectedId));
                      },
                    ),
                  ),
                ),
              ),
            ),

          // ====== Zoom + my_location — กลางขวา (ซ่อนเมื่อมี card) ======
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: selectedId != null ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: IgnorePointer(
                ignoring: selectedId != null,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'zoom_in',
                        onPressed: _zoomIn,
                        backgroundColor: AppColors.espresso,
                        elevation: 4,
                        child: const Icon(Icons.add, color: AppColors.gold, size: 22),
                      ),
                      const SizedBox(height: 6),
                      FloatingActionButton.small(
                        heroTag: 'zoom_out',
                        onPressed: _zoomOut,
                        backgroundColor: AppColors.espresso,
                        elevation: 4,
                        child: const Icon(Icons.remove, color: AppColors.gold, size: 22),
                      ),
                      const SizedBox(height: 6),
                      FloatingActionButton.small(
                        heroTag: 'my_location',
                        onPressed: _goToMyLocation,
                        backgroundColor: AppColors.espresso,
                        elevation: 4,
                        child: const Icon(Icons.my_location, color: AppColors.gold, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Marker สถานที่
// ============================================================
class _StationMarker extends StatelessWidget {
  final Place place;
  final bool isSelected;
  final VoidCallback onTap;

  const _StationMarker({
    required this.place,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = place.status == PlaceStatus.done;
    final isActive = place.status == PlaceStatus.active;
    final isLocked = place.status == PlaceStatus.locked;

    final Color pinColor;
    if (isDone) {
      pinColor = AppColors.gold;
    } else if (isActive) {
      pinColor = AppColors.cream;
    } else {
      pinColor = AppColors.mahogany;
    }

    final IconData pinIcon;
    if (isDone) {
      pinIcon = Icons.check_circle;
    } else if (isLocked) {
      pinIcon = Icons.lock;
    } else {
      pinIcon = Icons.location_on;
    }

    final double size = isSelected ? 44 : 34;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: pinColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.amber : AppColors.espresso,
                width: isSelected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected || isActive
                      ? AppColors.gold.withOpacity(0.6)
                      : Colors.black.withOpacity(0.4),
                  blurRadius: isSelected ? 16 : 6,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Icon(
              pinIcon,
              color: (isDone || isActive)
                  ? AppColors.ink
                  : AppColors.cream.withOpacity(0.6),
              size: size * 0.55,
            ),
          ),
          Container(width: 2, height: 6, color: pinColor),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.gold : AppColors.ink.withOpacity(0.85),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected ? AppColors.amber : pinColor.withOpacity(0.6),
                width: 0.8,
              ),
            ),
            child: Text(
              place.id,
              style: TextStyle(
                color: isSelected ? AppColors.ink : AppColors.cream,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                fontFamily: 'Noto Serif Thai',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Marker ตำแหน่งผู้ใช้ — pulse effect
// ============================================================
class _UserLocationMarker extends AnimatedWidget {
  const _UserLocationMarker({required AnimationController animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final double t = (listenable as Animation<double>).value;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 52 * (0.4 + t * 0.6),
          height: 52 * (0.4 + t * 0.6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.teal.withOpacity(0.15 * (1 - t)),
            border: Border.all(
              color: AppColors.teal.withOpacity(0.4 * (1 - t)),
              width: 1.5,
            ),
          ),
        ),
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.teal,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(color: AppColors.teal.withOpacity(0.5), blurRadius: 8),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Navigation Panel — แสดงขั้นตอนนำทางปัจจุบัน
// ============================================================
IconData _stepIcon(String type, String modifier) {
  if (type == 'arrive') return Icons.flag_rounded;
  if (type == 'depart') return Icons.navigation_rounded;
  switch (modifier) {
    case 'left':
    case 'sharp left':
      return Icons.turn_left_rounded;
    case 'right':
    case 'sharp right':
      return Icons.turn_right_rounded;
    case 'slight left':
      return Icons.turn_slight_left_rounded;
    case 'slight right':
      return Icons.turn_slight_right_rounded;
    default:
      return Icons.straight_rounded;
  }
}

class _NavigationPanel extends StatelessWidget {
  final RouteStep step;
  final int stepIndex;
  final int totalSteps;
  final VoidCallback onStop;

  const _NavigationPanel({
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final isArrived = step.type == 'arrive';
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.espresso.withOpacity(0.95),
            border: Border(
              bottom: BorderSide(color: AppColors.teal.withOpacity(0.4), width: 1),
            ),
          ),
          child: Row(
            children: [
              // ไอคอนทิศทาง
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isArrived
                      ? AppColors.gold.withOpacity(0.2)
                      : AppColors.teal.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isArrived ? AppColors.gold : AppColors.teal,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  _stepIcon(step.type, step.modifier),
                  color: isArrived ? AppColors.gold : AppColors.teal,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              // ข้อความ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      step.instruction,
                      style: const TextStyle(
                        color: AppColors.cream,
                        fontSize: 15,
                        fontFamily: 'Noto Serif Thai',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ขั้นตอนที่ ${stepIndex + 1} / $totalSteps',
                      style: TextStyle(
                        color: AppColors.cream.withOpacity(0.5),
                        fontSize: 11,
                        fontFamily: 'Noto Serif Thai',
                      ),
                    ),
                  ],
                ),
              ),
              // ปุ่มหยุดนำทาง
              GestureDetector(
                onTap: onStop,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.mahogany.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.mahogany.withOpacity(0.6), width: 1),
                  ),
                  child: const Icon(Icons.close, color: AppColors.cream, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Navigation Loading Panel — แสดงขณะโหลดเส้นทาง ORS
// ============================================================
class _NavigationLoadingPanel extends StatelessWidget {
  final VoidCallback onStop;
  const _NavigationLoadingPanel({required this.onStop});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: AppColors.espresso.withOpacity(0.95),
            border: Border(
              bottom: BorderSide(color: AppColors.teal.withOpacity(0.4), width: 1),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.teal),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'กำลังโหลดเส้นทาง...',
                  style: TextStyle(
                    color: AppColors.cream,
                    fontSize: 15,
                    fontFamily: 'Noto Serif Thai',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onStop,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.mahogany.withOpacity(0.3),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.mahogany.withOpacity(0.6), width: 1),
                  ),
                  child: const Icon(Icons.close, color: AppColors.cream, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Bottom card — รายละเอียด + ปุ่มดูข้อมูล + ถ่ายรูป + นำทาง
// ============================================================
class _MapBottomCard extends ConsumerWidget {
  final Place place;
  final Position? userPosition;
  final Map<String, String> translations;
  final bool isNavigating;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const _MapBottomCard({
    super.key,
    required this.place,
    required this.userPosition,
    required this.translations,
    required this.isNavigating,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coord = stationCoordinates[place.id];
    final dist = distanceToStation(userPosition, place.id);
    final isDone = place.status == PlaceStatus.done;

    final String distanceText = dist != null
        ? '${formatDistance(dist)} จากคุณ'
        : place.location;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) => Transform.translate(
        offset: Offset(0, 220 * (1 - value)),
        child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.espresso.withOpacity(0.92),
              border: Border.all(color: AppColors.gold.withOpacity(0.35), width: 1),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ====== Top row: ภาพ + ข้อมูล + ปุ่มปิด ======
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        place.imageUrl,
                        width: 66,
                        height: 66,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 66,
                          height: 66,
                          color: AppColors.mahogany,
                          child: const Icon(Icons.image_not_supported,
                              color: AppColors.cream),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            translations['place_${place.id}_name'] ?? place.name,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'Noto Serif Thai',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                userPosition != null
                                    ? Icons.near_me
                                    : Icons.location_on_outlined,
                                color: AppColors.teal,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  distanceText,
                                  style: TextStyle(
                                    color: AppColors.cream.withOpacity(0.8),
                                    fontSize: 11,
                                    fontFamily: 'Noto Serif Thai',
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _StatusBadge(
                              status: place.status, translations: translations),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.mahogany.withOpacity(0.4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: AppColors.cream, size: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
                Divider(color: AppColors.gold.withOpacity(0.2), height: 1),
                const SizedBox(height: 10),

                // ====== Action buttons ======
                Row(
                  children: [
                    // ดูรายละเอียด/ประวัติ
                    Expanded(
                      child: _CardActionButton(
                        icon: Icons.info_outline_rounded,
                        label: 'รายละเอียด',
                        color: AppColors.cream,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PlaceDetailScreen(
                              place: place,
                              index: int.tryParse(place.id) ?? 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ถ่ายภาพ
                    Expanded(
                      child: _CardActionButton(
                        icon: isDone
                            ? Icons.check_circle_outline_rounded
                            : Icons.camera_alt_rounded,
                        label: isDone ? 'สำเร็จแล้ว' : 'ถ่ายภาพ',
                        color: isDone
                            ? Colors.greenAccent.shade200
                            : AppColors.gold,
                        onTap: isDone
                            ? null
                            : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        CameraScreen(placeId: place.id),
                                  ),
                                ),
                      ),
                    ),
                    // ปุ่มนำทาง
                    if (coord != null) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onNavigate,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isNavigating ? AppColors.mahogany : AppColors.teal,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (isNavigating ? AppColors.mahogany : AppColors.teal).withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Icon(
                            isNavigating ? Icons.stop_rounded : Icons.navigation_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ปุ่ม action ใน bottom card
// ============================================================
class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _CardActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.4), width: 0.8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 15),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontFamily: 'Noto Serif Thai',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Status badge เล็ก
// ============================================================
class _StatusBadge extends StatelessWidget {
  final PlaceStatus status;
  final Map<String, String> translations;

  const _StatusBadge({required this.status, required this.translations});

  @override
  Widget build(BuildContext context) {
    if (status == PlaceStatus.active) return const SizedBox.shrink();

    final Color color;
    final String label;
    if (status == PlaceStatus.done) {
      color = Colors.greenAccent.shade200;
      label = translations['map_done'] ?? '✓ สำเร็จ';
    } else {
      color = AppColors.cream.withOpacity(0.4);
      label = translations['map_locked'] ?? '🔒 ล็อค';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          fontFamily: 'Noto Serif Thai',
        ),
      ),
    );
  }
}

// ============================================================
// Legend มุมบนขวา
// ============================================================
class _MapLegend extends StatelessWidget {
  final Map<String, String> translations;

  const _MapLegend({required this.translations});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.espresso.withOpacity(0.9),
            border: Border.all(color: AppColors.gold.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LegendRow(
                  color: AppColors.cream,
                  label: translations['map_unlocked'] ?? 'พร้อมเยี่ยมชม'),
              const SizedBox(height: 6),
              _LegendRow(
                  color: AppColors.gold,
                  label: translations['map_done']?.replaceAll('✓ ', '') ?? 'สำเร็จ'),
              const SizedBox(height: 6),
              _LegendRow(color: AppColors.teal, label: 'คุณอยู่ที่นี่', isCircle: false),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final bool isCircle;

  const _LegendRow({
    required this.color,
    required this.label,
    this.isCircle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: isCircle ? null : BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.cream,
            fontSize: 10,
            fontFamily: 'Noto Serif Thai',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Tile download progress banner
// ============================================================
class _TileDownloadBanner extends StatelessWidget {
  final double progress; // 0.0 – 1.0

  const _TileDownloadBanner({required this.progress});

  @override
  Widget build(BuildContext context) {
    final pct = (progress * 100).round();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.espresso.withOpacity(0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.teal.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.teal),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'บันทึกแผนที่ offline... $pct%',
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 10,
                  fontFamily: 'Noto Serif Thai',
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            width: 160,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(AppColors.teal),
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// GPS status chip — แตะเพื่อเปิด settings / retry
// ============================================================
class _LocationChip extends ConsumerWidget {
  final AsyncValue<Position?> locationAsync;

  const _LocationChip({required this.locationAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String label;
    final Color dotColor;
    final bool loading;

    if (locationAsync.isLoading) {
      label = 'กำลังหาตำแหน่ง...';
      dotColor = AppColors.honey;
      loading = true;
    } else if (locationAsync.hasError) {
      label = 'แตะเพื่อลองใหม่';
      dotColor = AppColors.mahogany;
      loading = false;
    } else if (locationAsync.valueOrNull == null) {
      label = 'แตะเพื่อเปิด GPS';
      dotColor = AppColors.cream.withOpacity(0.4);
      loading = false;
    } else {
      label = 'GPS เชื่อมต่อแล้ว';
      dotColor = AppColors.teal;
      loading = false;
    }

    return GestureDetector(
      onTap: () async {
        if (loading) return;
        if (locationAsync.hasError) {
          await Geolocator.openAppSettings();
        } else if (locationAsync.valueOrNull == null) {
          await Geolocator.openLocationSettings();
        }
        ref.invalidate(userLocationProvider);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.espresso.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (loading)
              const SizedBox(
                width: 10,
                height: 10,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation(AppColors.gold),
                ),
              )
            else
              Container(
                width: 8,
                height: 8,
                decoration:
                    BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.cream,
                fontSize: 10,
                fontFamily: 'Noto Serif Thai',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
