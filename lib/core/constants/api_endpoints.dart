/// Local Trusted Python FastAPI endpoints
class ApiEndpoints {
  // Local development host (10.0.2.2 for Android Emulator, localhost for Web/Desktop)
  static const String baseApiUrl = 'http://10.0.2.2:8000';
  static const String webBaseApiUrl = 'http://localhost:8000';

  // AI Chat
  static const String aiChat = '/v1/ai/chat';

  // Dynamic Workshop Form Schema
  static const String workshopFormActive = '/v1/workshop-form/active';
  static const String workshopFormDrafts = '/v1/workshop-form/drafts';
  static const String workshopFormPublish = '/v1/workshop-form'; // + /{versionId}/publish
  static const String workshopFormFieldRetire = '/v1/workshop-form/fields'; // + /{fieldId}/retire
  static const String workshopFormFieldRestore = '/v1/workshop-form/fields'; // + /{fieldId}/restore

  // Media Authorization (Signed Cloudinary Uploads)
  static const String mediaUploadAuthorize = '/v1/media/upload-authorize';

  // Application & Decisions
  static const String partnerApplications = '/v1/partner-applications';
  static const String applicationDecision = '/v1/applications'; // + /{id}/decision

  // Booking & Orders Transactions
  static const String bookings = '/v1/bookings';
  static const String orders = '/v1/orders';
  static const String paymentsConfirm = '/v1/payments'; // + /{id}/confirm

  // Super Admin Settlements & Provisioning
  static const String settlements = '/v1/settlements';
  static const String admins = '/v1/admins';
}
