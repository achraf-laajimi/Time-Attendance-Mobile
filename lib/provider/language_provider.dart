import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/auth_service.dart';

class LanguageProvider with ChangeNotifier {
  String _currentLanguage = 'en';
  String? _userId;

  String get currentLanguage => _currentLanguage;

  // Key for SharedPreferences
  static const String LANGUAGE_KEY = 'language';

  LanguageProvider() {
    _initializeUser();
  }

  // Initialize user ID and load associated settings
  Future<void> _initializeUser() async {
    // Try to get the current user ID from auth service
    _userId = await AuthService.getCurrentUserId();

    // Load language for the current user
    _loadSavedLanguage();
  }

  // Generate user-specific preference key
  String _getUserSpecificKey(String baseKey) {
    return _userId != null ? "${_userId}_$baseKey" : baseKey;
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    // Use user-specific key
    final languageKey = _getUserSpecificKey(LANGUAGE_KEY);
    _currentLanguage = prefs.getString(languageKey) ?? 'en';
    notifyListeners();
  }

  Future<void> changeLanguage(String languageCode) async {
    if (_currentLanguage != languageCode) {
      _currentLanguage = languageCode;

      // Save to preferences using user-specific key
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_getUserSpecificKey(LANGUAGE_KEY), languageCode);

      notifyListeners();
      print("Language changed to: $languageCode");
    }
  }

  // Update user ID (call this when user logs in)
  Future<void> updateUserId(String? userId) async {
    bool userChanged = _userId != userId;
    _userId = userId;

    // If user changed, reload language for the new user
    if (userChanged) {
      await _loadSavedLanguage();
    }
  }
}