// lib/screens/profile/user_profile_tabs/user_personal_info_tab.dart
import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import '../../../models/profile_model.dart';

class UserPersonalInfoTab extends StatelessWidget {
  final ProfileModel profile;

  const UserPersonalInfoTab({
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
            title: 'Basic Information',
            children: [
              _buildInfoRow(
                context,
                label: localizations.getString('firstName'),
                value: profile.firstName,
                icon: Icons.person_outline,
              ),
              _buildInfoRow(
                context,
                label: localizations.getString('lastName'),
                value: profile.lastName,
                icon: Icons.person_outline,
              ),
              _buildInfoRow(
                context,
                label: localizations.getString('userName'),
                value: profile.username,
                icon: Icons.account_circle_outlined,
              ),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          _buildSectionCard(
            context,
            title: 'Contact Information',
            children: [
              _buildInfoRow(
                context,
                label: localizations.getString('emailAddress'),
                value: profile.email,
                icon: Icons.email_outlined,
              ),
              if (profile.personalEmail != null && profile.personalEmail!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: 'Personal Email',
                  value: profile.personalEmail!,
                  icon: Icons.alternate_email,
                ),
              if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: localizations.getString('mobileNumber'),
                  value: profile.phoneNumber!,
                  icon: Icons.phone_outlined,
                ),
              if (profile.address != null && profile.address!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: localizations.getString('address'),
                  value: profile.address!,
                  icon: Icons.location_on_outlined,
                ),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          _buildSectionCard(
            context,
            title: 'Personal Details',
            children: [
              if (profile.birthDate != null && profile.birthDate!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: localizations.getString('dateOfBirth'),
                  value: _formatDate(profile.birthDate!),
                  icon: Icons.cake_outlined,
                ),
              if (profile.gender != null && profile.gender!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: localizations.getString('gender'),
                  value: _formatGender(profile.gender!),
                  icon: Icons.person_outline,
                ),
              if (profile.maritalStatus != null && profile.maritalStatus!.isNotEmpty)
                _buildInfoRow(
                  context,
                  label: localizations.getString('maritalStatus'),
                  value: _formatMaritalStatus(profile.maritalStatus!),
                  icon: Icons.favorite_border,
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdaptiveColors.getPrimaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AdaptiveColors.getPrimaryColor(context),
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
                Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: value.isNotEmpty
                        ? AdaptiveColors.primaryTextColor(context)
                        : AdaptiveColors.tertiaryTextColor(context),
                  ),
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

  String _formatGender(String gender) {
    switch (gender.toUpperCase()) {
      case 'MALE':
        return 'Male';
      case 'FEMALE':
        return 'Female';
      case 'OTHER':
        return 'Other';
      default:
        return gender;
    }
  }

  String _formatMaritalStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SINGLE':
        return 'Single';
      case 'MARRIED':
        return 'Married';
      case 'DIVORCED':
        return 'Divorced';
      case 'WIDOWED':
        return 'Widowed';
      default:
        return status;
    }
  }
}