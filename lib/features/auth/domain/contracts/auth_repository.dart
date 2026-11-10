import '../entities/auth_user.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/partner_type.dart';

/// Contract for Authentication Operations
abstract class AuthRepository {
  Stream<AuthUser?> get authStateChanges;
  AuthUser? get currentUser;

  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required UserRole role,
    PartnerType? partnerType,
  });

  Future<void> sendEmailVerification();
  Future<AuthUser?> reloadUserAndCheckVerification();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  Future<String?> getIdToken({bool forceRefresh = false});
}
