import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ic.dart';
import '../theme/adaptive_colors.dart';
import '../auth/role_helper.dart';

class CustomSideNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomSideNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomSideNavigationBar> createState() => _CustomSideNavigationBarState();
}

class _CustomSideNavigationBarState extends State<CustomSideNavigationBar> {
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

  Widget _buildNavItem(NavigationItem item, double iconSize) {
    final isSelected = widget.selectedIndex == item.index;
    final color = isSelected
        ? AdaptiveColors.primaryGreen
        : AdaptiveColors.secondaryTextColor(context);

    // More aggressive spacing reduction for landscape mode
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    
    double verticalPadding;
    if (isLandscape) {
      // In landscape, use minimal padding to fit more items
      verticalPadding = _navigationItems.length > 8 
          ? MediaQuery.of(context).size.height * 0.005 
          : MediaQuery.of(context).size.height * 0.008;
    } else {
      // In portrait, use normal spacing
      verticalPadding = _navigationItems.length > 6 
          ? MediaQuery.of(context).size.height * 0.01 
          : MediaQuery.of(context).size.height * 0.02;
    }

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

    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Container(
        decoration: BoxDecoration(
          border: isSelected
              ? Border(
              left: BorderSide(
                color: AdaptiveColors.primaryGreen,
                width: MediaQuery.of(context).size.width * 0.003,
              ))
              : null,
        ),
        child: IconButton(
          icon: Iconify(
            isSelected ? filledIcon : outlineIcon,
            size: iconSize,
            color: color,
          ),
          onPressed: () => widget.onItemTapped(item.index),
          tooltip: item.label,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final iconSize = screenHeight * 0.05;

    if (_isLoading) {
      return Container(
        width: screenWidth * 0.06,
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          border: Border(
            right: BorderSide(
              color: AdaptiveColors.borderColor(context),
              width: 1,
            ),
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return Container(
      width: screenWidth * 0.06,
      decoration: BoxDecoration(
        color: AdaptiveColors.cardColor(context),
        border: Border(
          right: BorderSide(
            color: AdaptiveColors.borderColor(context),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AdaptiveColors.shadowColor(context),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final orientation = MediaQuery.of(context).orientation;
          final isLandscape = orientation == Orientation.landscape;
          
          // Calculate if we need scrolling - be more aggressive in landscape
          final estimatedItemHeight = isLandscape 
              ? iconSize + (screenHeight * 0.016) // Reduced spacing for landscape
              : iconSize + (screenHeight * 0.04);  // Normal spacing for portrait
              
          final totalItemHeight = _navigationItems.length * estimatedItemHeight;
          final needsScrolling = totalItemHeight > constraints.maxHeight;
          
          // In landscape mode, always use scrolling if more than 5 items
          final forceScrollingInLandscape = isLandscape && _navigationItems.length > 5;
          
          if (needsScrolling || forceScrollingInLandscape) {
            // Use scrollable list for many items
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                vertical: isLandscape 
                    ? screenHeight * 0.01  // Minimal padding in landscape
                    : screenHeight * 0.02  // Normal padding in portrait
              ),
              child: Column(
                children: _navigationItems
                    .map((item) => _buildNavItem(item, iconSize))
                    .toList(),
              ),
            );
          } else {
            // Use centered layout for few items
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _navigationItems
                  .map((item) => _buildNavItem(item, iconSize))
                  .toList(),
            );
          }
        },
      ),
    );
  }
}