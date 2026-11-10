import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../controllers/auth_controller.dart';

/// D07 (Repurposed): Email Link Verification Screen
/// Complies with Section 4.1A: Zero-SMS cost, link-based Firebase email confirmation,
/// resend throttle/cooldown, reload/refresh token, and pending account state.
class VerifyEmailView extends StatelessWidget {
  const VerifyEmailView({super.key});

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();
    final userEmail = authCtrl.user?.email ?? 'your email';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Verify Email', style: AppTypography.headlineSmall),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => authCtrl.signOut(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Mail Verification Icon Badge
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryContainer.withOpacity(0.15),
                    width: 2,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.mark_email_unread_rounded,
                    size: 56,
                    color: AppColors.primaryContainer,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                'Verification Link Sent',
                textAlign: TextAlign.center,
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle with user email
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.onSurfaceVariant),
                  children: [
                    const TextSpan(text: 'We have dispatched a secure verification link to:\n'),
                    TextSpan(
                      text: userEmail,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '\n\nPlease open your email inbox, click the verification link, and then tap the button below.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // "I Verified My Email" Primary CTA (Golden Yellow)
              Obx(
                () => CarfixziButton(
                  text: 'I Verified My Email',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: authCtrl.isLoading.value,
                  onPressed: () => authCtrl.checkEmailVerification(),
                ),
              ),
              const SizedBox(height: 16),

              // Resend with 60-Second Cooldown
              Obx(() {
                final cooldown = authCtrl.resendCooldownSeconds.value;
                if (cooldown > 0) {
                  return Text(
                    'Resend link available in ${cooldown}s',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                  );
                }
                return TextButton.icon(
                  onPressed: () => authCtrl.resendVerificationEmail(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    'Resend Verification Email',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),

              // Honest zero-cost notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromRGBO(45, 49, 66, 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, size: 20, color: AppColors.outline),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Zero-budget security policy: Email link confirmation is mandatory for all roles. Phone SMS OTP is disabled.',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.outline),
                      ),
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

