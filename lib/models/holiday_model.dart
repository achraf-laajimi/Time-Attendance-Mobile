class HolidayModel {
  final int id;
  final int month;
  final int day;
  final Map<String, String> label;
  final int count;
  final String type;
  final bool recurring;
  final String? description;

  HolidayModel({
    required this.id,
    required this.month,
    required this.day,
    required this.label,
    required this.count,
    required this.type,
    required this.recurring,
    this.description,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) {
    // Log the incoming JSON for debugging
    print('Processing holiday: ${json['id']}');

    // Extract the label properly handling different formats
    Map<String, String> labelMap = {};

    if (json['label'] != null) {
      if (json['label'] is Map) {
        // Convert all values to strings and filter out null/empty values
        (json['label'] as Map).forEach((key, value) {
          if (value != null && value.toString().isNotEmpty) {
            labelMap[key.toString()] = value.toString();
          }
        });
      } else if (json['label'] is String) {
        // If label is a simple string, use it for common languages
        final labelString = json['label'].toString();
        labelMap = {
          'en': labelString,
          // Only add other languages if we're sure they exist
        };
      }
    }

    // Ensure we have at least one label
    if (labelMap.isEmpty) {
      labelMap['en'] = 'Unnamed Holiday';
    }

    // Extract date components
    int month, day;

    if (json['date'] != null) {
      // Parse the date string (format: "YYYY-MM-DD")
      final DateTime date = DateTime.parse(json['date']);
      month = date.month;
      day = date.day;
    } else {
      // Fallback to separate fields if available
      month = json['month'] ?? 1;
      day = json['day'] ?? 1;
    }

    // Extract and parse the ID
    int holidayId;
    if (json['id'] is int) {
      holidayId = json['id'];
    } else if (json['id'] is String) {
      holidayId = int.tryParse(json['id']) ?? 0;
    } else {
      holidayId = 0;
    }

    return HolidayModel(
      id: holidayId,
      month: month,
      day: day,
      label: labelMap,
      count: json['count'] ?? 1,
      type: json['type'] ?? 'Public',
      recurring: json['recurring'] ?? true,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': DateTime(DateTime.now().year, month, day).toIso8601String().substring(0, 10),
      'label': label,
      'count': count,
      'type': type,
      'recurring': recurring,
      if (description != null) 'description': description,
    };
  }

  // Get the name based on the current language with better fallback logic
  String getName(String languageCode) {
    // Try to get the requested language
    if (label[languageCode] != null && label[languageCode]!.isNotEmpty) {
      return label[languageCode]!;
    }

    // Fallback to English if available
    if (label['en'] != null && label['en']!.isNotEmpty) {
      return label['en']!;
    }

    // Fallback to the first available language
    if (label.isNotEmpty) {
      final firstKey = label.keys.first;
      if (label[firstKey] != null && label[firstKey]!.isNotEmpty) {
        return label[firstKey]!;
      }
    }

    // Last resort fallback
    return 'Unnamed Holiday';
  }

  // Get all available language codes for this holiday
  List<String> getAvailableLanguages() {
    return label.keys.where((key) =>
    label[key] != null && label[key]!.isNotEmpty
    ).toList();
  }

  // Check if a specific language is available
  bool hasLanguage(String languageCode) {
    return label[languageCode] != null && label[languageCode]!.isNotEmpty;
  }

  // Get date for a specific year
  DateTime getDateForYear(int year) {
    return DateTime(year, month, day);
  }

  // Create a copy with updated labels
  HolidayModel copyWithLabels(Map<String, String> newLabels) {
    return HolidayModel(
      id: id,
      month: month,
      day: day,
      label: newLabels,
      count: count,
      type: type,
      recurring: recurring,
      description: description,
    );
  }
}