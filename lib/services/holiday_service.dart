import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../auth/global.dart';
import '../models/holiday_model.dart';

class HolidayService {
  static final HolidayService _instance = HolidayService._internal();
  factory HolidayService() => _instance;
  HolidayService._internal();
  final List<Function()> _listeners = [];

  // Cache for holidays
  List<HolidayModel> _holidays = [];
  bool _hasLoaded = false;

  // Get all holidays
  List<HolidayModel> get holidays => List.unmodifiable(_holidays);

  // Fetch holidays
  Future<List<HolidayModel>> fetchHolidays({bool forceRefresh = false, int? year}) async {
    if (_hasLoaded && !forceRefresh && _holidays.isNotEmpty) {
      return _holidays;
    }
    try {
      final Uri url = year != null
          ? Uri.parse("${Global.baseUrl}/secure/holidays?year=$year")
          : Uri.parse("${Global.baseUrl}/secure/holidays");

      print('Fetching holidays from: $url');
      final response = await http.get(
        url,
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> holidaysJson = json.decode(response.body);
        print('Received ${holidaysJson.length} holidays from API');

        _holidays = holidaysJson.map((json) => HolidayModel.fromJson(json)).toList();
        _hasLoaded = true;
        _notifyListeners();
        return _holidays;
      } else {
        print('Failed to load holidays: ${response.statusCode}');
        print('Response body: ${response.body}');
        throw Exception('Failed to load holidays: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching holidays: $e');
      throw Exception('Error fetching holidays: $e');
    }
  }

  // Add a new holiday
  Future<bool> addHoliday(Map<String, dynamic> holidayData) async {
    try {
      final DateTime date = holidayData['date'];
      print('Original holiday data for creation: $holidayData');
      final Map<String, dynamic> apiHoliday = {
        'date': DateFormat('yyyy-MM-dd').format(date),
        'count': holidayData['count'] ?? 1,
        'label': holidayData['name'] ?? holidayData['label'] ?? {'en': '', 'fr': ''},
        'type': holidayData['type'] ?? 'Public',
        'recurring': holidayData['recurring'] ?? false,
      };

      print('Sending holiday data: ${jsonEncode(apiHoliday)}');

      final response = await http.post(
        Uri.parse("${Global.baseUrl}/secure/holidays"),
        headers: {
          ...await Global.getHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(apiHoliday),
      );

      print('Add holiday response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh the holiday list
        await fetchHolidays(forceRefresh: true);
        return true;
      } else {
        print('Failed to add holiday: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error adding holiday: $e');
      return false;
    }
  }

  // Delete a holiday by ID
  Future<bool> deleteHoliday(int id) async {
    print('Attempting to delete holiday with ID: $id');
    try {
      final url = Uri.parse("${Global.baseUrl}/secure/holidays/$id");
      print('DELETE request to: $url');

      final headers = await Global.getHeaders();

      final response = await http.delete(
        url,
        headers: headers,
      );

      print('Delete response status code: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        print('Delete response body: ${response.body}');
      }

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Successfully deleted holiday with ID: $id');
        // Remove from cache and notify listeners
        _holidays.removeWhere((h) => h.id == id);
        _notifyListeners();
        return true;
      } else {
        print('Failed to delete holiday. Status code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting holiday: $e');
      return false;
    }
  }

  // Update a holiday
  Future<bool> updateHoliday(int id, Map<String, dynamic> holidayData) async {
    try {
      // Prepare the update payload with ID included in the body
      final Map<String, dynamic> apiHoliday = {
        'id': id, // Include ID in the request body
        'label': holidayData['label'] ?? {'en': '', 'fr': ''},
        'count': holidayData['count'] ?? 1,
        'type': holidayData['type'] ?? 'Public',
        'recurring': holidayData['recurring'] ?? holidayData['isRecurringYearly'] ?? true,
      };

      // If we have month and day, construct a date
      if (holidayData['month'] != null && holidayData['day'] != null) {
        final date = DateTime(DateTime.now().year, holidayData['month'], holidayData['day']);
        apiHoliday['date'] = DateFormat('yyyy-MM-dd').format(date);
      }
      // If we have a date object, format and include it
      else if (holidayData['date'] != null && holidayData['date'] is DateTime) {
        apiHoliday['date'] = DateFormat('yyyy-MM-dd').format(holidayData['date']);
      }

      print('Updating holiday with ID $id: ${jsonEncode(apiHoliday)}');

      // Changed URL to not include ID in path
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/holidays"),
        headers: {
          ...await Global.getHeaders(),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(apiHoliday),
      );

      print('Update response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Refresh the holiday list
        await fetchHolidays(forceRefresh: true);
        return true;
      } else {
        print('Failed to update holiday: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating holiday: $e');
      return false;
    }
  }

  // Get holidays for a specific year
  Future<List<HolidayModel>> getHolidaysForYear(int year) async {
    return fetchHolidays(year: year, forceRefresh: true);
  }

  // Get upcoming holidays
  List<HolidayModel> getUpcomingHolidays(int year) {
    final now = DateTime.now();
    return _holidays.where((holiday) {
      final holidayDate = DateTime(
        year,
        holiday.month,
        holiday.day,
      );
      return holidayDate.isAfter(now) ||
          (holidayDate.year == now.year &&
              holidayDate.month == now.month &&
              holidayDate.day == now.day);
    }).toList()
      ..sort((a, b) {
        final aDate = DateTime(year, a.month, a.day);
        final bDate = DateTime(year, b.month, b.day);
        return aDate.compareTo(bDate);
      });
  }

  // Get past holidays
  List<HolidayModel> getPastHolidays(int year) {
    final now = DateTime.now();
    return _holidays.where((holiday) {
      final holidayDate = DateTime(
        year,
        holiday.month,
        holiday.day,
      );
      return holidayDate.isBefore(now) &&
          !(holidayDate.year == now.year &&
              holidayDate.month == now.month &&
              holidayDate.day == now.day);
    }).toList()
      ..sort((a, b) {
        final aDate = DateTime(year, a.month, a.day);
        final bDate = DateTime(year, b.month, b.day);
        return bDate.compareTo(aDate); // Reverse order for past holidays
      });
  }

  // Add a listener
  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  // Remove a listener
  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  // Notify all listeners
  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
}