// lib/services/attendance_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../auth/global.dart';

class AttendanceService {
  static Future<Map<String, dynamic>> getEmployeeAttendance(
      String employeeId, {
        int page = 0,
        int size = 10,
        int? year,
      }) async
  {
    // Build URL with pagination parameters
    final Uri url = Uri.parse(
        "${Global.baseUrl}/secure/attendance/user?userId=$employeeId&page=$page&size=$size${year != null ? '&year=$year' : '&year=2025'}");

    try {
      final response = await http.get(
        url,
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        List<Map<String, dynamic>> processedAttendances = [];

        // Extract pagination metadata
        int totalElements = responseData['totalElements'] ?? 0;
        int totalPages = responseData['totalPages'] ?? 1;
        int currentPage = responseData['pageable']?['pageNumber'] ?? 0;
        int pageSize = responseData['pageable']?['pageSize'] ?? size;
        bool isFirst = responseData['first'] ?? true;
        bool isLast = responseData['last'] ?? true;

        // Process the content array if present
        final List<dynamic> content = responseData['content'] ?? [];

        for (var attendance in content) {
          // Default end time for calculations if needed
          const String endWorkTime = "18:00:00";

          final String localDate = attendance['localDate'] ?? '';
          final List<dynamic> entries = attendance['entries'] ?? [];
          final bool isLate = attendance['late'] ?? false;

          // Format date to a nice display format
          DateTime? parsedDate;
          String displayDate = localDate;
          try {
            parsedDate = DateTime.parse(localDate);
            displayDate = DateFormat('MMMM dd, yyyy').format(parsedDate);
          } catch (e) {
            // Keep original format if parsing fails
          }

          // Process check-in/check-out times - keep original format with seconds
          String check1 = entries.isNotEmpty ? entries[0] : '';
          String check2 = entries.length > 1 ? entries[1] : '';
          String check3 = entries.length > 2 ? entries[2] : '';
          String check4 = entries.length > 3 ? entries[3] : '';

          // Calculate breaks and working hours
          String breakTime = '00:00';
          String workingHours = '00:00';

          if (entries.length >= 2) {
            try {
              // Calculate breaks - assume even entries are check-ins, odd entries are check-outs
              Duration totalBreak = Duration.zero;

              for (int i = 1; i < entries.length - 1; i += 2) {
                final checkOut = _parseTimeToMinutes(entries[i]);
                final nextCheckIn = _parseTimeToMinutes(entries[i + 1]);
                totalBreak += Duration(minutes: nextCheckIn - checkOut);
              }

              // Format break time with seconds
              final breakHours = totalBreak.inHours;
              final breakMinutes = (totalBreak.inMinutes % 60);
              final breakSeconds = (totalBreak.inSeconds % 60);
              breakTime = '${breakHours.toString().padLeft(2, '0')}:${breakMinutes.toString().padLeft(2, '0')}:${breakSeconds.toString().padLeft(2, '0')}';

              // Calculate working hours
              final firstCheckIn = _parseTimeToMinutes(entries.first);

              // Use last entry as checkout or default end time
              int lastCheckOut;
              if (entries.length % 2 == 0) {
                // Even number of entries - use the last one
                lastCheckOut = _parseTimeToMinutes(entries.last);
              } else {
                // Odd number of entries - use default end time
                lastCheckOut = _parseTimeToMinutes(endWorkTime);
              }

              final totalWorkMinutes = lastCheckOut - firstCheckIn - totalBreak.inMinutes;
              final workHours = totalWorkMinutes ~/ 60;
              final workMinutes = totalWorkMinutes % 60;
              // Include 00 seconds in working hours
              workingHours = '${workHours.toString().padLeft(2, '0')}:${workMinutes.toString().padLeft(2, '0')}:00';
            } catch (e) {
              print("Error calculating times: $e");
            }
          } else if (entries.length == 1) {
            // Just checked in - assume working until end of day
            try {
              final checkIn = _parseTimeToMinutes(entries.first);
              final checkOut = _parseTimeToMinutes(endWorkTime);
              final totalWorkMinutes = checkOut - checkIn;
              final workHours = totalWorkMinutes ~/ 60;
              final workMinutes = totalWorkMinutes % 60;
              workingHours = '${workHours.toString().padLeft(2, '0')}:${workMinutes.toString().padLeft(2, '0')}';
            } catch (e) {
              print("Error calculating times with single entry: $e");
            }
          }

          // Add to processed attendances - format to match the web version
          processedAttendances.add({
            'date': displayDate,
            'localDate': localDate, // Keep original date format for sorting
            'check1': check1,
            'check2': check2,
            'check3': check3,
            'check4': check4,
            'break': breakTime,
            'workingHours': workingHours,
            'status': isLate ? 'Late' : 'On Time', // Use full text for web version
            'isLate': isLate,
            'rawData': attendance, // Store original data for reference if needed
          });
        }

        // Sort by date descending (most recent first) - already sorted by API but keep as fallback
        processedAttendances.sort((a, b) {
          final aDate = a['localDate'];
          final bDate = b['localDate'];
          return bDate.compareTo(aDate);
        });

        return {
          "success": true,
          "attendances": processedAttendances,
          "totalElements": totalElements,
          "totalPages": totalPages,
          "currentPage": currentPage,
          "pageSize": pageSize,
          "isFirst": isFirst,
          "isLast": isLast,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load attendance data: ${response.statusCode}",
          "attendances": [],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
        "attendances": [],
      };
    }
  }

  // Helper to parse time string to minutes since midnight
  static int _parseTimeToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }

  // Get available years for attendance records
  static Future<List<int>> getAvailableYears(String employeeId) async {
    try {
      // This is a simplified approach - ideally the API would provide this information
      // For now, we'll return current year and a few past years
      final currentYear = DateTime.now().year;
      return [currentYear, currentYear - 1, currentYear - 2];
    } catch (e) {
      print("Error getting available years: $e");
      return [DateTime.now().year];
    }
  }

  static Future<Map<String, dynamic>> getDailyAttendance({
    required String date,
    int page = 0,
    int size = 10,
  }) async
  {
    final Uri url = Uri.parse(
        "${Global.baseUrl}/secure/attendance/date?page=$page&size=$size&date=$date");

    try {
      final response = await http.get(
        url,
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        return {
          "success": true,
          "content": responseData["content"] ?? [],
          "totalElements": responseData["totalElements"] ?? 0,
          "totalPages": responseData["totalPages"] ?? 0,
          "currentPage": responseData["pageable"]?["pageNumber"] ?? 0,
          "size": responseData["pageable"]?["pageSize"] ?? size,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load attendance: ${response.statusCode}",
          "content": [],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
        "content": [],
      };
    }
  }

  // Format the entry times into a readable format
  static String formatTime(String timeString) {
    if (timeString.isEmpty) return '';

    // Parse the time string in format "08:31:32"
    final parts = timeString.split(':');
    if (parts.length < 2) return timeString;

    int hour = int.tryParse(parts[0]) ?? 0;
    final minutes = parts[1];

    // Convert to 12-hour format
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    return '$hour:$minutes $period';
  }


}