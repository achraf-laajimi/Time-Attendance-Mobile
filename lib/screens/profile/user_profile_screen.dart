import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:provider/provider.dart';
import '../../provider/profile_provider.dart';
import '../../models/profile_model.dart';
import 'edit_user_profile_screen.dart';
import 'user_profile_tabs/user_personal_info_tab.dart';
import 'user_profile_tabs/user_professional_info_tab.dart';
import 'user_profile_tabs/user_settings_tab.dart';
import '../../widget/responsive_navigation_scaffold.dart';
import '../../services/navigation_service.dart';
import '../../widget/user_profile_header.dart';
import '../../screens/notifications/notifications_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 4; // Selected index for navigation (User Profile is 4)
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProfile();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  Future<void> _loadProfile() async {
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);

    if (profileProvider.userProfile == null) {
      await profileProvider.loadProfile();
    }

    setState(() {
      _isLoading = false;
      _errorMessage = profileProvider.error;
    });
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.refreshProfile();

    setState(() {
      _isLoading = false;
      _errorMessage = profileProvider.error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Consumer<ProfileProvider>(
                builder: (context, profileProvider, child) {
                  if (_isLoading || profileProvider.isLoading) {
                    return _buildLoadingScreen(localizations);
                  }

                  if (_errorMessage.isNotEmpty ||
                      profileProvider.error.isNotEmpty) {
                    return _buildErrorScreen(
                        localizations,
                        profileProvider.error.isNotEmpty
                            ? profileProvider.error
                            : _errorMessage);
                  }

                  if (profileProvider.userProfile == null) {
                    return _buildNoDataScreen(localizations);
                  }

                  return _buildProfileContent(
                      context, localizations, profileProvider.userProfile!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingScreen(AppLocalizations localizations) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorScreen(AppLocalizations localizations, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshProfile,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataScreen(AppLocalizations localizations) {
    return Center(
      child: Text(
        'No profile data available',
        style: TextStyle(
          color: AdaptiveColors.primaryTextColor(context),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context,
      AppLocalizations localizations, ProfileModel profile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverAppBar(
          expandedHeight: screenHeight * 0.25,
          floating: false,
          pinned: true,
          backgroundColor: AdaptiveColors.cardColor(context),
          flexibleSpace: FlexibleSpaceBar(
            background: _buildProfileHeader(context, profile),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditUserProfileScreen(
                      profile: profile,
                      onProfileUpdated: _refreshProfile,
                    ),
                  ),
                );
              },
              tooltip: localizations.getString('edit'),
            ),
          ],
        ),

        // Tab Bar
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.person_outline, size: 18),
                  text: localizations.getString('personalInformation'),
                ),
                Tab(
                  icon: const Icon(Icons.work_outline, size: 18),
                  text: localizations.getString('professionalInformation'),
                ),
                Tab(
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  text: localizations.getString('settings'),
                ),
              ],
              labelColor: AdaptiveColors.primaryGreen,
              unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
              indicatorColor: AdaptiveColors.primaryGreen,
              indicatorWeight: 3,
              isScrollable: false,
              labelStyle: const TextStyle(fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
            ),
          ),
        ),

// Tab Content
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              UserPersonalInfoTab(profile: profile),
              UserProfessionalInfoTab(profile: profile),
              UserSettingsTab(profile: profile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, ProfileModel profile) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final avatarSize = screenWidth * 0.12; // Reduced avatar size

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AdaptiveColors.getPrimaryColor(context).withOpacity(0.1),
            AdaptiveColors.cardColor(context),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center, // Changed from end to center
          mainAxisSize: MainAxisSize.min, // Added to prevent overflow
          children: [
// Avatar - Made smaller
            CircleAvatar(
              radius: avatarSize,
              backgroundColor:
                  AdaptiveColors.getPrimaryColor(context).withOpacity(0.2),
              child: Text(
                '${profile.firstName.isNotEmpty ? profile.firstName[0] : ''}${profile.lastName.isNotEmpty ? profile.lastName[0] : ''}',
                style: TextStyle(
                  color: AdaptiveColors.getPrimaryColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: avatarSize * 0.6,
                ),
              ),
            ),

            SizedBox(height: screenHeight * 0.008), // Reduced spacing

// Name - Made smaller
            Flexible(
              child: Text(
                '${profile.firstName} ${profile.lastName}',
                style: TextStyle(
                  fontSize: screenWidth * 0.045, // Reduced font size
                  fontWeight: FontWeight.bold,
                  color: AdaptiveColors.primaryTextColor(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: screenHeight * 0.004), // Reduced spacing

// Role/Designation - Made smaller
            Flexible(
              child: Text(
                profile.designation ?? profile.role,
                style: TextStyle(
                  fontSize: screenWidth * 0.032, // Reduced font size
                  color: AdaptiveColors.secondaryTextColor(context),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            SizedBox(height: screenHeight * 0.008), // Reduced spacing

// Status Badge - Made smaller
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.025, // Reduced padding
                vertical: screenHeight * 0.004, // Reduced padding
              ),
              decoration: BoxDecoration(
                color: profile.active
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(
                  color: profile.active ? Colors.green : Colors.red,
                  width: 1,
                ),
              ),
              child: Text(
                profile.active ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: profile.active ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.028, // Reduced font size
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom delegate for pinned tab bar
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AdaptiveColors.cardColor(context),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) {
    return false;
  }
}
