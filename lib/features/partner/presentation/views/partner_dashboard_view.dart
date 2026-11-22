import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'partner_inventory_view.dart';
import 'partner_billing_view.dart';

/// D19/D20: Shop Owner Dashboard & Multi-Tab Hub
/// Operations hub for verified workshop partners in Pakistan pilot:
/// 0: Operations Hub (Today's Orders, Live Bay Monitoring, Cash Summary)
/// 1: Bookings Queue (Active Customer Job Requests)
/// 2: Parts Inventory (Stock Management & Add Part)
/// 3: Billing & Commission (Invoices & Settlements with Save Photo)
/// 4: Partner Staff & Profile
class PartnerDashboardView extends StatefulWidget {
  const PartnerDashboardView({super.key});

  @override
  State<PartnerDashboardView> createState() => _PartnerDashboardViewState();
}

class _PartnerDashboardViewState extends State<PartnerDashboardView> {
  int _currentNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final user = authCtrl.user;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildOperationsTab(context, user, authCtrl),
          _buildBookingsQueueTab(context),
          const PartnerInventoryView(),
          const PartnerBillingView(),
          _buildProfileTab(context, user, authCtrl),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryContainer,
        unselectedItemColor: AppColors.outline,
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 8,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment_rounded),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2_rounded),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Billing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  /// Tab 0: Main Operations Dashboard
  Widget _buildOperationsTab(BuildContext context, dynamic user, AuthController authCtrl) {
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

              // Operational Quick Action Buttons (switches tabs!)
              Row(
                children: [
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.assignment_outlined,
                      label: 'Bookings Queue',
                      badgeCount: '4',
                      onTap: () => setState(() => _currentNavIndex = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.inventory_2_outlined,
                      label: 'Parts Inventory',
                      badgeCount: '2 Low',
                      onTap: () => setState(() => _currentNavIndex = 2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ActionTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'Billing Ledger',
                      badgeCount: null,
                      onTap: () => setState(() => _currentNavIndex = 3),
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

              const _BayCard(
                bayNumber: '01',
                vehicle: 'Toyota Corolla GLi (LES-18-4921)',
                service: 'Full Brake Pad Replacement',
                assignedMechanic: 'Ustad Rashid',
                progress: 0.85,
                statusLabel: 'Final Inspection',
              ),
              const SizedBox(height: 12),
              const _BayCard(
                bayNumber: '02',
                vehicle: 'Honda Civic X (LEB-21-9901)',
                service: 'Engine Diagnostic & Tuning',
                assignedMechanic: 'Ali Raza',
                progress: 0.45,
                statusLabel: 'In Progress',
              ),
              const SizedBox(height: 12),
              const _BayCard(
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

  /// Tab 1: Bookings Queue Tab
  Widget _buildBookingsQueueTab(BuildContext context) {
    final bookings = [
      {
        'id': 'BK-2026-101',
        'customer': 'Muhammad Usman',
        'phone': '0300-1234567',
        'vehicle': 'Toyota Yaris ATIV (SL-22-3011)',
        'service': 'Full Periodic Maintenance & Oil Change',
        'time': 'Today, 2:30 PM',
        'type': 'Workshop Bay',
        'amount': 850000,
        'status': 'Accepted',
      },
      {
        'id': 'BK-2026-102',
        'customer': 'Farhan Qureshi',
        'phone': '0321-9876543',
        'vehicle': 'Suzuki Alto VXR (LES-21-5544)',
        'service': 'Doorstep Express Mobile Wash',
        'time': 'Today, 4:00 PM',
        'type': 'Doorstep Mobile',
        'amount': 80000,
        'status': 'Pending Confirmation',
      },
      {
        'id': 'BK-2026-103',
        'customer': 'Ahmad Raza',
        'phone': '0333-7654321',
        'vehicle': 'Honda City 1.5 Aspire (MN-20-4109)',
        'service': 'Brake Disc Resurfacing & Pad Replace',
        'time': 'Tomorrow, 10:00 AM',
        'type': 'Workshop Bay',
        'amount': 520000,
        'status': 'Pending Confirmation',
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Bookings Queue', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final b = bookings[index];
            final isPending = b['status'] == 'Pending Confirmation';

            return CarfixziCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          b['id'] as String,
                          style: AppTypography.labelSmall.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      StatusBadge(
                        label: b['status'] as String,
                        variant: isPending ? StatusBadgeVariant.warning : StatusBadgeVariant.success,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    b['service'] as String,
                    style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.directions_car_rounded, size: 16, color: AppColors.outline),
                      const SizedBox(width: 6),
                      Text(b['vehicle'] as String, style: AppTypography.bodySmall),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_outline_rounded, size: 16, color: AppColors.outline),
                      const SizedBox(width: 6),
                      Text('${b['customer']} · ${b['phone']}', style: AppTypography.bodySmall.copyWith(color: AppColors.outline)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16, color: AppColors.outline),
                      const SizedBox(width: 6),
                      Text(b['time'] as String, style: AppTypography.bodySmall.copyWith(color: AppColors.primaryContainer, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        CurrencyUtils.formatPaisa(b['amount'] as int),
                        style: AppTypography.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryContainer,
                        ),
                      ),
                      if (isPending)
                        Row(
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                minimumSize: const Size(0, 32),
                              ),
                              onPressed: () {
                                Get.snackbar('Job Declined', 'Booking marked as declined.',
                                    snackPosition: SnackPosition.BOTTOM);
                              },
                              child: const Text('Decline'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                minimumSize: const Size(0, 32),
                              ),
                              onPressed: () {
                                setState(() {
                                  b['status'] = 'Accepted';
                                });
                                Get.snackbar('Job Accepted', 'Customer notified of bay reservation.',
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: AppColors.successContainer,
                                    colorText: AppColors.success);
                              },
                              child: const Text('Accept Job'),
                            ),
                          ],
                        )
                      else
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryContainer,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: const Size(0, 32),
                          ),
                          icon: const Icon(Icons.build_circle_rounded, size: 14),
                          label: const Text('Assign Bay'),
                          onPressed: () {
                            Get.snackbar('Bay Assigned', 'Vehicle routed to Bay 04 for service.',
                                snackPosition: SnackPosition.BOTTOM);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Tab 4: Workshop Profile & Staff Tab
  Widget _buildProfileTab(BuildContext context, dynamic user, AuthController authCtrl) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Workshop Profile', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Partner Info Card
              CarfixziCard(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accentGold, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.storefront_rounded,
                            size: 36,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.displayName ?? 'Apex GT Motorwerks',
                      style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      'Sahiwal Bypass, Near High Court Bench',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                    ),
                    const SizedBox(height: 8),
                    const StatusBadge(label: 'VERIFIED WORKSHOP PARTNER', variant: StatusBadgeVariant.success),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Workshop Details Menu
              CarfixziCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.people_outline_rounded, color: AppColors.primaryContainer),
                      title: const Text('Staff & Technicians'),
                      subtitle: const Text('4 active mechanics assigned'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.car_repair_rounded, color: AppColors.primaryContainer),
                      title: const Text('Service Bays & Capacities'),
                      subtitle: const Text('4 Dedicated Hydraulic Lift Bays'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.smart_toy_outlined, color: AppColors.primaryContainer),
                      title: const Text('Partner AI Assistant'),
                      subtitle: const Text('Troubleshooting & repair manuals'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Get.toNamed(AppRoutes.partnerAiAssistant),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                      title: Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                      onTap: () => authCtrl.signOut(),
                    ),
                  ],
                ),
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
