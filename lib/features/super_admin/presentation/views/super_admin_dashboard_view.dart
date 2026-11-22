import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// D24: Super Admin Dashboard (Web / Desktop Root Portal)
/// Highest level platform control:
/// - Platform GMV & Ledger Aggregation (PKR Paisa)
/// - Commission Policies Configuration
/// - Manual Partner Settlement Processing (Audited Balance Reduction)
/// - Admin Account Management & Revocation
/// - Exclusive Form Field Retirement / Restoration
class SuperAdminDashboardView extends StatelessWidget {
  const SuperAdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(Icons.shield, size: 18, color: AppColors.accentGold),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'SUPER ADMIN',
                style: AppTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Admin Panel',
                style: AppTypography.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Platform AI Assistant',
            icon: const Icon(Icons.smart_toy_outlined, color: AppColors.primaryContainer),
            onPressed: () => Get.toNamed(AppRoutes.superAdminAiAssistant),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 650;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top GMV & Platform Net Revenue Banner (Adaptive)
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkSlate,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: isMobile
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'GROSS MERCHANDISE VALUE (PILOT RUN)',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyUtils.formatPaisa(48295000), // Rs 482,950.00
                                style: AppTypography.headlineMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white24),
                              const SizedBox(height: 12),
                              Text(
                                'PLATFORM COMMISSION RECEIVABLES',
                                style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white70,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyUtils.formatPaisa(4829500), // Rs 48,295.00
                                style: AppTypography.headlineMedium.copyWith(
                                  color: AppColors.accentGold,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'GROSS MERCHANDISE VALUE (PILOT RUN)',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: Colors.white70,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      CurrencyUtils.formatPaisa(48295000), // Rs 482,950.00
                                      style: AppTypography.displayLarge.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Verified Cash-on-Service Transactions',
                                      style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 1,
                                height: 70,
                                color: Colors.white24,
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PLATFORM COMMISSION RECEIVABLES',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: Colors.white70,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      CurrencyUtils.formatPaisa(4829500), // Rs 48,295.00
                                      style: AppTypography.displayLarge.copyWith(
                                        color: AppColors.accentGold,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Pending Settlement Against Partner Ledgers',
                                      style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Super Admin Exclusive Controls Grid (Adaptive)
                  Text(
                    'Governance & Admin Privileges',
                    style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),

                  if (isMobile) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _GovernanceTile(
                            icon: Icons.percent_rounded,
                            title: 'Commission Policy',
                            subtitle: '10% Services · 5% Parts',
                            ctaText: 'Rates',
                            onTap: () => Get.toNamed(AppRoutes.superAdminCommission),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GovernanceTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Settlement Ledger',
                            subtitle: 'Record partner payouts',
                            ctaText: 'Settlements',
                            onTap: () => Get.toNamed(AppRoutes.superAdminSettlements),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _GovernanceTile(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Admin Staff',
                            subtitle: 'Provision manager access',
                            ctaText: 'Staff',
                            onTap: () => Get.toNamed(AppRoutes.superAdminAdmins),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _GovernanceTile(
                            icon: Icons.delete_sweep_outlined,
                            title: 'Field Retirement',
                            subtitle: 'Retire/restore fields',
                            ctaText: 'Governance',
                            onTap: () => Get.toNamed(AppRoutes.superAdminFormGovernance),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Row(
                      children: [
                        Expanded(
                          child: _GovernanceTile(
                            icon: Icons.percent_rounded,
                            title: 'Commission Policy',
                            subtitle: '10.00% Services · 5.00% Parts',
                            ctaText: 'Adjust Rates',
                            onTap: () => Get.toNamed(AppRoutes.superAdminCommission),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _GovernanceTile(
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Manual Settlement Ledger',
                            subtitle: 'Record partner cash payouts',
                            ctaText: 'Post Settlement',
                            onTap: () => Get.toNamed(AppRoutes.superAdminSettlements),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _GovernanceTile(
                            icon: Icons.admin_panel_settings_outlined,
                            title: 'Admin Provisioning',
                            subtitle: 'Grant or revoke Admin access',
                            ctaText: 'Manage Staff',
                            onTap: () => Get.toNamed(AppRoutes.superAdminAdmins),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _GovernanceTile(
                            icon: Icons.delete_sweep_outlined,
                            title: 'Form Field Retirement',
                            subtitle: 'Super Admin exclusive field retire/restore',
                            ctaText: 'Field Governance',
                            onTap: () => Get.toNamed(AppRoutes.superAdminFormGovernance),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GovernanceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String ctaText;
  final VoidCallback onTap;

  const _GovernanceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.ctaText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: AppColors.primaryContainer),
          const SizedBox(height: 12),
          Text(title, style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTypography.bodySmall, maxLines: 2),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  ctaText,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.primaryContainer),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
