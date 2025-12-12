import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/vacation_model.dart';
import '../../models/vacation_balance_model.dart';
import '../../services/vacation_service.dart';
import '../../theme/adaptive_colors.dart';

class EditVacationDialog extends StatefulWidget {
  final VacationRequest request;
  final VacationBalance? balance;
  final Function(VacationRequest) onSubmit;

  const EditVacationDialog({
    super.key,
    required this.request,
    this.balance,
    required this.onSubmit,
  });

  @override
  State<EditVacationDialog> createState() => _EditVacationDialogState();
}

class _EditVacationDialogState extends State<EditVacationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final VacationService _vacationService = VacationService();

  late DateTime _startDate;
  late DateTime _endDate;
  late String _startTime;
  late String _endTime;
  late String _vacationType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _startDate = DateTime.parse(widget.request.startDate);
    _endDate = DateTime.parse(widget.request.endDate);
    _startTime = widget.request.startTime;
    _endTime = widget.request.endTime;
    _vacationType = widget.request.type;
    _reasonController.text = widget.request.reason;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int _calculateDays() {
    int days = _endDate.difference(_startDate).inDays + 1;

    // Adjust for half days
    if (_startDate == _endDate) {
      if (_startTime == Day.afternoon || _endTime == Day.morning) {
        return 1; // Half day counts as 1
      }
    } else {
      if (_startTime == Day.afternoon) days--;
      if (_endTime == Day.morning) days--;
    }

    return days;
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final initialDate = isStart ? _startDate : _endDate;
    final firstDate = isStart
        ? DateTime.now()
        : _startDate;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  Future<void> _submitEdit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // First, cancel the existing request
      final cancelResult = await _vacationService.cancelRequest(widget.request.id!);

      if (cancelResult['success']) {
        // Create new request with updated data
        final newRequest = VacationRequest(
          startDate: DateFormat('yyyy-MM-dd').format(_startDate),
          endDate: DateFormat('yyyy-MM-dd').format(_endDate),
          startTime: _startTime,
          endTime: _endTime,
          type: _vacationType,
          reason: _reasonController.text.trim(),
        );

        final createResult = await _vacationService.createRequest(newRequest);

        setState(() => _isLoading = false);

        if (createResult['success']) {
          widget.onSubmit(newRequest);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vacation request updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update request: ${createResult['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update request: ${cancelResult['message']}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.9,
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.04),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Vacation Request',
                        style: TextStyle(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.02),

                      // Warning message
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning, color: Colors.orange),
                            SizedBox(width: screenWidth * 0.02),
                            Expanded(
                              child: Text(
                                'Editing will cancel the current request and create a new one',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: screenWidth * 0.03,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (widget.balance != null) ...[
                        SizedBox(height: screenWidth * 0.02),
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blue),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                'Available balance: ${widget.balance!.availableDays} days',
                                style: const TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: screenWidth * 0.04),

                      // Vacation Type
                      DropdownButtonFormField<String>(
                        value: _vacationType,
                        decoration: const InputDecoration(
                          labelText: 'Vacation Type',
                          border: OutlineInputBorder(),
                        ),
                        items: VacationType.displayNames.entries.map((entry) {
                          return DropdownMenuItem(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _vacationType = value!;
                          });
                        },
                      ),
                      SizedBox(height: screenWidth * 0.04),

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
                                  DateFormat('MMM dd, yyyy').format(_startDate),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
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
                                  DateFormat('MMM dd, yyyy').format(_endDate),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: screenWidth * 0.04),

                      // Time Selection
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _startTime,
                              decoration: const InputDecoration(
                                labelText: 'Start Time',
                                border: OutlineInputBorder(),
                              ),
                              items: Day.displayNames.entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _startTime = value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _endTime,
                              decoration: const InputDecoration(
                                labelText: 'End Time',
                                border: OutlineInputBorder(),
                              ),
                              items: Day.displayNames.entries.map((entry) {
                                return DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
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
                      SizedBox(height: screenWidth * 0.04),

                      // Reason
                      TextFormField(
                        controller: _reasonController,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please provide a reason';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: screenWidth * 0.04),
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.03),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Colors.green),
                            SizedBox(width: screenWidth * 0.02),
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

                      SizedBox(height: screenWidth * 0.04),

                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          SizedBox(width: screenWidth * 0.02),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _submitEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdaptiveColors.primaryGreen,
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                                : const Text('Update Request'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}