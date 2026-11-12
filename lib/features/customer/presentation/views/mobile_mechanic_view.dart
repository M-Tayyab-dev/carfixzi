import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/carfixzi_text_field.dart';
import '../../../../shared/widgets/osm_location_picker.dart';
import '../../../../app/routes/app_routes.dart';

/// NEW-04: Mobile Mechanic Minor Issue Request Screen
/// On-demand minor roadside or home mechanic dispatch managed by partner workshop
class MobileMechanicView extends StatefulWidget {
  const MobileMechanicView({super.key});

  @override
  State<MobileMechanicView> createState() => _MobileMechanicViewState();
}

class _MobileMechanicViewState extends State<MobileMechanicView> {
  final _addressCtrl = TextEditingController(text: 'College Road, Near Stadium, Sahiwal');
  final _descriptionCtrl = TextEditingController();
  String _selectedIssue = 'Dead Battery / Jumpstart Required';
  bool _hasAttachedPhoto = false;
  bool _isSubmitting = false;

  final List<String> _commonIssues = [
    'Dead Battery / Jumpstart Required',
    'Flat Tire / Wheel Replacement',
    'Engine Overheating / Coolant Leak',
    'Brake Jam / Unusual Grinding Noise',
    'Other Minor Mechanical Issue',
  ];

  @override
  void dispose() {
    _addressCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() => _isSubmitting = false);
      Get.toNamed(
        AppRoutes.serviceTracking,
        arguments: {
          'title': 'Mobile Mechanic: $_selectedIssue',
          'vehicle': 'Customer Vehicle',
          'address': _addressCtrl.text,
          'pricePaisa': 120000, // Rs 1,200 initial inspection quote
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Mobile Mechanic', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notice Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color.fromRGBO(45, 49, 66, 0.08)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.handyman_outlined, color: AppColors.primaryContainer, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nearby verified partner workshops dispatch on-duty mechanics for minor roadside or doorstep repairs.',
                        style: AppTypography.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Issue Category Selector
              Text(
                '1. Select Primary Issue',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ..._commonIssues.map((issue) {
                final isSelected = issue == _selectedIssue;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CarfixziCard(
                    color: isSelected ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryContainer : const Color.fromRGBO(45, 49, 66, 0.1),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    onTap: () => setState(() => _selectedIssue = issue),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 18,
                          color: isSelected ? AppColors.primaryContainer : AppColors.outline,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            issue,
                            style: AppTypography.labelMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),

              // Breakdown Location
              CarfixziTextField(
                label: 'Breakdown / Vehicle Location (Sahiwal)',
                hint: 'Street, Landmark, or Area',
                controller: _addressCtrl,
                prefixIcon: const Icon(Icons.pin_drop_outlined, color: AppColors.outline),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primaryContainer,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  ),
                  icon: const Icon(Icons.map_rounded, size: 16),
                  label: const Text('Pick Exact Pin on OpenStreetMap'),
                  onPressed: () async {
                    final result = await OsmLocationPicker.show(
                      context,
                      title: 'Pick Roadside Breakdown Location',
                    );
                    if (result != null) {
                      setState(() => _addressCtrl.text = result.address);
                    }
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Problem Description
              CarfixziTextField(
                label: 'Symptoms Description (Optional)',
                hint: 'Describe sounds, warnings or specific behavior...',
                controller: _descriptionCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 14),

              // Symptom Photo Upload
              CarfixziCard(
                child: Row(
                  children: [
                    const Icon(Icons.camera_alt_outlined, size: 24, color: AppColors.primaryContainer),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Symptom Photo', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                          Text(
                            _hasAttachedPhoto ? 'Attached: symptom_photo_01.jpg' : 'Attach picture of dashboard warning or engine bay',
                            style: AppTypography.bodySmall.copyWith(
                              color: _hasAttachedPhoto ? AppColors.success : AppColors.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _hasAttachedPhoto = !_hasAttachedPhoto),
                      child: Text(_hasAttachedPhoto ? 'Remove' : 'Attach'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Request Button
              CarfixziButton(
                text: 'Request Nearby Mechanic (Rs 1,200 Inspection)',
                icon: Icons.send_rounded,
                isLoading: _isSubmitting,
                onPressed: _handleSubmit,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

