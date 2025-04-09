import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  final String key = 'theme_mode';
  late SharedPreferences _prefs;
  bool _darkMode = false;

  // Getters
  bool get darkMode => _darkMode;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  // Constructor
  ThemeProvider() {
    _loadFromPreferences();
  }

  // Toggle theme
  void toggleTheme() {
    _darkMode = !_darkMode;
    _saveToPreferences();
    notifyListeners();
  }

  // Load theme from preferences
  Future<void> _loadFromPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _darkMode = _prefs.getBool(key) ?? false;
    notifyListeners();
  }

  // Save theme to preferences
  Future<void> _saveToPreferences() async {
    await _prefs.setBool(key, _darkMode);
  }
}
