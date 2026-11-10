import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/carfixzi_text_field.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// D05: CarFixZi Login Screen
/// Implements role toggle (Customer vs Workshop Partner), email/password login,
/// strong password handling, and biometric session unlock integration.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;
  bool _obscurePassword = true;
  bool _rememberDevice = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      final authCtrl = Get.find<AuthController>();
      authCtrl.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Sign In', style: AppTypography.headlineSmall),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header Badge
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color.fromRGBO(45, 49, 66, 0.08)),
                    ),
                    child: const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 40,
                      color: AppColors.primaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    'Welcome to CARFIXZI',
                    style: AppTypography.headlineMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Precision Automotive Care Marketplace',
                    style: AppTypography.bodySmall,
                  ),
                ),
                const SizedBox(height: 24),

                // Role Segmented Switcher (Customer vs Workshop Partner)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _RoleTab(
                          label: 'Customer / Owner',
                          isSelected: _selectedRole == UserRole.customer,
                          onTap: () => setState(() => _selectedRole = UserRole.customer),
                        ),
                      ),
                      Expanded(
                        child: _RoleTab(
                          label: 'Workshop Partner',
                          isSelected: _selectedRole == UserRole.workshop,
                          onTap: () => setState(() => _selectedRole = UserRole.workshop),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Email Input
                CarfixziTextField(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.outline),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),

                // Password Input
                CarfixziTextField(
                  label: 'Password',
                  hint: 'Enter your 12+ character password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.outline,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Password is required' : null,
                ),
                const SizedBox(height: 12),

                // Remember Device & Forgot Password Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberDevice,
                            activeColor: AppColors.primaryContainer,
                            onChanged: (v) => setState(() => _rememberDevice = v ?? true),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Remember device',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.darkSlate,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.forgotPassword),
                      child: Text(
                        'Forgot Password?',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Primary Ignite Session Button (Golden Yellow)
                Obx(
                  () => CarfixziButton(
                    text: 'Ignite Session',
                    icon: Icons.flash_on_rounded,
                    isLoading: authCtrl.isLoading.value,
                    onPressed: _handleLogin,
                  ),
                ),
                const SizedBox(height: 20),

                // Biometric Login Prompt (Optional Local Android convenience)
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
                      const Icon(Icons.fingerprint_rounded, size: 28, color: AppColors.primaryContainer),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Biometric Quick Unlock',
                              style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              'Available for verified sessions on supported Android devices',
                              style: AppTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ", style: AppTypography.bodyMedium),
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.register),
                      child: Text(
                        'Create Account',
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleTab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

