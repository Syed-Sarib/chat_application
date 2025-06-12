import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isSystemTheme = true;
  ThemeData? _customLightTheme;
  ThemeData? _customDarkTheme;

  // Initialize with custom themes
  void initializeThemes({
    required ThemeData customLightTheme,
    required ThemeData customDarkTheme,
  }) {
    _customLightTheme = customLightTheme;
    _customDarkTheme = customDarkTheme;
    notifyListeners();
  }

  ThemeData get currentLightTheme => _customLightTheme ?? ThemeData.light();
  ThemeData get currentDarkTheme => _customDarkTheme ?? ThemeData.dark();

  ThemeData get themeData {
    if (_isSystemTheme) {
      return currentLightTheme; // Default to light theme for system theme
    }
    return _isDarkMode ? currentDarkTheme : currentLightTheme;
  }

  bool get isDarkMode => _isDarkMode;
  bool get isSystemTheme => _isSystemTheme;

  void setLightTheme() {
    _isDarkMode = false;
    _isSystemTheme = false;
    notifyListeners();
  }

  void setDarkTheme() {
    _isDarkMode = true;
    _isSystemTheme = false;
    notifyListeners();
  }

  void setSystemTheme() {
    _isSystemTheme = true;
    notifyListeners();
  }
}