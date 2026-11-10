import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/carfixzi_text_field.dart';
import '../controllers/auth_controller.dart';

/// Password Reset View using Firebase Email-based link reset
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final authCtrl = Get.find<AuthController>();
      authCtrl.sendPasswordReset(_emailController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Reset Password', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recover Your Account',
                  style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your registered email address and we will dispatch a secure Firebase password reset link.',
                  style: AppTypography.bodyMedium,
                ),
                const SizedBox(height: 28),
                CarfixziTextField(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.outline),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 28),
                Obx(
                  () => CarfixziButton(
                    text: 'Send Reset Link',
                    icon: Icons.send_rounded,
                    isLoading: authCtrl.isLoading.value,
                    onPressed: _handleSubmit,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

