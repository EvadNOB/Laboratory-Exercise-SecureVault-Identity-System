import 'package:flutter/material.dart';
import 'package:secure_vault/models/user_model.dart';
import 'package:secure_vault/services/auth_service.dart';
import 'package:secure_vault/services/storage_service.dart';
import 'package:secure_vault/services/security_service.dart';
import 'package:secure_vault/services/biometric_service.dart';
import 'package:secure_vault/utils/constants.dart';

class AuthViewModel extends ChangeNotifier {
  final _authService = AuthService();
  final _storageService = StorageService();
  final _securityService = SecurityService();
  final _biometricService = BiometricService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLocked = false;
  int _failedAttempts = 0;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLocked => _isLocked;
  int get failedAttempts => _failedAttempts;

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final hasToken = await _authService.hasValidToken();
      if (hasToken) {
        _user = await _authService.getCurrentUser();
        notifyListeners();
      }
      return hasToken;
    } catch (e) {
      print('AuthViewModel Authentication check error: $e');
      return false;
    }
  }

  // Register user
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.registerUser(
        email: email,
        password: password,
        displayName: displayName,
      );

      _user = user;
      _errorMessage = AppConstants.registerSuccess;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Login user
  Future<bool> login({required String email, required String password}) async {
    try {
      // Check if account is locked
      _isLocked = await _securityService.isAccountLocked();
      if (_isLocked) {
        _errorMessage = AppConstants.accountLocked;
        notifyListeners();
        return false;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.loginUser(
        email: email,
        password: password,
      );

      _user = user;
      _failedAttempts = 0;
      _isLocked = false;
      _errorMessage = AppConstants.loginSuccess;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();

      // Check if account is now locked
      _isLocked = await _securityService.isAccountLocked();
      if (_isLocked) {
        _errorMessage = AppConstants.accountLocked;
      }

      _failedAttempts = await _securityService.getFailedAttempts();

      notifyListeners();
      return false;
    }
  }

  // Google Sign-In
  Future<bool> googleLogin() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithGoogle();

      _user = user;
      _failedAttempts = 0;
      _isLocked = false;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Facebook Sign-In
  Future<bool> facebookLogin() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithFacebook();

      _user = user;
      _failedAttempts = 0;
      _isLocked = false;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Forgot Password
  Future<bool> forgotPassword({required String email}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.sendPasswordResetEmail(email);

      _errorMessage = 'Password reset email sent! Check your inbox.';
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Check biometric availability
  Future<bool> isBiometricAvailable() async {
    try {
      return await _biometricService.deviceSupportsAuthentication();
    } catch (e) {
      print('AuthViewModel Biometric check error: $e');
      return false;
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final isAuthenticated = await _biometricService.authenticateUser(
        reason: 'Scan your fingerprint to login',
      );

      if (isAuthenticated) {
        _user = await _authService.getCurrentUser();
        _failedAttempts = 0;
        _isLocked = false;
        _errorMessage = 'Biometric login successful';
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _errorMessage = 'Biometric authentication failed';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign in with fingerprint (for login screen)
  Future<bool> biometricSignIn() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if user has valid token first
      final hasToken = await _authService.hasValidToken();
      if (!hasToken) {
        _isLoading = false;
        _errorMessage = 'Please login with email and password first to enable fingerprint sign-in';
        notifyListeners();
        return false;
      }

      // Authenticate with biometrics
      final isAuthenticated = await _biometricService.authenticateUser(
        reason: 'Scan your fingerprint to sign in',
      );

      if (isAuthenticated) {
        _user = await _authService.getCurrentUser();
        _failedAttempts = 0;
        _isLocked = false;
        _errorMessage = 'Fingerprint login successful!';
        _isLoading = false;
        notifyListeners();
        return true;
      }

      _isLoading = false;
      _errorMessage = 'Fingerprint authentication failed';
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.logout();

      // Clear biometric settings on logout
      await _storageService.clearBiometricEmail();
      await _storageService.saveBiometricEnabled(false);

      _user = null;
      _errorMessage = null;
      _isLoading = false;
      _failedAttempts = 0;
      _isLocked = false;

      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
