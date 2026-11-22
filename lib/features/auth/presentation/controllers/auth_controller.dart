import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/contracts/auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/partner_type.dart';
import '../../../../app/routes/app_routes.dart';

/// App-wide Authentication Controller managing User Session, Role Navigation & Verification Gate
class AuthController extends GetxController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  final Rx<AuthUser?> _currentUser = Rx<AuthUser?>(null);
  AuthUser? get user => _currentUser.value;
  bool get isAuthenticated => _currentUser.value != null;
  bool get isEmailVerified => _currentUser.value?.emailVerified ?? false;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Email resend cooldown
  final RxInt resendCooldownSeconds = 0.obs;
  Timer? _cooldownTimer;

  StreamSubscription<AuthUser?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _authSubscription = _authRepository.authStateChanges.listen((user) {
      _currentUser.value = user;
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _cooldownTimer?.cancel();
    super.onClose();
  }

  /// Sign In with Email & Password
  Future<void> signIn(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authRepository.signInWithEmailPassword(
        email: email,
        password: password,
      );
      _currentUser.value = user;
      _navigateBasedOnRoleAndVerification(user);
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Login Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign Up with Email, Password & Role
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required UserRole role,
    PartnerType? partnerType,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final user = await _authRepository.signUpWithEmailPassword(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
        partnerType: partnerType,
      );
      _currentUser.value = user;

      // Navigate to Email Verification Screen immediately
      Get.offAllNamed(AppRoutes.verifyEmail);
      _startResendCooldown();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Registration Failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Check Verification Status (Called when user taps "I verified my email")
  Future<void> checkEmailVerification() async {
    isLoading.value = true;
    try {
      final refreshed = await _authRepository.reloadUserAndCheckVerification();
      if (refreshed != null) {
        _currentUser.value = refreshed;
        if (refreshed.emailVerified) {
          Get.snackbar(
            'Email Verified',
            'Welcome to CARFIXZI!',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100,
            colorText: Colors.green.shade900,
            margin: const EdgeInsets.all(16),
          );
          _navigateBasedOnRoleAndVerification(refreshed);
        } else {
          Get.snackbar(
            'Not Yet Verified',
            'Please click the link sent to ${refreshed.email} before continuing.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.amber.shade100,
            colorText: Colors.amber.shade900,
            margin: const EdgeInsets.all(16),
          );
        }
      }
    } catch (e) {
      Get.snackbar('Verification Check Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Resend Email Verification Link
  Future<void> resendVerificationEmail() async {
    if (resendCooldownSeconds.value > 0) return;

    try {
      await _authRepository.sendEmailVerification();
      _startResendCooldown();
      Get.snackbar(
        'Link Sent',
        'A fresh verification link was sent to your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue.shade100,
        colorText: Colors.blue.shade900,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar('Resend Failed', e.toString());
    }
  }

  void _startResendCooldown([int seconds = 60]) {
    resendCooldownSeconds.value = seconds;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendCooldownSeconds.value > 0) {
        resendCooldownSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  /// Send Password Reset Email
  Future<void> sendPasswordReset(String email) async {
    isLoading.value = true;
    try {
      await _authRepository.sendPasswordResetEmail(email);
      Get.snackbar(
        'Password Reset Email Sent',
        'Check your inbox for instructions to reset your password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        margin: const EdgeInsets.all(16),
      );
      Get.offNamed(AppRoutes.login);
    } catch (e) {
      Get.snackbar('Reset Failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    await _authRepository.signOut();
    _currentUser.value = null;
    Get.offAllNamed(AppRoutes.login);
  }

  /// Authoritative Role & Email-Verification Navigation Decision
  void _navigateBasedOnRoleAndVerification(AuthUser user) {
    if (!user.emailVerified) {
      Get.offAllNamed(AppRoutes.verifyEmail);
      return;
    }

    // Use WidgetsBinding to ensure navigation happens after the current
    // frame completes, avoiding layout race conditions with Scaffold/FAB.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      switch (user.role) {
        case UserRole.customer:
          Get.offAllNamed(AppRoutes.customerHome);
          break;
        case UserRole.workshop:
          if (user.partnerStatus?.name == 'approved') {
            Get.offAllNamed(AppRoutes.partnerDashboard);
          } else {
            Get.offAllNamed(AppRoutes.partnerReviewStatus);
          }
          break;
        case UserRole.admin:
          Get.offAllNamed(AppRoutes.adminDashboard);
          break;
        case UserRole.super_admin:
          Get.offAllNamed(AppRoutes.superAdminDashboard);
          break;
      }
    });
  }
}

