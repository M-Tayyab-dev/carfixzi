import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/carfixzi_text_field.dart';
import '../../../../shared/widgets/osm_location_picker.dart';
import '../../../../app/routes/app_routes.dart';

/// D13: Mobile Car & Bike Wash Booking View
/// Doorstep wash scheduling with vehicle type toggle, packages,
/// and Sahiwal pilot zone address selection.
class CarWashBookingView extends StatefulWidget {
  const CarWashBookingView({super.key});

  @override
  State<CarWashBookingView> createState() => _CarWashBookingViewState();
}

class _CarWashBookingViewState extends State<CarWashBookingView> {
  final _addressCtrl = TextEditingController(text: 'House 42, Civil Lines, Sahiwal');
  bool _isMotorcycle = false;
  int _selectedPackageIndex = 0;

  final List<Map<String, dynamic>> _packages = [
    {
      'title': 'Express Snow Foam Wash',
      'carPaisa': 120000, // Rs 1,200
      'bikePaisa': 60000, // Rs 600
      'features': ['High-pressure water rinse', 'Snow foam hand shampoo', 'Tire dressing', 'Microfiber towel dry'],
      'duration': '40 mins',
    },
    {
      'title': 'Deep Interior & Exterior Spa',
      'carPaisa': 280000, // Rs 2,800
      'bikePaisa': 140000, // Rs 1,400
      'features': ['All Express features', 'Complete vacuum interior', 'Dashboard polish & conditioning', 'Engine bay degreasing'],
      'duration': '75 mins',
    },
    {
      'title': 'Ceramic Wax Detailing',
      'carPaisa': 450000, // Rs 4,500
      'bikePaisa': 220000, // Rs 2,200
      'features': ['Deep spa package', 'Hand ceramic wax coating', 'Hydrophobic glass treatment', 'Odor neutralization'],
      'duration': '120 mins',
    },
  ];

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pkg = _packages[_selectedPackageIndex];
    final pricePaisa = _isMotorcycle ? (pkg['bikePaisa'] as int) : (pkg['carPaisa'] as int);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Doorstep Wash', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isMotorcycle = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: !_isMotorcycle ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              'Car / SUV',
                              style: AppTypography.labelMedium.copyWith(
                                color: !_isMotorcycle ? Colors.white : AppColors.onSurfaceVariant,
                                fontWeight: !_isMotorcycle ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isMotorcycle = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _isMotorcycle ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              'Motorcycle',
                              style: AppTypography.labelMedium.copyWith(
                                color: _isMotorcycle ? Colors.white : AppColors.onSurfaceVariant,
                                fontWeight: _isMotorcycle ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Packages List
              Text(
                'Select Wash Package',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              ...List.generate(_packages.length, (idx) {
                final item = _packages[idx];
                final isSelected = idx == _selectedPackageIndex;
                final cost = _isMotorcycle ? (item['bikePaisa'] as int) : (item['carPaisa'] as int);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: CarfixziCard(
                    color: isSelected ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryContainer : const Color.fromRGBO(45, 49, 66, 0.1),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    onTap: () => setState(() => _selectedPackageIndex = idx),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['title'] as String,
                              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              CurrencyUtils.formatPaisa(cost),
                              style: AppTypography.headlineSmall.copyWith(
                                color: AppColors.primaryContainer,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Estimated Time: ${item['duration']}',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: (item['features'] as List<String>).map((feat) {
                            return Text(
                              '✓ $feat',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.darkSlate),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Doorstep Address Input
              CarfixziTextField(
                label: 'Doorstep Service Address (Sahiwal)',
                hint: 'House / Street / Area',
                controller: _addressCtrl,
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppColors.outline),
              ),
              const SizedBox(height: 24),

              // Confirm CTA Button
              CarfixziButton(
                text: 'Book Doorstep Wash (${CurrencyUtils.formatPaisa(pricePaisa)})',
                icon: Icons.local_car_wash_rounded,
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.serviceTracking,
                    arguments: {
                      'title': pkg['title'],
                      'vehicle': _isMotorcycle ? 'Motorcycle' : 'Car',
                      'address': _addressCtrl.text,
                      'pricePaisa': pricePaisa,
                    },
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
