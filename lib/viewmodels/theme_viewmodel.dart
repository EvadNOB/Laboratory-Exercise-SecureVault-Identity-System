import 'package:flutter/material.dart';
import 'package:secure_vault/services/storage_service.dart';

class ThemeViewModel extends ChangeNotifier {
  final _storageService = StorageService();
  late ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  ThemeViewModel() {
    _loadThemePreference();
  }

  // Load theme preference from storage
  Future<void> _loadThemePreference() async {
    try {
      final isDarkMode =
          await _storageService.getString('theme_mode') == 'dark';
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      print('ThemeViewModel Error loading theme: $e');
      _themeMode = ThemeMode.light;
    }
  }

  // Toggle theme
  Future<void> toggleTheme(bool isDarkMode) async {
    try {
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();

      // Save preference
      await _storageService.saveString(
        'theme_mode',
        isDarkMode ? 'dark' : 'light',
      );
    } catch (e) {
      print('ThemeViewModel Error toggling theme: $e');
    }
  }
}
