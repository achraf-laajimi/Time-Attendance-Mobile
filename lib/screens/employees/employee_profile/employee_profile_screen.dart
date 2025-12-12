// lib/screens/employees/employee_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/services/employee_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:http/http.dart' as http;
import '../../../auth/global.dart';
import '../edit_employee_screen.dart';
import 'employee_profile_tabs/profile_tab.dart';
import 'employee_profile_tabs/attendance_tab.dart';
import 'employee_profile_tabs/leave_tab.dart';


class EmployeeProfileScreen extends StatefulWidget {
  final int employeeId;
  final int initialTabIndex;

  const EmployeeProfileScreen({
    super.key,
    required this.employeeId,
    this.initialTabIndex = 0,
  });

  @override
  State<EmployeeProfileScreen> createState() => _EmployeeProfileScreenState();
}

class _EmployeeProfileScreenState extends State<EmployeeProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic>? _employeeData;
  String _errorMessage = '';
  Map<String, dynamic> _employeeMap = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this,initialIndex: widget.initialTabIndex,);
    _loadEmployeeDetails();
    _tabController.addListener(_handleTabChange);

  }
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    // Force rebuild when tab changes to update the app bar icons
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  Future<void> _loadEmployeeDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await EmployeeService.getEmployeeById(widget.employeeId);

      if (result["success"]) {
        // Stocker les données brutes
        _employeeData = result["employee"];

        // Extraire le département des attributs
        String department = _extractDepartment(_employeeData);

        setState(() {
          _employeeMap = _formatEmployeeData(_employeeData, department);
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

  String _extractDepartment(Map<String, dynamic>? data) {
    if (data == null) return 'Department';

    if (data['attributes'] != null &&
        data['attributes']['department'] != null &&
        data['attributes']['department']['name'] != null) {
      return data['attributes']['department']['name'];
    } else if (data['department'] != null) {
      return data['department'];
    } else if (data['designation'] != null &&
        data['designation'].contains(' ')) {
      return data['designation'].split(' ').last;
    }

    return 'Department';
  }

  Map<String, dynamic> _formatEmployeeData(Map<String, dynamic>? data, String department) {
    if (data == null) return {};

    return {
      'id': data['id']?.toString() ?? 'N/A',
      'name': '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim(),
      'firstName': data['firstName'] ?? 'N/A',
      'lastName': data['lastName'] ?? 'N/A',
      'username': data['username'] ?? 'N/A',
      'email': data['email'] ?? 'N/A',
      'personalEmail': data['personalEmail'] ?? 'N/A',
      'phoneNumber': data['phoneNumber'] ?? 'N/A',
      'avatar': data['firstName'] != null &&
          data['firstName'].isNotEmpty &&
          data['lastName'] != null &&
          data['lastName'].isNotEmpty
          ? '${data['firstName'][0]}${data['lastName'][0]}'
          : 'NA',
      'avatarColor': Colors.blue.shade100,
      'textColor': Colors.blue.shade800,
      'department': department,
      'designation': data['designation'] ?? 'N/A',
      'type': data['type'] ?? 'N/A',
      'birthDate': data['birthDate'] ?? 'N/A',
      'recruitmentDate': data['recruitmentDate'] ?? 'N/A',
      'gender': data['gender'] ?? 'N/A',
      'maritalStatus': data['maritalStatus'] ?? 'N/A',
      'address': data['address'] ?? 'N/A',
      'city': data['city'] ?? 'N/A',
      'state': data['state'] ?? 'N/A',
      'zipCode': data['zipCode'] ?? 'N/A',
      'nationality': data['nationality'] ?? 'N/A',
      'workingDays': data['workingDays'] ?? 'N/A',
      'officeLocation': data['officeLocation'] ?? 'N/A',
      'companyId': data['companyId'] ?? 'N/A',
      'active': data['active'] ?? false,
      'role': data['role'] ?? 'N/A',
      'attributes': data['attributes'] ?? {},
      'departmentKey': data['attributes']?['department']?['key']?.toString() ?? 'N/A',
    };
  }

  Future<void> _toggleUserActiveStatus() async {
    // Get current active status and user ID
    final bool isCurrentlyActive = _employeeMap['active'] == true;
    final String userId = _employeeMap['id'].toString();

    // Show confirmation dialog
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isCurrentlyActive ? 'Disable User' : 'Enable User',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            isCurrentlyActive
                ? 'Are you sure you want to disable this user? They will no longer be able to login to the system.'
                : 'Are you sure you want to enable this user? They will be able to login to the system.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: Text(
                AppLocalizations.of(context).getString('cancel'),
                style: TextStyle(color: AdaptiveColors.secondaryTextColor(context)),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrentlyActive ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(isCurrentlyActive ? 'Disable' : 'Enable'),
            ),
          ],
        );
      },
    );

    // If user cancelled, abort operation
    if (confirmed != true) return;

    // User confirmed, proceed with the status change
    setState(() {
      _isLoading = true;
    });

    try {
      // Determine which endpoint to use based on current status
      final String endpoint ="/secure/users/toggle/$userId";

      // Show loading indicator during API call
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      // Make API call
      final Uri url = Uri.parse("${Global.baseUrl}$endpoint");
      final response = await http.put(
        url,
        headers: await Global.getHeaders(),
      );

      // Close loading indicator
      Navigator.of(context).pop();

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isCurrentlyActive
                ? 'User disabled successfully'
                : 'User enabled successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Reload employee data to reflect the changes
        _loadEmployeeDetails();
      } else {
        // Show error message
        setState(() {
          _isLoading = false;
          _errorMessage = "Failed to update user status: ${response.statusCode}";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error updating user status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading indicator if still showing
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      setState(() {
        _isLoading = false;
        _errorMessage = "Error: $e";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.getString('employeeProfile')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.getString('employeeProfile')),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 60,
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
                onPressed: _loadEmployeeDetails,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_employeeMap.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.getString('employeeProfile')),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: Text(localizations.getString('employeeNotFound')),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      appBar: _buildAppBar(context, localizations),
      body: TabBarView(
        controller: _tabController,
        physics: const ClampingScrollPhysics(),
        children: [
          // Onglet du profil
          ProfileTab(employeeData: _employeeMap),

          // Onglet des présences
          AttendanceTab(
            employeeId: _employeeMap['id'],
          ),

          // Onglet des congés
          const LeaveTab(),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AdaptiveColors.cardColor(context),
        elevation: 0,
        title: Text(
          _employeeMap['name'] ?? 'Employee Profile',
          style: TextStyle(
            color: AdaptiveColors.primaryTextColor(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AdaptiveColors.primaryTextColor(context),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 60,
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
              onPressed: _loadEmployeeDetails,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations localizations) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        _employeeMap['name'] ?? '',
        style: TextStyle(
          color: AdaptiveColors.primaryTextColor(context),
        ),
      ),
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: AdaptiveColors.primaryTextColor(context),
        ),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _employeeMap['active'] == true
                ? Icons.toggle_on_outlined
                : Icons.toggle_off_outlined,
            color: _employeeMap['active'] == true
                ? Colors.green
                : Colors.red,
            size: 24,
          ),
          onPressed: _isLoading ? null : _toggleUserActiveStatus,
          tooltip: _employeeMap['active'] == true
              ? 'Disable User'
              : 'Enable User',
        ),
        // Bouton d'édition
        IconButton(
          icon: const Icon(
            Icons.edit_outlined,
            color: AdaptiveColors.primaryGreen,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditEmployeeScreen(
                  employeeData: _employeeMap,
                  onEmployeeUpdated: () {
                    _loadEmployeeDetails();
                  },
                ),
              ),
            );
          },
          tooltip: localizations.getString('edit'),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: const Icon(Icons.person_outline, size: 18),
            text: localizations.getString('profile'),
          ),
          Tab(
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            text: localizations.getString('attendance'),
          ),
          Tab(
            icon: const Icon(Icons.event_note_outlined, size: 18),
            text: localizations.getString('leave'),
          ),
        ],
        labelColor: AdaptiveColors.primaryGreen,
        unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
        indicatorColor: AdaptiveColors.primaryGreen,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
      ),
    );
  }
}