import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:in_out/services/navigation_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/landscape_user_profile_header.dart';
import 'package:in_out/widget/responsive_navigation_scaffold.dart';
import 'package:in_out/widget/pagination_widgets.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import '../../services/attendance_service.dart';
import '../../localization/app_localizations.dart';
import '../../widget/attendance_search_filter_bar.dart';
import '../employees/employee_profile/employee_profile_screen.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late TextEditingController _searchController;
  int _selectedIndex = 3;
  final ScrollController _mainScrollController = ScrollController();
  bool _isHeaderVisible = true;

  // API pagination parameters
  int _currentPage = 0; // API uses 0-based indexing
  int _totalPages = 0;
  int _totalElements = 0;
  final int _itemsPerPage = 10;

  // Filter state
  String _searchQuery = '';
  DateTime _selectedDate = DateTime.now();

  // Data state
  List<Map<String, dynamic>> _attendances = [];
  bool _isLoading = true;
  String _errorMessage = '';

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _searchQuery);
    _searchController.addListener(() {
      if (_searchController.text != _searchQuery) {
        setState(() {
          _searchQuery = _searchController.text;
          _currentPage = 0; // Reset to first page on search
        });
        _fetchAttendanceData();
      }
    });
    _mainScrollController.addListener(_scrollListener);

    // Set landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
    ]);

    // Fetch initial data
    _fetchAttendanceData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mainScrollController.removeListener(_scrollListener);
    _mainScrollController.dispose();

    // Reset orientation preferences
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _mainScrollController.offset <= 50;
    });
  }

  // Fetch attendance data from API
  Future<void> _fetchAttendanceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Format date to YYYY-MM-DD
      final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

      final result = await AttendanceService.getDailyAttendance(
        date: formattedDate,
        page: _currentPage,
        size: _itemsPerPage,
      );

      if (result["success"]) {
        List<Map<String, dynamic>> processedAttendances = [];

        for (var attendance in result["content"]) {
          // Extract employee name from attributes
          String employeeName = 'Unknown';
          if (attendance['attributes'] != null) {
            final firstName = attendance['attributes']['firstName'] ?? '';
            final lastName = attendance['attributes']['lastName'] ?? '';
            employeeName = '$firstName $lastName'.trim();

            if (employeeName.isEmpty) {
              employeeName = 'User ID: ${attendance['userId']}';
            }
          } else {
            employeeName = 'User ID: ${attendance['userId']}';
          }

          // Build a map of processed attendance data
          final Map<String, dynamic> processedAttendance = {
            'id': attendance['id']?.toString() ?? '',
            'employeeName': employeeName,
            'userId': attendance['userId']?.toString() ?? '',
            'type': attendance['type'] ?? '',
            'designation': attendance['attributes']?['designation'] ?? '',
            'date': attendance['date'] ?? '',
            'isLate': attendance['late'] == true,
            'status': attendance['late'] == true ? 'Late' : 'On Time',
            'entries': attendance['entries'] ?? [],
            // Extract up to 4 check-in/check-out times
            'checkInTime1': attendance['entries']?.length > 0 ? attendance['entries'][0] : '',
            'checkInTime2': attendance['entries']?.length > 1 ? attendance['entries'][1] : '',
            'checkInTime3': attendance['entries']?.length > 2 ? attendance['entries'][2] : '',
            'checkInTime4': attendance['entries']?.length > 3 ? attendance['entries'][3] : '',
            'complete': attendance['complete'] == true,
            'impaired': attendance['impaired'] == true,
            'initials': _getInitials(employeeName),
          };

          // Only add to the list if it matches search criteria
          if (_searchQuery.isEmpty ||
              employeeName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              processedAttendance['designation'].toString().toLowerCase().contains(_searchQuery.toLowerCase())) {
            processedAttendances.add(processedAttendance);
          }
        }

        setState(() {
          _attendances = processedAttendances;
          _totalElements = result["totalElements"];
          _totalPages = result["totalPages"];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result["message"];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error: $e";
        _isLoading = false;
      });
    }
  }

  // Get initials from name for avatar
  String _getInitials(String name) {
    if (name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0];
    } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
      return nameParts[0][0];
    }

    return '';
  }

  // Show date picker for filtering
  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)), // Allow future dates for planning
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _currentPage = 0; // Reset to first page on date change
      });
      _fetchAttendanceData();
    }
  }

  // Show filter dialog with date option
  void _showFilterDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // We use a StatefulBuilder to be able to update the date inside the dialog
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text(localizations.getString('filter')),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.getString('filterByDate'),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Display current selected date in the requested format
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('yyyy-MM-dd').format(_selectedDate),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Button to change date
                    Center(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.edit_calendar),
                        label: Text(localizations.getString('selectDate')),
                        onPressed: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );

                          if (picked != null && context.mounted) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(localizations.getString('cancel')),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _currentPage = 0; // Reset to first page on filter change
                      _fetchAttendanceData();
                    },
                    child: Text(localizations.getString('apply')),
                  ),
                ],
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final localizations = AppLocalizations.of(context);

    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
            // User profile header
            LandscapeUserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {},
            ),

            // Custom search and filter bar for attendance with refresh button
            AttendanceSearchFilterBar(
              searchController: _searchController,
              onSearchChanged: (value) {
                // Search is handled via listener in initState
              },
              onFilterTap: (context) => _showFilterDialog(context),
              selectedDate: _selectedDate,
              onRefresh: _fetchAttendanceData,
            ),

            // Main content
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(
                  screenWidth * 0.015,
                  0,
                  screenWidth * 0.015,
                  screenWidth * 0.015,
                ),
                decoration: BoxDecoration(
                  color: AdaptiveColors.cardColor(context),
                  borderRadius: BorderRadius.circular(screenWidth * 0.008),
                  boxShadow: [
                    BoxShadow(
                      color: AdaptiveColors.shadowColor(context),
                      spreadRadius: screenWidth * 0.001,
                      blurRadius: screenWidth * 0.003,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build the appropriate content based on state
  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

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
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchAttendanceData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Attendance table
        Expanded(
          child: TwoDimensionalAttendanceTable(
            attendances: _attendances,
            onViewAttendance: (userId) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeProfileScreen(
                    employeeId: int.parse(userId),
                    initialTabIndex: 1,
                  ),
                ),
              );
            },
          ),
        ),

        // Pagination footer
        PaginationFooter(
          currentPage: _currentPage + 1, // Display is 1-indexed but API is 0-indexed
          totalPages: _totalPages > 0 ? _totalPages : 1,
          filteredEmployeesCount: _totalElements,
          itemsPerPage: _itemsPerPage,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page - 1; // Convert from 1-indexed to 0-indexed
            });
            _fetchAttendanceData();
          },
        ),
      ],
    );
  }
}

