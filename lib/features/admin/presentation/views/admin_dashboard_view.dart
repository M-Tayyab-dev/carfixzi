import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// D23: Admin Manager Dashboard (Responsive Web / Desktop)
/// Operational oversight for platform administrators:
/// - Workshop Onboarding Verification Queue (protected CNIC & Tax reviews)
/// - Service & Price Proposal Moderation
/// - Dynamic Workshop Form Builder (Create/Edit/Reorder/Required Toggle)
/// - Audit Trail
class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'ADMIN PORTAL',
                style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 12),
            Text('Regional Operations · Sahiwal', style: AppTypography.headlineSmall),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Admin AI Copilot',
            icon: const Icon(Icons.smart_toy_outlined, color: AppColors.primaryContainer),
            onPressed: () => Get.toNamed(AppRoutes.adminAiAssistant),
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pulse Bento Grid
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'PENDING WORKSHOP AUDITS',
                      value: '03',
                      subtitle: 'CNIC & Tax docs uploaded',
                      color: AppColors.error,
                      icon: Icons.assignment_late_outlined,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: 'PRICE REVISION PROPOSALS',
                      value: '05',
                      subtitle: 'Awaiting moderation',
                      color: AppColors.warning,
                      icon: Icons.price_change_outlined,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _MetricCard(
                      title: 'ACTIVE APPROVED PARTNERS',
                      value: '18',
                      subtitle: 'Live in pilot city',
                      color: AppColors.success,
                      icon: Icons.verified_outlined,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Form Builder Navigation Banner (Mandatory Section 4.2A)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.primaryContainer.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.dynamic_form_rounded, size: 36, color: AppColors.primaryContainer),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Workshop Registration Form Builder',
                            style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            'Add custom onboarding questions, toggle Required/Optional on configurable fields, and publish new schema versions.',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryContainer,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.edit_note_rounded, size: 20),
                      label: const Text('Open Form Builder'),
                      onPressed: () => Get.toNamed(AppRoutes.adminFormBuilder),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Pending Verification Queue Section
              Text(
                'Partner Onboarding Queue (Protected Review)',
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),

              _VerificationRow(
                businessName: 'Pak Punjab Auto Works',
                ownerName: 'Muhammad Asif',
                submittedAt: 'Today, 10:45 AM',
                partnerType: 'Physical Workshop',
                status: 'pending_review',
                onReview: () {
                  Get.defaultDialog(
                    title: 'Protected Review',
                    middleText:
                        'Accessing protected Cloudinary assets: Business photo, CNIC Front/Back, and Current Tax Return.',
                    textConfirm: 'Approve Workshop',
                    textCancel: 'Request Changes',
                    confirmTextColor: AppColors.darkSlate,
                    buttonColor: AppColors.accentGold,
                    onConfirm: () => Get.back(),
                  );
                },
              ),
              const SizedBox(height: 10),
              _VerificationRow(
                businessName: 'Express Doorstep Bike Wash',
                ownerName: 'Hamza Tariq',
                submittedAt: 'Yesterday, 04:12 PM',
                partnerType: 'Mobile Detailing Partner',
                status: 'pending_review',
                onReview: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: AppTypography.labelSmall.copyWith(color: AppColors.outline, letterSpacing: 0.8),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.displayLarge.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.bodySmall),
        ],
      ),
    );
  }
}

class _VerificationRow extends StatelessWidget {
  final String businessName;
  final String ownerName;
  final String submittedAt;
  final String partnerType;
  final String status;
  final VoidCallback onReview;

  const _VerificationRow({
    required this.businessName,
    required this.ownerName,
    required this.submittedAt,
    required this.partnerType,
    required this.status,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.primaryContainer),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(businessName, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
                Text('$ownerName · $partnerType', style: AppTypography.bodySmall),
                Text('Submitted: $submittedAt', style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
              ],
            ),
          ),
          const StatusBadge(
            label: 'PENDING AUDIT',
            variant: StatusBadgeVariant.warning,
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.darkSlate,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            ),
            onPressed: onReview,
            child: Text('Inspect & Decide', style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
