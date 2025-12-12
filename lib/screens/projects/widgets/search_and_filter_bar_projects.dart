import 'package:flutter/material.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/localization/app_localizations.dart';

class SearchAndFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final Function(String) onSearchChanged;
  final VoidCallback? onAddNewProject;
  final Function(BuildContext) onFilterTap;

  const SearchAndFilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    this.onAddNewProject,
    required this.onFilterTap,
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
          Expanded(
            flex: 2,
            child: Container(
              height: screenHeight * 0.065, // Reduced height
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
                  fontSize: screenHeight * 0.022, // Consistent font size
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
                    vertical: screenHeight * 0.018, // Center text vertically
                  ),
                  isDense: true, // Makes the field more compact
                ),
                textAlignVertical: TextAlignVertical.center, // Center text vertically
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.015),
          if (onAddNewProject != null) ...[
            ElevatedButton.icon(
              onPressed: onAddNewProject,
              icon: Icon(Icons.add, color: Colors.white, size: screenHeight * 0.025),
              label: Text(
                  localizations.getString('addNewProject'),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenHeight * 0.022,
                  )
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.015,
                  vertical: screenHeight * 0.018,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.006),
                ),
                minimumSize: Size(0, screenHeight * 0.065),
              ),
            ),
            SizedBox(width: screenWidth * 0.015),
          ],
          SizedBox(width: screenWidth * 0.015),
          // Changed from DropdownButton to a regular Container with InkWell
          InkWell(
            onTap: () => onFilterTap(context), // Pass the context to the onFilterTap function
            child: Container(
              height: screenHeight * 0.065, // Match search field height
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
                    localizations.getString('filter'),
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