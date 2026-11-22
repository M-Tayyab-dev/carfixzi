import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// D01: Splash Screen (Classic Badge Edition)
/// Clean automotive branding with logo badge, glowing ambient ring, and real auth initialization
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _progressAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _progressAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.forward().then((_) => _onAnimationComplete());
  }

  void _onAnimationComplete() {
    // Defer navigation to the next frame so the outgoing Scaffold is fully
    // disposed before the incoming page builds, preventing hit-test /
    // layout errors on widgets that haven't been laid out yet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (Get.isRegistered<AuthController>()) {
        final auth = Get.find<AuthController>();
        if (auth.isAuthenticated) {
          if (!auth.isEmailVerified) {
            Get.offAllNamed(AppRoutes.verifyEmail);
          } else {
            // Route based on role
            final role = auth.user?.role;
            if (role == null || role.isCustomer) {
              Get.offAllNamed(AppRoutes.customerHome);
            } else if (role.isWorkshop) {
              Get.offAllNamed(AppRoutes.partnerDashboard);
            } else if (role.isAdmin) {
              Get.offAllNamed(AppRoutes.adminDashboard);
            } else if (role.isSuperAdmin) {
              Get.offAllNamed(AppRoutes.superAdminDashboard);
            }
          }
          return;
        }
      }
      // Default: Show Onboarding
      Get.offAllNamed(AppRoutes.onboarding);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Ambient Glow at top
          Positioned(
            top: -100,
            left: 0,
            right: 0,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryContainer.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Center Branding Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Badge with Golden Ring
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accentGold, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 104,
                      height: 104,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(
                          Icons.directions_car_rounded,
                          size: 56,
                          color: AppColors.accentGold,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Brand Title
                Text(
                  'CARFIXZI',
                  style: AppTypography.displayLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 3.0,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  'Precision Car Care & Auto Services',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 60),

                // Animated Progress Bar with Golden Indicator
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    children: [
                      AnimatedBuilder(
                        animation: _progressAnim,
                        builder: (context, child) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: LinearProgressIndicator(
                              value: _progressAnim.value,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.accentGold,
                              ),
                              minHeight: 5,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'INITIALIZING SERVICES...',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.outline,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Version Footer
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'v1.0.0 · Verified Marketplace',
                style: AppTypography.labelSmall.copyWith(color: AppColors.outline),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
