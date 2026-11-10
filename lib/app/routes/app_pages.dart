import 'package:get/get.dart';
import 'app_routes.dart';
import '../middleware/auth_middleware.dart';
import '../../core/enums/user_role.dart';

// Auth Views
import '../../features/auth/presentation/views/splash_view.dart';
import '../../features/auth/presentation/views/onboarding_view.dart';
import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/register_view.dart';
import '../../features/auth/presentation/views/verify_email_view.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';

// Customer Views
import '../../features/customer/presentation/views/customer_home_view.dart';
import '../../features/customer/presentation/views/workshop_locator_view.dart';

// Partner Views
import '../../features/partner/presentation/views/partner_dashboard_view.dart';
import '../../features/partner/presentation/views/partner_onboarding_view.dart';
import '../../features/partner/presentation/views/partner_review_status_view.dart';

// Admin & Super Admin Views
import '../../features/admin/presentation/views/admin_dashboard_view.dart';
import '../../features/admin/presentation/views/admin_form_builder_view.dart';
import '../../features/super_admin/presentation/views/super_admin_dashboard_view.dart';
import '../../features/super_admin/presentation/views/super_admin_form_governance_view.dart';

// Shared AI Assistant
import '../../features/ai_assistant/presentation/views/ai_assistant_view.dart';

/// Centralized GetPage definitions with AuthMiddleware role protection
class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    // Shared Auth Routes
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
    ),
    GetPage(
      name: AppRoutes.verifyEmail,
      page: () => const VerifyEmailView(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordView(),
    ),

    // Customer Protected Routes (Android Mobile)
    GetPage(
      name: AppRoutes.customerHome,
      page: () => const CustomerHomeView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.workshopLocator,
      page: () => const WorkshopLocatorView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.customerAiAssistant,
      page: () => const AiAssistantView(),
      middlewares: [AuthMiddleware()],
    ),

    // Partner Protected Routes (Android Mobile)
    GetPage(
      name: AppRoutes.partnerOnboarding,
      page: () => const PartnerOnboardingView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.workshop])],
    ),
    GetPage(
      name: AppRoutes.partnerDashboard,
      page: () => const PartnerDashboardView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.workshop])],
    ),
    GetPage(
      name: AppRoutes.partnerReviewStatus,
      page: () => const PartnerReviewStatusView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.workshop])],
    ),
    GetPage(
      name: AppRoutes.partnerAiAssistant,
      page: () => const AiAssistantView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.workshop])],
    ),

    // Admin Protected Routes (Responsive Web)
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const AdminDashboardView(),
      middlewares: [
        AuthMiddleware(allowedRoles: [UserRole.admin, UserRole.super_admin]),
      ],
    ),
    GetPage(
      name: AppRoutes.adminFormBuilder,
      page: () => const AdminFormBuilderView(),
      middlewares: [
        AuthMiddleware(allowedRoles: [UserRole.admin, UserRole.super_admin]),
      ],
    ),
    GetPage(
      name: AppRoutes.adminAiAssistant,
      page: () => const AiAssistantView(),
      middlewares: [
        AuthMiddleware(allowedRoles: [UserRole.admin, UserRole.super_admin]),
      ],
    ),

    // Super Admin Protected Routes (Responsive Web)
    GetPage(
      name: AppRoutes.superAdminDashboard,
      page: () => const SuperAdminDashboardView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.super_admin])],
    ),
    GetPage(
      name: AppRoutes.superAdminFormGovernance,
      page: () => const SuperAdminFormGovernanceView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.super_admin])],
    ),
    GetPage(
      name: AppRoutes.superAdminAiAssistant,
      page: () => const AiAssistantView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.super_admin])],
    ),
  ];
}

