import 'package:flutter/material.dart';
import 'package:in_out/auth/auth_service.dart'; // Add this import
import 'package:in_out/screens/notifications/notifications_screen.dart';
import 'package:in_out/widget/translate_text.dart';
import '../theme/adaptive_colors.dart';
import '../localization/app_localizations.dart';

class LandscapeUserProfileHeader extends StatefulWidget {
  final bool isHeaderVisible;
  final VoidCallback? onNotificationTap;
  final int? unreadNotificationsCount;

  const LandscapeUserProfileHeader({
    super.key,
    required this.isHeaderVisible,
    this.onNotificationTap,
    this.unreadNotificationsCount,
  });

  @override
  State<LandscapeUserProfileHeader> createState() => _LandscapeUserProfileHeaderState();
}

class _LandscapeUserProfileHeaderState extends State<LandscapeUserProfileHeader> {
  String _fullName = '';
  String _role = '';

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    final userDetails = await AuthService.getUserDetails();
    setState(() {
      _fullName = '${userDetails['firstName']} ${userDetails['lastName']}'.trim();
      _role = userDetails['role'] ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final avatarSize = screenHeight * 0.035;
    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final localizations = AppLocalizations.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: widget.isHeaderVisible ? null : 0,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: screenHeight * 0.02,
          horizontal: screenWidth * 0.015,
        ),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          boxShadow: widget.isHeaderVisible
              ? []
              : [
            BoxShadow(
              color: AdaptiveColors.shadowColor(context),
              spreadRadius: screenWidth * 0.001,
              blurRadius: screenWidth * 0.003,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: avatarSize,
              backgroundColor: const Color(0xFFFFD6EC),
              child: Text(
                _fullName.isNotEmpty
                    ? _fullName.split(' ').map((e) => e[0]).take(2).join('')
                    : "RA",
                style: TextStyle(
                  color: const Color(0xFFD355A8),
                  fontWeight: FontWeight.bold,
                  fontSize: avatarSize * 0.7,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fullName.isNotEmpty ? _fullName : localizations.getString("robertAllen"),
                    style: TextStyle(
                      fontSize: screenHeight * 0.025,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  TranslateText(
                    _role.isNotEmpty
                        ? _role.toLowerCase().replaceAll('_', ' ')
                        : "juniorFullStackDeveloper",
                    style: TextStyle(
                      fontSize: screenHeight * 0.021,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: widget.onNotificationTap ??
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const NotificationsScreen()),
                    );
                  },
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.008),
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? const Color(0xFF1E4620)
                      : const Color(0xFFE5F5E5),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Stack(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: AdaptiveColors.primaryGreen,
                      size: screenHeight * 0.032,
                    ),
                    if (widget.unreadNotificationsCount != null &&
                        widget.unreadNotificationsCount! > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(screenWidth * 0.005),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            widget.unreadNotificationsCount.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.01,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}