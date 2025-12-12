import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:provider/provider.dart';
import '../../../models/profile_model.dart';
import '../../../provider/profile_provider.dart';
import '../../settings/two_factor_dialog.dart';

class UserSettingsTab extends StatefulWidget {
  final ProfileModel profile;

  const UserSettingsTab({
    super.key,
    required this.profile,
  });

  @override
  State<UserSettingsTab> createState() => _UserSettingsTabState();
}

class _UserSettingsTabState extends State<UserSettingsTab> {
  bool _isUpdating = false;
  bool _showPasswordForm = false;
  bool _showOtpForm = false;

  // Password form controllers
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otpController = TextEditingController();

  // Password visibility states
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Form key for validation
  final _passwordFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Password Update Section
          _buildSectionCard(
            context,
            title: 'Update Password',
            subtitle: 'Change your account password for security',
            children: [
              if (!_showPasswordForm && !_showOtpForm)
                _buildPasswordUpdateButton(context)
              else if (_showPasswordForm && !_showOtpForm)
                _buildPasswordForm(context, localizations)
              else if (_showOtpForm)
                  _buildOtpForm(context, localizations),
            ],
          ),

          SizedBox(height: screenWidth * 0.04),

          // Account Information Section
          _buildSectionCard(
            context,
            title: 'Account Information',
            subtitle: 'View your account details',
            children: [
              _buildAccountInfo(context, localizations),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, {
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

  Widget _buildPasswordUpdateButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isUpdating ? null : () {
          setState(() {
            _showPasswordForm = true;
          });
        },
        icon: const Icon(Icons.lock_outline),
        label: const Text('Update Password'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AdaptiveColors.getPrimaryColor(context),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordForm(BuildContext context, AppLocalizations localizations) {
    return Form(
      key: _passwordFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Old Password Field
          TextFormField(
            controller: _oldPasswordController,
            obscureText: _obscureOldPassword,
            decoration: InputDecoration(
              labelText: 'Current Password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(_obscureOldPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureOldPassword = !_obscureOldPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your current password';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // New Password Field
          TextFormField(
            controller: _newPasswordController,
            obscureText: _obscureNewPassword,
            decoration: InputDecoration(
              labelText: 'New Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureNewPassword = !_obscureNewPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a new password';
              }
              if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Confirm Password Field
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirm New Password',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your new password';
              }
              if (value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isUpdating ? null : () {
                    setState(() {
                      _showPasswordForm = false;
                      _clearPasswordForm();
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isUpdating ? null : _submitPasswordUpdate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdaptiveColors.getPrimaryColor(context),
                    foregroundColor: Colors.white,
                  ),
                  child: _isUpdating
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Update'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOtpForm(BuildContext context, AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'An OTP code has been sent to your email. Please enter it below to confirm the password change.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // OTP Dialog Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isUpdating ? null : _showOtpDialog,
            icon: const Icon(Icons.security),
            label: const Text('Enter OTP Code'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdaptiveColors.getPrimaryColor(context),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Back Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isUpdating ? null : () {
              setState(() {
                _showOtpForm = false;
                _showPasswordForm = true;
                _otpController.clear();
              });
            },
            child: const Text('Back to Password Form'),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountInfo(BuildContext context, AppLocalizations localizations) {
    return Column(
      children: [
        _buildAccountInfoRow(
          context,
          'User ID',
          widget.profile.id.toString(),
          Icons.badge_outlined,
        ),
        _buildAccountInfoRow(
          context,
          'Account Type',
          _formatRole(widget.profile.role),
          Icons.account_circle_outlined,
        ),
        _buildAccountInfoRow(
          context,
          'Account Status',
          widget.profile.active ? 'Active' : 'Inactive',
          widget.profile.active ? Icons.check_circle : Icons.cancel,
          statusColor: widget.profile.active ? Colors.green : Colors.red,
        ),
        if (widget.profile.recruitmentDate != null && widget.profile.recruitmentDate!.isNotEmpty)
          _buildAccountInfoRow(
            context,
            'Member Since',
            _formatDate(widget.profile.recruitmentDate!),
            Icons.calendar_today_outlined,
          ),
      ],
    );
  }

  Widget _buildAccountInfoRow(BuildContext context, String label, String value, IconData icon, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: statusColor ?? AdaptiveColors.secondaryTextColor(context),
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
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusColor ?? AdaptiveColors.primaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPasswordUpdate() async {
    if (!_passwordFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

      // Call the password update API
      final success = await profileProvider.updatePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success) {
        // Move to OTP verification step
        setState(() {
          _showPasswordForm = false;
          _showOtpForm = true;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password update initiated. Please check for OTP code.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update password: ${profileProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating password: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _showOtpDialog() async {
    try {
      // Function to resend OTP
      Future<String?> resendOtpFunction() async {
        final success = await _resendPasswordOtp();
        if (success) {
          return "OTP resent successfully";
        }
        return null;
      }

      final otp = await TwoFactorDialog.showOtpDialog(
        context,
        null,
        resendOtpFunction,
      );

      if (otp != null && otp.isNotEmpty) {
        await _submitOtpVerification(otp);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error showing OTP dialog: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitOtpVerification(String otpCode) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

      // Verify OTP and complete password update
      final success = await profileProvider.verifyPasswordUpdateOtp(
        otpCode: otpCode,
      );

      if (success) {
        // Password updated successfully
        setState(() {
          _showOtpForm = false;
          _clearPasswordForm();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to verify OTP: ${profileProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error verifying OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<bool> _resendPasswordOtp() async {
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

      final success = await profileProvider.resendPasswordUpdateOtp(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('New OTP sent to your email'),
              backgroundColor: Colors.green,
            ),
          );
        }
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to resend OTP: ${profileProvider.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resending OTP: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  void _clearPasswordForm() {
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    _otpController.clear();
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}