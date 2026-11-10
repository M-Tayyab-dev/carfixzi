/// Typed route constants for CARFIXZI
abstract class AppRoutes {
  // Shared & Auth Routes
  static const splash = '/splash';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const verifyEmail = '/verify-email';
  static const forgotPassword = '/forgot-password';

  // Customer Routes (Android Mobile)
  static const customerHome = '/customer/home';
  static const workshopLocator = '/customer/workshops';
  static const workshopDetail = '/customer/workshop-detail';
  static const serviceBooking = '/customer/booking';
  static const serviceRepairDetails = '/customer/repair-details';
  static const carWashBooking = '/customer/wash-booking';
  static const mobileMechanic = '/customer/mobile-mechanic';
  static const serviceTracking = '/customer/tracking';
  static const paymentCheckout = '/customer/checkout';
  static const serviceHistory = '/customer/history';
  static const customerProfile = '/customer/profile';
  static const vehicleRegistration = '/customer/vehicles';
  static const partsMarketplace = '/customer/parts';
  static const cart = '/customer/cart';
  static const myOrders = '/customer/orders';
  static const customerAiAssistant = '/customer/ai-assistant';

  // Partner Routes (Android Mobile)
  static const partnerOnboarding = '/partner/onboarding';
  static const partnerReviewStatus = '/partner/review-status';
  static const partnerDashboard = '/partner/dashboard';
  static const partnerInventory = '/partner/inventory';
  static const partnerBilling = '/partner/billing';
  static const partnerServices = '/partner/services';
  static const partnerStaff = '/partner/staff';
  static const partnerAiAssistant = '/partner/ai-assistant';

  // Admin Routes (Responsive Web)
  static const adminDashboard = '/admin/dashboard';
  static const adminVerifications = '/admin/verifications';
  static const adminProposals = '/admin/proposals';
  static const adminFormBuilder = '/admin/workshop-form-builder';
  static const adminAudit = '/admin/audit';
  static const adminAiAssistant = '/admin/ai-assistant';

  // Super Admin Routes (Responsive Web)
  static const superAdminDashboard = '/super/dashboard';
  static const superAdminAdmins = '/super/admins';
  static const superAdminPartners = '/super/partners';
  static const superAdminCommission = '/super/commission-policies';
  static const superAdminSettlements = '/super/settlements';
  static const superAdminFormGovernance = '/super/workshop-form-builder';
  static const superAdminSettings = '/super/settings';
  static const superAdminAiAssistant = '/super/ai-assistant';
}
