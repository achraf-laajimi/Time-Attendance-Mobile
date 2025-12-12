import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'project_add_screen.dart';
import 'project_edit_date.dart';
import 'package:in_out/services/navigation_service.dart';
import 'package:in_out/screens/projects/services/project_service.dart';
import 'services/user_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/responsive_navigation_scaffold.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'project_tasks_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../localization/app_localizations.dart';
import 'models/project_model.dart';
import 'models/ExpressUser.dart';
import 'widgets/search_and_filter_bar_projects.dart';
import '../../widget/pagination_widgets.dart';
import 'package:in_out/widget/landscape_user_profile_header.dart';

class ProjectTableScreen extends StatefulWidget {
  const ProjectTableScreen({super.key});

  @override
  State<ProjectTableScreen> createState() => _ProjectTableScreenState();
}

class _ProjectTableScreenState extends State<ProjectTableScreen>{
  late TextEditingController _searchController;
  int _selectedIndex = 2; // Adjust index based on your navigation
  final ScrollController _mainScrollController = ScrollController();
  bool _isHeaderVisible = true;
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalElements = 0;
  final int _itemsPerPage = 10;
  String _searchQuery = '';

  List<Project> _projects = [];
  bool _isLoading = true;
  String _errorMessage = '';

  List<String> _statusOptions = [];
  final Set<String> _selectedStatuses = {};
  List<ExpressUser> _availableClients = [];
  final Set<String> _selectedClientIds = {};
  List<ExpressUser> _availableManagers = [];
  final Set<String> _selectedManagerIds = {};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: _searchQuery);
    _statusOptions = ProjectStatus.values.map((e) => e.value).toList();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    _mainScrollController.addListener(_scrollListener);
    _fetchProjects();
    _fetchClientsAndManagers();
  }

  Future<void> _fetchClientsAndManagers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final clientsFuture = ExpressUserService().getClients();
      final managersFuture = ExpressUserService().getManagers();

      final results = await Future.wait([clientsFuture, managersFuture]);

      if (!mounted) return;

      setState(() {
        _availableClients = results[0];
        _availableManagers = results[1];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading user data: ${e.toString()}';
        _availableClients = [];
        _availableManagers = [];
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _searchController.dispose();
    _mainScrollController.removeListener(_scrollListener);
    _mainScrollController.dispose();
    super.dispose();
  }


  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _mainScrollController.offset <= 50;
    });
  }

  Future<void> _fetchProjects() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final result = await ProjectService().getProjects(
      page: _currentPage + 1,
      limit: _itemsPerPage,
      search: _searchQuery,
      status: _selectedStatuses.isNotEmpty ? _selectedStatuses.first : null,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success'] == true) {
        _projects = result['data']['projects'];
        _totalElements = result['data']['pagination']['total'];
        _totalPages = result['data']['pagination']['pages'];
      } else {
        _errorMessage = result['message'];
        if (result['shouldLogout'] == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }
      }
    });
  }


  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) {
      setState(() {
        _selectedIndex = index;
      });
      NavigationService.navigateToScreen(context, index);
    });
  }


  void _viewProjectDetails(Project project) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]).then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProjectTasksScreen(project: project),
        ),
      ).then((_) {
        if (mounted) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.landscapeRight,
            DeviceOrientation.landscapeLeft,
          ]);
          _fetchProjects();
        }
      });
    });
  }

  void _showFilterDialog(BuildContext context) {
    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final localizations = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final size = MediaQuery.of(context).size;
        final screenWidth = size.width;
        final screenHeight = size.height;

        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            backgroundColor: AdaptiveColors.cardColor(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(screenWidth * 0.012),
            ),
            child: Container(
              width: screenWidth * 0.85,
              constraints: BoxConstraints(
                maxWidth: screenWidth * 0.85,
                maxHeight: screenHeight * 0.8,
              ),
              padding: EdgeInsets.all(screenWidth * 0.02),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.getString('filter'),
                    style: TextStyle(
                      fontSize: screenWidth * 0.018,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF377D25),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.getString('status'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.016,
                              color: AdaptiveColors.primaryTextColor(context),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          Wrap(
                            spacing: screenWidth * 0.01,
                            runSpacing: screenHeight * 0.01,
                            children: _statusOptions.map((status) {
                              return ChoiceChip(
                                label: Text(status),
                                selected: _selectedStatuses.contains(status),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedStatuses.add(status);
                                      _selectedClientIds.clear();
                                      _selectedManagerIds.clear();
                                    } else {
                                      _selectedStatuses.remove(status);
                                    }
                                  });
                                },
                                backgroundColor: AdaptiveColors.cardColor(context),
                                selectedColor: const Color(0xFFEAF2EB).withOpacity(isDarkMode ? 0.3 : 1.0),
                                checkmarkColor: const Color(0xFF377D25),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: screenHeight * 0.02),
                          
                          Text(
                            localizations.getString('client'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.016,
                              color: AdaptiveColors.primaryTextColor(context),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          Wrap(
                            spacing: screenWidth * 0.01,
                            runSpacing: screenHeight * 0.01,
                            children: _availableClients.map((client) {
                              return ChoiceChip(
                                label: Text(client.name),
                                selected: _selectedClientIds.contains(client.id),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedClientIds.add(client.id);
                                      _selectedStatuses.clear();
                                      _selectedManagerIds.clear();
                                    } else {
                                      _selectedClientIds.remove(client.id);
                                    }
                                  });
                                },
                                backgroundColor: AdaptiveColors.cardColor(context),
                                selectedColor: const Color(0xFFEAF2EB).withOpacity(isDarkMode ? 0.3 : 1.0),
                                checkmarkColor: const Color(0xFF377D25),
                              );
                            }).toList(),
                          ),

                          SizedBox(height: screenHeight * 0.02),
                          
                          Text(
                            localizations.getString('projectManager'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.016,
                              color: AdaptiveColors.primaryTextColor(context),
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.01),

                          Wrap(
                            spacing: screenWidth * 0.01,
                            runSpacing: screenHeight * 0.01,
                            children: _availableManagers.map((manager) {
                              return ChoiceChip(
                                label: Text(manager.name),
                                selected: _selectedManagerIds.contains(manager.id),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedManagerIds.add(manager.id);
                                      _selectedStatuses.clear();
                                      _selectedClientIds.clear();
                                    } else {
                                      _selectedManagerIds.remove(manager.id);
                                    }
                                  });
                                },
                                backgroundColor: AdaptiveColors.cardColor(context),
                                selectedColor: const Color(0xFFEAF2EB).withOpacity(isDarkMode ? 0.3 : 1.0),
                                checkmarkColor: const Color(0xFF377D25),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.02),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedStatuses.clear();
                            _selectedClientIds.clear();
                            _selectedManagerIds.clear();
                          });
                        },
                        child: Text(
                          localizations.getString('clearFilters'),
                          style: const TextStyle(
                            color: Color(0xFF377D25),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _currentPage = 0;
                          });
                          _fetchProjects();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF377D25),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(screenWidth * 0.004),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.024,
                              vertical: screenHeight * 0.012
                          ),
                        ),
                        child: Text(localizations.getString('apply')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
            LandscapeUserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
              onNotificationTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                );
              },
            ),
            SearchAndFilterBar(
              searchController: _searchController,
              onSearchChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _currentPage = 0;
                });
                _fetchProjects();
              },
              onAddNewProject: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProjectAddScreen()
                  ),
                ).then((_) => _fetchProjects());
              },
              onFilterTap: (context) => _showFilterDialog(context),
            ),
            Expanded(
              child: SingleChildScrollView( 
                child: Container(
                  margin: EdgeInsets.fromLTRB(
                    screenWidth * 0.015,
                    0,
                    screenWidth * 0.015,
                    screenWidth * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: AdaptiveColors.cardColor(context),
                    borderRadius: BorderRadius.circular(screenWidth * 0.008),
                    boxShadow: [
                      BoxShadow(
                        color: AdaptiveColors.shadowColor(context),
                        spreadRadius: screenWidth * 0.001,
                        blurRadius: screenWidth * 0.003,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Important for scrolling
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Colors.green.shade800,
                                ),
                              )
                            : _errorMessage.isNotEmpty
                                ? Center(
                                    child: Text(
                                      _errorMessage,
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: screenWidth * 0.02,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                : TwoDimensionalProjectTable(
                                    projects: _projects,
                                    onViewProject: _viewProjectDetails,
                                  ),
                      ),
                      PaginationFooter(
                        currentPage: _currentPage + 1,
                        totalPages: _totalPages > 0 ? _totalPages : 1,
                        filteredEmployeesCount: _totalElements,
                        itemsPerPage: _itemsPerPage,
                        onPageChanged: (page) {
                          if (page != _currentPage + 1) {
                            setState(() {
                              _currentPage = page - 1;
                            });
                            _fetchProjects();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TwoDimensionalProjectTable extends StatelessWidget {
  final List<Project> projects;
  final Function(Project) onViewProject;

  const TwoDimensionalProjectTable({
    super.key,
    required this.projects,
    required this.onViewProject,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    if (projects.isEmpty) {
      return SizedBox(
        height: screenHeight * 0.5,
        child: Center(
          child: Text(
            localizations.getString('noProjectsFound'),
            style: TextStyle(
              fontSize: 16,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
          ),
        ),
      );
    }

    final headerTitles = [
      localizations.getString('projectName'),
      localizations.getString('company'),
      localizations.getString('client'),
      localizations.getString('projectManager'),
      localizations.getString('startDate'),
      localizations.getString('endDate'),
      localizations.getString('status'),
      localizations.getString('action')
    ];

    return SizedBox(
      height: screenSize.height * 0.7, // Adjust based on your needs
      child: TableView.builder(
        rowCount: projects.length + 1,
        columnCount: headerTitles.length,
        cellBuilder: (context, vicinity) {
          return TableViewCell(
            child: _buildCellWidget(context, vicinity, headerTitles),
          );
        },

        columnBuilder: (index) {
          double width;
          switch (index) {
            case 0: // Project name
              width = screenWidth * 0.2;
              break;
            case 1: // Company
              width = screenWidth * 0.1;
              break;
            case 2: // Client
              width = screenWidth * 0.1;
              break;
            case 3: // Project Manager
              width = screenWidth * 0.1;
              break;
            case 4: // Start Date
              width = screenWidth * 0.1;
              break;
            case 5: // End Date
              width = screenWidth * 0.1;
              break;
            case 6: // Status
              width = screenWidth * 0.1;
              break;
            case 7: // Action
              width = screenWidth * 0.1;
              break;
            default:
              width = screenWidth * 0.15;
          }
          return TableSpan(
            extent: FixedTableSpanExtent(width),
          );
        },

        rowBuilder: (index) {
          double height = index == 0
              ? screenHeight * 0.08
              : screenHeight * 0.09;
          return TableSpan(
            extent: FixedTableSpanExtent(height),
          );
        },

        pinnedRowCount: 1,
        pinnedColumnCount: 1,
      ),
    );
  }

  Widget _buildCellWidget(BuildContext context, TableVicinity vicinity, List<String> headerTitles) {
    final row = vicinity.row;
    final column = vicinity.column;
    final isDarkMode = AdaptiveColors.isDarkMode(context);
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final borderColor = isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200;
    AppLocalizations.of(context);

    if (row == 0) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.015,
          vertical: screenHeight * 0.02,
        ),
        decoration: BoxDecoration(
          color: AdaptiveColors.cardColor(context),
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
            right: column > 0 ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
          ),
        ),
        child: Text(
          headerTitles[column],
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: screenHeight * 0.025,
          ),
        ),
      );
    }

    final projectIndex = row - 1;
    final project = projects[projectIndex];

    if (column == 0) {
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
            right: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: screenHeight * 0.028,
              backgroundColor: Colors.blue.shade100,
              child: Text(
                _getInitials(project.name),
                style: TextStyle(
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: screenHeight * 0.02,
                ),
              ),
            ),
            SizedBox(width: screenWidth * 0.01),
            Expanded(
              child: Text(
                project.name,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: screenHeight * 0.022,
                  color: AdaptiveColors.primaryTextColor(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    if (column == 7) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: Center(
          child: PopupMenuButton<String>(
            icon: Icon(
                Icons.more_vert,
                size: screenHeight * 0.035,
                color: AdaptiveColors.secondaryTextColor(context)
            ),
            padding: EdgeInsets.zero,
            color: AdaptiveColors.cardColor(context),
            onSelected: (String result) {
              if (result == 'view') {
                onViewProject(project);
              } else if (result == 'edit') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectEditScreen(project: project),
                  ),
                );
              } else if (result == 'delete') {
                _showDeleteConfirmation(context, project);
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              _buildPopupItem(context, 'view', Icons.visibility_outlined, 'view'),
              _buildPopupItem(context, 'edit', Icons.edit_outlined, 'edit'),
              _buildPopupItem(context, 'delete', Icons.delete_outline, 'delete', isDelete: true),
            ],
          ),
        ),
      );
    }

    String cellText = '';
    switch (column) {
      case 1:
        cellText = project.entreprise;
        break;
      case 2:
        cellText = project.client.name;
        break;
      case 3:
        cellText = project.projectManager.name;
        break;
      case 4:
        cellText = _formatDate(project.beginDate);
        break;
      case 5:
        cellText = _formatDate(project.endDate);
        break;
      case 6:
        cellText = project.status.value;
        break;
    }

    Color statusColor = Colors.grey;
    switch (project.status) {
      case ProjectStatus.toDo:
        statusColor = Colors.blue;
        break;
      case ProjectStatus.inProgress:
        statusColor = Colors.orange;
        break;
      case ProjectStatus.completed:
        statusColor = Colors.green;
        break;
      case ProjectStatus.cancelled:
        statusColor = Colors.red;
        break;
    }

    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.015,
        vertical: screenHeight * 0.02,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
          right: column < 7 ? BorderSide(color: borderColor, width: 1) : BorderSide.none,
        ),
      ),
      child: column == 6 
          ? Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.01,
                vertical: screenHeight * 0.005,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                cellText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: screenHeight * 0.02,
                ),
              ),
            )
          : Text(
              cellText,
              style: TextStyle(
                color: AdaptiveColors.primaryTextColor(context),
                fontSize: screenHeight * 0.022,
              ),
              overflow: TextOverflow.ellipsis,
            ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '';

    List<String> nameParts = name.split(' ');
    if (nameParts.length > 1) {
      return nameParts[0][0] + nameParts[1][0];
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0];
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeleteConfirmation(BuildContext context, Project project) {
    final localizations = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(localizations.getString('confirmDelete')),
          content: Text(localizations.getString('areYouSureDeleteProject')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(localizations.getString('cancel')),
            ),
            TextButton(
              onPressed: () {
                _deleteProject(context, project);
                Navigator.of(context).pop();
              },
              child: Text(
                localizations.getString('delete'),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProject(BuildContext context, Project project) async {
    try {
      final result = await ProjectService().deleteProject(project.id);

      if (result["success"]) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // ignore: use_build_context_synchronously
            content: Text(AppLocalizations.of(context).getString('projectDeletedSuccessfully')),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the page
        if (context.mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const ProjectTableScreen(),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${result["message"]}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  PopupMenuItem<String> _buildPopupItem(
      BuildContext context, String value, IconData icon, String textKey,
      {bool isDelete = false}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: screenHeight * 0.035,
            color: isDelete
                ? Colors.red
                : AdaptiveColors.secondaryTextColor(context),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.008),
          Text(
            localizations.getString(textKey),
            style: TextStyle(
              color: isDelete
                  ? Colors.red
                  : AdaptiveColors.primaryTextColor(context),
              fontSize: screenHeight * 0.022,
            ),
          ),
        ],
      ),
    );
  }
}
