import 'package:flutter/material.dart';
import 'package:in_out/provider/user_settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorProvider with ChangeNotifier {
  // Default colors
  Color _primaryColor = const Color(0xFF2E7D32); // Green
  Color _secondaryColor = const Color(0xFFFF7240); // Orange

  // Getters for the colors
  Color get primaryColor => _primaryColor;
  Color get secondaryColor => _secondaryColor;

  // Keys for SharedPreferences
  static const String PRIMARY_COLOR_KEY = "primary_color";
  static const String SECONDARY_COLOR_KEY = "secondary_color";

  ColorProvider() {
    _loadSavedColors();
  }

  // Load colors from SharedPreferences
  Future<void> _loadSavedColors() async {
    final prefs = await SharedPreferences.getInstance();
    final primaryColorValue = prefs.getInt(PRIMARY_COLOR_KEY);
    final secondaryColorValue = prefs.getInt(SECONDARY_COLOR_KEY);

    if (primaryColorValue != null) {
      _primaryColor = Color(primaryColorValue);
    }
    if (secondaryColorValue != null) {
      _secondaryColor = Color(secondaryColorValue);
    }
    notifyListeners();
  }

  // Change primary color
  Future<void> changePrimaryColor(Color color) async {
    _primaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PRIMARY_COLOR_KEY, color.value);
    notifyListeners();
  }

  // Change secondary color
  Future<void> changeSecondaryColor(Color color) async {
    _secondaryColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(SECONDARY_COLOR_KEY, color.value);
    notifyListeners();
  }
  void syncWithUserSettings(BuildContext context) {
    final userSettings = Provider.of<UserSettingsProvider>(context, listen: false).currentSettings;
    if (_primaryColor != userSettings.primaryColor ||
        _secondaryColor != userSettings.secondaryColor) {
      _primaryColor = userSettings.primaryColor;
      _secondaryColor = userSettings.secondaryColor;
      notifyListeners();
    }
  }
}