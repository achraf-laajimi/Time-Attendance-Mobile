import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/vacation_model.dart';
import '../../../theme/adaptive_colors.dart';

class VacationRequestItem extends StatelessWidget {
  final VacationRequest request;
  final VoidCallback? onCancel;
  final VoidCallback? onEdit;

  const VacationRequestItem({
    super.key,
    required this.request,
    this.onCancel,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AdaptiveColors.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AdaptiveColors.shadowColor(context),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        VacationType.displayNames[request.type] ?? request.type,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: AdaptiveColors.primaryTextColor(context),
                        ),
                      ),
                    ),
                    _buildStatusChip(context, request.status ?? 'PENDING'),
                  ],
                ),
                SizedBox(height: screenHeight * 0.01),

                // Date range
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: screenWidth * 0.04,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      _formatDateRange(request),
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: AdaptiveColors.primaryTextColor(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.005),

                // Duration
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: screenWidth * 0.04,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                    SizedBox(width: screenWidth * 0.02),
                    Text(
                      '${request.numberOfDays} day${request.numberOfDays != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: AdaptiveColors.primaryTextColor(context),
                      ),
                    ),
                  ],
                ),

                if (request.reason.isNotEmpty) ...[
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    'Reason: ${request.reason}',
                    style: TextStyle(
                      fontSize: screenWidth * 0.035,
                      color: AdaptiveColors.secondaryTextColor(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (onCancel != null || onEdit != null)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AdaptiveColors.borderColor(context),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onEdit,
                        icon: Icon(
                          Icons.edit,
                          size: screenWidth * 0.04,
                        ),
                        label: const Text('Edit'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                  if (onEdit != null && onCancel != null)
                    Container(
                      width: 1,
                      height: screenHeight * 0.04,
                      color: AdaptiveColors.borderColor(context),
                    ),
                  if (onCancel != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onCancel,
                        icon: Icon(
                          Icons.cancel,
                          size: screenWidth * 0.04,
                        ),
                        label: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, String status) {
    final screenWidth = MediaQuery.of(context).size.width;
    final color = VacationStatus.colors[status] ?? Colors.grey;
    final displayName = VacationStatus.displayNames[status] ?? status;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.03,
        vertical: screenWidth * 0.015,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          color: color,
          fontSize: screenWidth * 0.03,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDateRange(VacationRequest request) {
    try {
      final startDate = DateTime.parse(request.startDate);
      final endDate = DateTime.parse(request.endDate);
      final formatter = DateFormat('MMM dd, yyyy');

      if (request.startDate == request.endDate) {
        String dayPart = '';
        if (request.startTime == 'AFTERNOON' || request.endTime == 'MORNING') {
          dayPart = ' (${Day.displayNames[request.startTime] ?? request.startTime})';
        }
        return formatter.format(startDate) + dayPart;
      } else {
        return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
      }
    } catch (e) {
      return '${request.startDate} - ${request.endDate}';
    }
  }
}