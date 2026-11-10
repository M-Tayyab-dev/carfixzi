import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_typography.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/partner_type.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/carfixzi_button.dart';
import '../../../../shared/widgets/carfixzi_text_field.dart';
import '../../../../shared/widgets/password_strength_indicator.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/auth_controller.dart';

/// D06: Customer & Workshop Registration Screen
/// Enforces Firebase 12+ char strong password policy, role selection,
/// unverified +92 contact phone labeling, and links to email verification.
class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  UserRole _selectedRole = UserRole.customer;
  PartnerType _partnerType = PartnerType.workshop;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  String _currentPassword = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_agreedToTerms) {
      Get.snackbar(
        'Terms Required',
        'Please accept the Terms of Service and Privacy Policy to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade100,
        colorText: Colors.amber.shade900,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        Get.snackbar(
          'Passwords Mismatch',
          'The passwords you entered do not match.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      final authCtrl = Get.find<AuthController>();
      authCtrl.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim().isNotEmpty ? _phoneController.text.trim() : null,
        role: _selectedRole,
        partnerType: _selectedRole.isWorkshop ? _partnerType : null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authCtrl = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text('Create Account', style: AppTypography.headlineSmall),
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
                // Step Indicator Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        'Step 1 of 2 · Account Profile',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Free Account',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.outline),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Role Switcher (Customer vs Workshop Partner)
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
                          label: 'Car Owner / Customer',
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
                const SizedBox(height: 20),

                // Partner Type Selection (Shown only when Workshop Partner is selected)
                if (_selectedRole == UserRole.workshop) ...[
                  Text(
                    'Partner Operation Type',
                    style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<PartnerType>(
                    value: _partnerType,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: PartnerType.workshop,
                        child: Text('Physical Automotive Workshop'),
                      ),
                      DropdownMenuItem(
                        value: PartnerType.mobile_wash,
                        child: Text('Mobile Detailing & Bike/Car Wash'),
                      ),
                      DropdownMenuItem(
                        value: PartnerType.both,
                        child: Text('Full Workshop & Mobile Wash Fleet'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _partnerType = val);
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Full Name
                CarfixziTextField(
                  label: _selectedRole == UserRole.workshop ? 'Business Owner Name' : 'Full Name',
                  hint: 'e.g. Tariq Mehmood',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.outline),
                  validator: (v) => Validators.validateRequired(v, 'Name'),
                ),
                const SizedBox(height: 16),

                // Email Address
                CarfixziTextField(
                  label: 'Email Address',
                  hint: 'name@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined, color: AppColors.outline),
                  validator: Validators.validateEmail,
                  helperText: 'A mandatory verification link will be sent to this email.',
                ),
                const SizedBox(height: 16),

                // Contact Phone Number (Pakistan +92)
                CarfixziTextField(
                  label: 'Mobile Contact Number (Optional)',
                  hint: '+92 300 1234567',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.outline),
                  validator: (v) => Validators.validatePakistaniPhone(v, isOptional: true),
                  helperText: 'Contact information only (Unverified — zero SMS costs).',
                ),
                const SizedBox(height: 16),

                // Password Input with Real-time 4-Bar Strength Meter
                CarfixziTextField(
                  label: 'Strong Password',
                  hint: 'At least 12 characters',
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
                  onChanged: (val) => setState(() => _currentPassword = val),
                  validator: Validators.validatePassword,
                ),
                PasswordStrengthIndicator(password: _currentPassword),
                const SizedBox(height: 16),

                // Confirm Password
                CarfixziTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefixIcon: const Icon(Icons.lock_reset_rounded, color: AppColors.outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: AppColors.outline,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Please confirm your password' : null,
                ),
                const SizedBox(height: 16),

                // Terms of Service Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreedToTerms,
                        activeColor: AppColors.primaryContainer,
                        onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'I agree to the CARFIXZI Terms of Service and Privacy Policy',
                        style: AppTypography.bodySmall.copyWith(color: AppColors.darkSlate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit CTA Button
                Obx(
                  () => CarfixziButton(
                    text: 'Create Account & Continue',
                    icon: Icons.arrow_forward_rounded,
                    isLoading: authCtrl.isLoading.value,
                    onPressed: _handleRegister,
                  ),
                ),
                const SizedBox(height: 24),

                // Back to Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already registered? ', style: AppTypography.bodyMedium),
                    GestureDetector(
                      onTap: () => Get.offNamed(AppRoutes.login),
                      child: Text(
                        'Sign In',
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
            textAlign: TextAlign.center,
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
