import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';
import '../../domain/entities/service_item.dart';

/// D11: Service Booking & Slot Scheduling Screen
/// Implements slot selection, vehicle type filter, PKR transparent pricing,
/// and auto vs manual confirmation workflow.
class ServiceBookingView extends StatefulWidget {
  const ServiceBookingView({super.key});

  @override
  State<ServiceBookingView> createState() => _ServiceBookingViewState();
}

class _ServiceBookingViewState extends State<ServiceBookingView> {
  final List<ServiceItem> _services = ServiceItem.pilotServices;
  late ServiceItem _selectedService;
  String _selectedVehicleType = 'Sedan / Hatchback';
  final DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = '10:30 AM';
  bool _isSubmitting = false;

  final List<String> _slots = [
    '09:00 AM',
    '10:30 AM',
    '01:00 PM',
    '03:30 PM',
    '05:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _selectedService = _services.first;
  }

  void _handleConfirmBooking() {
    setState(() => _isSubmitting = true);

    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() => _isSubmitting = false);
      Get.toNamed(
        AppRoutes.paymentCheckout,
        arguments: {
          'service': _selectedService,
          'vehicle': _selectedVehicleType,
          'slot': _selectedSlot,
          'date': _selectedDate,
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Book Service', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Workshop Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color.fromRGBO(45, 49, 66, 0.08)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.build_circle_rounded, color: AppColors.accentGold, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Apex GT Motorwerks',
                            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'High Street Commercial Zone, Sahiwal · Tier-1 Partner',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. Service Selection Grid
              Text(
                '1. Select Automotive Service',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._services.map((srv) {
                final isSelected = srv.id == _selectedService.id;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: CarfixziCard(
                    color: isSelected ? AppColors.surfaceContainerLowest : AppColors.surfaceContainerLow,
                    border: Border.all(
                      color: isSelected ? AppColors.primaryContainer : const Color.fromRGBO(45, 49, 66, 0.1),
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    onTap: () => setState(() => _selectedService = srv),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: srv.id,
                          groupValue: _selectedService.id,
                          activeColor: AppColors.primaryContainer,
                          onChanged: (_) => setState(() => _selectedService = srv),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      srv.title,
                                      style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (srv.isAutoConfirm)
                                    const StatusBadge(
                                      label: 'INSTANT SLOT',
                                      variant: StatusBadgeVariant.success,
                                    )
                                  else
                                    const StatusBadge(
                                      label: 'APPROVAL REQ.',
                                      variant: StatusBadgeVariant.warning,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(srv.description, style: AppTypography.bodySmall),
                              const SizedBox(height: 6),
                              Text(
                                '${CurrencyUtils.formatPaisa(srv.pricePaisa)} · Est. ${srv.estimatedDurationMinutes} mins',
                                style: AppTypography.labelMedium.copyWith(
                                  color: AppColors.primaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),

              // 2. Vehicle Selection
              Text(
                '2. Choose Vehicle Type',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _VehicleChip(
                      label: 'Car / SUV',
                      icon: Icons.directions_car_rounded,
                      isSelected: _selectedVehicleType.contains('Car') || _selectedVehicleType.contains('Sedan'),
                      onTap: () => setState(() => _selectedVehicleType = 'Sedan / Hatchback'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VehicleChip(
                      label: 'Motorcycle',
                      icon: Icons.two_wheeler_rounded,
                      isSelected: _selectedVehicleType.contains('Motorcycle'),
                      onTap: () => setState(() => _selectedVehicleType = 'Motorcycle (70cc-150cc)'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Time Slot Grid
              Text(
                '3. Available Service Slots (Sahiwal Bay)',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _slots.map((slot) {
                  final isSelected = slot == _selectedSlot;
                  return ChoiceChip(
                    label: Text(slot),
                    selected: isSelected,
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color: isSelected ? Colors.white : AppColors.onSurface,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (_) => setState(() => _selectedSlot = slot),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Order Summary Card
              CarfixziCard(
                color: AppColors.surfaceContainerLow,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Service Price:', style: AppTypography.bodyMedium),
                        Text(
                          CurrencyUtils.formatPaisa(_selectedService.pricePaisa),
                          style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Payment Mode:', style: AppTypography.bodySmall),
                        Text('Cash on Delivery / Service', style: AppTypography.bodySmall.copyWith(color: AppColors.success)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Estimated Duration:', style: AppTypography.bodySmall),
                        Text('${_selectedService.estimatedDurationMinutes} minutes', style: AppTypography.bodySmall),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Continue to Checkout CTA
              CarfixziButton(
                text: 'Proceed to Payment & Review',
                icon: Icons.arrow_forward_rounded,
                isLoading: _isSubmitting,
                onPressed: _handleConfirmBooking,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : const Color.fromRGBO(45, 49, 66, 0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? Colors.white : AppColors.darkSlate),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.darkSlate,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
