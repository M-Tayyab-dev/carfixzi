import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/partner_type.dart';
import '../../../../core/enums/application_status.dart';

/// Core Authenticated User Entity
class AuthUser {
  final String uid;
  final String email;
  final String displayName;
  final String? phone; // Stored as unverified contact number
  final bool emailVerified;
  final UserRole role;
  final PartnerType? partnerType;
  final ApplicationStatus? partnerStatus;
  final String? partnerId;
  final bool isActive;
  final DateTime createdAt;

  const AuthUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phone,
    required this.emailVerified,
    required this.role,
    this.partnerType,
    this.partnerStatus,
    this.partnerId,
    this.isActive = true,
    required this.createdAt,
  });

  bool get isCustomer => role.isCustomer;
  bool get isWorkshop => role.isWorkshop;
  bool get isAdmin => role.isAdmin;
  bool get isSuperAdmin => role.isSuperAdmin;

  AuthUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? phone,
    bool? emailVerified,
    UserRole? role,
    PartnerType? partnerType,
    ApplicationStatus? partnerStatus,
    String? partnerId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      emailVerified: emailVerified ?? this.emailVerified,
      role: role ?? this.role,
      partnerType: partnerType ?? this.partnerType,
      partnerStatus: partnerStatus ?? this.partnerStatus,
      partnerId: partnerId ?? this.partnerId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

