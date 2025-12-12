import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../../auth/global.dart';


class EditEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic> employeeData;
  final Function? onEmployeeUpdated;

  const EditEmployeeScreen({
    super.key,
    required this.employeeData,
    this.onEmployeeUpdated,
  });

  @override
  State<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends State<EditEmployeeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Text controllers for all editable fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _personalEmailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _companyIdController;
  late TextEditingController _designationController;

  // Selected dropdown values
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedType;
  String? _selectedRole;

  // Date fields
  DateTime? _birthDate;
  DateTime? _recruitmentDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize controllers with existing employee data
    _firstNameController = TextEditingController(text: widget.employeeData['firstName'] ?? '');
    _lastNameController = TextEditingController(text: widget.employeeData['lastName'] ?? '');
    _emailController = TextEditingController(text: widget.employeeData['email'] ?? '');
    _personalEmailController = TextEditingController(text: widget.employeeData['personalEmail'] ?? '');
    _phoneController = TextEditingController(text: widget.employeeData['phoneNumber'] ?? '');
    _addressController = TextEditingController(text: widget.employeeData['address'] ?? '');
    _companyIdController = TextEditingController(text: widget.employeeData['companyId'] ?? '');
    _designationController = TextEditingController(text: widget.employeeData['designation'] ?? '');

    // Initialize dropdown values
    _selectedGender = widget.employeeData['gender'] ?? 'MALE';
    _selectedMaritalStatus = widget.employeeData['maritalStatus'] ?? 'SINGLE';
    _selectedType = widget.employeeData['type'] ?? 'OFFICE';
    _selectedRole = widget.employeeData['role'] ?? 'USER';

    // Initialize dates
    if (widget.employeeData['birthDate'] != null && widget.employeeData['birthDate'].toString().isNotEmpty) {
      _birthDate = DateTime.parse(widget.employeeData['birthDate']);
    }

    if (widget.employeeData['recruitmentDate'] != null && widget.employeeData['recruitmentDate'].toString().isNotEmpty) {
      _recruitmentDate = DateTime.parse(widget.employeeData['recruitmentDate']);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _personalEmailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companyIdController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  // Format date to string for API
  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate
          ? (_birthDate ?? DateTime(2000))
          : (_recruitmentDate ?? DateTime.now()),
      firstDate: isBirthDate ? DateTime(1950) : DateTime(2000),
      lastDate: isBirthDate ? DateTime.now() : DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _birthDate = picked;
        } else {
          _recruitmentDate = picked;
        }
      });
    }
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Format dates properly
      final birthDateFormatted = _birthDate != null ? _formatDate(_birthDate) : null;
      final recruitmentDateFormatted = _recruitmentDate != null ? _formatDate(_recruitmentDate) : null;

      // Create a simple update payload that matches your API expectations
      final Map<String, dynamic> updatePayload = {
        "id": widget.employeeData['id'].toString(),
        "email": _emailController.text,
        "personalEmail": _personalEmailController.text,
        "phoneNumber": _phoneController.text,
        "firstName": _firstNameController.text,
        "lastName": _lastNameController.text,
        "gender": _selectedGender,
        "maritalStatus": _selectedMaritalStatus,
        "companyId": _companyIdController.text,
        "designation": _designationController.text,
        "role": _selectedRole,
        "type": _selectedType,
        "address": _addressController.text,
        "birthDate": birthDateFormatted,
        "recruitmentDate": recruitmentDateFormatted
      };

      // Log the update payload for debugging
      print("Update payload: ${json.encode(updatePayload)}");

      // Make a direct HTTP request instead of using the service
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/users"),
        headers: await Global.getHeaders(),
        body: json.encode(updatePayload),
      );

      // Log the response
      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Call callback if provided
        if (widget.onEmployeeUpdated != null) {
          widget.onEmployeeUpdated!();
        }

        // Navigate back
        Navigator.pop(context);
      } else {
        // Show error message with more details
        String errorMessage = 'Failed to update employee';
        if (response.body.isNotEmpty) {
          try {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } catch (e) {
            // If JSON parsing fails, use the status code
            errorMessage = 'Failed to update employee: ${response.statusCode}';
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Log and show any exceptions
      print('Exception during update: $e');

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Edit ${widget.employeeData['firstName']} ${widget.employeeData['lastName']}',
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
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.getString('personalInformation')),
            Tab(text: localizations.getString('professionalInformation')),
          ],
          labelColor: AdaptiveColors.primaryGreen,
          unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
          indicatorColor: AdaptiveColors.primaryGreen,
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Personal Information Tab
            _buildPersonalInfoForm(context, screenWidth, screenHeight),

            // Professional Information Tab
            _buildProfessionalInfoForm(context, screenWidth, screenHeight),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          boxShadow: [
            BoxShadow(
              color: AdaptiveColors.shadowColor(context),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(localizations.getString('cancel')),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateEmployee,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdaptiveColors.primaryGreen,
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(localizations.getString('apply')),
            ),
          ],
        ),
      ),
    );
  }

  // Build personal information form
  Widget _buildPersonalInfoForm(BuildContext context, double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Email Fields Row
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: AppLocalizations.of(context).getString('emailAddress'),
                  controller: _emailController,
                  validator: (value) => value!.isEmpty ? 'Email is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: 'Personal Email',
                  controller: _personalEmailController,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Name Fields Row
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: AppLocalizations.of(context).getString('firstName'),
                  controller: _firstNameController,
                  validator: (value) => value!.isEmpty ? 'First name is required' : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFormField(
                  label: AppLocalizations.of(context).getString('lastName'),
                  controller: _lastNameController,
                  validator: (value) => value!.isEmpty ? 'Last name is required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Phone Number Field
          _buildFormField(
            label: AppLocalizations.of(context).getString('mobileNumber'),
            controller: _phoneController,
            validator: (value) => value!.isEmpty ? 'Phone number is required' : null,
          ),
          const SizedBox(height: 16),

          // Date of Birth and Gender Row
          Row(
            children: [
              Expanded(
                child: _buildDatePickerField(
                  context: context,
                  label: AppLocalizations.of(context).getString('dateOfBirth'),
                  date: _birthDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: AppLocalizations.of(context).getString('gender'),
                  value: _selectedGender,
                  items: ['MALE', 'FEMALE', 'OTHER'],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Marital Status Dropdown
          _buildDropdownField(
            label: AppLocalizations.of(context).getString('maritalStatus'),
            value: _selectedMaritalStatus,
            items: ['SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED'],
            onChanged: (value) {
              setState(() {
                _selectedMaritalStatus = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Address Field
          _buildFormField(
            label: AppLocalizations.of(context).getString('address'),
            controller: _addressController,
          ),
        ],
      ),
    );
  }

  // Build professional information form
  Widget _buildProfessionalInfoForm(BuildContext context, double screenWidth, double screenHeight) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username Display (Read-only)
          _buildReadOnlyField(
            label: AppLocalizations.of(context).getString('userName'),
            value: widget.employeeData['username'] ?? '',
          ),
          const SizedBox(height: 16),

          // Employment Type and Role Row
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: AppLocalizations.of(context).getString('type'),
                  value: _selectedType,
                  items: ['OFFICE', 'REMOTE', 'HYBRID'],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdownField(
                  label: 'Role',
                  value: _selectedRole,
                  items: ['USER', 'ADMIN', 'MANAGER'],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Designation Field
          _buildFormField(
            label: AppLocalizations.of(context).getString('designation'),
            controller: _designationController,
            validator: (value) => value!.isEmpty ? 'Designation is required' : null,
          ),
          const SizedBox(height: 16),

          // Company ID and Joining Date Row
          Row(
            children: [
              Expanded(
                child: _buildFormField(
                  label: 'Company ID',
                  controller: _companyIdController,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDatePickerField(
                  context: context,
                  label: AppLocalizations.of(context).getString('joiningDate'),
                  date: _recruitmentDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Form field with label above
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    bool isPassword = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          readOnly: readOnly,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? Colors.grey.withOpacity(0.1) : AdaptiveColors.cardColor(context),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AdaptiveColors.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }

  // Date picker field with label above
  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    String displayText = date != null
        ? DateFormat('yyyy-MM-dd').format(date)
        : 'Select Date';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: AdaptiveColors.cardColor(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayText,
                  style: TextStyle(
                    color: date != null
                        ? AdaptiveColors.primaryTextColor(context)
                        : Colors.grey,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: AdaptiveColors.secondaryTextColor(context),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown field with label above
  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: AdaptiveColors.cardColor(context),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text('Select $label'),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Read-only field for display-only information
  Widget _buildReadOnlyField({
    required String label,
    required String value,
  })
  {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey.withOpacity(0.1),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: AdaptiveColors.primaryTextColor(context),
            ),
          ),
        ),
      ],
    );
  }
}