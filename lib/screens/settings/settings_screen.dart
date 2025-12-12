// lib/screens/settings/settings_screen.dart
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/provider/user_settings_provider.dart';
import 'package:in_out/services/navigation_service.dart';
import 'package:in_out/provider/profile_provider.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/responsive_navigation_scaffold.dart';
import 'package:in_out/widget/user_profile_header.dart';
import 'package:in_out/widget/bottom_navigation_bar.dart';
import 'package:in_out/widget/translate_text.dart';
import 'package:provider/provider.dart';
import 'package:in_out/auth/auth_service.dart';
import 'package:in_out/screens/Login/login_page.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../ai/face_registration_screen.dart';
import '../../services/locales_service.dart';
import '../notifications/notifications_screen.dart';
import '../profile/user_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 8;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();

  bool _mobilePushEnabled = true;
  bool _desktopPushEnabled = true;
  bool _emailNotificationsEnabled = true;

  Future<List<String>>? _supportedLocalesFuture;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    LocalesService().initialize();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider =
      Provider.of<ProfileProvider>(context, listen: false);

      if (profileProvider.userProfile == null && !profileProvider.isLoading) {
        profileProvider.loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    NavigationService.navigateToScreen(context, index);
  }

  // Updated methods with modern card design
  Widget _buildSectionCard(BuildContext context, {
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AdaptiveColors.cardColor(context),
      margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.04),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.contains('.') ? AppLocalizations.of(context).getString(title) : title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle.contains('.') ? AppLocalizations.of(context).getString(subtitle) : subtitle,
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

  Widget _buildThemeSelector(BuildContext context) {
    return Consumer<UserSettingsProvider>(
      builder: (context, userSettings, child) {
        final currentTheme = userSettings.currentSettings.themeMode;
        final localizations = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Mode',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    context,
                    localizations.getString('light'),
                    Icons.light_mode,
                    'light',
                    currentTheme == 'light',
                        () => _changeTheme('light', context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeOption(
                    context,
                    localizations.getString('dark'),
                    Icons.dark_mode,
                    'dark',
                    currentTheme == 'dark',
                        () => _changeTheme('dark', context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildThemeOption(
                    context,
                    localizations.getString('system'),
                    Icons.brightness_auto,
                    'system',
                    currentTheme == 'system',
                        () => _changeTheme('system', context),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildThemeOption(BuildContext context, String title, IconData icon, String value, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AdaptiveColors.getPrimaryColor(context).withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AdaptiveColors.getPrimaryColor(context)
                : AdaptiveColors.borderColor(context),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AdaptiveColors.getPrimaryColor(context)
                  : AdaptiveColors.secondaryTextColor(context),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? AdaptiveColors.getPrimaryColor(context)
                    : AdaptiveColors.secondaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context) {
    return Consumer<UserSettingsProvider>(
      builder: (context, userSettings, child) {
        final profileProvider = Provider.of<ProfileProvider>(context);
        final currentLanguage = profileProvider.userProfile?.locale ?? userSettings.currentSettings.language;
        final localizations = AppLocalizations.of(context);
        final localesService = LocalesService();

        return ValueListenableBuilder<List<String>?>(
          valueListenable: localesService.supportedLocalesNotifier,
          builder: (context, supportedLocales, child) {
            // If not loaded yet, check loading state
            if (supportedLocales == null) {
              return ValueListenableBuilder<bool>(
                valueListenable: localesService.isLoadingNotifier,
                builder: (context, isLoading, child) {
                  if (isLoading) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localizations.getString('language'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 48,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Trigger load if not loading and no data
                    localesService.getSupportedLocales();
                    return const SizedBox.shrink();
                  }
                },
              );
            }

            final localeInfo = LocalesService.getLocaleInfo();

            // If only one language is supported, show it without ability to change
            if (supportedLocales.length == 1) {
              final locale = supportedLocales.first;
              final info = localeInfo[locale];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.getString('language'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AdaptiveColors.primaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AdaptiveColors.backgroundColor(context),
                      border: Border.all(
                        color: AdaptiveColors.borderColor(context),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AdaptiveColors.secondaryTextColor(context),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              info?['code'] ?? locale.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                localizations.getString(info?['name'] ?? 'language'),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AdaptiveColors.primaryTextColor(context),
                                ),
                              ),
                              Text(
                                'Only language available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AdaptiveColors.secondaryTextColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }

            // Multiple languages supported - show selectable options
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.getString('language'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AdaptiveColors.primaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 12),
                // For 2-3 languages, show them side by side
                if (supportedLocales.length <= 3)
                  Row(
                    children: supportedLocales.map((locale) {
                      final info = localeInfo[locale];
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: locale != supportedLocales.last ? 12 : 0,
                          ),
                          child: _buildLanguageOption(
                            context,
                            localizations.getString(info?['name'] ?? locale),
                            info?['code'] ?? locale.toUpperCase(),
                            locale,
                            currentLanguage == locale,
                                () => _updateLanguage(locale),
                          ),
                        ),
                      );
                    }).toList(),
                  )
                // For more than 3 languages, show in a grid
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: supportedLocales.length,
                    itemBuilder: (context, index) {
                      final locale = supportedLocales[index];
                      final info = localeInfo[locale];
                      return _buildLanguageOption(
                        context,
                        localizations.getString(info?['name'] ?? locale),
                        info?['code'] ?? locale.toUpperCase(),
                        locale,
                        currentLanguage == locale,
                            () => _updateLanguage(locale),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageOptionWithNativeName(
      BuildContext context,
      String translatedName,
      String nativeName,
      String code,
      String value,
      bool isSelected,
      VoidCallback onTap,
      )
  {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AdaptiveColors.getPrimaryColor(context).withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AdaptiveColors.getPrimaryColor(context)
                : AdaptiveColors.borderColor(context),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? AdaptiveColors.getPrimaryColor(context)
                    : AdaptiveColors.secondaryTextColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    translatedName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? AdaptiveColors.getPrimaryColor(context)
                          : AdaptiveColors.primaryTextColor(context),
                    ),
                  ),
                  if (nativeName != translatedName)
                    Text(
                      nativeName,
                      style: TextStyle(
                        fontSize: 12,
                        color: AdaptiveColors.secondaryTextColor(context),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, String code, String value, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AdaptiveColors.getPrimaryColor(context).withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AdaptiveColors.getPrimaryColor(context)
                : AdaptiveColors.borderColor(context),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? AdaptiveColors.getPrimaryColor(context)
                    : AdaptiveColors.secondaryTextColor(context),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? AdaptiveColors.getPrimaryColor(context)
                      : AdaptiveColors.primaryTextColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector(BuildContext context) {
    return Consumer<UserSettingsProvider>(
      builder: (context, userSettings, child) {
        final settings = userSettings.currentSettings;
        final localizations = AppLocalizations.of(context);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Colors',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildColorOption(
                    context,
                    localizations.getString('primaryColor'),
                    settings.primaryColor,
                        () => _showColorPicker(context, true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildColorOption(
                    context,
                    localizations.getString('secondaryColor'),
                    settings.secondaryColor,
                        () => _showColorPicker(context, false),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorOption(BuildContext context, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AdaptiveColors.backgroundColor(context),
          border: Border.all(color: AdaptiveColors.borderColor(context)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AdaptiveColors.borderColor(context),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AdaptiveColors.primaryTextColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwoFactorToggle(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final isEnabled = profileProvider.userProfile?.secondFactorEnabled ?? false;
        final localizations = AppLocalizations.of(context);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AdaptiveColors.backgroundColor(context),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AdaptiveColors.borderColor(context)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isEnabled ? Colors.green : Colors.orange).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEnabled ? Icons.security : Icons.security_outlined,
                  color: isEnabled ? Colors.green : Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.getString('twoFactorAuth'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AdaptiveColors.primaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEnabled ? 'Enabled' : 'Disabled',
                      style: TextStyle(
                        fontSize: 14,
                        color: isEnabled ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: isEnabled,
                onChanged: (value) => _updateTwoFactorAuthentication(value),
                activeColor: Colors.green,
                inactiveThumbColor: Colors.grey,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationToggle(BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdaptiveColors.backgroundColor(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AdaptiveColors.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AdaptiveColors.getPrimaryColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AdaptiveColors.getPrimaryColor(context),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).getString(title),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AdaptiveColors.primaryTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context).getString(subtitle),
                  style: TextStyle(
                    fontSize: 14,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AdaptiveColors.getPrimaryColor(context),
            inactiveThumbColor: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        final profile = profileProvider.userProfile;
        final screenWidth = MediaQuery.of(context).size.width;

        return Container(
          margin: EdgeInsets.only(bottom: screenWidth * 0.04),
          child: Container(
            decoration: BoxDecoration(
              color: AdaptiveColors.cardColor(context),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AdaptiveColors.shadowColor(context).withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AdaptiveColors.shadowColor(context).withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const UserProfileScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Row(
                    children: [
                      // Enhanced Avatar with status indicator
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AdaptiveColors.getPrimaryColor(context),
                                  AdaptiveColors.getPrimaryColor(context).withOpacity(0.7),
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: screenWidth * 0.07,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: screenWidth * 0.065,
                                backgroundColor: AdaptiveColors.getPrimaryColor(context).withOpacity(0.1),
                                child: Text(
                                  profile != null
                                      ? '${profile.firstName.isNotEmpty ? profile.firstName[0] : ''}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}'
                                      : 'U',
                                  style: TextStyle(
                                    color: AdaptiveColors.getPrimaryColor(context),
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.05,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Status indicator
                          if (profile != null)
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: profile.active ? Colors.green : Colors.orange,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AdaptiveColors.cardColor(context),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      SizedBox(width: screenWidth * 0.04),

                      // Profile info with enhanced styling
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name with subtle background
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AdaptiveColors.getPrimaryColor(context).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                profile != null
                                    ? '${profile.firstName} ${profile.lastName}'
                                    : 'Your Profile',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.042,
                                  fontWeight: FontWeight.bold,
                                  color: AdaptiveColors.primaryTextColor(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            SizedBox(height: screenWidth * 0.015),

                            // Role/designation with icon
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AdaptiveColors.secondaryTextColor(context).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.work_outline,
                                    size: 14,
                                    color: AdaptiveColors.secondaryTextColor(context),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    profile != null
                                        ? _formatRole(profile.designation ?? profile.role)
                                        : 'View and edit your profile',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: AdaptiveColors.secondaryTextColor(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),

                            if (profile != null) ...[
                              SizedBox(height: screenWidth * 0.015),

                              // Additional info row
                              Row(
                                children: [
                                  // Account type indicator
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: profile.active
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: profile.active
                                            ? Colors.green.withOpacity(0.3)
                                            : Colors.orange.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      profile.active ? 'Active' : 'Inactive',
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.028,
                                        color: profile.active ? Colors.green : Colors.orange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  // 2FA indicator
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: profile.secondFactorEnabled
                                          ? Colors.green.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Icon(
                                      profile.secondFactorEnabled
                                          ? Icons.security
                                          : Icons.security_outlined,
                                      size: 12,
                                      color: profile.secondFactorEnabled
                                          ? Colors.green
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(width: screenWidth * 0.02),

                      // Enhanced arrow with background
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AdaptiveColors.getPrimaryColor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: AdaptiveColors.getPrimaryColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSettingsHeader(String titleKey, String subtitleKey) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TranslateText(
          titleKey,
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: AdaptiveColors.primaryTextColor(context),
          ),
        ),
        SizedBox(height: screenWidth * 0.01),
        TranslateText(
          subtitleKey,
          style: TextStyle(
            fontSize: screenWidth * 0.03,
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
        SizedBox(height: screenWidth * 0.04),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.02,
      ),
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show confirmation dialog
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Logout Confirmation'),
                content: const Text('Are you sure you want to logout?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Close the dialog
                      Navigator.of(context).pop();

                      // Show loading indicator
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );

                      // Perform logout
                      await AuthService.logout(context);

                      // Close loading indicator
                      Navigator.of(context).pop();

                      // Navigate to login page
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                            (route) => false,
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            },
          );
        },
        icon: const Icon(
          Icons.logout,
          color: Colors.white,
        ),
        label: const Text('Logout'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  // Helper methods
  void _changeTheme(String themeMode, BuildContext context) {
    final userSettingsProvider =
    Provider.of<UserSettingsProvider>(context, listen: false);
    userSettingsProvider.changeThemeMode(themeMode);

    if (themeMode == 'light') {
      AdaptiveTheme.of(context).setLight();
    } else if (themeMode == 'dark') {
      AdaptiveTheme.of(context).setDark();
    } else if (themeMode == 'system') {
      AdaptiveTheme.of(context).setSystem();
    }
  }

  Future<void> _updateLanguage(String languageCode) async {
    final profileProvider =
    Provider.of<ProfileProvider>(context, listen: false);
    final userSettingsProvider =
    Provider.of<UserSettingsProvider>(context, listen: false);

    // First update the UI (UserSettingsProvider) for immediate feedback
    userSettingsProvider.changeLanguage(languageCode);

    // Then update the backend
    final success = await profileProvider.updateLanguage(languageCode);

    if (!success) {
      // Show error message but don't revert the UI (to avoid jarring language switch)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
            Text("Failed to update language: ${profileProvider.error}")),
      );
    }
  }

  Future<void> _updateTwoFactorAuthentication(bool enabled) async {
    if (!mounted) return;
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.setTwoFactorEnabledUIOnly(enabled);
    final success = await profileProvider.updateTwoFactorAuthentication(enabled, context);
    if (!mounted) return;
    try {
      await profileProvider.refreshProfile();
    } catch (e) {
      print("Erreur lors du rafraîchissement du profil: $e");
    }
    if (!mounted) return;
    Future.microtask(() {
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "L'authentification à deux facteurs a été ${enabled ? 'activée' : 'désactivée'} avec succès"
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else if (profileProvider.error.isNotEmpty && mounted) {
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Échec de mise à jour: ${profileProvider.error}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  void _showColorPicker(BuildContext context, bool isPrimary) {
    final userSettingsProvider =
    Provider.of<UserSettingsProvider>(context, listen: false);
    final settings = userSettingsProvider.currentSettings;
    Color pickerColor =
    isPrimary ? settings.primaryColor : settings.secondaryColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            isPrimary
                ? AppLocalizations.of(context).getString('selectPrimaryColor')
                : AppLocalizations.of(context)
                .getString('selectSecondaryColor'),
          ),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: pickerColor,
              onColorChanged: (Color color) {
                pickerColor = color;
              },
              pickerAreaHeightPercent: 0.8,
              enableAlpha: false,
              displayThumbColor: true,
              paletteType: PaletteType.hsvWithHue,
              labelTypes: const [ColorLabelType.rgb, ColorLabelType.hex],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context).getString('cancel')),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context).getString('apply')),
              onPressed: () {
                // Apply changes to both providers
                if (isPrimary) {
                  userSettingsProvider.changePrimaryColor(pickerColor);
                } else {
                  userSettingsProvider.changeSecondaryColor(pickerColor);
                }

                // Rebuild the entire app to apply color changes
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;

    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            Expanded(
              child: Consumer<ProfileProvider>(
                  builder: (context, profileProvider, child) {
                    // Loading state
                    if (profileProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Error state
                    if (profileProvider.error.isNotEmpty &&
                        profileProvider.userProfile == null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              profileProvider.error,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            ElevatedButton(
                              onPressed: () => profileProvider.loadProfile(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    // Success state - show settings
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.all(padding),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              // Settings Header
                              _buildSettingsHeader("settings", "allSystemSettings"),

                              // User Profile Card
                              _buildProfileCard(context),

                              // Appearance Section
                              _buildSectionCard(
                                context,
                                title: "appearance",
                                subtitle: "customizeTheme",
                                children: [
                                  _buildThemeSelector(context),
                                  const SizedBox(height: 16),
                                  _buildLanguageSelector(context),
                                  const SizedBox(height: 16),
                                  _buildColorSelector(context),
                                ],
                              ),

                              // Security Section
                              _buildSectionCard(
                                context,
                                title: "twoFactorAuth",
                                subtitle: "twoFactorDescription",
                                children: [
                                  _buildTwoFactorToggle(context),
                                ],
                              ),

                              // Notifications Section
                              _buildSectionCard(
                                context,
                                title: "Notifications",
                                subtitle: "Manage your notification preferences",
                                children: [
                                  _buildNotificationToggle(
                                    context,
                                    title: "mobilePushNotifications",
                                    subtitle: "receivePushNotification",
                                    value: _mobilePushEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _mobilePushEnabled = value;
                                      });
                                    },
                                    icon: Icons.phone_android,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildNotificationToggle(
                                    context,
                                    title: "desktopNotification",
                                    subtitle: "desktopPushDescription",
                                    value: _desktopPushEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _desktopPushEnabled = value;
                                      });
                                    },
                                    icon: Icons.desktop_windows,
                                  ),
                                  const SizedBox(height: 12),
                                  _buildNotificationToggle(
                                    context,
                                    title: "emailNotifications",
                                    subtitle: "receiveEmailNotification",
                                    value: _emailNotificationsEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _emailNotificationsEnabled = value;
                                      });
                                    },
                                    icon: Icons.email_outlined,
                                  ),
                                ],
                              ),

                              // Face Recognition Section
                              _buildSectionCard(
                                context,
                                title: "Remote Attendance",
                                subtitle: "Biometric authentication settings",
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AdaptiveColors.backgroundColor(context),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AdaptiveColors.borderColor(context)),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => const FaceRegistrationScreen(),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: AdaptiveColors.getPrimaryColor(context).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.face,
                                              color: AdaptiveColors.getPrimaryColor(context),
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "Face Recognition Setup",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500,
                                                    color: AdaptiveColors.primaryTextColor(context),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  "Check in/out remotely using Face ID",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AdaptiveColors.secondaryTextColor(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_forward_ios,
                                            size: 16,
                                            color: AdaptiveColors.secondaryTextColor(context),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Logout Button
                              _buildLogoutButton(context),
                            ]),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}