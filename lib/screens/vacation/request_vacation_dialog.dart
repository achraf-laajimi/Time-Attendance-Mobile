// lib/screens/vacation/request_vacation_dialog.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vacation_model.dart';
import '../../models/vacation_balance_model.dart';
import '../../theme/adaptive_colors.dart';
import '../../localization/app_localizations.dart';

class RequestVacationDialog extends StatefulWidget {
  final VacationBalance? balance;
  final Function(VacationRequest) onSubmit;
  final VacationRequest? editRequest;

  const RequestVacationDialog({
    super.key,
    this.balance,
    required this.onSubmit,
    this.editRequest,
  });

  @override
  State<RequestVacationDialog> createState() => _RequestVacationDialogState();
}

class _RequestVacationDialogState extends State<RequestVacationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _startTime = Day.morning;
  String _endTime = Day.afternoon;
  String _vacationType = VacationType.regularLeave;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editRequest != null;
    if (_isEditing) {
      _initializeEditData();
    }
  }

  void _initializeEditData() {
    final request = widget.editRequest!;
    _startDate = DateTime.parse(request.startDate);
    _endDate = DateTime.parse(request.endDate);
    _startTime = request.startTime;
    _endTime = request.endTime;
    _vacationType = request.type;
    _reasonController.text = request.reason;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int _calculateDays() {
    if (_startDate == null || _endDate == null) return 0;

    int days = _endDate!.difference(_startDate!).inDays + 1;

    if (_startDate!.isAtSameMomentAs(_endDate!)) {
      if (_startTime == Day.afternoon && _endTime == Day.morning) {
        return 0;
      } else if (_startTime == Day.afternoon || _endTime == Day.morning) {
        return 1;
      }
    } else {
      if (_startTime == Day.afternoon) days--;
      if (_endTime == Day.morning) days--;
    }

    return days;
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  DateTime _getNextWeekday(DateTime date) {
    DateTime nextDate = date;
    while (_isWeekend(nextDate)) {
      nextDate = nextDate.add(const Duration(days: 1));
    }
    return nextDate;
  }

  DateTime _getPreviousWeekday(DateTime date) {
    DateTime prevDate = date;
    while (_isWeekend(prevDate)) {
      prevDate = prevDate.subtract(const Duration(days: 1));
    }
    return prevDate;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart
        ? (_startDate ?? _getNextWeekday(DateTime.now()))
        : (_endDate ?? _startDate ?? DateTime.now());

    final firstDate = isStart
        ? _getNextWeekday(DateTime.now())
        : (_startDate ?? DateTime.now());

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: (DateTime date) {
        // Both start and end dates should not be weekends
        return !_isWeekend(date);
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
          // If end date is before new start date, adjust it
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
          // Ensure end date is not a weekend
          if (_isWeekend(_endDate!)) {
            _endDate = _getPreviousWeekday(_endDate!);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Vacation cannot end on weekends. Adjusted to previous weekday.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      });
    }
  }

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select start and end dates'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Additional validation for weekend dates
      if (_isWeekend(_startDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Vacation cannot start on weekends. Please select a weekday.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_isWeekend(_endDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Vacation cannot end on weekends. Please select a weekday.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check day calculation for 0 days (invalid)
      final days = _calculateDays();
      if (days <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Invalid date/time combination. Please check your selections.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check available balance if not editing
      if (!_isEditing &&
          widget.balance != null &&
          days > widget.balance!.availableDays) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Insufficient balance. Available: ${widget.balance!.availableDays} days',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Create the request with the exact format expected by the API
      final request = VacationRequest(
        id: widget.editRequest?.id,
        startDate: DateFormat('yyyy-MM-dd').format(_startDate!),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate!),
        startTime: _startTime,
        endTime: _endTime,
        type: _vacationType,
        reason: _reasonController.text.trim(),
        status: widget.editRequest?.status,
      );

      // Debug: Print the request data
      print('Creating vacation request:');
      print(
          'Start Date: ${request.startDate} (${DateFormat('EEEE').format(_startDate!)})');
      print(
          'End Date: ${request.endDate} (${DateFormat('EEEE').format(_endDate!)})');
      print('Start Time: ${request.startTime}');
      print('End Time: ${request.endTime}');
      print('Type: ${request.type}');
      print('Reason: ${request.reason}');
      print('JSON: ${request.toJson()}');

      widget.onSubmit(request);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isEditing ? 'Edit Vacation Request' : 'Request Vacation',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Weekend restriction notice
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note: Vacation requests cannot start or end on weekends (Saturday/Sunday)',
                            style: TextStyle(
                              color: Colors.amber.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (widget.balance != null && !_isEditing) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue),
                          const SizedBox(width: 8),
                          Text(
                            'Available balance: ${widget.balance!.availableDays} days',
                            style: const TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Vacation Type
                  DropdownButtonFormField<String>(
                    value: _vacationType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                        .getString('vacationType'),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                    ),
                    menuMaxHeight: 300,
                    items: VacationType.displayNames.entries.map((entry) {
                      return DropdownMenuItem(
                        value: entry.key,
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _vacationType = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Date Selection
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Start Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _startDate != null
                                  ? '${DateFormat('MMM dd').format(_startDate!)} (${DateFormat('E').format(_startDate!)})'
                                  : 'Select weekday',
                              style: TextStyle(
                                color: _startDate != null &&
                                        _isWeekend(_startDate!)
                                    ? Colors.orange
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'End Date',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            child: Text(
                              _endDate != null
                                  ? '${DateFormat('MMM dd').format(_endDate!)} (${DateFormat('E').format(_endDate!)})'
                                  : 'Select weekday',
                              style: TextStyle(
                                color: _endDate != null && _isWeekend(_endDate!)
                                    ? Colors.orange
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Time Selection
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _startTime,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)
                              .getString('startTime'),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          // Use minimal padding to prevent overflow
                          itemHeight: 48,
                          menuMaxHeight: 200,
                          items: Day.displayNames.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _startTime = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _endTime,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: AppLocalizations.of(context)
                              .getString('endTime'),
                            border: const OutlineInputBorder(),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                          ),
                          // Use minimal padding to prevent overflow
                          itemHeight: 48,
                          menuMaxHeight: 200,
                          items: Day.displayNames.entries.map((entry) {
                            return DropdownMenuItem(
                              value: entry.key,
                              child: Text(
                                entry.value,
                                style: const TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _endTime = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Reason
                  TextFormField(
                    controller: _reasonController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)
                        .getString('reason'),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 16),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please provide a reason';
                      }
                      return null;
                    },
                  ),

                  if (_startDate != null && _endDate != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.green),
                          const SizedBox(width: 8),
                          Text(
                            'Total days: ${_calculateDays()}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                            AppLocalizations.of(context).getString('cancel')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _submitRequest,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdaptiveColors.primaryGreen,
                        ),
                        child: Text(_isEditing
                            ? AppLocalizations.of(context)
                                .getString('updateRequest')
                            : AppLocalizations.of(context)
                                .getString('submitRequest')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
