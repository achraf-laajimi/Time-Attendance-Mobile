import 'package:flutter/material.dart';
import 'package:in_out/models/employee_model.dart';
import 'package:in_out/services/employee_service.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/provider/language_provider.dart';
import 'package:in_out/services/nationality_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/landscape_user_profile_header.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Function(Employee)? onEmployeeAdded;
  const AddEmployeeScreen({
    super.key,
    this.onEmployeeAdded,
  });

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {

  // Controllers for text fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _personalEmailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();

  // Selected values for dropdowns
  String? _selectedMaritalStatus;
  String? _selectedGender;

  // Birth date and joining date
  DateTime? _dateOfBirth;
  DateTime? _joiningDate;
  bool _isPersonalInfoActive = true;
  bool _isProfessionalInfoActive = false;
  bool _isHeaderVisible = true;
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  // Form validation
  final _formKey = GlobalKey<FormState>();
  bool _formIsValid = false;
  List<String> _nationalities = [];
  final _nationalityService = NationalityService();
  bool _nationalitiesLoaded = false;
  String _selectedRole = 'USER';
  String _selectedType = 'OFFICE';
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);

    // Initialize default values
    _selectedGender = 'MALE';
    _selectedMaritalStatus = 'SINGLE';
    _selectedRole = 'USER';
    _selectedType = 'OFFICE';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Load nationalities in didChangeDependencies instead of initState
    if (!_nationalitiesLoaded) {
      _loadNationalities();
      _nationalitiesLoaded = true;
    }
  }

  Future<void> _loadNationalities() async {
    // Get language from provider
    final languageProvider =
    Provider.of<LanguageProvider>(context, listen: false);
    final String languageCode = languageProvider.currentLanguage;

    // Load nationalities using our service
    final nationalities =
    await _nationalityService.getNationalitiesByLanguage(languageCode);

    if (mounted) {
      setState(() {
        _nationalities = nationalities;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _emailController.dispose();
    _personalEmailController.dispose();
    _addressController.dispose();
    _employeeIdController.dispose();
    _userNameController.dispose();
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 50;
    });
  }

  void _toggleTab(bool isPersonal) {
    setState(() {
      _isPersonalInfoActive = isPersonal;
      _isProfessionalInfoActive = !isPersonal;
    });
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate
          ? (_dateOfBirth ?? DateTime(2000))
          : (_joiningDate ?? DateTime.now()),
      firstDate: isBirthDate ? DateTime(1950) : DateTime(2000),
      lastDate: isBirthDate ? DateTime.now() : DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isBirthDate) {
          _dateOfBirth = picked;
        } else {
          _joiningDate = picked;
        }
      });
    }
  }

  void _validateForm() {
    if (_isPersonalInfoActive) {
      // Validate personal info
      _formIsValid = _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _mobileNumberController.text.isNotEmpty;
    } else {
      // Validate professional info
      _formIsValid = _designationController.text.isNotEmpty; // At least designation is required
    }
  }

  // Format date to API format
  String _formatDateForApi(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void _createEmployee() async {
    // Validate form before proceeding
    _validateForm();
    if (!_formIsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? formattedBirthDate;
    if (_dateOfBirth != null) {
      formattedBirthDate = "${_dateOfBirth!.year}-${_dateOfBirth!.month.toString().padLeft(2, '0')}-${_dateOfBirth!.day.toString().padLeft(2, '0')}";
    }

    String? formattedRecruitmentDate;
    if (_joiningDate != null) {
      formattedRecruitmentDate = "${_joiningDate!.year}-${_joiningDate!.month.toString().padLeft(2, '0')}-${_joiningDate!.day.toString().padLeft(2, '0')}";
    }

    // Generate a username based on first and last name if not provided
    // Note: This is handled by the backend but we'll keep this for compatibility
    String username = _userNameController.text.isNotEmpty
        ? _userNameController.text
        : ("${_firstNameController.text.toLowerCase()}_${_lastNameController.text.toLowerCase()}").replaceAll(' ', '_');

    // Create employee object
    final employee = Employee(
      username: username,
      email: _emailController.text,
      personalEmail: _personalEmailController.text.isNotEmpty ? _personalEmailController.text : null,
      phoneNumber: _mobileNumberController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      password: _passwordController.text,
      gender: _selectedGender ?? 'MALE',
      maritalStatus: _selectedMaritalStatus ?? 'SINGLE',
      birthDate: formattedBirthDate,
      recruitmentDate: formattedRecruitmentDate,
      role: _selectedRole,
      type: _selectedType,
      companyId: _companyIdController.text.isEmpty ? null : _companyIdController.text,
      designation: _designationController.text,
      address: _addressController.text.isNotEmpty ? _addressController.text : null,
      attributes: {},
      active: true,
    );

    try {
      final result = await EmployeeService.createEmployee(employee);

      setState(() {
        _isLoading = false;
      });

      if (result["success"]) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Employee added successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Call the callback if it exists
        if (widget.onEmployeeAdded != null) {
          widget.onEmployeeAdded!(result["employee"]);
        }

        // Navigate back
        Navigator.pop(context);
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result["message"]}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      // Show error message
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            LandscapeUserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {},
            ),

            // Title and breadcrumb
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenHeight * 0.01,
              ),
              child: Row(
                children: [
                  Text(
                    localizations.getString('addEmployee'),
                    style: TextStyle(
                      fontSize: screenWidth * 0.016,
                      fontWeight: FontWeight.bold,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                  Text(
                    '/ ${localizations.getString('employees')} / ${localizations.getString('addEmployee')}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.012,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Container(
                margin: EdgeInsets.all(screenWidth * 0.01),
                decoration: BoxDecoration(
                  color: AdaptiveColors.cardColor(context),
                  borderRadius: BorderRadius.circular(screenWidth * 0.005),
                  boxShadow: [
                    BoxShadow(
                      color: AdaptiveColors.shadowColor(context),
                      spreadRadius: 1,
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Tabs for Personal/Professional Information
                    _buildTabs(context, screenWidth, screenHeight),

                    // Form
                    Expanded(
                      child: Form(
                        key: _formKey,
                        onChanged: () {
                          _validateForm();
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          padding: EdgeInsets.all(screenWidth * 0.01),
                          child: _isPersonalInfoActive
                              ? _buildPersonalInfoForm(
                              context, screenWidth, screenHeight)
                              : _buildProfessionalInfoForm(
                              context, screenWidth, screenHeight),
                        ),
                      ),
                    ),

                    // Action buttons at the bottom
                    _buildActionButtons(context, screenWidth, screenHeight),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(
      BuildContext context, double screenWidth, double screenHeight) {
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AdaptiveColors.borderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _toggleTab(true),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _isPersonalInfoActive
                          ? const Color(0xFF2E7D32)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: _isPersonalInfoActive
                          ? const Color(0xFF2E7D32)
                          : AdaptiveColors.secondaryTextColor(context),
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.005),
                    Text(
                      localizations.getString('personalInformation'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.01,
                        fontWeight: _isPersonalInfoActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _isPersonalInfoActive
                            ? const Color(0xFF2E7D32)
                            : AdaptiveColors.secondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Professional Information Tab
          Expanded(
            child: InkWell(
              onTap: () => _toggleTab(false),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.02,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _isProfessionalInfoActive
                          ? const Color(0xFF2E7D32)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.work,
                      color: _isProfessionalInfoActive
                          ? const Color(0xFF2E7D32)
                          : AdaptiveColors.secondaryTextColor(context),
                      size: screenWidth * 0.012,
                    ),
                    SizedBox(width: screenWidth * 0.005),
                    Text(
                      localizations.getString('professionalInformation'),
                      style: TextStyle(
                        fontSize: screenWidth * 0.01,
                        fontWeight: _isProfessionalInfoActive
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _isProfessionalInfoActive
                            ? const Color(0xFF2E7D32)
                            : AdaptiveColors.secondaryTextColor(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoForm(BuildContext context, double screenWidth, double screenHeight) {
    final localizations = AppLocalizations.of(context);
    final fieldHeight = screenHeight * 0.065;

    return Column(
      children: [
        // First row: Email fields (Primary and Personal)
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                _emailController,
                localizations.getString('emailAddress'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
                isRequired: true,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildTextField(
                context,
                _personalEmailController,
                'Personal Email', // You might want to add this to your localization
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Second row: First Name and Last Name
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                _firstNameController,
                localizations.getString('firstName'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
                isRequired: true,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildTextField(
                context,
                _lastNameController,
                localizations.getString('lastName'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
                isRequired: true,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Third row: Phone Number and Password
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                _mobileNumberController,
                localizations.getString('mobileNumber'),
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
                isRequired: true,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildTextField(
                context,
                _passwordController,
                'Password',
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
                isRequired: true,
                isPassword: true,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Fourth row: Date of Birth and Gender
        Row(
          children: [
            Expanded(
              child: _buildDateField(
                context,
                localizations.getString('dateOfBirth'),
                screenWidth,
                screenHeight,
                isBirthDate: true,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('gender'),
                ['MALE', 'FEMALE', 'OTHER'],
                _selectedGender,
                    (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Fifth row: Marital Status and Role
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context,
                localizations.getString('maritalStatus'),
                ['SINGLE', 'MARRIED', 'DIVORCED'],
                _selectedMaritalStatus,
                    (value) {
                  setState(() {
                    _selectedMaritalStatus = value;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDropdown(
                context,
                'Role',
                ['USER', 'ADMIN', 'MANAGER'],
                _selectedRole,
                    (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Address field
        _buildTextField(
          context,
          _addressController,
          localizations.getString('address'),
          screenWidth,
          screenHeight,
          fieldHeight: fieldHeight,
        ),
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }

  Widget _buildProfessionalInfoForm(BuildContext context, double screenWidth, double screenHeight) {
    final localizations = AppLocalizations.of(context);
    final fieldHeight = screenHeight * 0.065; // Consistent field height

    return Column(
      children: [
        // First row: Type and Designation
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context,
                'Type',
                ['OFFICE', 'REMOTE', 'HYBRID'],
                _selectedType,
                    (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildTextField(
                context,
                _designationController,
                'Designation',
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
                isRequired: true,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Second row: Company ID and Joining Date
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                context,
                _companyIdController,
                'Company ID',
                screenWidth,
                screenHeight,
                fieldHeight: fieldHeight,
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: _buildDateField(
                context,
                localizations.getString('joiningDate'),
                screenWidth,
                screenHeight,
                isBirthDate: false,
                fieldHeight: fieldHeight,
              ),
            ),
          ],
        ),
        SizedBox(height: screenHeight * 0.02),

        // Username (read-only with note that it will be generated)
        _buildTextField(
          context,
          _userNameController,
          'Username (Will be auto-generated if empty)',
          screenWidth,
          screenHeight,
          fieldHeight: fieldHeight,
          isReadOnly: true,
        ),
        SizedBox(height: screenHeight * 0.01),
        Text(
          'Note: Username will be generated automatically based on first and last name if left empty.',
          style: TextStyle(
            fontSize: screenWidth * 0.008,
            fontStyle: FontStyle.italic,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }

  Widget _buildTextField(
      BuildContext context,
      TextEditingController controller,
      String label,
      double screenWidth,
      double screenHeight,
      {double? fieldHeight,
        bool isRequired = false,
        bool isPassword = false,
        bool isReadOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label displayed above the field
        Text(
          isRequired ? "$label *" : label,
          style: TextStyle(
            fontSize: screenWidth * 0.01,
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        // Text field without a floating label
        Container(
          height: fieldHeight,
          decoration: BoxDecoration(
            border: Border.all(
              color: AdaptiveColors.borderColor(context),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(screenWidth * 0.005),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.01,
                vertical: fieldHeight != null
                    ? fieldHeight / 2 - screenWidth * 0.01
                    : screenHeight * 0.015,
              ),
            ),
            style: TextStyle(
              fontSize: screenWidth * 0.01,
              color: AdaptiveColors.primaryTextColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context,
      String label,
      double screenWidth,
      double screenHeight,
      {required bool isBirthDate, double? fieldHeight}) {
    final DateTime? dateValue = isBirthDate ? _dateOfBirth : _joiningDate;
    final String displayText = dateValue != null
        ? '${dateValue.day.toString().padLeft(2, '0')}/${dateValue.month
        .toString().padLeft(2, '0')}/${dateValue.year}'
        : label;

    return InkWell(
      onTap: () => _selectDate(context, isBirthDate),
      child: Container(
        height: fieldHeight,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.01,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AdaptiveColors.borderColor(context),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(screenWidth * 0.005),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              displayText,
              style: TextStyle(
                fontSize: screenWidth * 0.01,
                color: dateValue != null
                    ? AdaptiveColors.primaryTextColor(context)
                    : AdaptiveColors.secondaryTextColor(context),
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: AdaptiveColors.secondaryTextColor(context),
              size: screenWidth * 0.012,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(BuildContext context,
      String label,
      List<String> items,
      String? selectedValue,
      Function(String?) onChanged,
      double screenWidth,
      double screenHeight,
      {double? fieldHeight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      // Label above the dropdown
      Text(
      label,
      style: TextStyle(
        fontSize: screenWidth * 0.01,
        fontWeight: FontWeight.w500,
        color: AdaptiveColors.secondaryTextColor(context),
      ),
    ),
    SizedBox(height: screenHeight * 0.01),
    // Dropdown container
    Container(
    height: fieldHeight,
    padding: EdgeInsets.symmetric(
    horizontal: screenWidth * 0.01,
    ),
    decoration: BoxDecoration(
    border: Border.all(
    color: AdaptiveColors.borderColor(context),
    width: 1,
    ),
    borderRadius: BorderRadius.circular(screenWidth * 0.005),
    ),
    child: DropdownButtonHideUnderline(
    child: DropdownButton<String>(
    value: selectedValue,
    hint: Text(
    "Select $label",
    style: TextStyle(
    fontSize: screenWidth * 0.01,
    color: AdaptiveColors.tertiaryTextColor(context),
    ),
    ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            color: AdaptiveColors.secondaryTextColor(context),
            size: screenWidth * 0.012,
          ),
          isExpanded: true,
          dropdownColor: AdaptiveColors.cardColor(context),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: screenWidth * 0.01,
                  color: AdaptiveColors.primaryTextColor(context),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    )
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, double screenWidth, double screenHeight) {
    final localizations = AppLocalizations.of(context);
    final buttonHeight = screenHeight * 0.05; // Consistent button height

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.01),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AdaptiveColors.borderColor(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Cancel/Back button
          OutlinedButton(
            onPressed: () {
              if (_isProfessionalInfoActive) {
                _toggleTab(true);
              } else {
                Navigator.pop(context);
              }
            },
            style: OutlinedButton.styleFrom(
              minimumSize: Size(screenWidth * 0.08, buttonHeight),
              side: BorderSide(color: AdaptiveColors.borderColor(context)),
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.003),
              ),
            ),
            child: Text(
              _isPersonalInfoActive
                  ? localizations.getString('cancel')
                  : localizations.getString('back'),
              style: TextStyle(
                fontSize: screenWidth * 0.009,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.01),

          // Next/Apply button
          ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
              if (_isPersonalInfoActive) {
                // Move to professional information tab
                _toggleTab(false);
              } else {
                // Create and save employee
                _createEmployee();
              }
            },
            style: ElevatedButton.styleFrom(
              minimumSize: Size(screenWidth * 0.08, buttonHeight),
              backgroundColor: const Color(0xFF2E7D32),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.015,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenWidth * 0.003),
              ),
            ),
            child: _isLoading
                ? Container(
              width: screenWidth * 0.02,
              height: screenWidth * 0.02,
              padding: EdgeInsets.all(screenWidth * 0.005),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              _isPersonalInfoActive
                  ? localizations.getString('next')
                  : localizations.getString('apply'),
              style: TextStyle(
                fontSize: screenWidth * 0.009,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
