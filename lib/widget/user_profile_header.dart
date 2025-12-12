import 'package:flutter/material.dart';
import 'package:in_out/widget/translate_text.dart';
import 'package:in_out/screens/notifications/notifications_screen.dart';
import '../auth/auth_service.dart';
import '../theme/adaptive_colors.dart';

class UserProfileHeader extends StatefulWidget {
  final bool isHeaderVisible;
  final VoidCallback? onNotificationTap;
  final int? unreadNotificationsCount;

  const UserProfileHeader({
    super.key,
    required this.isHeaderVisible,
    this.onNotificationTap,
    this.unreadNotificationsCount,
  });

  @override
  State<UserProfileHeader> createState() => _UserProfileHeaderState();
}

class _UserProfileHeaderState extends State<UserProfileHeader> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth * 0.06;
    final isDarkMode = AdaptiveColors.isDarkMode(context);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenWidth * 0.04,
        horizontal: screenWidth * 0.04,
      ),
      decoration: BoxDecoration(
        color: AdaptiveColors.cardColor(context),
        boxShadow: widget.isHeaderVisible
            ? []
            : [
          BoxShadow(
            color: AdaptiveColors.shadowColor(context),
            spreadRadius: 1,
            blurRadius: 3,
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
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _fullName.isNotEmpty ? _fullName : "Robert Allen",
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
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
                    fontSize: screenWidth * 0.03,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: widget.onNotificationTap ?? () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsScreen()),
              );
            },
            child: Container(
              padding: EdgeInsets.all(screenWidth * 0.02),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? const Color(0xFF1E4620) // Version sombre du vert clair
                    : const Color(0xFFE5F5E5),
                borderRadius: BorderRadius.circular(screenWidth * 0.06),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_outlined,
                    color: AdaptiveColors.primaryGreen,
                    size: screenWidth * 0.05,
                  ),
                  if (widget.unreadNotificationsCount != null && widget.unreadNotificationsCount! > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: EdgeInsets.all(screenWidth * 0.01),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          widget.unreadNotificationsCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.02,
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
    );
  }
}