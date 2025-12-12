// lib/screens/profile/user_profile_tabs/user_professional_info_tab.dart
import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import '../../../models/profile_model.dart';

class UserProfessionalInfoTab extends StatelessWidget {
  final ProfileModel profile;

  const UserProfessionalInfoTab({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionCard(
            context,
            title: 'Employee Information',
            children: [
              _buildInfoRow(
                context,
                label: 'Employee ID',
                value: profile.id.toString(),
                icon: Icons.badge_outlined,
              ),
              _buildInfoRow(
                context,
                label: localizations.getString('userName'),
                value: profile.username,
                icon: Icons.account_circle_outlined,
              ),
              if (profile.companyId != null && profile.companyId!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: 'Company ID',
                  value: profile.companyId!,
                  icon: Icons.business_outlined,
                ),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          _buildSectionCard(
            context,
            title: 'Role & Position',
            children: [
              _buildInfoRow(
                context,
                label: 'Role',
                value: _formatRole(profile.role),
                icon: Icons.verified_user_outlined,
              ),
              if (profile.designation != null && profile.designation!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: localizations.getString('designation'),
                  value: profile.designation!,
                  icon: Icons.work_outline,
                ),
              if (profile.type != null && profile.type!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: localizations.getString('type'),
                  value: _formatType(profile.type!),
                  icon: Icons.business_center_outlined,
                ),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          _buildSectionCard(
            context,
            title: 'Employment Details',
            children: [
              if (profile.recruitmentDate != null && profile.recruitmentDate!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: localizations.getString('joiningDate'),
                  value: _formatDate(profile.recruitmentDate!),
                  icon: Icons.date_range_outlined,
                ),
              _buildInfoRow(
                context,
                label: 'Account Status',
                value: profile.active ? 'Active' : 'Inactive',
                icon: profile.active ? Icons.check_circle_outline : Icons.cancel_outlined,
                isStatus: true,
                statusColor: profile.active ? Colors.green : Colors.red,
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          _buildSectionCard(
            context,
            title: 'Security & Preferences',
            children: [
              _buildInfoRow(
                context,
                label: 'Language',
                value: _formatLanguage(profile.locale),
                icon: Icons.language_outlined,
              ),
              _buildInfoRow(
                context,
                label: 'Two-Factor Authentication',
                value: profile.secondFactorEnabled ? 'Enabled' : 'Disabled',
                icon: profile.secondFactorEnabled ? Icons.security : Icons.security_outlined,
                isStatus: true,
                statusColor: profile.secondFactorEnabled ? Colors.green : Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {required String title, required List<Widget> children}) {
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
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool isStatus = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (statusColor ?? AdaptiveColors.getPrimaryColor(context)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: statusColor ?? AdaptiveColors.getPrimaryColor(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      value.isNotEmpty ? value : 'Not specified',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isStatus && statusColor != null
                            ? statusColor
                            : (value.isNotEmpty
                            ? AdaptiveColors.primaryTextColor(context)
                            : AdaptiveColors.tertiaryTextColor(context)),
                      ),
                    ),
                    if (isStatus && statusColor != null)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatRole(String role) {
    switch (role.toUpperCase()) {
      case 'USER':
        return 'Employee';
      case 'ADMIN':
        return 'Administrator';
      case 'MANAGER':
        return 'Manager';
      case 'HR':
        return 'Human Resources';
      default:
        return role.replaceAll('_', ' ').split(' ')
            .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join(' ');
    }
  }

  String _formatType(String type) {
    switch (type.toUpperCase()) {
      case 'OFFICE':
        return 'Office Based';
      case 'REMOTE':
        return 'Remote';
      case 'HYBRID':
        return 'Hybrid';
      default:
        return type.replaceAll('_', ' ').split(' ')
            .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1).toLowerCase())
            .join(' ');
    }
  }

  String _formatLanguage(String locale) {
    switch (locale.toLowerCase()) {
      case 'en':
        return 'English';
      case 'fr':
        return 'French';
      default:
        return locale.toUpperCase();
    }
  }
}