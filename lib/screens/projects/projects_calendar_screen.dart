import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';
import 'project_add_screen.dart';
import '../../../services/navigation_service.dart';
import '../../../widget/bottom_navigation_bar.dart';
import 'project_tasks_screen.dart';
import 'models/project_model.dart';
import 'services/project_service.dart';

class ProjectCalendarScreen extends StatefulWidget {
  const ProjectCalendarScreen({super.key});

  @override
  State<ProjectCalendarScreen> createState() => _ProjectCalendarScreenState();
}

class _ProjectCalendarScreenState extends State<ProjectCalendarScreen> {
  int _selectedIndex = 1;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  bool _showYearView = false;
  List<Project> _projects = [];
  late PageController _yearPageController;
  late ProjectDataSource _dataSource;
  bool _isLoading = true;
  String _errorMessage = '';


  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
    _yearPageController = PageController(initialPage: now.year - 2020);
    _dataSource = ProjectDataSource(_projects); 
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await ProjectService().getProjects();
      
      if (result['success'] == true) {
        final projects = result['data']['projects'] as List<Project>;
        setState(() {
          _projects = projects;
          _dataSource = ProjectDataSource(_projects);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Failed to load projects';
          _isLoading = false;
          // If there's partial data, still use it
          if (result['data'] != null && result['data']['projects'] != null) {
            _projects = result['data']['projects'];
            _dataSource = ProjectDataSource(_projects);
          }
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _yearPageController.dispose();
    super.dispose();
  }

  DateTime _stripTime(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      Future.microtask(() {
        if (mounted) {
          setState(fn);
        }
      });
    }
  }

  void _navigateToPreviousMonth() {
    final newMonth = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
    _safeSetState(() {
      _focusedDay = newMonth;
      _selectedDay = _stripTime(newMonth);
    });
  }

  void _navigateToNextMonth() {
    final newMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
    _safeSetState(() {
      _focusedDay = newMonth;
      _selectedDay = _stripTime(newMonth);
    });
  }

  void _navigateToPreviousYear() {
    final currentPage = _yearPageController.page?.round() ?? (_focusedDay.year - 2020);
    _yearPageController.animateToPage(
      currentPage - 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToNextYear() {
    final currentPage = _yearPageController.page?.round() ?? (_focusedDay.year - 2020);
    _yearPageController.animateToPage(
      currentPage + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  void _showAppointmentSelectionMenu(BuildContext context, CalendarTapDetails details) {
    // Calculate position for the popup (near the tap location)
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset position = overlay.localToGlobal(Offset.zero);
    
    // Show popup menu with all appointments
    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          position, 
          position,
        ),
        Offset.zero & overlay.size,
      ),
      items: details.appointments!.map((appointment) {
        final project = appointment.resourceIds!.first as Project;
        return PopupMenuItem<Project>(
          value: project,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: appointment.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  project.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedProject) {
      if (selectedProject != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectTasksScreen(project: selectedProject),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _showYearView
              ? 'Year ${_focusedDay.year}'
              : DateFormat.yMMMM().format(_focusedDay),
        ),
        leading: _showYearView
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _navigateToPreviousYear,
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: _navigateToPreviousMonth,
              ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: _showYearView ? _navigateToNextYear : _navigateToNextMonth,
          ),
          IconButton(
            icon: Icon(_showYearView ? Icons.calendar_month : Icons.calendar_view_day),
            onPressed: () {
              _safeSetState(() {
                _showYearView = !_showYearView;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              _safeSetState(() {
                final now = DateTime.now();
                _focusedDay = DateTime(now.year, now.month, now.day);
                _selectedDay = _focusedDay;
                _showYearView = false;
              });
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProjectAddScreen()));
              },
            icon: const Icon(Icons.add)
          )
        ],
      ),
      body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _errorMessage.isNotEmpty && _projects.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_errorMessage),
                    ElevatedButton(
                      onPressed: _fetchProjects,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _showYearView ? _buildYearView() : _buildMonthView(),
      bottomNavigationBar: CustomBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      
    );
  }

  Widget _buildMonthView() {
    return Column(
      children: [
        Container(
          height: 40,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Row(
            children:  [
              Expanded(child: Center(child: Text('Sun', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)))),
              Expanded(child: Center(child: Text('Mon', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)))),
              Expanded(child: Center(child: Text('Tue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)))),
              Expanded(child: Center(child: Text('Wed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)))),
              Expanded(child: Center(child: Text('Thu', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)))),
              Expanded(child: Center(child: Text('Fri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)))),
              Expanded(child: Center(child: Text('Sat', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)))),
            ],
          ),
        ),
        Expanded(
          child: SfCalendar(
            key: ValueKey('month_calendar_${_focusedDay.year}_${_focusedDay.month}'),
            view: CalendarView.month,
            initialSelectedDate: _selectedDay,
            initialDisplayDate: _focusedDay,
            firstDayOfWeek: 7, // Sunday
            controller: CalendarController()..displayDate = _focusedDay,
            dataSource: _dataSource,
            monthViewSettings: const MonthViewSettings(
              appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
              showAgenda: false,
              appointmentDisplayCount: 5, // Show up to 5 appointments per cell
              monthCellStyle: MonthCellStyle(
                backgroundColor: Colors.transparent,
                textStyle: TextStyle(fontSize: 16),
                leadingDatesTextStyle: TextStyle(color: Colors.grey, fontSize: 16),
                trailingDatesTextStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            viewHeaderHeight: 0, // Hide default header
            headerHeight: 0,
            cellBorderColor: Colors.transparent,
            selectionDecoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            todayHighlightColor: Colors.transparent,
            appointmentTextStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            onTap: (details) {
              if (details.appointments != null && details.appointments!.isNotEmpty) {
                if (details.appointments!.length == 1) {
                  // Single appointment - navigate directly
                  final appointment = details.appointments!.first;
                  if (appointment.resourceIds != null && 
                      appointment.resourceIds!.isNotEmpty) {
                    final project = appointment.resourceIds!.first as Project;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProjectTasksScreen(project: project),
                      ),
                    );
                  }
                } else {
                  // Multiple appointments - show popup menu
                  _showAppointmentSelectionMenu(context, details);
                }
              } else if (details.date != null) {
                _safeSetState(() {
                  _selectedDay = _stripTime(details.date!);
                  _focusedDay = _stripTime(details.date!);
                });
              }
            },
            onViewChanged: (details) {
              print('View changed to: ${details.visibleDates[details.visibleDates.length ~/ 2]}');
              _safeSetState(() {
                _focusedDay = _stripTime(details.visibleDates[details.visibleDates.length ~/ 2]);
              });
            },
            monthCellBuilder: (context, cellDetails) {
              final date = _stripTime(cellDetails.date);
              final isSelected = _isSameDay(date, _selectedDay);
              final isLeadingOrTrailing = date.month != _focusedDay.month;

              return Container(
                key: ValueKey('month_cell_${date.millisecondsSinceEpoch}'),
                margin: const EdgeInsets.all(2),
                constraints: const BoxConstraints(minHeight: 150, minWidth: 50),
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.3) : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : isLeadingOrTrailing
                                    ? Colors.grey
                                    : Theme.of(context).textTheme.bodyLarge?.color,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    // Appointments handled by dataSource
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildYearView() {
    return PageView.builder(
      controller: _yearPageController,
      onPageChanged: (index) {
        _safeSetState(() {
          _focusedDay = DateTime(2020 + index, _focusedDay.month, _focusedDay.day);
        });
      },
      itemBuilder: (context, yearIndex) {
        final year = 2020 + yearIndex;
        final months = List.generate(12, (i) => DateTime(year, i + 1));

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.0,
          ),
          itemCount: 12,
          itemBuilder: (context, index) {
            final month = months[index];
            return _buildMiniCalendar(month);
          },
        );
      },
    );
  }

  Widget _buildMiniCalendar(DateTime month) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          print('Tapped month: ${DateFormat.yMMM().format(month)}');
          _safeSetState(() {
            _focusedDay = month;
            _selectedDay = month;
            _showYearView = false;
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(
                DateFormat.MMM().format(month),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: month.month == DateTime.now().month && month.year == DateTime.now().year
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: SfCalendar(
                  key: ValueKey('mini_calendar_${month.year}_${month.month}'),
                  view: CalendarView.month,
                  firstDayOfWeek: 7, // Sunday
                  initialDisplayDate: month,
                  headerHeight: 0,
                  viewHeaderHeight: 0,
                  allowViewNavigation: false,
                  showNavigationArrow: false,
                  cellBorderColor: Colors.transparent,
                  selectionDecoration: const BoxDecoration(color: Colors.transparent),
                  todayHighlightColor: Theme.of(context).primaryColor.withOpacity(0.7),
                  monthViewSettings: const MonthViewSettings(
                    appointmentDisplayMode: MonthAppointmentDisplayMode.none,
                    showAgenda: false,
                    agendaItemHeight: 4,
                    monthCellStyle: MonthCellStyle(
                      backgroundColor: Colors.transparent,
                      textStyle: TextStyle(fontSize: 12),
                      todayTextStyle: TextStyle(fontSize: 12),
                      leadingDatesTextStyle: TextStyle(color: Colors.grey, fontSize: 12),
                      trailingDatesTextStyle: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class ProjectDataSource extends CalendarDataSource {
  static final List<Color> _colorPalette = [
    Colors.green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    const Color.fromARGB(255, 150, 0, 22),
    Colors.indigo,
  ];

  // Track color assignments to maintain consistency
  static final Map<String, Color> _projectColorMap = {};

  ProjectDataSource(List<Project> source) {
    appointments = source.map((project) {
      // Get color from our palette-based system
      final color = _getProjectColor(project);
      
      return Appointment(
        startTime: project.beginDate,
        endTime: project.endDate,
        subject: project.name!,
        color: color.withOpacity(0.7), // Apply opacity to our palette color
        notes: project.status.toString(),
        resourceIds: [project],
      );
    }).toList();
  }

  Color _getProjectColor(Project project) {
    // Use project ID if available, otherwise use name as fallback key
    final colorKey = project.id ?? project.name;
    
    // Return existing color if already assigned
    if (_projectColorMap.containsKey(colorKey)) {
      return _projectColorMap[colorKey]!;
    }
    
    // Find the least recently used color from palette
    final usedColors = _projectColorMap.values.toSet();
    Color assignedColor;
    
    // 1. Try to find an unused color first
    for (final color in _colorPalette) {
      if (!usedColors.contains(color)) {
        assignedColor = color;
        _projectColorMap[colorKey] = assignedColor;
        return assignedColor;
      }
    }
    
    // 2. If all colors are used, cycle through palette
    assignedColor = _colorPalette[_projectColorMap.length % _colorPalette.length];
    _projectColorMap[colorKey] = assignedColor;
    return assignedColor;
  }

  @override
  DateTime getStartTime(int index) => appointments![index].startTime;

  @override
  DateTime getEndTime(int index) => appointments![index].endTime;

  @override
  String getSubject(int index) => appointments![index].subject;

  @override
  Color getColor(int index) => appointments![index].color;
}
