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
import '../../features/customer/presentation/views/service_booking_view.dart';
import '../../features/customer/presentation/views/car_wash_booking_view.dart';
import '../../features/customer/presentation/views/mobile_mechanic_view.dart';
import '../../features/customer/presentation/views/service_tracking_view.dart';
import '../../features/customer/presentation/views/payment_checkout_view.dart';
import '../../features/customer/presentation/views/parts_marketplace_view.dart';
import '../../features/customer/presentation/views/cart_view.dart';
import '../../features/customer/presentation/views/vehicle_registration_view.dart';
import '../../features/customer/presentation/views/customer_profile_view.dart';
import '../../features/customer/presentation/views/service_history_view.dart';

// Partner Views
import '../../features/partner/presentation/views/partner_dashboard_view.dart';
import '../../features/partner/presentation/views/partner_onboarding_view.dart';
import '../../features/partner/presentation/views/partner_review_status_view.dart';
import '../../features/partner/presentation/views/partner_inventory_view.dart';
import '../../features/partner/presentation/views/partner_billing_view.dart';

// Admin & Super Admin Views
import '../../features/admin/presentation/views/admin_dashboard_view.dart';
import '../../features/admin/presentation/views/admin_form_builder_view.dart';
import '../../features/admin/presentation/views/admin_verifications_view.dart';
import '../../features/super_admin/presentation/views/super_admin_dashboard_view.dart';
import '../../features/super_admin/presentation/views/super_admin_form_governance_view.dart';
import '../../features/super_admin/presentation/views/super_admin_commission_view.dart';
import '../../features/super_admin/presentation/views/super_admin_settlements_view.dart';
import '../../features/super_admin/presentation/views/super_admin_admins_view.dart';

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
      name: AppRoutes.serviceBooking,
      page: () => const ServiceBookingView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.carWashBooking,
      page: () => const CarWashBookingView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.mobileMechanic,
      page: () => const MobileMechanicView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.serviceTracking,
      page: () => const ServiceTrackingView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.paymentCheckout,
      page: () => const PaymentCheckoutView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.partsMarketplace,
      page: () => const PartsMarketplaceView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.vehicleRegistration,
      page: () => const VehicleRegistrationView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.customerProfile,
      page: () => const CustomerProfileView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.customer])],
    ),
    GetPage(
      name: AppRoutes.serviceHistory,
      page: () => const ServiceHistoryView(),
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
      name: AppRoutes.partnerInventory,
      page: () => const PartnerInventoryView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.workshop])],
    ),
    GetPage(
      name: AppRoutes.partnerBilling,
      page: () => const PartnerBillingView(),
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
      name: AppRoutes.adminVerifications,
      page: () => const AdminVerificationsView(),
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
      name: AppRoutes.superAdminAdmins,
      page: () => const SuperAdminAdminsView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.super_admin])],
    ),
    GetPage(
      name: AppRoutes.superAdminFormGovernance,
      page: () => const SuperAdminFormGovernanceView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.super_admin])],
    ),
    GetPage(
      name: AppRoutes.superAdminCommission,
      page: () => const SuperAdminCommissionView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.super_admin])],
    ),
    GetPage(
      name: AppRoutes.superAdminSettlements,
      page: () => const SuperAdminSettlementsView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.super_admin])],
    ),
    GetPage(
      name: AppRoutes.superAdminAiAssistant,
      page: () => const AiAssistantView(),
      middlewares: [AuthMiddleware(allowedRoles: [UserRole.super_admin])],
    ),
  ];
}

