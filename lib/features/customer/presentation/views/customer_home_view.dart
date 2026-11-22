import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import 'workshop_locator_view.dart';
import 'service_tracking_view.dart';
import 'parts_marketplace_view.dart';
import 'customer_profile_view.dart';

/// D09: Customer Home Dashboard
/// Persistent 5-Tab Navigation Container hosting:
/// 0: Home Dashboard
/// 1: Workshop Discovery Map
/// 2: Service Milestone Tracking
/// 3: Spare Parts Marketplace
/// 4: Customer Profile & Settings
class CustomerHomeView extends StatefulWidget {
  const CustomerHomeView({super.key});

  @override
  State<CustomerHomeView> createState() => _CustomerHomeViewState();
}

class _CustomerHomeViewState extends State<CustomerHomeView> {
  int _currentNavIndex = 0;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _isReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final user = authCtrl.user;
    final userName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Customer';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: IndexedStack(
        index: _currentNavIndex,
        children: [
          _buildDashboardTab(context, userName, authCtrl),
          const WorkshopLocatorView(),
          const ServiceTrackingView(),
          const PartsMarketplaceView(),
          const CustomerProfileView(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primaryContainer,
        unselectedItemColor: AppColors.outline,
        backgroundColor: AppColors.surface,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore_rounded), label: 'Locate'),
          BottomNavigationBarItem(icon: Icon(Icons.timelapse_rounded), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.build_circle_outlined), label: 'Parts'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context, String userName, AuthController authCtrl) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.directions_car_rounded, size: 18, color: AppColors.accentGold),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text('CARFIXZI', style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'AI Support Assistant',
            icon: const Icon(Icons.smart_toy_outlined, color: AppColors.primaryContainer),
            onPressed: () => Get.toNamed(AppRoutes.customerAiAssistant),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded, color: AppColors.outline),
            onPressed: () => authCtrl.signOut(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Greeting
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, $userName 👋',
                        style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Pilot City: Sahiwal, Pakistan',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.primaryContainer),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'C',
                      style: AppTypography.labelLarge.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 2 Large Featured Service Cards (Repair Service + Car Wash)
              Row(
                children: [
                  Expanded(
                    child: _ServiceFeatureCard(
                      title: 'Repair Service',
                      subtitle: 'Engine & Mechanical',
                      icon: Icons.car_repair_rounded,
                      color: AppColors.primaryContainer,
                      onTap: () => setState(() => _currentNavIndex = 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ServiceFeatureCard(
                      title: 'Mobile Wash',
                      subtitle: 'Car & Motorcycle Wash',
                      icon: Icons.local_car_wash_rounded,
                      color: AppColors.secondaryNavy,
                      onTap: () => Get.toNamed(AppRoutes.carWashBooking),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Mobile Mechanic & Spare Parts Cards
              Row(
                children: [
                  Expanded(
                    child: _ServiceFeatureCard(
                      title: 'Mobile Mechanic',
                      subtitle: 'Minor On-site Repairs',
                      icon: Icons.handyman_rounded,
                      color: AppColors.secondary,
                      onTap: () => Get.toNamed(AppRoutes.mobileMechanic),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ServiceFeatureCard(
                      title: 'Spare Parts',
                      subtitle: 'Buy Workshop Parts',
                      icon: Icons.shopping_bag_outlined,
                      color: AppColors.darkSlate,
                      onTap: () => setState(() => _currentNavIndex = 3),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Promotional Banner
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const StatusBadge(
                            label: 'PILOT SPECIAL',
                            variant: StatusBadgeVariant.accent,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pre-Season Full Inspection',
                            style: AppTypography.labelLarge.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Book certified multi-point diagnostics with cash on delivery',
                            style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.darkSlate,
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: () => setState(() => _currentNavIndex = 1),
                      child: Text(
                        'Book Now',
                        style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nearby Verified Workshops Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Nearby Verified Workshops',
                      style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _currentNavIndex = 1),
                    child: Text(
                      'View Map',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.primaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Horizontal Workshop Cards
              SizedBox(
                height: 195,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _WorkshopCard(
                      name: 'Apex GT Motorwerks',
                      category: 'Engine & Transmission',
                      rating: '4.9',
                      distance: '1.2 km',
                      isOpen: true,
                      onTap: () => setState(() => _currentNavIndex = 1),
                    ),
                    const SizedBox(width: 12),
                    _WorkshopCard(
                      name: 'Royal Auto Care',
                      category: 'Detailing & Tuning',
                      rating: '4.8',
                      distance: '2.4 km',
                      isOpen: true,
                      onTap: () => setState(() => _currentNavIndex = 1),
                    ),
                    const SizedBox(width: 12),
                    _WorkshopCard(
                      name: 'Speedy Wash Hub',
                      category: 'Car & Bike Wash',
                      rating: '4.7',
                      distance: '3.1 km',
                      isOpen: false,
                      onTap: () => setState(() => _currentNavIndex = 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isReady
          ? FloatingActionButton(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.darkSlate,
              onPressed: () => Get.toNamed(AppRoutes.customerAiAssistant),
              tooltip: 'AI Assistant',
              child: const Icon(Icons.chat_bubble_outline_rounded),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ServiceFeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceFeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, size: 28, color: Colors.white),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(color: Colors.white70),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkshopCard extends StatelessWidget {
  final String name;
  final String category;
  final String rating;
  final String distance;
  final bool isOpen;
  final VoidCallback onTap;

  const _WorkshopCard({
    required this.name,
    required this.category,
    required this.rating,
    required this.distance,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 210,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color.fromRGBO(45, 49, 66, 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(
                  label: isOpen ? 'OPEN NOW' : 'CLOSED',
                  variant: isOpen ? StatusBadgeVariant.accent : StatusBadgeVariant.neutral,
                ),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(rating, style: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              category,
              maxLines: 1,
              style: AppTypography.bodySmall,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.navigation_outlined, size: 14, color: AppColors.outline),
                const SizedBox(width: 4),
                Text(distance, style: AppTypography.labelSmall.copyWith(color: AppColors.outline)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
