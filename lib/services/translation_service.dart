// lib/services/translation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService {
  // Default to a public LibreTranslate instance
  final String baseUrl;

  // Cache for storing translations to avoid repeated API calls
  Map<String, String> _translationCache = {};

  TranslationService({this.baseUrl = 'https://libretranslate.de'});

  // Generate a cache key for storing translations
  String _getCacheKey(String text, String sourceLang, String targetLang) {
    return '${sourceLang}_${targetLang}_$text';
  }

  // Translate text from source language to target language
  Future<String> translate(String text, {
    String sourceLang = 'en',
    String targetLang = 'fr'
  }) async {
    // Don't translate empty strings
    if (text.isEmpty || text.trim().isEmpty) {
      return text;
    }

    // Check cache first
    final cacheKey = _getCacheKey(text, sourceLang, targetLang);
    if (_translationCache.containsKey(cacheKey)) {
      return _translationCache[cacheKey]!;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': sourceLang,
          'target': targetLang,
          'format': 'text',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Translation failed: ${response.reasonPhrase}');
      }

      final data = jsonDecode(response.body);
      final translatedText = data['translatedText'] as String;

      // Store in cache
      _translationCache[cacheKey] = translatedText;

      return translatedText;
    } catch (error) {
      print('Translation error: $error');
      return text; // Fallback to original text on error
    }
  }

  // Check if the LibreTranslate API is available
  Future<bool> checkAvailability() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/languages'));
      return response.statusCode == 200;
    } catch (error) {
      print('LibreTranslate API unavailable: $error');
      return false;
    }
  }

  // Load translations from cache
  Future<void> loadCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('translationCache');
      if (jsonString != null) {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        _translationCache = decoded.map((key, value) =>
            MapEntry(key, value.toString()));
      }
    } catch (e) {
      print('Error loading cached translations: $e');
    }
  }

  // Save translations to cache
  Future<void> saveCachedTranslations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('translationCache', jsonEncode(_translationCache));
    } catch (e) {
      print('Error saving cached translations: $e');
    }
  }

  // Clear the translation cache
  Future<void> clearCache() async {
    _translationCache = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('translationCache');
    } catch (e) {
      print('Error clearing cached translations: $e');
    }
  }
}