class TwoDimensionalAttendanceTable extends StatelessWidget {
  final List<Map<String, dynamic>> attendances;
  final Function(String userId) onViewAttendance;

  const TwoDimensionalAttendanceTable({
    super.key,
    required this.attendances,
    required this.onViewAttendance,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    // If no attendances found
    if (attendances.isEmpty) {
      return SizedBox(
        height: screenHeight * 0.5,
        child: Center(
          child: Text(
            localizations.getString('noAttendanceRecords'),
            style: TextStyle(
              fontSize: 16,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
          ),
        ),
      );
    }

    // Column headers
    final headerTitles = [
      localizations.getString('employeeName'),
      localizations.getString('designation'),
      localizations.getString('type'),
      'Check-In 1',   // Using direct strings since these aren't in localization yet
      'Check-Out 1',
      'Check-In 2',
      'Check-Out 2',
      localizations.getString('status'),
      localizations.getString('actions')
    ];

    return TableView.builder(
      // Table configuration
      rowCount: attendances.length + 1, // +1 for header
      columnCount: headerTitles.length,

      // Cell builder
      cellBuilder: (context, vicinity) {
        return TableViewCell(
          child: _buildCellWidget(context, vicinity, headerTitles),
        );
      },

      // Column widths
      columnBuilder: (index) {
        double width;
        switch (index) {
          case 0: // Employee name
            width = screenWidth * 0.20;
            break;
          case 1: // Designation
            width = screenWidth * 0.15;
            break;
          case 2: // Type
            width = screenWidth * 0.10;
            break;
          case 3: // Check-In 1
          case 4: // Check-Out 1
          case 5: // Check-In 2
          case 6: // Check-Out 2
            width = screenWidth * 0.10;
            break;
          case 7: // Status
            width = screenWidth * 0.10;
            break;
          case 8: // Action
            width = screenWidth * 0.08;
            break;
          default:
            width = screenWidth * 0.10;
        }
        return TableSpan(
          extent: FixedTableSpanExtent(width),
        );
      },
      rowBuilder: (index) {
        double height = index == 0
            ? screenHeight * 0.08
            : screenHeight * 0.09;
        return TableSpan(
          extent: FixedTableSpanExtent(height),
        );
      },

      pinnedRowCount: 1,
      pinnedColumnCount: 1,
    );
  }

  Widget _buildCellWidget(
      BuildContext context, TableVicinity vicinity, List<String> headerTitles) {
    final row = vicinity.row;
    final column = vicinity.column;
    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    final localizations = AppLocalizations.of(context);

    // Header row
    if (row == 0) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.015,
          vertical: screenHeight * 0.02,
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
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: screenHeight * 0.025,
          ),
        ),
      );
    }

    final attendanceIndex = row - 1;
    final attendance = attendances[attendanceIndex];
    if (column == 0) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
            right: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: screenHeight * 0.028,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                attendance['initials'] ?? '',
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.02,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Text(
                attendance['employeeName'],
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: screenHeight * 0.022,
                  color: AdaptiveColors.primaryTextColor(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }
    if (column == 7) {
      final bool isLate = attendance['isLate'] == true;
      final Color statusColor = isLate ? Colors.red : Colors.green;
      final String status = isLate
          ? localizations.getString("late")
          : localizations.getString("onTime");

      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
            right: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.01,
            vertical: screenHeight * 0.005,
          ),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.01),
          ),
          child: Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: screenHeight * 0.018,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (column == 8) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Center(
          child: IconButton(
            icon: Icon(
              Icons.visibility_outlined,
              color: AdaptiveColors.secondaryTextColor(context),
              size: screenHeight * 0.03,
            ),
            onPressed: () {
              onViewAttendance(attendance['userId']);
            },
          ),
        ),
      );
    }
    String cellText = '';
    switch (column) {
      case 1: // Designation
        cellText = attendance['designation'] ?? '';
        break;
      case 2: // Type
        cellText = attendance['type'] ?? '';
        break;
      case 3: // Check-In 1
        cellText = attendance['entries']?.length > 0
            ? AttendanceService.formatTime(attendance['entries'][0])
            : '';
        break;
      case 4: // Check-Out 1
        cellText = attendance['entries']?.length > 1
            ? AttendanceService.formatTime(attendance['entries'][1])
            : '';
        break;
      case 5: // Check-In 2
        cellText = attendance['entries']?.length > 2
            ? AttendanceService.formatTime(attendance['entries'][2])
            : '';
        break;
      case 6: // Check-Out 2
        cellText = attendance['entries']?.length > 3
            ? AttendanceService.formatTime(attendance['entries'][3])
            : '';
        break;
    }

    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.015,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
          right: column < 8 ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
        ),
      ),
      child: Text(
        cellText,
        style: TextStyle(
          color: AdaptiveColors.primaryTextColor(context),
          fontSize: screenHeight * 0.022,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}