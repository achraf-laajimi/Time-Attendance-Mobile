import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/global.dart';

class AppInitializer {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(Global.REMEMBER_ME_KEY) ?? false;
      final token = prefs.getString(Global.TOKEN_KEY);

      print("App initializing - Remember Me: $rememberMe, Token: ${token != null ? 'Present' : 'Not present'}");

      if (rememberMe && token != null) {
        await Global.getAuthToken();
      }
    } catch (e) {
      print("Error during app initialization: $e");
    }
  }

  static void handleHotReload(BuildContext context) {
    _initialized = true;
  }
}