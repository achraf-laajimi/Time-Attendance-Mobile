import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/screens/employees/employee_profile/employee_profile_tabs/personal_info_tab.dart';
import 'package:in_out/screens/employees/employee_profile/employee_profile_tabs/professional_info_tab.dart';
import 'package:in_out/theme/adaptive_colors.dart';

class ProfileTab extends StatelessWidget {
  final Map<String, dynamic> employeeData;

  const ProfileTab({
    super.key,
    required this.employeeData,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Personal/Professional tabs
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: AdaptiveColors.cardColor(context),
              border: Border(
                bottom: BorderSide(
                  color: AdaptiveColors.borderColor(context),
                  width: 1,
                ),
              ),
            ),
            child: TabBar(
              labelColor: AdaptiveColors.primaryGreen,
              unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
              indicatorColor: AdaptiveColors.primaryGreen,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: [
                Tab(
                  text: localizations.getString('personalInformation'),
                ),
                Tab(
                  text: localizations.getString('professionalInformation'),
                ),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                // Personal Information
                PersonalInfoTab(employeeData: employeeData),

                // Professional Information
                ProfessionalInfoTab(employeeData: employeeData),
              ],
            ),
          ),
        ],
      ),
    );
  }
}