import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:in_out/screens/projects/models/task_model.dart';
import 'models/ExpressUser.dart';
import 'services/task_service.dart';
import 'services/user_service.dart';

class TaskEditScreen extends StatefulWidget {
  final Task task;
  const TaskEditScreen({super.key, required this.task});

  @override
  State<TaskEditScreen> createState() => _TaskEditScreenState();
}

class _TaskEditScreenState extends State<TaskEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController = TextEditingController();
  late TextEditingController descriptionController = TextEditingController();
  late DateTime beginDate;
  late DateTime endDate;
  TaskPriority _selectedPriority = TaskPriority.Medium;
  TaskStatus _selectedStatus = TaskStatus.ToDo;
  ExpressUser? _selectedAssignedTo;
  List<ExpressUser> availableTechnicians = []; 

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.task.name);
    descriptionController = TextEditingController(text: widget.task.description);
    beginDate = widget.task.beginDate;
    endDate = widget.task.endDate;
    _selectedPriority = widget.task.priority;
    _selectedStatus = widget.task.status;
    _loadTechnicians();
  }

  Future<void> _loadTechnicians() async {
    try {
      final technicians = await ExpressUserService().getTechnicians();
      setState(() {
        availableTechnicians = technicians;
        // Find and set the assigned technician if available
        if (widget.task.assignedTo!.isNotEmpty) {
          _selectedAssignedTo = technicians.firstWhere(
            (tech) => tech.id == widget.task.assignedTo,
            orElse: () => technicians.firstWhere(
              (tech) => tech.id == widget.task.assignedTo,
              orElse: () => technicians.isNotEmpty ? technicians[0] : ExpressUser(
                id: '',
                name: 'Unknown',
                email: '',
                role: '',
              ),
            ),
          );
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load technicians: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: const Text('Edit Task'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: _saveTask,
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Name
              Text(
                'Task Name',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameController,
                style: theme.textTheme.titleLarge,
                decoration: InputDecoration(
                  hintText: 'Enter task name',
                  filled: true,
                  fillColor: isDarkMode 
                      ? Colors.grey[900] 
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                validator: (value) => 
                    value!.isEmpty ? 'Name cannot be empty' : null,
              ),
              const SizedBox(height: 24),

              // Date Range
              Row(
                children: [
                  Expanded(
                    child: _buildDateField(
                      context: context,
                      label: 'Start Date',
                      date: beginDate,
                      onDateSelected: (date) {
                        setState(() => beginDate = date);
                        if (endDate.isBefore(date)) {
                          setState(() => endDate = date.add(const Duration(days: 1)));
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDateField(
                      context: context,
                      label: 'End Date',
                      date: endDate,
                      onDateSelected: (date) {
                        if (date.isAfter(beginDate)) {
                          setState(() => endDate = date);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('End date must be after start date'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Description
              Text(
                'Description',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter task description...',
                  filled: true,
                  fillColor: isDarkMode 
                      ? Colors.grey[900] 
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 24),

              // Assigned To
              _buildDropdownField(
                context: context,
                label: 'Assigned To',
                value: _selectedAssignedTo?.name ?? 'Select technician',
                onTap: _showTechnicianSelectionDialog,
              ),
              const SizedBox(height: 24),

              // Priority
              Text(
                'Priority',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return ChoiceChip(
                    label: Text(
                      priority.toString().split('.').last,
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedPriority = priority);
                    },
                    selectedColor: theme.primaryColor,
                    backgroundColor: isDarkMode 
                        ? Colors.grey[800] 
                        : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Status
              Text(
                'Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: TaskStatus.values.map((status) {
                  final isSelected = _selectedStatus == status;
                  return ChoiceChip(
                    label: Text(
                      status.toString().split('.').last,
                      style: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedStatus = status);
                    },
                    selectedColor: theme.primaryColor,
                    backgroundColor: isDarkMode 
                        ? Colors.grey[800] 
                        : Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime date,
    required Function(DateTime) onDateSelected,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final selectedDate = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    colorScheme: theme.colorScheme.copyWith(
                      primary: theme.primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (selectedDate != null) {
              onDateSelected(selectedDate);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.grey[900] 
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat.yMMMd().format(date),
                  style: theme.textTheme.bodyLarge,
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? Colors.grey[900] 
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: value == 'Select technician'
                        ? theme.colorScheme.onSurface.withOpacity(0.5)
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showTechnicianSelectionDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Technician',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...availableTechnicians.map((tech) {
                  return ListTile(
                    title: Text(tech.name),
                    leading: Radio<ExpressUser>(
                      value: tech,
                      groupValue: _selectedAssignedTo,
                      onChanged: (ExpressUser? value) {
                        Navigator.of(context).pop();
                        if (value != null) {
                          setState(() {
                            _selectedAssignedTo = value;
                          });
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _selectedAssignedTo = tech;
                      });
                    },
                  );
                }),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Updating task...')),
      );

      try {
        final result = await TaskService().updateTask(
          taskId: widget.task.id,
          name: nameController.text,
          description: descriptionController.text,
          beginDate: beginDate,
          endDate: endDate,
          priority: _selectedPriority,
          status: _selectedStatus,
          assignedTo: _selectedAssignedTo?.id ?? widget.task.assignedTo,
        );

        if (result['success'] == true) {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('task updated with success'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context, result['data']); 
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update task: ${result['message']}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating task'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}