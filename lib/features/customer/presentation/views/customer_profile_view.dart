import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/carfixzi_card.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/status_badge.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/security/biometric_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

/// D17: Customer Profile & Account Management
class CustomerProfileView extends StatefulWidget {
  const CustomerProfileView({super.key});

  @override
  State<CustomerProfileView> createState() => _CustomerProfileViewState();
}

class _CustomerProfileViewState extends State<CustomerProfileView> {
  final BiometricService _biometricService = BiometricService();
  bool _biometricsAvailable = false;
  bool _biometricsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricEnabled();
    if (mounted) {
      setState(() {
        _biometricsAvailable = available;
        _biometricsEnabled = enabled;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    await _biometricService.setBiometricEnabled(value);
    setState(() => _biometricsEnabled = value);
    Get.snackbar(
      'Biometric Unlock',
      value ? 'Biometric authentication enabled.' : 'Biometric authentication disabled.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final user = authCtrl.user;
    final displayName = user?.displayName.isNotEmpty == true ? user!.displayName : 'Customer';
    final email = user?.email ?? 'customer@carfixzi.pk';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Account Profile', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // User Hero Banner
            CarfixziCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.primaryContainer,
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'C',
                      style: AppTypography.headlineMedium.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          email,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                        ),
                        const SizedBox(height: 6),
                        const StatusBadge(
                          label: 'VERIFIED EMAIL',
                          variant: StatusBadgeVariant.success,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quick Nav List
            Text(
              'My Account',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            _ProfileMenuItem(
              icon: Icons.directions_car_rounded,
              title: 'My Vehicles',
              subtitle: 'Manage your registered cars & motorcycles',
              onTap: () => Get.toNamed(AppRoutes.vehicleRegistration),
            ),
            const SizedBox(height: 8),

            _ProfileMenuItem(
              icon: Icons.receipt_long_rounded,
              title: 'Service History & Receipts',
              subtitle: 'View completed bookings & digital receipts',
              onTap: () => Get.toNamed(AppRoutes.serviceHistory),
            ),
            const SizedBox(height: 8),

            _ProfileMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Spare Parts Orders',
              subtitle: 'Track parts orders & fulfillment',
              onTap: () => Get.toNamed(AppRoutes.cart),
            ),
            const SizedBox(height: 20),

            // Security & Preferences
            Text(
              'Security & Biometrics',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            CarfixziCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.fingerprint_rounded, size: 28, color: AppColors.primaryContainer),
                title: Text(
                  'Biometric Unlock',
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  _biometricsAvailable
                      ? 'Use Fingerprint or Face ID for fast re-authentication'
                      : 'Biometric hardware not available on this device',
                  style: AppTypography.bodySmall,
                ),
                value: _biometricsEnabled,
                activeColor: AppColors.primaryContainer,
                onChanged: _biometricsAvailable ? _toggleBiometrics : null,
              ),
            ),
            const SizedBox(height: 8),

            _ProfileMenuItem(
              icon: Icons.lock_outline_rounded,
              title: 'Password & Security',
              subtitle: '12+ char strong policy enforced',
              onTap: () => Get.toNamed(AppRoutes.forgotPassword),
            ),
            const SizedBox(height: 20),

            // Support & Help
            Text(
              'Help & Information',
              style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),

            _ProfileMenuItem(
              icon: Icons.smart_toy_outlined,
              title: 'CARFIXZI AI Assistant',
              subtitle: 'Instant answers on policies, pricing & workshops',
              onTap: () => Get.toNamed(AppRoutes.customerAiAssistant),
            ),
            const SizedBox(height: 8),

            _ProfileMenuItem(
              icon: Icons.payments_outlined,
              title: 'Cash on Service Policy',
              subtitle: 'Learn how physical cash payments work',
              onTap: () {
                Get.defaultDialog(
                  title: 'Cash on Service Policy',
                  titleStyle: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                  contentPadding: const EdgeInsets.all(20),
                  content: Text(
                    'CARFIXZI operates exclusively on a transparent Cash-on-Service model for physical fulfillment in Pakistan. '
                    'Pay physical Pakistani Rupees directly to the workshop or technician upon completion of the service. '
                    'Digital receipts #REC-2026 are issued immediately upon confirmation.',
                    style: AppTypography.bodySmall,
                  ),
                  confirm: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.darkSlate,
                    ),
                    onPressed: () => Get.back(),
                    child: const Text('Understood'),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Sign Out Button
            CarfixziButton(
              text: 'Sign Out',
              icon: Icons.logout_rounded,
              variant: ButtonVariant.ghost,
              onPressed: () => authCtrl.signOut(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CarfixziCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryContainer, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.outline),
        ],
      ),
    );
  }
}
