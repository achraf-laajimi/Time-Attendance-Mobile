import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/user_settings_provider.dart';

class AdaptiveColors {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // Get the primary color consistently using UserSettingsProvider
  static Color getPrimaryColor(BuildContext context) {
    try {
      final userSettings = Provider.of<UserSettingsProvider>(context, listen: false).currentSettings;
      return userSettings.primaryColor;
    } catch (e) {
      // Fallback to default if provider isn't available
      return const Color(0xFF2E7D32); // Default green color
    }
  }

  // Get secondary color consistently using UserSettingsProvider
  static Color getSecondaryColor(BuildContext context) {
    try {
      final userSettings = Provider.of<UserSettingsProvider>(context, listen: false).currentSettings;
      return userSettings.secondaryColor;
    } catch (e) {
      return const Color(0xFFFF7240); // Default orange color
    }
  }

  // Legacy method for compatibility
  static const Color primaryGreen = Color(0xFF2E7D32);

  // Update these colors to use the dynamic theme colors
  static Color presentColor(BuildContext context) => getPrimaryColor(context);
  static Color absentColor(BuildContext context) => const Color(0xFFF44336);
  static Color onTimeColor(BuildContext context) => getPrimaryColor(context);
  static Color lateColor(BuildContext context) => const Color(0xFFF44336);

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color darkBorderColor = Color(0xFF333333);

  // Light mode colors
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightCardColor = Colors.white;
  static const Color lightBorderColor = Color(0xFFE0E0E0);

  // Dynamic colors based on theme
  static Color cardColor(BuildContext context) {
    return isDarkMode(context) ? darkCardColor : lightCardColor;
  }

  static Color backgroundColor(BuildContext context) {
    return isDarkMode(context) ? darkBackground : lightBackground;
  }

  static Color primaryTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.white : Colors.black87;
  }

  static Color secondaryTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade400 : Colors.grey.shade600;
  }

  static Color tertiaryTextColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade600 : Colors.grey.shade400;
  }

  static Color borderColor(BuildContext context) {
    return isDarkMode(context) ? darkBorderColor : lightBorderColor;
  }

  static Color shadowColor(BuildContext context) {
    return isDarkMode(context)
        ? Colors.black.withOpacity(0.3)
        : Colors.grey.withOpacity(0.1);
  }

  static Color chartGridColor(BuildContext context) {
    return isDarkMode(context) ? darkBorderColor : lightBorderColor;
  }

  // Use the primary color for accent elements
  static Color accentColor(BuildContext context) {
    return getPrimaryColor(context);
  }

  // Use secondary color for specific highlights
  static Color highlightColor(BuildContext context) {
    return getSecondaryColor(context);
  }

  static Color dropdownBackgroundColor(BuildContext context) {
    return isDarkMode(context) ? const Color(0xFF262626) : Colors.white;
  }

  static Color statusColor(bool isOnTime, BuildContext context) {
    return isOnTime ? onTimeColor(context) : lateColor(context);
  }

  static Color positiveIndicatorColor(BuildContext context) {
    return getPrimaryColor(context);
  }

  static Color negativeIndicatorColor(BuildContext context) {
    return const Color(0xFFF44336);
  }

  static Color buttonColor(BuildContext context) {
    return getPrimaryColor(context);
  }

  static Color dividerColor(BuildContext context) {
    return isDarkMode(context) ? Colors.grey.shade800 : Colors.grey.shade200;
  }

  // Return consistent themed decorations
  static BoxDecoration cardBoxDecoration(BuildContext context) {
    return BoxDecoration(
      color: cardColor(context),
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: shadowColor(context),
          spreadRadius: 1,
          blurRadius: 3,
          offset: const Offset(0, 1),
        ),
      ],
    );
  }

  // Button styles using primary color
  static ButtonStyle primaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: getPrimaryColor(context),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // Secondary button style using secondary color
  static ButtonStyle secondaryButtonStyle(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: getSecondaryColor(context),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}