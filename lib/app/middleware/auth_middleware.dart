import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../core/enums/user_role.dart';

/// GetX Route Guard enforcing:
/// 1. Firebase Authentication
/// 2. Mandatory email_verified == true check
/// 3. Role boundary protection (Customer / Partner / Admin / Super Admin)
class AuthMiddleware extends GetMiddleware {
  final List<UserRole>? allowedRoles;

  AuthMiddleware({this.allowedRoles, super.priority});

  @override
  RouteSettings? redirect(String? route) {
    // If controller is not yet registered (during splash), allow navigation
    if (!Get.isRegistered<AuthController>()) return null;

    final authCtrl = Get.find<AuthController>();
    final user = authCtrl.user;

    // 1. Not signed in -> redirect to Login
    if (user == null) {
      if (route == AppRoutes.login ||
          route == AppRoutes.register ||
          route == AppRoutes.splash ||
          route == AppRoutes.onboarding ||
          route == AppRoutes.forgotPassword) {
        return null; // Public routes allowed
      }
      return const RouteSettings(name: AppRoutes.login);
    }

    // 2. Not email verified -> redirect to Verify Email
    if (!user.emailVerified) {
      if (route == AppRoutes.verifyEmail || route == AppRoutes.login) {
        return null;
      }
      return const RouteSettings(name: AppRoutes.verifyEmail);
    }

    // If user is already on verify-email or auth screens but already verified, redirect forward
    if (user.emailVerified &&
        (route == AppRoutes.verifyEmail ||
            route == AppRoutes.login ||
            route == AppRoutes.register)) {
      return RouteSettings(name: _getHomeRouteForRole(user.role));
    }

    // 3. Role Boundary Enforcement
    if (allowedRoles != null && allowedRoles!.isNotEmpty) {
      if (!allowedRoles!.contains(user.role)) {
        // Redirect to user's authorized home screen
        return RouteSettings(name: _getHomeRouteForRole(user.role));
      }
    }

    return null;
  }

  String _getHomeRouteForRole(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return AppRoutes.customerHome;
      case UserRole.workshop:
        return AppRoutes.partnerDashboard;
      case UserRole.admin:
        return AppRoutes.adminDashboard;
      case UserRole.super_admin:
        return AppRoutes.superAdminDashboard;
    }
  }
}

