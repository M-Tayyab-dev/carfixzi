import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';

/// D14: Service Milestone Progress Tracking
/// Honest milestone timeline replacing fictional GPS tracking:
/// - Confirmed -> Assigned -> Checked In -> In Progress -> Quality Check -> Completed
/// - Mechanic details & customer quote authorization
class ServiceTrackingView extends StatefulWidget {
  const ServiceTrackingView({super.key});

  @override
  State<ServiceTrackingView> createState() => _ServiceTrackingViewState();
}

class _ServiceTrackingViewState extends State<ServiceTrackingView> {
  final int _currentMilestone = 2; // 0 = Confirmed, 1 = Assigned, 2 = In Progress, 3 = Completed

  final List<Map<String, dynamic>> _milestones = [
    {
      'title': 'Booking Confirmed',
      'time': '10:15 AM',
      'description': 'Appointment verified by Apex GT Motorwerks bay scheduler',
    },
    {
      'title': 'Staff Assigned & Checked In',
      'time': '10:30 AM',
      'description': 'Assigned to Ustad Rashid (Senior Mechanical Specialist)',
    },
    {
      'title': 'Diagnostics & Repair in Progress',
      'time': '10:45 AM',
      'description': 'Vehicle currently mounted on Bay 01. Brake pads dismounted.',
    },
    {
      'title': 'Quality Assurance & Road Test',
      'time': 'Estimated 11:45 AM',
      'description': 'Hydraulic fluid pressure check & brake pad bedding test',
    },
    {
      'title': 'Completed & Ready for Handover',
      'time': 'Estimated 12:00 PM',
      'description': 'Customer inspects vehicle and settles cash payment',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Service Progress', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active Job Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const StatusBadge(
                          label: 'IN PROGRESS',
                          variant: StatusBadgeVariant.accent,
                        ),
                        Text(
                          'Job #CFX-2026-89',
                          style: AppTypography.labelSmall.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Honda Civic X (LEB-21-9901)',
                      style: AppTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Full Brake Pad Replacement & Bleed',
                      style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.surfaceContainerHigh,
                                child: Icon(Icons.person_rounded, size: 20, color: AppColors.primary),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Ustad Rashid',
                                      style: AppTypography.labelMedium.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'Lead Brake Technician',
                                      style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyUtils.formatPaisa(420000), // Rs 4,200.00
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Milestone Progress Timeline
              Text(
                'Service Milestones',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),

              ...List.generate(_milestones.length, (idx) {
                final milestone = _milestones[idx];
                final isPassed = idx < _currentMilestone;
                final isCurrent = idx == _currentMilestone;
                final isFuture = idx > _currentMilestone;

                Color dotColor = isPassed
                    ? AppColors.success
                    : (isCurrent ? AppColors.accentGold : AppColors.surfaceDim);

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrent ? AppColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isPassed
                                ? const Icon(Icons.check, size: 14, color: Colors.white)
                                : (isCurrent
                                    ? Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      )
                                    : null),
                          ),
                        ),
                        if (idx < _milestones.length - 1)
                          Container(
                            width: 2,
                            height: 52,
                            color: isPassed ? AppColors.success : AppColors.surfaceDim,
                          ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    milestone['title'] as String,
                                    style: AppTypography.labelLarge.copyWith(
                                      fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                                      color: isFuture ? AppColors.outline : AppColors.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  milestone['time'] as String,
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isCurrent ? AppColors.primaryContainer : AppColors.outline,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              milestone['description'] as String,
                              style: AppTypography.bodySmall.copyWith(
                                color: isFuture ? AppColors.outline : AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 12),

              // Handover & Cash Settlement Button
              CarfixziButton(
                text: 'Proceed to Payment & Receipt',
                icon: Icons.receipt_long_rounded,
                onPressed: () {
                  Get.toNamed(
                    AppRoutes.paymentCheckout,
                    arguments: {
                      'title': 'Brake Pad Replacement & Bleed',
                      'vehicle': 'Honda Civic X',
                      'pricePaisa': 420000,
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
