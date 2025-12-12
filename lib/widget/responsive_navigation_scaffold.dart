// lib/widget/responsive_navigation_scaffold.dart
import 'package:flutter/material.dart';
import '../theme/adaptive_colors.dart';
import 'custom_side_navigation_bar.dart';
import 'bottom_navigation_bar.dart';

class ResponsiveNavigationScaffold extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const ResponsiveNavigationScaffold({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      appBar: appBar,
      body: isLandscape
          ? Row(
        children: [
          CustomSideNavigationBar(
            selectedIndex: selectedIndex,
            onItemTapped: onItemTapped,
          ),
          Expanded(child: body),
        ],
      )
          : body,
      bottomNavigationBar: isLandscape
          ? null
          : (bottomNavigationBar ?? CustomBottomNavigationBar(
        selectedIndex: selectedIndex,
        onItemTapped: onItemTapped,
      )),
    );
  }
}