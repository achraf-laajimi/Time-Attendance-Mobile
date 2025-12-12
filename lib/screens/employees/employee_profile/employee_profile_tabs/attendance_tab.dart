import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/services/attendance_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/pagination_widgets.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class AttendanceTab extends StatefulWidget {
  final String employeeId;

  const AttendanceTab({
    super.key,
    required this.employeeId,
  });

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  List<Map<String, dynamic>> _attendances = [];
  bool _isLoading = true;
  String _errorMessage = '';

  // Pagination variables
  int _currentPage = 0;
  int _pageSize = 10;
  int _totalElements = 0;
  int _totalPages = 1;

  // Year filter
  int? _selectedYear;
  List<int> _availableYears = [];
  bool _isLoadingYears = true;

  @override
  void initState() {
    super.initState();
    _loadAvailableYears();
  }

  Future<void> _loadAvailableYears() async {
    if (widget.employeeId.isEmpty || widget.employeeId == 'N/A') {
      setState(() {
        _errorMessage = 'Invalid employee ID';
        _isLoading = false;
        _isLoadingYears = false;
      });
      return;
    }

    try {
      final years = await AttendanceService.getAvailableYears(widget.employeeId);

      setState(() {
        _availableYears = years;
        _selectedYear = years.isNotEmpty ? years.first : DateTime.now().year;
        _isLoadingYears = false;
      });

      // Load attendance data after setting year
      _loadAttendanceData();
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading available years: $e";
        _isLoading = false;
        _isLoadingYears = false;
      });
    }
  }

  Future<void> _loadAttendanceData() async {
    if (widget.employeeId.isEmpty || widget.employeeId == 'N/A') {
      setState(() {
        _errorMessage = 'Invalid employee ID';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await AttendanceService.getEmployeeAttendance(
        widget.employeeId,
        page: _currentPage,
        size: _pageSize,
        year: _selectedYear,
      );
      setState(() {
        if (result["success"]) {
          _attendances = result["attendances"];
          _totalElements = result["totalElements"] ?? 0;
          _totalPages = result["totalPages"] ?? 1;
          _currentPage = result["currentPage"] ?? 0;
          _pageSize = result["pageSize"] ?? _pageSize;
        } else {
          _errorMessage = result["message"];
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Error loading attendance: $e";
        _isLoading = false;
      });
    }
  }
  void _changeYear(int? year) {
    if (year != null && year != _selectedYear) {
      setState(() {
        _selectedYear = year;
        _currentPage = 0;
      });
      _loadAttendanceData();
    }
  }

  void _changePage(int page) {
    final apiPage = page - 1;
    if (apiPage != _currentPage) {
      setState(() {
        _currentPage = apiPage;
      });
      _loadAttendanceData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (_isLoadingYears) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Year: ',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AdaptiveColors.primaryTextColor(context),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AdaptiveColors.borderColor(context)),
                  borderRadius: BorderRadius.circular(4),
                  color: AdaptiveColors.cardColor(context),
                ),
                child: DropdownButton<int>(
                  value: _selectedYear,
                  underline: Container(),
                  items: _availableYears.map((int year) {
                    return DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    );
                  }).toList(),
                  onChanged: _changeYear,
                  hint: const Text('Select Year'),
                  style: TextStyle(
                    color: AdaptiveColors.primaryTextColor(context),
                    fontSize: 14,
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh attendance data',
                onPressed: _loadAttendanceData,
                color: AdaptiveColors.primaryGreen,
              ),
            ],
          ),
        ),

        Expanded(
          child: _buildContent(localizations),
        ),

        // Pagination controls
        if (!_isLoading && _errorMessage.isEmpty && _attendances.isNotEmpty)
          PaginationFooter(
            currentPage: _currentPage + 1,
            totalPages: _totalPages,
            filteredEmployeesCount: _totalElements,
            itemsPerPage: _pageSize,
            onPageChanged: _changePage,
          ),
      ],
    );
  }

  Widget _buildContent(AppLocalizations localizations) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading attendance data...',
              style: TextStyle(
                color: AdaptiveColors.secondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    // Show error if any
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $_errorMessage',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAttendanceData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_attendances.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 48,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
            const SizedBox(height: 16),
            Text(
              'No attendance records found for $_selectedYear',
              style: TextStyle(
                fontSize: 16,
                color: AdaptiveColors.secondaryTextColor(context),
              ),
            ),
          ],
        ),
      );
    }

    final headerTitles = [
      'Date',
      'Check 1',
      'Check 2',
      'Check 3',
      'Check 4',
      'Breaks',
      'Work Hours',
      'Status'
    ];

    return TableView.builder(
      // Main configuration
      rowCount: _attendances.length + 1,
      columnCount: headerTitles.length,

      // Cell builder
      cellBuilder: (context, vicinity) {
        return TableViewCell(
          child: _buildCellWidget(context, vicinity, headerTitles),
        );
      },

      columnBuilder: (index) {
        double width;
        switch (index) {
          case 0:
            width = 120;
            break;
          case 1:
          case 2:
          case 3:
          case 4:
            width = 100;
            break;
          case 5:
            width = 80;
            break;
          case 6:
            width = 100;
            break;
          case 7:
            width = 80;
            break;
          default:
            width = 100;
        }
        return TableSpan(
          extent: FixedTableSpanExtent(width),
        );
      },

      rowBuilder: (index) {
        // Fixed row heights
        double height = index == 0
            ? 50 // Header row height
            : 60; // Data rows height
        return TableSpan(
          extent: FixedTableSpanExtent(height),
        );
      },

      pinnedRowCount: 1,
      pinnedColumnCount: 1,
    );
  }

  Widget _buildCellWidget(BuildContext context, TableVicinity vicinity, List<String> headerTitles) {
    final row = vicinity.row;
    final column = vicinity.column;
    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;

    // Header row
    if (row == 0) {
      return Container(
        alignment: Alignment.center, // Center align headers
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
            right: column > 0 ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
          ),
        ),
        child: Text(
          headerTitles[column],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Data rows
    final attendance = _attendances[row - 1];
    String cellText = '';
    bool isStatus = false;
    bool isLate = false;

    switch (column) {
      case 0: // Date
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: borderColor, width: 0.5),
              right: BorderSide(color: borderColor, width: 0.5),
            ),
          ),
          child: Center(
            child: Text(
              attendance['date'] ?? '',
              style: TextStyle(
                color: AdaptiveColors.primaryTextColor(context),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      case 1: // Check 1
        cellText = attendance['check1'] ?? '';
        break;
      case 2: // Check 2
        cellText = attendance['check2'] ?? '';
        break;
      case 3: // Check 3
        cellText = attendance['check3'] ?? '';
        break;
      case 4: // Check 4
        cellText = attendance['check4'] ?? '';
        break;
      case 5: // Breaks
        cellText = attendance['break'] ?? '';
        break;
      case 6: // Working Hours
        cellText = attendance['workingHours'] ?? '';
        break;
      case 7: // Status
        isStatus = true;
        isLate = attendance['isLate'] == true;
        cellText = isLate ? "Late" : "On Time";
        break;
    }

    // Status column with special styling
    if (isStatus) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isLate
              ? Colors.red.withOpacity(0.1)
              : Colors.green.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(color: borderColor, width: 0.5),
            right: BorderSide(color: borderColor, width: 0.5),
          ),
        ),
        child: Center(
          child: Text(
            cellText,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isLate ? Colors.red : Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    // Regular data cell
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 0.5),
          right: BorderSide(color: borderColor, width: 0.5),
        ),
      ),
      child: Text(
        cellText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AdaptiveColors.primaryTextColor(context),
          fontSize: 14,
        ),
      ),
    );
  }
}