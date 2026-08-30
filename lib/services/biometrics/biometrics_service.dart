import 'package:local_auth/local_auth.dart';

/// Result of one biometric/device-credential verification attempt.
///
/// [failed] covers both the user dismissing the prompt and platform errors we
/// can't classify further — either way the caller should stay on the lock
/// screen with a retry affordance, never crash.
enum BiometricAuthResult {
  success,
  failed,
  notSetUp,
  lockedOut,
  permanentlyLockedOut,
  unsupported,
}

class BiometricsService {
  BiometricsService({LocalAuthentication? auth})
    : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  Future<BiometricAuthResult> authenticate() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return BiometricAuthResult.unsupported;
    } catch (_) {
      return BiometricAuthResult.unsupported;
    }

    try {
      final ok = await _auth.authenticate(
        localizedReason: 'Unlock the photo attached to this job visit.',
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );
      return ok ? BiometricAuthResult.success : BiometricAuthResult.failed;
    } on LocalAuthException catch (e) {
      return switch (e.code) {
        LocalAuthExceptionCode.noCredentialsSet ||
        LocalAuthExceptionCode.noBiometricsEnrolled =>
          BiometricAuthResult.notSetUp,
        LocalAuthExceptionCode.temporaryLockout =>
          BiometricAuthResult.lockedOut,
        LocalAuthExceptionCode.biometricLockout =>
          BiometricAuthResult.permanentlyLockedOut,
        LocalAuthExceptionCode.noBiometricHardware ||
        LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable =>
          BiometricAuthResult.unsupported,
        _ => BiometricAuthResult.failed,
      };
    } catch (_) {
      return BiometricAuthResult.failed;
    }
  }
}
