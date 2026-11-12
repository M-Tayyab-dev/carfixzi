import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import 'carfixzi_button.dart';

class LocationPickResult {
  final LatLng point;
  final String address;

  const LocationPickResult({required this.point, required this.address});
}

/// Interactive OpenStreetMap Location Picker (using flutter_map & latlong2)
/// Allows users to pan, zoom, tap, and pick precise geographic coordinates
/// with landmark recognition for Sahiwal and surrounding Punjab sectors.
class OsmLocationPicker extends StatefulWidget {
  final LatLng? initialPoint;
  final String title;

  const OsmLocationPicker({
    super.key,
    this.initialPoint,
    this.title = 'Select Location on Map',
  });

  /// Helper to show picker as a bottom sheet or dialog
  static Future<LocationPickResult?> show(
    BuildContext context, {
    LatLng? initialPoint,
    String title = 'Pick Location on Map',
  }) async {
    return await Get.bottomSheet<LocationPickResult>(
      Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: OsmLocationPicker(
            initialPoint: initialPoint,
            title: title,
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  State<OsmLocationPicker> createState() => _OsmLocationPickerState();
}

class _OsmLocationPickerState extends State<OsmLocationPicker> {
  final MapController _mapController = MapController();
  late LatLng _selectedPoint;
  String _detectedAddress = 'Locating area...';

  // Sahiwal Landmark Snapping
  static final List<Map<String, dynamic>> _sahiwalLandmarks = [
    {'name': 'High Street Commercial Zone, Sahiwal', 'point': const LatLng(30.6682, 73.1114)},
    {'name': 'Civil Lines Road, Sahiwal', 'point': const LatLng(30.6720, 73.1180)},
    {'name': 'GT Road Bypass, Sahiwal', 'point': const LatLng(30.6610, 73.1050)},
    {'name': 'College Road, Near Stadium, Sahiwal', 'point': const LatLng(30.6750, 73.1090)},
    {'name': 'Farid Town Sector 03, Sahiwal', 'point': const LatLng(30.6810, 73.1250)},
    {'name': 'Circular Road, Sahiwal', 'point': const LatLng(30.6640, 73.1140)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedPoint = widget.initialPoint ??
        const LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude);
    _updateAddress(_selectedPoint);
  }

  void _updateAddress(LatLng point) {
    // Find closest landmark or formulate coordinate address
    const Distance distance = Distance();
    double minMeters = double.infinity;
    String closestName = 'Sahiwal District, Punjab, Pakistan';

    for (final lm in _sahiwalLandmarks) {
      final meters = distance.as(LengthUnit.Meter, point, lm['point'] as LatLng);
      if (meters < minMeters) {
        minMeters = meters;
        closestName = lm['name'] as String;
      }
    }

    setState(() {
      if (minMeters < 800) {
        _detectedAddress = '$closestName (~${minMeters.toInt()}m)';
      } else {
        _detectedAddress =
            'Near Sahiwal (${point.latitude.toStringAsFixed(4)}°N, ${point.longitude.toStringAsFixed(4)}°E)';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: AppTypography.headlineSmall),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          // FlutterMap OpenStreetMap View
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedPoint,
              initialZoom: 15.0,
              onTap: (tapPosition, point) {
                setState(() => _selectedPoint = point);
                _updateAddress(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: AppConstants.osmTileUrl,
                userAgentPackageName: AppConstants.osmUserAgent,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedPoint,
                    width: 50,
                    height: 50,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
                            ],
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // OSM Attribution
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: Text(
                'OpenStreetMap · Sahiwal Pilot',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          // Recenter / Quick Landmark Buttons
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                FloatingActionButton.small(
                  heroTag: 'osm_recenter',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryContainer,
                  tooltip: 'Center on Sahiwal Core',
                  onPressed: () {
                    const center = LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude);
                    _mapController.move(center, 15.0);
                    setState(() => _selectedPoint = center);
                    _updateAddress(center);
                  },
                  child: const Icon(Icons.my_location_rounded),
                ),
              ],
            ),
          ),

          // Bottom Confirmation Card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pin_drop_rounded, color: AppColors.error, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Selected Location',
                          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _detectedAddress,
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.darkSlate),
                    ),
                    Text(
                      'Lat: ${_selectedPoint.latitude.toStringAsFixed(5)}, Lon: ${_selectedPoint.longitude.toStringAsFixed(5)}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                    ),
                    const SizedBox(height: 16),
                    CarfixziButton(
                      text: 'Confirm This Location',
                      icon: Icons.check_circle_rounded,
                      onPressed: () {
                        Get.back(
                          result: LocationPickResult(
                            point: _selectedPoint,
                            address: _detectedAddress,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

