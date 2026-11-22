import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';

/// D08: Vehicle Garage & Registration (Customer Android)
/// Manages user vehicles with Pakistani provincial registration plates.
class VehicleRegistrationView extends StatefulWidget {
  const VehicleRegistrationView({super.key});

  @override
  State<VehicleRegistrationView> createState() => _VehicleRegistrationViewState();
}

class _VehicleRegistrationViewState extends State<VehicleRegistrationView> {
  final List<_VehicleRecord> _vehicles = [
    _VehicleRecord(
      id: 'v_01',
      make: 'Honda',
      model: 'Civic Oriel 1.8 i-VTEC',
      year: 2020,
      registrationNumber: 'LES-20-8812',
      mileageKm: 48500,
      isPrimary: true,
      fuelType: 'Petrol',
    ),
    _VehicleRecord(
      id: 'v_02',
      make: 'Toyota',
      model: 'Corolla GLi 1.3 VVTi',
      year: 2018,
      registrationNumber: 'SL-18-4921',
      mileageKm: 76200,
      isPrimary: false,
      fuelType: 'Petrol / CNG',
    ),
    _VehicleRecord(
      id: 'v_03',
      make: 'Atlas Honda',
      model: 'CG 125 Motorcycle',
      year: 2022,
      registrationNumber: 'SLN-22-3104',
      mileageKm: 14000,
      isPrimary: false,
      fuelType: 'Petrol',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('My Vehicles', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddVehicleDialog,
        backgroundColor: AppColors.accentGold,
        foregroundColor: AppColors.darkSlate,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Add Vehicle',
          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Garage Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_car_rounded, color: AppColors.accentGold, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_vehicles.length} Vehicles Registered',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Select your vehicle when booking repair or wash services.',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              'Registered Vehicles',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            ..._vehicles.map((v) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _VehicleCard(
                    vehicle: v,
                    onSetPrimary: () {
                      setState(() {
                        for (final item in _vehicles) {
                          item.isPrimary = item.id == v.id;
                        }
                      });
                      Get.snackbar(
                        'Primary Vehicle Updated',
                        '${v.make} ${v.model} is now your default vehicle.',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showAddVehicleDialog() {
    final makeCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final regCtrl = TextEditingController();
    final yearCtrl = TextEditingController(text: '2021');
    final mileageCtrl = TextEditingController();

    Get.defaultDialog(
      title: 'Register New Vehicle',
      titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
      contentPadding: const EdgeInsets.all(20),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: makeCtrl,
              decoration: InputDecoration(
                labelText: 'Make / Manufacturer',
                hintText: 'e.g. Honda, Toyota, Suzuki',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: modelCtrl,
              decoration: InputDecoration(
                labelText: 'Model & Variant',
                hintText: 'e.g. Civic 1.8 Oriel',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: regCtrl,
              decoration: InputDecoration(
                labelText: 'Registration Number',
                hintText: 'e.g. LES-21-4921',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: yearCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Year',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: mileageCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Odometer (km)',
                      hintText: '45000',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          foregroundColor: AppColors.darkSlate,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        onPressed: () {
          final make = makeCtrl.text.trim();
          final model = modelCtrl.text.trim();
          final reg = regCtrl.text.trim().toUpperCase();
          final year = int.tryParse(yearCtrl.text.trim()) ?? 2021;
          final mileage = int.tryParse(mileageCtrl.text.trim()) ?? 0;

          if (make.isEmpty || model.isEmpty || reg.isEmpty) {
            Get.snackbar(
              'Validation Error',
              'Please enter make, model, and registration plate.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.errorContainer,
              colorText: AppColors.error,
            );
            return;
          }

          setState(() {
            _vehicles.add(_VehicleRecord(
              id: 'v_${DateTime.now().millisecondsSinceEpoch}',
              make: make,
              model: model,
              year: year,
              registrationNumber: reg,
              mileageKm: mileage,
              isPrimary: _vehicles.isEmpty,
              fuelType: 'Petrol',
            ));
          });

          Get.back();
          Get.snackbar(
            'Vehicle Registered',
            '$make $model ($reg) added to your registered vehicles.',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: const Text('Save Vehicle'),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: const Text('Cancel'),
      ),
    );
  }
}

class _VehicleRecord {
  final String id;
  final String make;
  final String model;
  final int year;
  final String registrationNumber;
  final int mileageKm;
  bool isPrimary;
  final String fuelType;

  _VehicleRecord({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.registrationNumber,
    required this.mileageKm,
    required this.isPrimary,
    required this.fuelType,
  });
}

class _VehicleCard extends StatelessWidget {
  final _VehicleRecord vehicle;
  final VoidCallback onSetPrimary;

  const _VehicleCard({
    required this.vehicle,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Plate badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkSlate,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.accentGold, width: 1.5),
                ),
                child: Text(
                  vehicle.registrationNumber,
                  style: AppTypography.labelLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              if (vehicle.isPrimary)
                const StatusBadge(label: 'PRIMARY', variant: StatusBadgeVariant.accent)
              else
                TextButton(
                  onPressed: onSetPrimary,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 30)),
                  child: Text(
                    'Set as Primary',
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primaryContainer),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${vehicle.year} ${vehicle.make} ${vehicle.model}',
            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 16, color: AppColors.outline),
              const SizedBox(width: 4),
              Text(
                '${vehicle.mileageKm.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} km',
                style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
              ),
              const SizedBox(width: 14),
              const Icon(Icons.local_gas_station_rounded, size: 16, color: AppColors.outline),
              const SizedBox(width: 4),
              Text(
                vehicle.fuelType,
                style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
