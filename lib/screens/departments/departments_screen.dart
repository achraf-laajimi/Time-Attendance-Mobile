import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:in_out/screens/departments/department_detail_screen.dart';
import 'package:in_out/screens/notifications/notifications_screen.dart';
import 'package:in_out/services/navigation_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/responsive_navigation_scaffold.dart';
import 'package:in_out/widget/user_profile_header.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
import 'package:in_out/auth/global.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/screens/departments/add_department_screen.dart';


class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({super.key});

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  int _selectedIndex = 5;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();
  late TextEditingController _searchController;
  String _searchQuery = '';

  // State variables for departments
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    _scrollController.addListener(_scrollListener);


    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/department"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> departments = [];

        for (var dept in data) {
          Map<String, dynamic> department = {
            'id': dept['id'],
            'name': dept['name'],
            'key': dept['key'],
            'attributes': dept['attributes'] ?? {},
            'members': (dept['attributes'] != null && dept['attributes']['users'] != null)
                ? dept['attributes']['users'].length
                : 0,
            'employees': dept['attributes'] != null && dept['attributes']['users'] != null
                ? dept['attributes']['users'].map<Map<String, dynamic>>((user) => {
              'name': "${user['firstName']} ${user['lastName']}",
              'position': 'Employee', // Default position if not available
              'avatar': user['firstName'][0] + user['lastName'][0],
            }).toList()
                : [],
          };
          departments.add(department);
        }
        
        setState(() {
          _departments = departments;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load departments: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredDepartments {
    if (_searchQuery.isEmpty) {
      return _departments;
    }

    return _departments.where((department) =>
        department['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
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

  void _navigateToDepartmentDetail(Map<String, dynamic> department) {

    print("Navigating to department detail with data: $department");

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DepartmentDetailScreen(
          departmentName: department['name'],
          departmentData: department,
          departmentKey: department['key'],
          departmentId: department['id'],
        ),
      ),
    ).then((_) {
      _fetchDepartments();
    });
  }


  void _addNewDepartment(Map<String, dynamic> newDepartment) {
    setState(() {
      _departments.add(newDepartment);
    });
    // Refresh departments list from API after adding
    _fetchDepartments();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
            // User profile header
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),

            // Search bar
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: localizations.getString('search'),
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: AdaptiveColors.cardColor(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                    borderSide: BorderSide(color: Colors.green.shade800),
                  ),
                ),
              ),
            ),

            // Department title with Add button
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localizations.getString('departments'),
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddDepartmentScreen(
                            onDepartmentAdded: _addNewDepartment,
                          ),
                        ),
                      );
                    },
                    icon: Icon(Icons.add, size: screenWidth * 0.04),
                    label: Text(
                      localizations.getString('addDepartment'),
                      style: TextStyle(fontSize: screenWidth * 0.035),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.03,
                        vertical: screenHeight * 0.01,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.02),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Departments list or loading indicator
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                  ? Center(
                child: Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: screenWidth * 0.04,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  : _filteredDepartments.isEmpty
                  ? Center(
                child: Text(
                  localizations.getString('noDepartmentsFound'),
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(screenWidth * 0.04),
                itemCount: _filteredDepartments.length,
                itemBuilder: (context, index) {
                  final department = _filteredDepartments[index];
                  return _buildDepartmentCard(
                    context,
                    department,
                    screenWidth,
                    screenHeight,
                  );
                },
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

  Widget _buildDepartmentCard(
      BuildContext context,
      Map<String, dynamic> department,
      double screenWidth,
      double screenHeight,
      ) {
    return GestureDetector(
      onTap: () => _navigateToDepartmentDetail(department),
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.02),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          boxShadow: [
            BoxShadow(
              color: AdaptiveColors.shadowColor(context),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      department['name'],
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AdaptiveColors.primaryTextColor(context),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      '${department['members']} ${AppLocalizations.of(context).getString('members')}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: AdaptiveColors.secondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AdaptiveColors.secondaryTextColor(context),
                size: screenWidth * 0.05,
              ),
            ],
          ),
        ),
      ),
    );
  }
}