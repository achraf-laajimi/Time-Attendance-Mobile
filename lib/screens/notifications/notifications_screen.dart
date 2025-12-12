import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/services/navigation_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/notification_item.dart';
import 'package:in_out/widget/responsive_navigation_scaffold.dart';
import 'package:in_out/widget/user_profile_header.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
import 'package:in_out/widget/translate_text.dart';

// Gardez la classe NotificationsService telle quelle
class NotificationsService {
  static final NotificationsService _instance = NotificationsService._internal();

  factory NotificationsService() => _instance;

  NotificationsService._internal();

  final List<NotificationModel> _notifications = [];

  List<NotificationModel> get notifications => List.unmodifiable(_notifications);

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  Future<void> initialize() async {
    _addSampleNotifications();
  }

  void addNotification(NotificationModel notification) {
    _notifications.add(notification);
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index >= 0) {
      final notification = _notifications[index];
      final updatedNotification = NotificationModel(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        avatarUrl: notification.avatarUrl,
        avatarInitials: notification.avatarInitials,
        avatarColor: notification.avatarColor,
        icon: notification.icon,
        iconBackgroundColor: notification.iconBackgroundColor,
        iconColor: notification.iconColor,
        isRead: true,
      );

      _notifications[index] = updatedNotification;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var i = 0; i < _notifications.length; i++) {
      final notification = _notifications[i];
      _notifications[i] = NotificationModel(
        id: notification.id,
        title: notification.title,
        message: notification.message,
        timestamp: notification.timestamp,
        avatarUrl: notification.avatarUrl,
        avatarInitials: notification.avatarInitials,
        avatarColor: notification.avatarColor,
        icon: notification.icon,
        iconBackgroundColor: notification.iconBackgroundColor,
        iconColor: notification.iconColor,
        isRead: true,
      );
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  final List<Function()> _listeners = [];

  void addListener(Function() listener) {
    _listeners.add(listener);
  }

  void removeListener(Function() listener) {
    _listeners.remove(listener);
  }

  void notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void _addSampleNotifications() {
    _notifications.addAll([
      NotificationModel(
        id: '1',
        title: 'Leave Request',
        message: '@Robert Fox has applied for leave',
        timestamp: DateTime.now(),
        avatarInitials: 'RF',
        avatarColor: Colors.blue.shade100,
      ),
      NotificationModel(
        id: '2',
        title: 'Check In Issue',
        message: '@Alexa shared a message regarding check in issue',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        avatarInitials: 'A',
        avatarColor: Colors.orange.shade100,
      ),
      NotificationModel(
        id: '3',
        title: 'Applied job for "Sales Manager" Position',
        message: '@Shane Watson has applied for job',
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        icon: Icons.person_outline,
        iconBackgroundColor: Colors.green.shade100,
        iconColor: Colors.green,
      ),
      NotificationModel(
        id: '4',
        title: 'Robert Fox has share his feedback',
        message: '"It was an amazing experience with your organization"',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        avatarInitials: 'RF',
        avatarColor: Colors.purple.shade100,
      ),
      NotificationModel(
        id: '5',
        title: 'Password Update successfully',
        message: 'Your password has been updated successfully',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        icon: Icons.lock_outline,
        iconBackgroundColor: Colors.green.shade100,
        iconColor: Colors.green,
      ),
    ]);
  }
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _selectedIndex = 0;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();
  final NotificationsService _notificationsService = NotificationsService();
  List<NotificationModel> _notifications = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _notificationsService.addListener(_updateNotifications);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    await _notificationsService.initialize();
    _updateNotifications();
  }

  void _updateNotifications() {
    setState(() {
      _notifications = _notificationsService.notifications;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _notificationsService.removeListener(_updateNotifications);
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark notification as read when tapped
    if (!notification.isRead) {
      _notificationsService.markAsRead(notification.id);
    }

    // Handle different notification types
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notification tapped: ${notification.title}'),
        backgroundColor: AdaptiveColors.primaryGreen,
      ),
    );
  }

  void _handleMarkAllAsRead() {
    _notificationsService.markAllAsRead();
  }

  Widget _buildPageHeader() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenWidth * 0.03,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TranslateText(
                "notifications",
                style: TextStyle(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                  color: AdaptiveColors.primaryTextColor(context),
                ),
              ),
              TranslateText(
                "allNotifications",
                style: TextStyle(
                  fontSize: screenWidth * 0.03,
                  color: AdaptiveColors.secondaryTextColor(context),
                ),
              ),
            ],
          ),
          if (_notifications.isNotEmpty && _notificationsService.unreadCount > 0)
            TextButton(
              onPressed: _handleMarkAllAsRead,
              style: TextButton.styleFrom(
                foregroundColor: AdaptiveColors.primaryGreen,
              ),
              child: Text(
                "Mark all as read",
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: screenWidth * 0.15,
            color: AdaptiveColors.isDarkMode(context)
                ? Colors.grey.shade600
                : Colors.grey.shade400,
          ),
          SizedBox(height: screenWidth * 0.04),
          TranslateText(
            "noNotifications",
            style: TextStyle(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: AdaptiveColors.primaryTextColor(context),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          TranslateText(
            "allCaughtUp",
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: (index) {
        NavigationService.navigateToScreen(context, index);
      },
      body: SafeArea(
        child: Column(
          children: [
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),

            // Content
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: _buildPageHeader(),
                  ),
                  SliverToBoxAdapter(
                    child: Divider(
                      color: AdaptiveColors.dividerColor(context),
                      height: 1,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final notification = _notifications[index];
                        return NotificationItem(
                          notification: notification,
                          onTap: () => _handleNotificationTap(notification),
                          onMarkAsRead: !notification.isRead
                              ? () => _notificationsService.markAsRead(notification.id)
                              : null,
                        );
                      },
                      childCount: _notifications.length,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}