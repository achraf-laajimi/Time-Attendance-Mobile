import 'package:flutter/material.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';

/// Tab displaying the leave requests of an employee
class LeaveTab extends StatelessWidget {
  const LeaveTab({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    // Sample leave data - in a real app, this would come from an API
    final leaveData = [
      {
        'date': 'July 01, 2023',
        'duration': 'July 05 - July 08',
        'days': '3 Days',
        'manager': 'Mark Willians',
        'status': 'Pending',
      },
      {
        'date': 'Apr 05, 2023',
        'duration': 'Apr 06 - Apr 10',
        'days': '4 Days',
        'manager': 'Mark Willians',
        'status': 'Approved',
      },
      {
        'date': 'Mar 12, 2023',
        'duration': 'Mar 14 - Mar 16',
        'days': '2 Days',
        'manager': 'Mark Willians',
        'status': 'Approved',
      },
      {
        'date': 'Feb 01, 2023',
        'duration': 'Feb 02 - Feb 10',
        'days': '8 Days',
        'manager': 'Mark Willians',
        'status': 'Approved',
      },
      {
        'date': 'Jan 01, 2023',
        'duration': 'Jan 16 - Jan 19',
        'days': '3 Days',
        'manager': 'Mark Willians',
        'status': 'Reject',
      },
    ];

    return Column(
      children: [
        // Add new leave request button
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ElevatedButton.icon(
            onPressed: () {
              // Handle leave request
            },
            icon: const Icon(Icons.add, size: 16),
            label: Text(
              localizations.getString('requestLeave'),
              style: const TextStyle(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AdaptiveColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              minimumSize: const Size(double.infinity, 46),
            ),
          ),
        ),

        // Leave list in a card
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
              color: AdaptiveColors.cardColor(context),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AdaptiveColors.borderColor(context),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            localizations.getString('date'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            localizations.getString('duration'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            'Days',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            localizations.getString('status'),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AdaptiveColors.primaryTextColor(context),
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Leave list
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: leaveData.length,
                      itemBuilder: (context, index) {
                        final leave = leaveData[index];
                        Color statusColor;
                        switch (leave['status']) {
                          case 'Approved':
                            statusColor = Colors.green;
                            break;
                          case 'Pending':
                            statusColor = Colors.orange;
                            break;
                          case 'Reject':
                            statusColor = Colors.red;
                            break;
                          default:
                            statusColor = Colors.grey;
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: AdaptiveColors.borderColor(context),
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  leave['date']!,
                                  style: TextStyle(
                                    color: AdaptiveColors.primaryTextColor(
                                        context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  leave['duration']!,
                                  style: TextStyle(
                                    color: AdaptiveColors.primaryTextColor(
                                        context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  leave['days']!,
                                  style: TextStyle(
                                    color: AdaptiveColors.primaryTextColor(
                                        context),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      leave['status']!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}