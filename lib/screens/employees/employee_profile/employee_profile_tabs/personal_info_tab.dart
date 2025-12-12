import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import '../employee_profile_widgets/info_field.dart';

/// Tab displaying the personal information of an employee
class PersonalInfoTab extends StatelessWidget {
  final Map<String, dynamic> employeeData;

  const PersonalInfoTab({
    super.key,
    required this.employeeData,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      primary: true,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12.0),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
        color: AdaptiveColors.cardColor(context),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // First/Last Name row
              Row(
                children: [
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('firstName'),
                      value: employeeData['firstName'] ?? '',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('lastName'),
                      value: employeeData['lastName'] ?? '',
                      icon: Icons.person_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Primary Email field
              InfoField(
                label: localizations.getString('emailAddress'),
                value: employeeData['email'] ?? '',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 24),

              // Personal Email field
              InfoField(
                label: 'Personal Email', // Add to localizations if needed
                value: employeeData['personalEmail'] ?? 'N/A',
                icon: Icons.alternate_email,
              ),
              const SizedBox(height: 24),

              // Mobile Number field
              InfoField(
                label: localizations.getString('mobileNumber'),
                value: employeeData['phoneNumber'] ?? '',
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 24),

              // Other personal info fields
              Row(
                children: [
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('dateOfBirth'),
                      value: employeeData['birthDate'] ?? '',
                      icon: Icons.cake_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('maritalStatus'),
                      value: employeeData['maritalStatus'] ?? '',
                      icon: Icons.favorite_border,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // More personal info
              Row(
                children: [
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('gender'),
                      value: employeeData['gender'] ?? '',
                      icon: Icons.person_outline,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('nationality'),
                      value: employeeData['nationality'] ?? '',
                      icon: Icons.flag_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Address field
              InfoField(
                label: localizations.getString('address'),
                value: employeeData['address'] ?? 'N/A',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 24),

              // Active status field
              InfoField(
                label: 'Account Status',
                value: employeeData['active'] == true ? 'Active' : 'Inactive',
                icon: Icons.verified_user_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}