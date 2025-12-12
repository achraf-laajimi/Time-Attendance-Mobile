import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class NationalityService {
  static final NationalityService _instance = NationalityService._internal();

  factory NationalityService() => _instance;

  NationalityService._internal();

  // Cached nationalities to avoid reloading files multiple times
  final Map<String, List<String>> _cachedNationalities = {};

  /// Loads nationalities from files based on language code
  /// Returns a list of nationality names
  Future<List<String>> getNationalitiesByLanguage(String languageCode) async {
    // Check if we already have loaded this language
    if (_cachedNationalities.containsKey(languageCode)) {
      return _cachedNationalities[languageCode]!;
    }

    try {
      // Determine which file to load based on language code
      String filename;

      switch (languageCode) {
        case 'fr':
          filename = 'assets/nationalityFR.json';
          break;
        case 'en':
        default:
          filename = 'assets/nationalityEN.json';
          break;
      }

      // Load the file content
      String content = await rootBundle.loadString(filename);

      // Parse JSON array
      List<dynamic> jsonList = jsonDecode(content);
      List<String> nationalities = jsonList.cast<String>();

      // Cache the results
      _cachedNationalities[languageCode] = nationalities;

      return nationalities;
    } catch (e) {
      print('Error loading nationalities file: $e');

      // Fallback to default nationalities
      return ['American', 'British', 'Canadian', 'French', 'German', 'Other'];
    }
  }

  /// Clears the nationality cache
  void clearCache() {
    _cachedNationalities.clear();
  }
}
