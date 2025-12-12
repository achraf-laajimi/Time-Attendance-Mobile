// lib/screens/profile/edit_user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/profile_model.dart';
import '../../provider/profile_provider.dart';
import '../../services/profile_service.dart';

class EditUserProfileScreen extends StatefulWidget {
  final ProfileModel profile;
  final VoidCallback? onProfileUpdated;

  const EditUserProfileScreen({
    super.key,
    required this.profile,
    this.onProfileUpdated,
  });

  @override
  State<EditUserProfileScreen> createState() => _EditUserProfileScreenState();
}

class _EditUserProfileScreenState extends State<EditUserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Text controllers
  late TextEditingController _personalEmailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  // Selected dropdown values
  String? _selectedGender;
  String? _selectedMaritalStatus;

  // Date field
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize controllers with existing profile data
    _personalEmailController = TextEditingController(text: widget.profile.personalEmail ?? '');
    _phoneController = TextEditingController(text: widget.profile.phoneNumber ?? '');
    _addressController = TextEditingController(text: widget.profile.address ?? '');

    // Initialize dropdown values
    _selectedGender = widget.profile.gender;
    _selectedMaritalStatus = widget.profile.maritalStatus;

    // Initialize birth date
    if (widget.profile.birthDate != null && widget.profile.birthDate!.isNotEmpty) {
      try {
        _birthDate = DateTime.parse(widget.profile.birthDate!);
      } catch (e) {
        print('Error parsing birth date: $e');
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _personalEmailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _selectBirthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create updated profile
      final updatedProfile = widget.profile.copyWith(
        personalEmail: _personalEmailController.text.trim().isEmpty
            ? null
            : _personalEmailController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        gender: _selectedGender,
        maritalStatus: _selectedMaritalStatus,
        birthDate: _birthDate != null ? _formatDate(_birthDate) : null,
      );

      // Update via ProfileProvider
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      final profileService = ProfileService();

      final result = await profileService.updateProfile(updatedProfile);

      if (result["success"]) {
        // Refresh the provider
        await profileProvider.loadProfile();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Call callback if provided
          if (widget.onProfileUpdated != null) {
            widget.onProfileUpdated!();
          }

          // Navigate back
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${result["message"]}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Edit Profile',
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
            Tab(
              icon: const Icon(Icons.person_outline, size: 18),
              text: localizations.getString('personalInformation'),
            ),
            Tab(
              icon: const Icon(Icons.contact_mail_outlined, size: 18),
              text: 'Contact Info',
            ),
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
            _buildPersonalInfoForm(context, screenWidth),
            _buildContactInfoForm(context, screenWidth),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(screenWidth * 0.04),
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
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  localizations.getString('cancel'),
                  style: TextStyle(
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AdaptiveColors.primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                    : Text(
                  'Update Profile',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoForm(BuildContext context, double screenWidth) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Read-only info section
          _buildInfoSection(
            context,
            title: 'Account Information',
            subtitle: 'These details cannot be changed',
            children: [
              _buildReadOnlyField(
                label: localizations.getString('firstName'),
                value: widget.profile.firstName,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildReadOnlyField(
                label: localizations.getString('lastName'),
                value: widget.profile.lastName,
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildReadOnlyField(
                label: localizations.getString('emailAddress'),
                value: widget.profile.email,
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),
              _buildReadOnlyField(
                label: localizations.getString('userName'),
                value: widget.profile.username,
                icon: Icons.account_circle_outlined,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Editable personal details
          _buildInfoSection(
            context,
            title: 'Personal Details',
            subtitle: 'Update your personal information',
            children: [
              _buildDatePickerField(
                context: context,
                label: localizations.getString('dateOfBirth'),
                date: _birthDate,
                onTap: () => _selectBirthDate(context),
                icon: Icons.cake_outlined,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: localizations.getString('gender'),
                value: _selectedGender,
                items: ['MALE', 'FEMALE', 'OTHER'],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              _buildDropdownField(
                label: localizations.getString('maritalStatus'),
                value: _selectedMaritalStatus,
                items: ['SINGLE', 'MARRIED', 'DIVORCED', 'WIDOWED'],
                onChanged: (value) {
                  setState(() {
                    _selectedMaritalStatus = value;
                  });
                },
                icon: Icons.favorite_border,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoForm(BuildContext context, double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            context,
            title: 'Contact Information',
            subtitle: 'Update your contact details',
            children: [
              _buildFormField(
                label: 'Personal Email',
                controller: _personalEmailController,
                icon: Icons.alternate_email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty && !value.contains('@')) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: AppLocalizations.of(context).getString('mobileNumber'),
                controller: _phoneController,
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              _buildFormField(
                label: AppLocalizations.of(context).getString('address'),
                controller: _addressController,
                icon: Icons.location_on_outlined,
                maxLines: 3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AdaptiveColors.cardColor(context),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: AdaptiveColors.secondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
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
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: AdaptiveColors.cardColor(context),
            prefixIcon: Icon(
              icon,
              color: AdaptiveColors.secondaryTextColor(context),
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AdaptiveColors.borderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AdaptiveColors.borderColor(context)),
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

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AdaptiveColors.tertiaryTextColor(context).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdaptiveColors.borderColor(context)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AdaptiveColors.tertiaryTextColor(context),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: AdaptiveColors.tertiaryTextColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
  }) {
    String displayText = date != null
        ? DateFormat('dd/MM/yyyy').format(date)
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
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: AdaptiveColors.cardColor(context),
              border: Border.all(color: AdaptiveColors.borderColor(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AdaptiveColors.secondaryTextColor(context),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 16,
                      color: date != null
                          ? AdaptiveColors.primaryTextColor(context)
                          : AdaptiveColors.tertiaryTextColor(context),
                    ),
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AdaptiveColors.cardColor(context),
            border: Border.all(color: AdaptiveColors.borderColor(context)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AdaptiveColors.secondaryTextColor(context),
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    hint: Text(
                      'Select $label',
                      style: TextStyle(
                        color: AdaptiveColors.tertiaryTextColor(context),
                      ),
                    ),
                    dropdownColor: AdaptiveColors.cardColor(context),
                    style: TextStyle(
                      color: AdaptiveColors.primaryTextColor(context),
                      fontSize: 16,
                    ),
                    items: items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(_formatDropdownValue(item)),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDropdownValue(String value) {
    switch (value.toUpperCase()) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      case 'SINGLE':
        return 'Single';
      case 'MARRIED':
        return 'Married';
      case 'DIVORCED':
        return 'Divorced';
      case 'WIDOWED':
        return 'Widowed';
      default:
        return value.replaceAll('_', ' ').split(' ')
            .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join(' ');
    }
  }
}