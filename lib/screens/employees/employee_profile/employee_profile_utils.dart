import 'package:flutter/material.dart';

/// Utility class for employee profile related functions
class EmployeeProfileUtils {
  /// Parse time string in format "HH:MM:SS" to minutes since midnight
  static int parseTimeToMinutes(String timeString) {
    final parts = timeString.split(':');
    if (parts.length >= 2) {
      return int.parse(parts[0]) * 60 + int.parse(parts[1]);
    }
    return 0;
  }

  /// Get avatar color based on name
  static Color getAvatarColor(String name) {
    if (name.isEmpty) {
      return Colors.grey;
    }

    // List of pastel colors for avatars
    final colors = [
      Colors.blue.shade100,
      Colors.red.shade100,
      Colors.green.shade100,
      Colors.orange.shade100,
      Colors.purple.shade100,
      Colors.pink.shade100,
      Colors.teal.shade100,
    ];

    // Generate a consistent index based on the name
    int hashCode = name.hashCode;
    return colors[hashCode.abs() % colors.length];
  }

  /// Format time to AM/PM format
  static String formatTimeToAmPm(String timeString) {
    if (timeString.isEmpty) return '';

    try {
      final timeParts = timeString.split(':');
      final hour = int.parse(timeParts[0]);
      final minutes = timeParts[1];
      return '${hour > 12 ? hour - 12 : hour}:$minutes ${hour >= 12 ? 'PM' : 'AM'}';
    } catch (e) {
      return timeString;
    }
  }
}