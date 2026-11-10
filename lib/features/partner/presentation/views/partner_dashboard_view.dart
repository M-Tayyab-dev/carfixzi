import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// D19/D20: Shop Owner Dashboard
/// Operations hub for verified workshop partners in Pakistan pilot:
/// - Workshop identity banner
/// - Today's Orders & Commission Liability
/// - Live Bay Monitoring & Technician Assignment
/// - Parts Inventory Alerts
class PartnerDashboardView extends StatelessWidget {
  const PartnerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final user = authCtrl.user;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Partner Operations', style: AppTypography.headlineSmall),
            Text(
              '${user?.displayName ?? 'Apex GT Motorwerks'} · Verified Partner',
              style: AppTypography.bodySmall.copyWith(color: AppColors.success),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Partner AI Support',
            icon: const Icon(Icons.smart_toy_outlined, color: AppColors.primaryContainer),
            onPressed: () => Get.toNamed(AppRoutes.partnerAiAssistant),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authCtrl.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Operational Metrics Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TODAY'S CASH COLLECTED",
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const StatusBadge(
                          label: 'ACTIVE PILOT',
                          variant: StatusBadgeVariant.accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyUtils.formatPaisa(4850000), // Rs 48,500.00
                      style: AppTypography.displayLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Platform Commission Due (10%):',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                        ),
                        Text(
                          CurrencyUtils.formatPaisa(485000), // Rs 4,850.00
                          style: AppTypography.labelMedium.copyWith(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Operational Action Buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.assignment_outlined,
                      label: 'Bookings Queue',
                      badgeCount: '4',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.inventory_2_outlined,
                      label: 'Parts Inventory',
                      badgeCount: '2 Low',
                      onTap: () => Get.toNamed(AppRoutes.partnerInventory),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'Invoices',
                      badgeCount: null,
                      onTap: () => Get.toNamed(AppRoutes.partnerBilling),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Live Bay Monitoring Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Active Service Bays',
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '3 of 4 Bays Occupied',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _BayCard(
                bayNumber: '01',
                vehicle: 'Toyota Corolla GLi (LES-18-4921)',
                service: 'Full Brake Pad Replacement',
                assignedMechanic: 'Ustad Rashid',
                progress: 0.85,
                statusLabel: 'Final Inspection',
              ),
              const SizedBox(height: 12),
              _BayCard(
                bayNumber: '02',
                vehicle: 'Honda Civic X (LEB-21-9901)',
                service: 'Engine Diagnostic & Tuning',
                assignedMechanic: 'Ali Raza',
                progress: 0.45,
                statusLabel: 'In Progress',
              ),
              const SizedBox(height: 12),
              _BayCard(
                bayNumber: '03',
                vehicle: 'Honda CG 125 Motorcycle',
                service: 'Doorstep Mobile Wash Queue',
                assignedMechanic: 'Kashif Mobile Team',
                progress: 0.15,
                statusLabel: 'En Route',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? badgeCount;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    this.badgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 28, color: AppColors.primaryContainer),
              if (badgeCount != null)
                Positioned(
                  top: -4,
                  right: -8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badgeCount!,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkSlate,
            ),
          ),
        ],
      ),
    );
  }
}

class _BayCard extends StatelessWidget {
  final String bayNumber;
  final String vehicle;
  final String service;
  final String assignedMechanic;
  final double progress;
  final String statusLabel;

  const _BayCard({
    required this.bayNumber,
    required this.vehicle,
    required this.service,
    required this.assignedMechanic,
    required this.progress,
    required this.statusLabel,
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'BAY $bayNumber',
                      style: AppTypography.labelSmall.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    assignedMechanic,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                  ),
                ],
              ),
              StatusBadge(
                label: statusLabel,
                variant: progress >= 0.8 ? StatusBadgeVariant.success : StatusBadgeVariant.info,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            vehicle,
            style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(service, style: AppTypography.bodySmall),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 0.8 ? AppColors.success : AppColors.primaryContainer,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
