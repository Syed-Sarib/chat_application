import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isSystemTheme = true;

  ThemeData get themeData {
    if (_isSystemTheme) {
      return ThemeData.light(); // Default to light theme for system theme
    }
    return _isDarkMode ? ThemeData.dark() : ThemeData.light();
  }

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