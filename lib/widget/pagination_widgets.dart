import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';
import '../theme/adaptive_colors.dart';

class PaginationFooter extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int filteredEmployeesCount;
  final int itemsPerPage;
  final Function(int) onPageChanged;

  const PaginationFooter({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.filteredEmployeesCount,
    required this.itemsPerPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    // Calculate start and end of displayed items
    final start = filteredEmployeesCount == 0 ? 0 : ((currentPage - 1) * itemsPerPage) + 1;
    final end = (currentPage * itemsPerPage) > filteredEmployeesCount
        ? filteredEmployeesCount
        : (currentPage * itemsPerPage);

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: screenHeight * 0.018,
        horizontal: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AdaptiveColors.borderColor(context)),
        ),
      ),
      child: Column(
        children: [
          // First row: Records info
          Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.01),
            child: Text(
              '${localizations.getString('showing')} $start ${localizations.getString('to')} $end ${localizations.getString('outOf')} $filteredEmployeesCount ${localizations.getString('records')}',
              style: TextStyle(
                color: AdaptiveColors.secondaryTextColor(context),
                fontSize: screenHeight * 0.018,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Second row: Pagination controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPaginationButton(
                context,
                icon: Icons.chevron_left,
                onPressed: currentPage > 1
                    ? () => onPageChanged(currentPage - 1)
                    : null,
              ),
              ..._buildPageNumbers(context),
              _buildPaginationButton(
                context,
                icon: Icons.chevron_right,
                onPressed: currentPage < totalPages
                    ? () => onPageChanged(currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);
    
    // Reduce the number of visible pages for smaller screens
    final isSmallScreen = screenWidth < 600;
    final maxVisiblePages = isSmallScreen ? 3 : 5;
    
    List<Widget> pageNumbers = [];
    List<int> pagesToShow = [];

    // Logic for which page numbers to show
    if (totalPages <= maxVisiblePages) {
      // Show all pages if there are maxVisiblePages or fewer
      pagesToShow = List.generate(totalPages, (i) => i + 1);
    } else {
      // Show only current page and one on each side for small screens
      if (isSmallScreen) {
        pagesToShow.add(1);
        if (currentPage > 2 && currentPage < totalPages - 1) {
          pagesToShow.add(currentPage);
        }
        pagesToShow.add(totalPages);
        pagesToShow = pagesToShow.toSet().toList()..sort();
      } else {
        // Original logic for larger screens
        pagesToShow.add(1);
        for (int i = currentPage - 1; i <= currentPage + 1; i++) {
          if (i > 1 && i < totalPages) {
            pagesToShow.add(i);
          }
        }
        pagesToShow.add(totalPages);
        pagesToShow = pagesToShow.toSet().toList()..sort();
      }

      // Add ellipses as needed (only for larger screens)
      if (!isSmallScreen) {
        if (pagesToShow[0] + 1 != pagesToShow[1]) {
          pagesToShow.insert(1, -1);
        }
        if (pagesToShow[pagesToShow.length - 2] + 1 != pagesToShow[pagesToShow.length - 1]) {
          pagesToShow.insert(pagesToShow.length - 1, -1);
        }
      }
    }

    // Create the widgets with smaller sizes for small screens
    final buttonSize = isSmallScreen ? screenHeight * 0.035 : screenHeight * 0.045;
    final marginSize = isSmallScreen ? screenWidth * 0.002 : screenWidth * 0.004;
    
    for (int i = 0; i < pagesToShow.length; i++) {
      if (pagesToShow[i] == -1) {
        // Ellipsis (only show on larger screens)
        pageNumbers.add(
          Padding(
            padding: EdgeInsets.symmetric(horizontal: marginSize * 2),
            child: Text(
              localizations.getString('ellipsis'),
              style: TextStyle(
                color: AdaptiveColors.secondaryTextColor(context),
                fontSize: screenHeight * 0.02,
              ),
            ),
          ),
        );
      } else {
        // Page number
        pageNumbers.add(
          Container(
            margin: EdgeInsets.symmetric(horizontal: marginSize),
            child: InkWell(
              onTap: () => onPageChanged(pagesToShow[i]),
              child: Container(
                width: buttonSize,
                height: buttonSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: currentPage == pagesToShow[i]
                      ? const Color(0xFF2E7D32)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(screenWidth * 0.004),
                  border: Border.all(
                    color: currentPage == pagesToShow[i]
                        ? const Color(0xFF2E7D32)
                        : AdaptiveColors.borderColor(context),
                  ),
                ),
                child: Text(
                  '${pagesToShow[i]}',
                  style: TextStyle(
                    color: currentPage == pagesToShow[i]
                        ? Colors.white
                        : AdaptiveColors.primaryTextColor(context),
                    fontWeight: currentPage == pagesToShow[i] ? FontWeight.bold : FontWeight.normal,
                    fontSize: isSmallScreen ? screenHeight * 0.018 : screenHeight * 0.02,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return pageNumbers;
  }

  Widget _buildPaginationButton(BuildContext context, {required IconData icon, required VoidCallback? onPressed}) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // Responsive sizing
    final isSmallScreen = screenWidth < 600;
    final buttonSize = isSmallScreen ? screenHeight * 0.035 : screenHeight * 0.045;
    final marginSize = isSmallScreen ? screenWidth * 0.002 : screenWidth * 0.004;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: marginSize),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(screenWidth * 0.004),
            border: Border.all(
              color: AdaptiveColors.borderColor(context),
            ),
          ),
          child: Icon(
            icon,
            size: isSmallScreen ? screenHeight * 0.018 : screenHeight * 0.022,
            color: onPressed == null
                ? AdaptiveColors.tertiaryTextColor(context)
                : AdaptiveColors.primaryTextColor(context),
          ),
        ),
      ),
    );
  }
}