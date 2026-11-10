import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../app/routes/app_routes.dart';

/// D10: Workshop Locator & Discovery Map Screen
/// Uses OpenStreetMap via flutter_map + latlong2 with visible attribution,
/// search filters, verified workshop pins, and fallback card list.
class WorkshopLocatorView extends StatefulWidget {
  const WorkshopLocatorView({super.key});

  @override
  State<WorkshopLocatorView> createState() => _WorkshopLocatorViewState();
}

class _WorkshopLocatorViewState extends State<WorkshopLocatorView> {
  final MapController _mapController = MapController();
  String _selectedFilter = 'All Centers';

  final List<String> _filters = [
    'All Centers',
    'Certified Workshops',
    'Mobile Wash',
    'Brake & Suspension',
    'Open Now',
  ];

  // Verified workshop seed pins for pilot city (Sahiwal)
  final List<Map<String, dynamic>> _workshops = [
    {
      'id': 'ws_01',
      'name': 'Apex GT Motorwerks',
      'category': 'Engine & Transmission Specialist',
      'address': 'High Street Commercial Zone, Sahiwal',
      'point': const LatLng(30.6682, 73.1114),
      'rating': '4.9',
      'distance': '1.2 km',
      'isOpen': true,
      'badge': 'Tier-1 Verified',
    },
    {
      'id': 'ws_02',
      'name': 'Precision Auto Detailing & Wash',
      'category': 'Mobile Detailing & Ceramic Wash',
      'address': 'Civil Lines Road, Sahiwal',
      'point': const LatLng(30.6720, 73.1180),
      'rating': '4.8',
      'distance': '2.1 km',
      'isOpen': true,
      'badge': 'Mobile Wash Partner',
    },
    {
      'id': 'ws_03',
      'name': 'Bayside Mechanics Hub',
      'category': 'General Auto Care & Suspension',
      'address': 'GT Road Bypass, Sahiwal',
      'point': const LatLng(30.6610, 73.1050),
      'rating': '4.7',
      'distance': '3.4 km',
      'isOpen': false,
      'badge': 'Verified Partner',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Find Workshops', style: AppTypography.headlineSmall),
        actions: [
          IconButton(
            tooltip: 'Pilot City Info',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () {
              Get.defaultDialog(
                title: 'Pilot Geography',
                middleText:
                    'CARFIXZI is currently active in Sahiwal, Pakistan for the verified pilot evaluation.',
                textConfirm: 'Got it',
                confirmTextColor: AppColors.darkSlate,
                buttonColor: AppColors.accentGold,
                onConfirm: () => Get.back(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Pills Row
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = filter == _selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    labelStyle: AppTypography.labelSmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    backgroundColor: AppColors.surfaceContainerLowest,
                    selectedColor: AppColors.primaryContainer,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9999)),
                    side: BorderSide(
                      color: isSelected ? Colors.transparent : const Color.fromRGBO(45, 49, 66, 0.12),
                    ),
                    onSelected: (val) => setState(() => _selectedFilter = filter),
                  ),
                );
              },
            ),
          ),

          // Interactive OpenStreetMap (flutter_map)
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
                    initialZoom: 14.0,
                  ),
                  children: [
                    // OpenStreetMap Raster Tiles
                    TileLayer(
                      urlTemplate: AppConstants.osmTileUrl,
                      userAgentPackageName: AppConstants.osmUserAgent,
                    ),

                    // Verified Workshop Markers
                    MarkerLayer(
                      markers: _workshops.map((ws) {
                        return Marker(
                          point: ws['point'] as LatLng,
                          width: 44,
                          height: 44,
                          child: GestureDetector(
                            onTap: () {
                              _showWorkshopBottomSheet(context, ws);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.accentGold, width: 2.5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.build_circle_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),

                // OSM Mandatory Attribution Bar
                Positioned(
                  bottom: 6,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      AppConstants.osmAttribution,
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 10,
                        color: AppColors.darkSlate,
                      ),
                    ),
                  ),
                ),

                // Map Recenter Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'recenter_map',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    onPressed: () {
                      _mapController.move(
                        LatLng(AppConstants.defaultLatitude, AppConstants.defaultLongitude),
                        14.0,
                      );
                    },
                    child: const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),

          // Workshop List Cards
          Expanded(
            flex: 4,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _workshops.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ws = _workshops[index];
                return _WorkshopListTile(
                  workshop: ws,
                  onTap: () => _showWorkshopBottomSheet(context, ws),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showWorkshopBottomSheet(BuildContext context, Map<String, dynamic> ws) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    label: ws['badge'] as String,
                    variant: StatusBadgeVariant.accent,
                  ),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(ws['rating'] as String, style: AppTypography.labelMedium),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                ws['name'] as String,
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                ws['category'] as String,
                style: AppTypography.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: AppColors.outline),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ws['address'] as String,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              CarfixziButton(
                text: 'Book Workshop Service',
                onPressed: () {
                  Get.back();
                  Get.toNamed(AppRoutes.serviceBooking);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WorkshopListTile extends StatelessWidget {
  final Map<String, dynamic> workshop;
  final VoidCallback onTap;

  const _WorkshopListTile({
    required this.workshop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = workshop['isOpen'] as bool;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color.fromRGBO(45, 49, 66, 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.car_repair_rounded, color: AppColors.primaryContainer, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workshop['name'] as String,
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    workshop['category'] as String,
                    style: AppTypography.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      StatusBadge(
                        label: isOpen ? 'OPEN' : 'CLOSED',
                        variant: isOpen ? StatusBadgeVariant.success : StatusBadgeVariant.neutral,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        workshop['distance'] as String,
                        style: AppTypography.labelSmall.copyWith(color: AppColors.outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
          ],
        ),
      ),
    );
  }
}
