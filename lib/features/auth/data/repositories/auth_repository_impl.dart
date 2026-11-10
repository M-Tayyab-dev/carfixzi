import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/contracts/auth_repository.dart';
import '../../domain/entities/auth_user.dart';
import '../models/auth_user_dto.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/enums/partner_type.dart';
import '../../../../core/enums/application_status.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/constants/firestore_paths.dart';

class AuthRepositoryImpl implements AuthRepository {
  FirebaseAuth? _firebaseAuth;
  FirebaseFirestore? _firestore;

  AuthUser? _cachedUser;

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) {
    _firebaseAuth = firebaseAuth;
    _firestore = firestore;
  }

  FirebaseAuth get _auth {
    try {
      return _firebaseAuth ??= FirebaseAuth.instance;
    } catch (_) {
      throw AuthException('Firebase Auth is not initialized');
    }
  }

  FirebaseFirestore get _db {
    try {
      return _firestore ??= FirebaseFirestore.instance;
    } catch (_) {
      throw AuthException('Firestore is not initialized');
    }
  }

  @override
  AuthUser? get currentUser => _cachedUser;

  @override
  Stream<AuthUser?> get authStateChanges {
    try {
      return _auth.authStateChanges().asyncMap((fbUser) async {
        if (fbUser == null) {
          _cachedUser = null;
          return null;
        }
        return await _fetchUserProfile(fbUser);
      });
    } catch (_) {
      return Stream.value(null);
    }
  }

  Future<AuthUser> _fetchUserProfile(User fbUser) async {
    try {
      final doc = await _db.collection(FirestorePaths.users).doc(fbUser.uid).get();
      final user = AuthUserDto.fromFirebaseAndFirestore(
        firebaseUser: fbUser,
        firestoreData: doc.data(),
      );
      _cachedUser = user;
      return user;
    } catch (e) {
      // Return basic user info if offline or firestore read is pending
      final fallback = AuthUser(
        uid: fbUser.uid,
        email: fbUser.email ?? '',
        displayName: fbUser.displayName ?? '',
        emailVerified: fbUser.emailVerified,
        role: UserRole.customer,
        createdAt: fbUser.metadata.creationTime ?? DateTime.now(),
      );
      _cachedUser = fallback;
      return fallback;
    }
  }

  @override
  Future<AuthUser> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        throw AuthException('Failed to retrieve user session');
      }

      return await _fetchUserProfile(user);
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<AuthUser> signUpWithEmailPassword({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required UserRole role,
    PartnerType? partnerType,
  }) async {
    try {
      // Security rule: Client signup can create ONLY customer or pending partner identity
      if (role.isStaffOrAdmin) {
        throw AuthException('Cannot self-register as an administrator');
      }

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = cred.user;
      if (fbUser == null) {
        throw AuthException('Failed to create account');
      }

      // Update Firebase display name
      await fbUser.updateDisplayName(fullName);

      // Send Firebase Email Verification Link immediately
      await fbUser.sendEmailVerification();

      // Build User entity
      final newUser = AuthUser(
        uid: fbUser.uid,
        email: email.trim(),
        displayName: fullName.trim(),
        phone: phone?.trim(),
        emailVerified: false,
        role: role,
        partnerType: role.isWorkshop ? (partnerType ?? PartnerType.workshop) : null,
        partnerStatus: role.isWorkshop ? ApplicationStatus.pending_review : null,
        createdAt: DateTime.now(),
      );

      // Persist in Firestore
      await _db
          .collection(FirestorePaths.users)
          .doc(fbUser.uid)
          .set(AuthUserDto.toFirestoreMap(newUser));

      _cachedUser = newUser;
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final fbUser = _auth.currentUser;
    if (fbUser != null && !fbUser.emailVerified) {
      await fbUser.sendEmailVerification();
    }
  }

  @override
  Future<AuthUser?> reloadUserAndCheckVerification() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;

    // Reload Firebase Auth session to get fresh emailVerified status
    await fbUser.reload();
    final refreshedUser = _auth.currentUser;
    if (refreshedUser == null) return null;

    // Force refresh ID token if verified
    if (refreshedUser.emailVerified) {
      await refreshedUser.getIdToken(true);
    }

    return await _fetchUserProfile(refreshedUser);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw AuthException(_mapFirebaseAuthError(e), code: e.code);
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    _cachedUser = null;
  }

  @override
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _auth.currentUser?.getIdToken(forceRefresh);
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password does not satisfy project security policy (min 12 chars, upper/lower/digit/special).';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      default:
        return e.message ?? 'An unexpected authentication error occurred.';
    }
  }
}
