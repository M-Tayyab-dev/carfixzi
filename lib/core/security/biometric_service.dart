import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Android Biometric Session Unlock Service (Section 9.4)
/// Note: Biometrics only unlock an already email-verified, locally saved session.
/// They NEVER replace Firebase Authentication or remote identity verification.
class BiometricService {
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  static const String _keyBiometricEnabled = 'carfixzi_biometric_enabled';
  static const String _keySessionToken = 'carfixzi_session_cache';

  BiometricService({
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Check if device supports hardware biometrics (Fingerprint/Face) or device credentials
  Future<bool> isBiometricAvailable() async {
    if (kIsWeb) return false; // Biometrics not supported on Flutter Web
    try {
      final canAuthenticateWithBiometrics = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canAuthenticateWithBiometrics || isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get list of available biometric sensors on the handset
  Future<List<BiometricType>> getAvailableBiometrics() async {
    if (kIsWeb) return [];
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Check if the user has opted-in to biometric lock in app preferences
  Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }

  /// Enable or disable biometric lock preference
  Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(
      key: _keyBiometricEnabled,
      value: enabled ? 'true' : 'false',
    );
  }

  /// Prompt user to authenticate using handset fingerprint, face, or PIN fallback
  Future<bool> authenticate({String reason = 'Authenticate to access CARFIXZI'}) async {
    if (kIsWeb) return true;
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) return false;

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false, // Allows device credential (PIN/pattern) fallback
        ),
      );
    } catch (_) {
      return false;
    }
  }

  /// Clear stored biometric preferences on logout
  Future<void> clearSession() async {
    await _secureStorage.delete(key: _keyBiometricEnabled);
    await _secureStorage.delete(key: _keySessionToken);
  }
}
