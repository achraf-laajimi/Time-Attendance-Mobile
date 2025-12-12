// lib/widget/bottom_navigation_bar.dart
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ic.dart';
import '../theme/adaptive_colors.dart';
import '../auth/role_helper.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  List<NavigationItem> _navigationItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNavigationItems();
  }

  Future<void> _loadNavigationItems() async {
    try {
      final items = await RoleHelper.getNavigationItems();
      if (mounted) {
        setState(() {
          _navigationItems = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading navigation items: $e');
      if (mounted) {
        setState(() {
          _navigationItems = RoleHelper.employeeNavItems;
          _isLoading = false;
        });
      }
    }
  }

  BottomNavigationBarItem _buildNavigationItem(NavigationItem item) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.06;
    final activeColor = AdaptiveColors.getPrimaryColor(context);
    final inactiveColor = AdaptiveColors.secondaryTextColor(context);

    String outlineIcon, filledIcon;

    switch (item.key) {
      case 'home':
        outlineIcon = Mdi.home_outline;
        filledIcon = Mdi.home;
        break;
      case 'employees':
        outlineIcon = Ic.outline_groups;
        filledIcon = Ic.baseline_groups;
        break;
      case 'vacation':
        outlineIcon = Mdi.umbrella_beach_outline;
        filledIcon = Mdi.umbrella_beach;
        break;
      case 'attendance':
        outlineIcon = Mdi.calendar_clock_outline;
        filledIcon = Mdi.calendar_clock;
        break;
      case 'profile':
        outlineIcon = Mdi.account_circle_outline;
        filledIcon = Mdi.account_circle;
        break;
      case 'departments':
        outlineIcon = Ic.outline_groups;
        filledIcon = Ic.baseline_groups;
        break;
      case 'holidays':
        outlineIcon = Mdi.calendar_star_outline;
        filledIcon = Mdi.calendar_star;
        break;
      case 'remote_attendance':
        outlineIcon = Mdi.remote;
        filledIcon = Mdi.remote;
        break;
      case 'settings':
        outlineIcon = Mdi.cog_outline;
        filledIcon = Mdi.cog;
        break;

      default:
        outlineIcon = Mdi.help_circle_outline;
        filledIcon = Mdi.help_circle;
    }

    return BottomNavigationBarItem(
      icon: Iconify(outlineIcon, size: iconSize, color: inactiveColor),
      activeIcon: Iconify(filledIcon, size: iconSize, color: activeColor),
      label: item.label.toLowerCase(),
      tooltip: item.label.toLowerCase(),
    );
  }

  int _getDisplayIndex(int originalIndex) {
    for (int i = 0; i < _navigationItems.length; i++) {
      if (_navigationItems[i].index == originalIndex) {
        return i;
      }
    }
    return 0;
  }

  int _getOriginalIndex(int displayIndex) {
    if (displayIndex < _navigationItems.length) {
      return _navigationItems[displayIndex].index;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        height: 60,
        color: AdaptiveColors.cardColor(context),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_navigationItems.isEmpty) {
      return const SizedBox.shrink();
    }
    final displayItems = _navigationItems.length > 5
        ? _navigationItems.take(10).toList()
        : _navigationItems;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AdaptiveColors.cardColor(context),
      selectedItemColor: AdaptiveColors.getPrimaryColor(context),
      unselectedItemColor: AdaptiveColors.secondaryTextColor(context),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: _getDisplayIndex(widget.selectedIndex),
      onTap: (displayIndex) {
        final originalIndex = _getOriginalIndex(displayIndex);
        widget.onItemTapped(originalIndex);
      },
      items: displayItems.map(_buildNavigationItem).toList(),
    );
  }
}
