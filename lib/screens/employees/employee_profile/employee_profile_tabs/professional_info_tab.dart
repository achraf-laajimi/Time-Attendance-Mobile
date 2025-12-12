import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import '../employee_profile_widgets/info_field.dart';

/// Tab displaying the professional information of an employee
class ProfessionalInfoTab extends StatelessWidget {
  final Map<String, dynamic> employeeData;

  const ProfessionalInfoTab({
    super.key,
    required this.employeeData,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return SingleChildScrollView(
      primary: true,
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
              Row(
                children: [
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('employeeId'),
                      value: employeeData['id'] ?? 'N/A',
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('userName'),
                      value: employeeData['username'] ?? 'N/A',
                      icon: Icons.account_circle_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('type'),
                      value: employeeData['type'] ?? 'N/A',
                      icon: Icons.business_center_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('department'),
                      value: employeeData['department'] ?? 'N/A',
                      icon: Icons.domain_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InfoField(
                      label: 'Company ID',
                      value: employeeData['companyId'] ?? 'N/A',
                      icon: Icons.badge_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('joiningDate'),
                      value: employeeData['recruitmentDate'] ?? 'N/A',
                      icon: Icons.date_range_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: InfoField(
                      label: 'Role',
                      value: employeeData['role'] ?? 'N/A',
                      icon: Icons.verified_user_outlined,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InfoField(
                      label: localizations.getString('workingDays'),
                      value: employeeData['workingDays'] ?? 'N/A',
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              InfoField(
                label: localizations.getString('officeLocation'),
                value: employeeData['officeLocation'] ?? 'N/A',
                icon: Icons.location_on_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }
}