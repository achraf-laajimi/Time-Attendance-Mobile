import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../localization/app_localizations.dart';
import '../theme/adaptive_colors.dart';

class AttendanceSearchFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final Function(BuildContext) onFilterTap;
  final DateTime selectedDate;
  final VoidCallback onRefresh;

  const AttendanceSearchFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onFilterTap,
    required this.selectedDate,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.015),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Search field
          Expanded(
            flex: 2,
            child: Container(
              height: screenHeight * 0.065,
              decoration: BoxDecoration(
                color: AdaptiveColors.cardColor(context),
                borderRadius: BorderRadius.circular(screenWidth * 0.006),
                border: Border.all(color: AdaptiveColors.borderColor(context)),
              ),
              child: TextField(
                controller: searchController,
                onChanged: onSearchChanged,
                style: TextStyle(
                  color: AdaptiveColors.primaryTextColor(context),
                  fontSize: screenHeight * 0.022,
                ),
                decoration: InputDecoration(
                  hintText: localizations.getString('search'),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                      Icons.search,
                      color: AdaptiveColors.secondaryTextColor(context),
                      size: screenHeight * 0.028
                  ),
                  hintStyle: TextStyle(
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.018,
                  ),
                  isDense: true,
                ),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.015),

          // Filter button with date info
          InkWell(
            onTap: () => onFilterTap(context),
            child: Container(
              height: screenHeight * 0.065,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
                vertical: screenHeight * 0.01,
              ),
              decoration: BoxDecoration(
                color: AdaptiveColors.cardColor(context),
                borderRadius: BorderRadius.circular(screenWidth * 0.006),
                border: Border.all(color: AdaptiveColors.borderColor(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: screenHeight * 0.025,
                    color: AdaptiveColors.primaryTextColor(context),
                  ),
                  SizedBox(width: screenWidth * 0.008),
                  Text(
                    DateFormat('yyyy-MM-dd').format(selectedDate),
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      color: AdaptiveColors.primaryTextColor(context),
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