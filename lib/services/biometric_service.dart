import 'package:local_auth/local_auth.dart';
import 'package:secure_vault/services/storage_service.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();

  factory BiometricService() {
    return _instance;
  }

  BiometricService._internal();

  final _localAuth = LocalAuthentication();

  // Check if biometric is enabled in storage
  Future<bool> isBiometricEnabled() async {
    try {
      final storageService = StorageService();
      final value = await storageService.getString('biometric_enabled');
      return value == 'true';
    } catch (e) {
      print('BiometricService Error checking if biometric enabled: $e');
      return false;
    }
  }

  // Check if device supports biometrics
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      print('BiometricService Error checking biometrics support: $e');
      return false;
    }
  }

  // Check if device has biometric capability
  Future<bool> deviceSupportsAuthentication() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } catch (e) {
      print('BiometricService Error checking device support: $e');
      return false;
    }
  }

  // Get available biometrics
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('BiometricService Error getting available biometrics: $e');
      return [];
    }
  }

  // Authenticate user with biometrics
  Future<bool> authenticateUser({
    required String reason,
    bool sensitiveTransaction = false,
  }) async {
    try {
      // First check if biometrics are supported
      final isSupported = await deviceSupportsAuthentication();
      if (!isSupported) {
        print('BiometricService: Biometrics not supported on this device');
        return false;
      }

      // Perform biometric authentication
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      print('BiometricService Error during authentication: $e');
      return false;
    }
  }

  // Stop authentication
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      print('BiometricService Error stopping authentication: $e');
    }
  }
}
