import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/auth_user.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/partner_type.dart';
import '../../../../core/enums/application_status.dart';

/// Data Transfer Object mapping Firestore and Firebase Auth to AuthUser domain entity
class AuthUserDto {
  static AuthUser fromFirebaseAndFirestore({
    required User firebaseUser,
    Map<String, dynamic>? firestoreData,
  }) {
    final roleStr = firestoreData?['role'] as String?;
    final partnerTypeStr = firestoreData?['partnerType'] as String?;
    final partnerStatusStr = firestoreData?['partnerStatus'] as String?;

    DateTime created = DateTime.now();
    if (firestoreData?['createdAt'] is Timestamp) {
      created = (firestoreData!['createdAt'] as Timestamp).toDate();
    } else if (firebaseUser.metadata.creationTime != null) {
      created = firebaseUser.metadata.creationTime!;
    }

    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firestoreData?['displayName'] ?? firebaseUser.displayName ?? '',
      phone: firestoreData?['phone'] ?? firebaseUser.phoneNumber,
      emailVerified: firebaseUser.emailVerified,
      role: UserRole.fromString(roleStr),
      partnerType: partnerTypeStr != null ? PartnerType.fromString(partnerTypeStr) : null,
      partnerStatus: partnerStatusStr != null ? ApplicationStatus.fromString(partnerStatusStr) : null,
      partnerId: firestoreData?['partnerId'] as String?,
      isActive: firestoreData?['isActive'] ?? true,
      createdAt: created,
    );
  }

  static Map<String, dynamic> toFirestoreMap(AuthUser user) {
    return {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'phone': user.phone,
      'phoneVerified': false, // Explicit: Contact number is unverified in MVP
      'role': user.role.value,
      'partnerType': user.partnerType?.name,
      'partnerStatus': user.partnerStatus?.name,
      'partnerId': user.partnerId,
      'isActive': user.isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

