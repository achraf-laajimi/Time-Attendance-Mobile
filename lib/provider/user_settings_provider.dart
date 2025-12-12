// lib/provider/user_settings_provider.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  String language;
  String themeMode;
  Color primaryColor;
  Color secondaryColor;

  UserSettings({
    required this.language,
    required this.themeMode,
    required this.primaryColor,
    required this.secondaryColor,
  });

  Map<String, dynamic> toMap() {
    return {
      'language': language,
      'themeMode': themeMode,
      'primaryColor': primaryColor.value,
      'secondaryColor': secondaryColor.value,
    };
  }

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      language: map['language'] ?? 'en',
      themeMode: map['themeMode'] ?? 'system',
      primaryColor: Color(map['primaryColor'] ?? 0xFF2E7D32), // Default green color
      secondaryColor: Color(map['secondaryColor'] ?? 0xFFFF7240), // Default orange color
    );
  }

  factory UserSettings.defaults() {
    return UserSettings(
      language: 'en',
      themeMode: 'system',
      primaryColor: const Color(0xFF2E7D32), // Default green color
      secondaryColor: const Color(0xFFFF7240), // Default orange color
    );
  }
}

class UserSettingsProvider with ChangeNotifier {
  final Map<String, UserSettings> _userSettings = {};
  String? _currentUserId;
  UserSettings? _currentSettings;

  UserSettings get currentSettings => _currentSettings ?? UserSettings.defaults();

  // Initialize user settings
  Future<void> initialize(String? userId) async {
    _currentUserId = userId;
    if (userId != null) {
      await _loadUserSettings(userId);
    } else {
      _currentSettings = UserSettings.defaults();
    }
    notifyListeners();
  }

  // Set current user and load their settings
  Future<void> setCurrentUser(String userId) async {
    _currentUserId = userId;
    await _loadUserSettings(userId);
    notifyListeners();
  }

  // Clear current user on logout
  void clearCurrentUser() {
    _currentUserId = null;
    _currentSettings = null;
    notifyListeners();
  }

  // Load settings for a specific user
  Future<void> _loadUserSettings(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString('user_settings_$userId');

    if (settingsJson != null) {
      try {
        final Map<String, dynamic> settingsMap = Map<String, dynamic>.from(
            json.decode(settingsJson) as Map
        );
        _currentSettings = UserSettings.fromMap(settingsMap);
      } catch (e) {
        print('Error loading user settings: $e');
        _currentSettings = UserSettings.defaults();
      }
    } else {
      _currentSettings = UserSettings.defaults();
    }

    _userSettings[userId] = _currentSettings!;
  }

  // Save settings for the current user
  Future<void> saveUserSettings() async {
    if (_currentUserId == null || _currentSettings == null) return;

    final prefs = await SharedPreferences.getInstance();
    final settingsJson = json.encode(_currentSettings!.toMap());
    await prefs.setString('user_settings_$_currentUserId', settingsJson);
  }

  // Update language setting
  Future<void> changeLanguage(String languageCode) async {
    if (_currentUserId == null || _currentSettings == null) return;

    if (_currentSettings!.language != languageCode) {
      _currentSettings = UserSettings(
        language: languageCode,
        themeMode: _currentSettings!.themeMode,
        primaryColor: _currentSettings!.primaryColor,
        secondaryColor: _currentSettings!.secondaryColor,
      );

      await saveUserSettings();
      notifyListeners();
    }
  }

  // Update theme mode setting
  Future<void> changeThemeMode(String themeMode) async {
    if (_currentUserId == null || _currentSettings == null) return;

    if (_currentSettings!.themeMode != themeMode) {
      _currentSettings = UserSettings(
        language: _currentSettings!.language,
        themeMode: themeMode,
        primaryColor: _currentSettings!.primaryColor,
        secondaryColor: _currentSettings!.secondaryColor,
      );

      await saveUserSettings();
      notifyListeners();
    }
  }

  // Update primary color setting
  Future<void> changePrimaryColor(Color color) async {
    if (_currentUserId == null || _currentSettings == null) return;

    if (_currentSettings!.primaryColor != color) {
      _currentSettings = UserSettings(
        language: _currentSettings!.language,
        themeMode: _currentSettings!.themeMode,
        primaryColor: color,
        secondaryColor: _currentSettings!.secondaryColor,
      );

      await saveUserSettings();
      notifyListeners();
    }
  }

  // Update secondary color setting
  Future<void> changeSecondaryColor(Color color) async {
    if (_currentUserId == null || _currentSettings == null) return;

    if (_currentSettings!.secondaryColor != color) {
      _currentSettings = UserSettings(
        language: _currentSettings!.language,
        themeMode: _currentSettings!.themeMode,
        primaryColor: _currentSettings!.primaryColor,
        secondaryColor: color,
      );

      await saveUserSettings();
      notifyListeners();
    }
  }
}