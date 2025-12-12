  import 'package:flutter/material.dart';
  import 'package:http/http.dart' as http;
  import 'dart:convert';
  import 'package:in_out/screens/employees/employee_profile/employee_profile_screen.dart';
  import 'package:in_out/theme/adaptive_colors.dart';
  import 'package:in_out/localization/app_localizations.dart';
  import 'package:in_out/auth/global.dart';
  
  class DepartmentDetailScreen extends StatefulWidget {
    final String departmentName;
    final dynamic departmentData;
    final String? departmentKey;
    final int? departmentId;
  
    const DepartmentDetailScreen({
      super.key,
      required this.departmentName,
      required this.departmentData,
      required this.departmentKey,
      this.departmentId,
    });
  
    @override
    State<DepartmentDetailScreen> createState() => _DepartmentDetailScreenState();
  }
  
  class _DepartmentDetailScreenState extends State<DepartmentDetailScreen> {
    double screenWidth = 0;
    double screenHeight = 0;
    final ScrollController _scrollController = ScrollController();
    bool _isHeaderVisible = true;
    late TextEditingController _searchController;
    String _searchQuery = '';
  
    // Pagination variables
    int _currentPage = 1;
    int _pageSize = 10;
    int _totalUsers = 0;
    int _totalPages = 1;
  
    // Available page size options
    final List<int> _pageSizeOptions = [5, 10, 20, 50];
  
    List<Map<String, dynamic>> _departmentUsers = [];
  
    List<Map<String, dynamic>> get _filteredEmployees {
      if (_searchQuery.isEmpty) {
        return _departmentUsers;
      }
  
      return _departmentUsers
          .where((employee) => employee['name']
          .toString()
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()))
          .toList();
    }
  
    bool _isLoadingUsers = true;
  
    @override
    void initState() {
      super.initState();
      _searchController = TextEditingController();
      _searchController.addListener(() {
        setState(() {
          _searchQuery = _searchController.text;
          // Reset to first page when search query changes
          _currentPage = 1;
        });
        _fetchDepartmentUsers();
      });
      _scrollController.addListener(_scrollListener);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateScreenDimensions();
        _fetchDepartmentUsers();
      });
    }

    Future<void> _fetchDepartmentUsers() async {
      if (widget.departmentId == null) {
        print("Cannot load users: departmentId is null");
        setState(() {
          _isLoadingUsers = false;
          _departmentUsers = [];
        });
        return;
      }

      setState(() {
        _isLoadingUsers = true;
      });

      try {
        // Construire l'URL avec les paramètres de pagination
        final url = Uri.parse(
            "${Global.baseUrl}/secure/user-department/users?departmentId=${widget.departmentId}&page=${_currentPage - 1}&size=$_pageSize"
        );

        print("Fetching users with URL: $url");

        final response = await http.get(
          url,
          headers: await Global.getHeaders(),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          List<Map<String, dynamic>> users = [];
          // Update pagination information
          if (data is Map<String, dynamic>) {
            _totalUsers = data['page']['totalElements'] ?? 0;
            _totalPages = data['totalPages'] ?? 1;
            // Process response content
          if (data.containsKey('content') && data['content'] is List) {
            for (var user in data['content']) {
              users.add({
                'id': user['id']?.toString() ?? '',
                'name': "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim(),
                'position': user['designation'] ?? 'Employee',
                'avatar': user['firstName'] != null && user['lastName'] != null ?
                "${user['firstName'][0]}${user['lastName'][0]}" : "",
                'username': user['username'] ?? '',
                'rawData': user
              });
            }
          }
          } else {
            print("Invalid data format: ${data.toString()}");
            setState(() {
              _totalUsers = 0;
              _totalPages = 1;
            });
          }

          setState(() {
            _departmentUsers = users;
            _isLoadingUsers = false;
          });

        } else {
          print("Error loading users: ${response.statusCode}");
          print("Response body: ${response.body}");

          setState(() {
            _isLoadingUsers = false;
          });
        }
      } catch (e) {
        print("Exception loading users: $e");
        setState(() {
          _isLoadingUsers = false;
        });
      }
    }
  
    void _updateScreenDimensions() {
      if (mounted) {
        setState(() {
          final size = MediaQuery.of(context).size;
          screenWidth = size.width;
          screenHeight = size.height;
        });
      }
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
  
    void _viewEmployeeDetails(Map<String, dynamic> employee) {
      final String employeeId = employee['id']?.toString() ?? '';
  
      if (employeeId.isNotEmpty) {
        try {
          final int id = int.parse(employeeId);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EmployeeProfileScreen(
                employeeId: id,
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid employee ID format: $employeeId'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot view employee details: Missing employee ID'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  
    // Function to show edit department dialog
    void _showEditDepartmentDialog() {
      final TextEditingController departmentNameController = TextEditingController(text: widget.departmentName);
  
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Department'),
          content: TextField(
            controller: departmentNameController,
            decoration: const InputDecoration(
              labelText: 'Department Name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _updateDepartmentName(departmentNameController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade800,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }
  
    // Function to update department name
    Future<void>  _updateDepartmentName(String newName) async {
      if (newName.isEmpty || newName == widget.departmentName) return;
  
      try {
        var departmentId = widget.departmentData['id'];
  
        // Ensure we have a valid ID
        if (departmentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Department ID is missing'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
  
        // Create the request body with the numeric ID
        final Map<String, dynamic> requestBody = {
          "id": departmentId,
          "key": widget.departmentKey ?? '',
          "name": newName
        };
  
        print("Updating department with payload: ${jsonEncode(requestBody)}");
  
        final response = await http.put(
          Uri.parse("${Global.baseUrl}/secure/department"),
          headers: {
            ...await Global.getHeaders(),
            'Content-Type': 'application/json',
          },
          body: jsonEncode(requestBody),
        );
  
        print("Update department response status: ${response.statusCode}");
        print("Update department response body: ${response.body}");
  
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Department updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
  
          // Update UI
          if (mounted) {
            Navigator.pop(context);
          }
        } else {
          // Show the exact error message from the API
          try {
            final errorData = json.decode(response.body);
            final errorMessage = errorData['error'] ?? 'Unknown error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update department: $errorMessage'),
                backgroundColor: Colors.red,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update department: ${response.statusCode}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print("Error updating department: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating department: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  
    // Function to show delete department confirmation dialog
    void _showDeleteDepartmentDialog() {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Department'),
          content: Text('Are you sure you want to delete "${widget.departmentName}" department? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteDepartment();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    }
  
    // Function to delete department
    Future<void> _deleteDepartment() async {
      try {
        // Ensure we have a valid ID
        if (widget.departmentId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Department ID is missing'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
  
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
  
        final response = await http.delete(
          Uri.parse("${Global.baseUrl}/secure/department/${widget.departmentId}"),
          headers: await Global.getHeaders(),
        );
  
        // Close loading indicator
        Navigator.pop(context);
  
        print("Delete department response status: ${response.statusCode}");
        print("Delete department response body: ${response.body}");
  
        if (response.statusCode == 200 || response.statusCode == 204) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Department deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
  
          // Navigate back to departments list
          Navigator.pop(context);
        } else {
          // Show the exact error message from the API
          try {
            final errorData = json.decode(response.body);
            final errorMessage = errorData['message'] ?? errorData['error'] ?? 'Unknown error';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete department: $errorMessage'),
                backgroundColor: Colors.red,
              ),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete department: ${response.statusCode}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print("Error deleting department: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting department: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  
    // Function to show assign employee bottom sheet
    void _showAssignEmployeeBottomSheet() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => AssignEmployeeBottomSheet(
          departmentId: widget.departmentData['id'].toString(), // Use the string ID
          onEmployeeAssigned: () {
            // Refresh the department data
            _fetchDepartmentUsers();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Employee assigned successfully'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      );
    }
  
    @override
    Widget build(BuildContext context) {
      final screenSize = MediaQuery.of(context).size;
      final screenWidth = screenSize.width;
      final screenHeight = screenSize.height;
      final localizations = AppLocalizations.of(context);
  
      return Scaffold(
        backgroundColor: AdaptiveColors.backgroundColor(context),
        appBar: AppBar(
          backgroundColor: AdaptiveColors.cardColor(context),
          elevation: 0,
          title: Text(
            widget.departmentName,
            style: TextStyle(
              color: AdaptiveColors.primaryTextColor(context),
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: IconThemeData(
            color: AdaptiveColors.primaryTextColor(context),
          ),
          actions: [
            // Edit Department button
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditDepartmentDialog,
              tooltip: 'Edit Department',
            ),
            // Assign Employee button
            IconButton(
              icon: const Icon(Icons.person_add),
              color: Colors.red,
              onPressed: _showAssignEmployeeBottomSheet,
              tooltip: 'Assign Employee',
            ),
            // Delete Department button
            IconButton(
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: _showDeleteDepartmentDialog,
              tooltip: 'Delete Department',
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Search and Pagination Controls
              _buildSearchAndPaginationControls(context, screenWidth),
  
              // Department members count
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.02,
                ),
                child: Row(
                  children: [
                    Text(
                      "$_totalUsers ${localizations.getString('members')}",
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AdaptiveColors.primaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
  
              // Employees list
              Expanded(
                child: _isLoadingUsers
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredEmployees.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: screenWidth * 0.15,
                        color: AdaptiveColors.secondaryTextColor(context),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        localizations.getString('noEmployeesFound'),
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          color: AdaptiveColors.secondaryTextColor(context),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),
                      Text(
                        "This department doesn't have any members yet.",
                        style: TextStyle(
                          fontSize: screenWidth * 0.035,
                          color: AdaptiveColors.tertiaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.separated(
                  controller: _scrollController,
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  itemCount: _filteredEmployees.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AdaptiveColors.borderColor(context),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final employee = _filteredEmployees[index];
                    return _buildEmployeeItem(employee);
                  },
                ),
              ),
  
              // Pagination controls at the bottom
              _buildPaginationControls(screenWidth, screenHeight),
            ],
          ),
        ),
      );
    }
  
    Widget _buildSearchAndPaginationControls(BuildContext context, double screenWidth) {
      return Padding(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          children: [
            // Search field
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).getString('search'),
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
  
            // Page size dropdown
            SizedBox(width: screenWidth * 0.02),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AdaptiveColors.cardColor(context),
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: DropdownButton<int>(
                value: _pageSize,
                isDense: true,
                underline: Container(),
                items: [
                  ..._pageSizeOptions.map((size) {
                    return DropdownMenuItem<int>(
                      value: size,
                      child: Text('$size'),
                    );
                  }),
                  const DropdownMenuItem<int>(
                    value: 999999, // Using a large number to represent "All"
                    child: Text('All'),
                  ),
                ],
                onChanged: (int? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _pageSize = newValue;
                      _currentPage = 1; // Reset to first page
                    });
                    _fetchDepartmentUsers();
                  }
                },
              ),
            ),
          ],
        ),
      );
    }
  
    Widget _buildPaginationControls(double screenWidth, double screenHeight) {
      if (_totalPages <= 1) {
        return const SizedBox.shrink(); // Hide pagination if only one page
      }
  
      return Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous page button
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: _currentPage > 1
                  ? () {
                setState(() {
                  _currentPage--;
                });
                _fetchDepartmentUsers();
              }
                  : null,
              color: AdaptiveColors.primaryGreen,
              disabledColor: Colors.grey,
            ),
  
            // Page indicator
            Text(
              'Page $_currentPage of $_totalPages',
              style: TextStyle(
                color: AdaptiveColors.primaryTextColor(context),
                fontWeight: FontWeight.bold,
              ),
            ),
  
            // Next page button
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: _currentPage < _totalPages
                  ? () {
                setState(() {
                  _currentPage++;
                });
                _fetchDepartmentUsers();
              }
                  : null,
              color: AdaptiveColors.primaryGreen,
              disabledColor: Colors.grey,
            ),
          ],
        ),
      );
    }
  
    Widget _buildEmployeeItem(Map<String, dynamic> employee) {
      return InkWell(
        onTap: () => _viewEmployeeDetails(employee),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
          child: Row(
            children: [
              _buildEmployeeAvatar(employee),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee['name'] ?? 'Unknown',
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,
                        fontWeight: FontWeight.bold,
                        color: AdaptiveColors.primaryTextColor(context),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      employee['position'] ?? employee['username'] ?? 'Employee',
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
                size: screenWidth * 0.04,
              ),
            ],
          ),
        ),
      );
    }
  
    Widget _buildEmployeeAvatar(Map<String, dynamic> employee) {
      final initials = employee['avatar'] ??
          _getInitials(employee['name'] ?? 'Unknown');
  
      return CircleAvatar(
        radius: 20,
        backgroundColor: _getAvatarColor(employee['name'] ?? 'Unknown'),
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  
    String _getInitials(String name) {
      if (name.isEmpty) return 'NA';
  
      List<String> nameParts = name.split(' ');
      if (nameParts.length > 1 && nameParts[0].isNotEmpty && nameParts[1].isNotEmpty) {
        return '${nameParts[0][0]}${nameParts[1][0]}';
      } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
        return nameParts[0][0];
      }
  
      return 'NA';
    }
  
    Color _getAvatarColor(String name) {
      final colors = [
        Colors.blue.shade300,
        Colors.red.shade300,
        Colors.green.shade300,
        Colors.orange.shade300,
        Colors.purple.shade300,
        Colors.pink.shade300,
        Colors.teal.shade300,
      ];
  
      int hash = name.hashCode;
      return colors[hash.abs() % colors.length];
    }
  }
  
  // Rest of the code for AssignEmployeeBottomSheet remains the same
  class AssignEmployeeBottomSheet extends StatefulWidget {
    final String departmentId;
    final VoidCallback? onEmployeeAssigned;
  
    const AssignEmployeeBottomSheet({
      super.key,
      required this.departmentId,
      this.onEmployeeAssigned,
    });
  
    @override
    _AssignEmployeeBottomSheetState createState() => _AssignEmployeeBottomSheetState();
  }
  
  class _AssignEmployeeBottomSheetState extends State<AssignEmployeeBottomSheet> {
    final TextEditingController _searchController = TextEditingController();
    List<Map<String, dynamic>> _allEmployees = [];
    List<Map<String, dynamic>> _filteredEmployees = [];
    final Set<String> _selectedEmployeeIds = {};
    bool _isLoading = true;
    String _searchQuery = '';
    bool _isAssigning = false;
    String _errorMessage = '';
  
    @override
    void initState() {
      super.initState();
      _fetchEmployees();
      _searchController.addListener(() {
        setState(() {
          _searchQuery = _searchController.text.toLowerCase();
          _filterEmployees();
        });
      });
    }
  
    void _filterEmployees() {
      setState(() {
        if (_searchQuery.isEmpty) {
          _filteredEmployees = List.from(_allEmployees);
        } else {
          _filteredEmployees = _allEmployees.where((emp) =>
          emp['username'].toString().toLowerCase().contains(_searchQuery) ||
              emp['fullName'].toString().toLowerCase().contains(_searchQuery)
          ).toList();
        }
      });
    }
  
    @override
    void dispose() {
      _searchController.dispose();
      super.dispose();
    }

    Future<void> _fetchEmployees() async {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // First, we need to get the current department details to know which users to exclude
        final departmentUsersUrl = Uri.parse(
            "${Global.baseUrl}/secure/user-department/users?departmentId=${widget.departmentId}&size=999999");

        print("Fetching department users from: $departmentUsersUrl");

        final departmentUsersResponse = await http.get(
          departmentUsersUrl,
          headers:await Global.getHeaders(),
        );

        // Set of user IDs already in this department
        Set<int> existingUserIds = {};

        if (departmentUsersResponse.statusCode == 200) {
          final data = json.decode(departmentUsersResponse.body);
          if (data is Map<String, dynamic> && data.containsKey('content') && data['content'] is List) {
            for (var user in data['content']) {
              if (user['id'] != null) {
                existingUserIds.add(user['id']);
              }
            }
          }
          print("Found ${existingUserIds.length} users already in department: $existingUserIds");
        }

        // Now fetch all users
        final Uri url = Uri.parse("${Global.baseUrl}/secure/users/filter?size=0");
        final Map<String, dynamic> filterBody = {};
        final response = await http.post(
          url,
          headers: {
            ...await Global.getHeaders(),
            'Content-Type': 'application/json',
          },
          body: jsonEncode(filterBody),
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = json.decode(response.body);

          if (data.containsKey('content') && data['content'] is List) {
            final List<dynamic> employeesData = data['content'];

            setState(() {
              _allEmployees = employeesData.map<Map<String, dynamic>>((emp) => {
                'id': emp['id']?.toString() ?? '',
                'rawId': emp['id'],
                'username': emp['username'] ?? '',
                'firstName': emp['firstName'] ?? '',
                'lastName': emp['lastName'] ?? '',
                'fullName': "${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}".trim(),
                'department': emp['department'],
              }).toList();

              // Filter out employees already in this department - improved filtering
              _allEmployees = _allEmployees.where((emp) {
                // Filter by rawId since that's the numeric ID we use
                final rawId = emp['rawId'];
                if (rawId == null) return false;

                // Keep this employee only if they're not in the existingUserIds set
                return !existingUserIds.contains(rawId);
              }).toList();

              _filteredEmployees = List.from(_allEmployees);
              _isLoading = false;
            });

            print("Loaded ${_allEmployees.length} assignable employees");
          } else {
            setState(() {
              _isLoading = false;
              _errorMessage = 'Invalid data format returned from the server';
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load employees: ${response.statusCode}';
          });
          print("Error response: ${response.body}");
        }
      } catch (e) {
        print('Error fetching employees: $e');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Network error: ${e.toString()}';
        });
      }
    }
  
    void _showErrorSnackBar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  
    Future<void> _assignEmployees() async {
      if (_selectedEmployeeIds.isEmpty) {
        _showErrorSnackBar('Please select at least one employee');
        return;
      }
  
      setState(() {
        _isAssigning = true;
        _errorMessage = '';
      });
  
      List<String> failedEmployeeIds = [];
      List<String> successfulEmployeeIds = [];
  
      try {
        for (String employeeIdStr in _selectedEmployeeIds) {
          try {
            // Find the employee to get the raw ID
            final employee = _allEmployees.firstWhere(
                  (emp) => emp['id'] == employeeIdStr,
              orElse: () => {'rawId': null},
            );
  
            // Get the numeric user ID
            final userId = employee['rawId'];
  
            if (userId == null) {
              print('User ID is null for employee $employeeIdStr');
              failedEmployeeIds.add(employeeIdStr);
              continue;
            }
  
            // IMPORTANT: Use the departmentId parameter that contains the key string
            final departmentKey = widget.departmentId;

            // Debug logging
            print("Assigning user ID: $userId to department key: $departmentKey");
  
            // Format the request body with the department key
            final requestBody = jsonEncode({
              "userId": userId,
              "departmentId": departmentKey  // Now correctly using the key value
            });
  
            print("Assignment request body: $requestBody");
  
            // Make the API request
            final response = await http.put(
              Uri.parse("${Global.baseUrl}/secure/user-department/assign"),
              headers: {
                ...await Global.getHeaders(),
                'Content-Type': 'application/json',
              },
              body: requestBody,
            );
  
            // Debug logging
            print("Response status: ${response.statusCode}");
            print("Response body: ${response.body}");
  
            // Check if the assignment was successful
            if (response.statusCode >= 200 && response.statusCode < 300) {
              successfulEmployeeIds.add(employeeIdStr);
            } else {
              print('Failed to assign user $employeeIdStr: ${response.statusCode} - ${response.body}');
              failedEmployeeIds.add(employeeIdStr);
            }
          } catch (e) {
            print('Error assigning user $employeeIdStr: $e');
            failedEmployeeIds.add(employeeIdStr);
          }
  
          // Small delay to avoid overwhelming the server
          await Future.delayed(const Duration(milliseconds: 100));
        }
  
        setState(() {
          _isAssigning = false;
        });
  
        // Report results
        if (failedEmployeeIds.isEmpty) {
          // All assignments successful
          if (widget.onEmployeeAssigned != null) {
            widget.onEmployeeAssigned!();
          }
          Navigator.of(context).pop();
        } else if (successfulEmployeeIds.isNotEmpty) {
          // Some assignments were successful, some failed
          _showErrorSnackBar('${failedEmployeeIds.length} employee(s) could not be assigned');
  
          // Still call the callback for the ones that succeeded
          if (widget.onEmployeeAssigned != null && successfulEmployeeIds.isNotEmpty) {
            widget.onEmployeeAssigned!();
          }
        } else {
          // All assignments failed
          _showErrorSnackBar('Failed to assign any employees. Please try again.');
        }
      } catch (e) {
        print('Error in assignment process: $e');
        setState(() {
          _isAssigning = false;
          _errorMessage = 'Error occurred while assigning employees: ${e.toString()}';
        });
        _showErrorSnackBar('Error assigning employees: ${e.toString()}');
      }
    }
  
    @override
    Widget build(BuildContext context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) {
          return Container(
            decoration: BoxDecoration(
              color: AdaptiveColors.cardColor(context),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
  
                // Title
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Text(
                        'Assign Employees',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AdaptiveColors.primaryTextColor(context),
                        ),
                      ),
                      const Spacer(),
                      // Add a small debug text
                      Text(
                        'Department ID: ${widget.departmentId}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
  
                // Search Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search employees',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
  
                // Error message if present
                if (_errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
  
                // Employee List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _filteredEmployees.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.person_off,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No employees available to assign',
                          style: TextStyle(
                            color: AdaptiveColors.secondaryTextColor(context),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Try adjusting your search criteria',
                              style: TextStyle(
                                color: AdaptiveColors.tertiaryTextColor(context),
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    controller: controller,
                    itemCount: _filteredEmployees.length,
                    itemBuilder: (context, index) {
                      final employee = _filteredEmployees[index];
                      final isSelected = _selectedEmployeeIds.contains(employee['id']);
  
                      return CheckboxListTile(
                        title: Text(
                          employee['fullName'].toString().isNotEmpty
                              ? employee['fullName']
                              : employee['username'],
                          style: TextStyle(
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              employee['username'],
                              style: TextStyle(
                                color: AdaptiveColors.secondaryTextColor(context),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Show the ID for debugging
                            Text(
                              'ID: ${employee['id']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        secondary: CircleAvatar(
                          backgroundColor: _getAvatarColor(employee['fullName'] ?? employee['username']),
                          child: Text(
                            _getInitials(employee['fullName'] ?? employee['username']),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedEmployeeIds.add(employee['id']);
                            } else {
                              _selectedEmployeeIds.remove(employee['id']);
                            }
                          });
                        },
                        activeColor: Colors.green.shade800,
                      );
                    },
                  ),
                ),
  
                // Assign Button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton(
                    onPressed: _isAssigning || _selectedEmployeeIds.isEmpty ? null : _assignEmployees,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade800,
                      minimumSize: const Size(double.infinity, 50),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    child: _isAssigning
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : Text(
                      'Assign ${_selectedEmployeeIds.length} Employee${_selectedEmployeeIds.length != 1 ? 's' : ''}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  
    String _getInitials(String name) {
      if (name.isEmpty) return 'NA';
  
      List<String> nameParts = name.split(' ');
      if (nameParts.length > 1 && nameParts[0].isNotEmpty && nameParts[1].isNotEmpty) {
        return '${nameParts[0][0]}${nameParts[1][0]}';
      } else if (nameParts.isNotEmpty && nameParts[0].isNotEmpty) {
        return nameParts[0][0];
      }
  
      return 'NA';
    }
  
    Color _getAvatarColor(String name) {
      final colors = [
        Colors.blue.shade300,
        Colors.red.shade300,
        Colors.green.shade300,
        Colors.orange.shade300,
        Colors.purple.shade300,
        Colors.pink.shade300,
        Colors.teal.shade300,
      ];
  
      int hash = name.hashCode;
      return colors[hash.abs() % colors.length];
    }
  }