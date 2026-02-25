import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  StorageService._internal();

  static const _storage = FlutterSecureStorage();

  // Save string value
  Future<void> saveString(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      print('StorageService Error saving $key: $e');
      rethrow;
    }
  }

  // Get string value
  Future<String?> getString(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      print('StorageService Error reading $key: $e');
      return null;
    }
  }

  // Save integer value
  Future<void> saveInt(String key, int value) async {
    try {
      await _storage.write(key: key, value: value.toString());
    } catch (e) {
      print('StorageService Error saving int $key: $e');
      rethrow;
    }
  }

  // Get integer value
  Future<int?> getInt(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null ? int.tryParse(value) : null;
    } catch (e) {
      print('StorageService Error reading int $key: $e');
      return null;
    }
  }

  // Delete value
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      print('StorageService Error deleting $key: $e');
      rethrow;
    }
  }

  // Clear all
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      print('StorageService Error clearing all: $e');
      rethrow;
    }
  }

  // Check if key exists
  Future<bool> containsKey(String key) async {
    try {
      final value = await _storage.read(key: key);
      return value != null;
    } catch (e) {
      print('StorageService Error checking key $key: $e');
      return false;
    }
  }

  // Biometric preference helpers
  Future<void> saveBiometricEnabled(bool enabled) async {
    try {
      await saveString('biometric_enabled', enabled.toString());
    } catch (e) {
      print('StorageService Error saving biometric preference: $e');
      rethrow;
    }
  }

  Future<bool> isBiometricEnabled() async {
    try {
      final value = await getString('biometric_enabled');
      return value == 'true';
    } catch (e) {
      print('StorageService Error reading biometric preference: $e');
      return false;
    }
  }

  // Store email for biometric sign-in
  Future<void> saveBiometricEmail(String email) async {
    try {
      await saveString('biometric_email', email);
    } catch (e) {
      print('StorageService Error saving biometric email: $e');
      rethrow;
    }
  }

  // Get email for biometric sign-in
  Future<String?> getBiometricEmail() async {
    try {
      return await getString('biometric_email');
    } catch (e) {
      print('StorageService Error reading biometric email: $e');
      return null;
    }
  }

  // Clear biometric email (when disabling or after logout)
  Future<void> clearBiometricEmail() async {
    try {
      await delete('biometric_email');
    } catch (e) {
      print('StorageService Error clearing biometric email: $e');
      rethrow;
    }
  }
}
