/// Defines all authenticated roles in CARFIXZI.
/// Super Admin is bootstrapped and manages Admins.
/// Admin handles workshop onboarding & price approvals.
/// Workshop is the service partner.
/// Customer is the vehicle owner.
enum UserRole {
  customer,
  workshop,
  admin,
  super_admin;

  String get value => name;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'super_admin':
      case 'superadmin':
        return UserRole.super_admin;
      case 'admin':
        return UserRole.admin;
      case 'workshop':
      case 'partner':
        return UserRole.workshop;
      case 'customer':
      default:
        return UserRole.customer;
    }
  }

  bool get isCustomer => this == UserRole.customer;
  bool get isWorkshop => this == UserRole.workshop;
  bool get isAdmin => this == UserRole.admin;
  bool get isSuperAdmin => this == UserRole.super_admin;
  bool get isStaffOrAdmin => this == UserRole.admin || this == UserRole.super_admin;
}

