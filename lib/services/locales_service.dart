// lib/services/locales_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../auth/global.dart';

class LocalesService {
  static final LocalesService _instance = LocalesService._internal();
  factory LocalesService() => _instance;
  LocalesService._internal();

  // Cache for supported locales
  List<String>? _supportedLocales;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(hours: 1);

  // ValueNotifier for reactive updates
  final ValueNotifier<List<String>?> supportedLocalesNotifier = ValueNotifier(null);

  // Loading state
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  // Initialize and load supported locales
  Future<void> initialize() async {
    if (supportedLocalesNotifier.value == null && !isLoadingNotifier.value) {
      await getSupportedLocales();
    }
  }

  // Get supported locales from API
  Future<List<String>> getSupportedLocales() async {
    // Return cached data if available and not expired
    if (_supportedLocales != null &&
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration) {
      return _supportedLocales!;
    }

    // Set loading state
    isLoadingNotifier.value = true;

    try {
      final Uri url = Uri.parse("${Global.baseUrl}/public/locales");

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> localesJson = json.decode(response.body);
        _supportedLocales = localesJson.cast<String>();
        _lastFetchTime = DateTime.now();

        // Update notifier
        supportedLocalesNotifier.value = _supportedLocales;

        print("Supported locales: $_supportedLocales");
        return _supportedLocales!;
      } else {
        print("Failed to load locales: ${response.statusCode}");
        // Return default if API fails
        final defaultLocales = _getDefaultLocales();
        supportedLocalesNotifier.value = defaultLocales;
        return defaultLocales;
      }
    } catch (e) {
      print("Error fetching locales: $e");
      // Return default if error occurs
      final defaultLocales = _getDefaultLocales();
      supportedLocalesNotifier.value = defaultLocales;
      return defaultLocales;
    } finally {
      isLoadingNotifier.value = false;
    }
  }
  List<String> _getDefaultLocales() {
    if (_supportedLocales != null) {
      return _supportedLocales!;
    }
    return ['en'];
  }

  // Clear cache
  void clearCache() {
    _supportedLocales = null;
    _lastFetchTime = null;
    supportedLocalesNotifier.value = null;
  }

  // Check if a specific locale is supported
  Future<bool> isLocaleSupported(String locale) async {
    final supportedLocales = await getSupportedLocales();
    return supportedLocales.contains(locale);
  }

  // Get locale display information
  static Map<String, Map<String, String>> getLocaleInfo() {
    return {
      'en': {
        'name': 'english',
        'code': 'EN',
        'nativeName': 'English',
      },
      'fr': {
        'name': 'french',
        'code': 'FR',
        'nativeName': 'Français',
      },
      'es': {
        'name': 'spanish',
        'code': 'ES',
        'nativeName': 'Español',
      },
      'de': {
        'name': 'german',
        'code': 'DE',
        'nativeName': 'Deutsch',
      },
      'it': {
        'name': 'italian',
        'code': 'IT',
        'nativeName': 'Italiano',
      },
      'pt': {
        'name': 'portuguese',
        'code': 'PT',
        'nativeName': 'Português',
      },
      'ar': {
        'name': 'arabic',
        'code': 'AR',
        'nativeName': 'العربية',
      },
      'zh': {
        'name': 'chinese',
        'code': 'ZH',
        'nativeName': '中文',
      },
      'ja': {
        'name': 'japanese',
        'code': 'JA',
        'nativeName': '日本語',
      },
      'ko': {
        'name': 'korean',
        'code': 'KO',
        'nativeName': '한국어',
      },
    };
  }

  // Force refresh locales from API
  Future<List<String>> refreshSupportedLocales() async {
    clearCache();
    return getSupportedLocales();
  }

  // Dispose method to clean up notifiers
  void dispose() {
    supportedLocalesNotifier.dispose();
    isLoadingNotifier.dispose();
  }
}