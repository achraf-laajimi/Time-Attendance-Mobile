// lib/screens/vacation/vacation_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/vacation_model.dart';
import '../../models/vacation_balance_model.dart';
import '../../services/navigation_service.dart';
import '../../services/vacation_service.dart';
import '../../theme/adaptive_colors.dart';
import '../../widget/responsive_navigation_scaffold.dart';
import '../../widget/user_profile_header.dart';
import '../../widget/bottom_navigation_bar.dart';
import '../../localization/app_localizations.dart';
import '../notifications/notifications_screen.dart';
import 'widgets/vacation_balance_card.dart';
import 'widgets/vacation_request_item.dart';
import 'request_vacation_dialog.dart';
import 'edit_vacation_dialog.dart';

class VacationScreen extends StatefulWidget {
  const VacationScreen({super.key});

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 2;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  final VacationService _vacationService = VacationService();
  VacationBalance? _balance;
  List<VacationRequest> _allRequests = [];
  List<VacationRequest> _pendingRequests = [];
  List<VacationRequest> _historyRequests = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _scrollController.addListener(_scrollListener);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _loadData();
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
    });
    NavigationService.navigateToScreen(context, index);
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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Load balance
      final balanceResult = await _vacationService.getMyBalance();
      if (balanceResult['success']) {
        setState(() {
          _balance = balanceResult['balance'];
        });
        print("Balance loaded: $_balance");
      } else {
        setState(() {
          _error = balanceResult['message'];
        });
      }

      // Load requests
      final requestsResult = await _vacationService.getMyRequests();
      if (requestsResult['success']) {
        _allRequests = requestsResult['requests'];
        _filterRequests();
      } else {
        _error = requestsResult['message'];
      }
    } catch (e) {
      _error = 'Error loading data: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterRequests() {
    _pendingRequests = _allRequests
        .where((r) => r.status == VacationStatus.pending)
        .toList();

    _historyRequests = _allRequests
        .where((r) => r.status != VacationStatus.pending)
        .toList();

    // Sort by date
    _pendingRequests.sort((a, b) => b.startDate.compareTo(a.startDate));
    _historyRequests.sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  void _showRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => RequestVacationDialog(
        balance: _balance,
        onSubmit: (request) async {
          print("=== SUBMITTING VACATION REQUEST ===");

          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
              child: CircularProgressIndicator(),
            ),
          );

          try {
            final result = await _vacationService.createRequest(request);

            // Close loading indicator
            Navigator.of(context).pop();

            print("Result: $result");

            if (result['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Request submitted successfully'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 3),
                ),
              );
              _loadData(); // Reload data
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Failed to submit request'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          } catch (e) {
            // Close loading indicator
            Navigator.of(context).pop();

            print("Exception: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditDialog(VacationRequest request) {
    showDialog(
      context: context,
      builder: (context) => EditVacationDialog(
        request: request,
        balance: _balance,
        onSubmit: (_) => _loadData(),
      ),
    );
  }

  Future<void> _cancelRequest(VacationRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this vacation request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _vacationService.cancelRequest(request.id!);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);

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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error.isNotEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
                  : CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // Balance Card
                  if (_balance != null)
                    SliverPadding(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      sliver: SliverToBoxAdapter(
                        child: VacationBalanceCard(balance: _balance!),
                      ),
                    ),

                  // Request Button
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: ElevatedButton.icon(
                        onPressed: _showRequestDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Request Vacation'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdaptiveColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Tabs
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabBarDelegate(
                      TabBar(
                        controller: _tabController,
                        labelColor: AdaptiveColors.primaryGreen,
                        unselectedLabelColor: AdaptiveColors.secondaryTextColor(context),
                        indicatorColor: AdaptiveColors.primaryGreen,
                        tabs: [
                          Tab(text: 'Pending (${_pendingRequests.length})'),
                          Tab(text: 'History (${_historyRequests.length})'),
                        ],
                      ),
                    ),
                  ),

                  // Tab Content
                  SliverFillRemaining(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Pending Requests
                        _buildRequestsList(_pendingRequests, true),
                        // History
                        _buildRequestsList(_historyRequests, false),
                      ],
                    ),
                  ),
                ],
              ),
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

  Widget _buildRequestsList(List<VacationRequest> requests, bool showActions) {
    if (requests.isEmpty) {
      return Center(
        child: Text(
          showActions ? 'No pending requests' : 'No vacation history',
          style: TextStyle(
            color: AdaptiveColors.secondaryTextColor(context),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.04),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        return VacationRequestItem(
          request: request,
          onCancel: showActions && request.canCancel
              ? () => _cancelRequest(request)
              : null,
          onEdit: showActions && request.canEdit
              ? () => _showEditDialog(request)
              : null,
        );
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _TabBarDelegate(this.tabBar);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AdaptiveColors.backgroundColor(context),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}