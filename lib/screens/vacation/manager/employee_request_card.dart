import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../theme/adaptive_colors.dart';
import '../../../models/vacation_model.dart';
import '../../../localization/app_localizations.dart';

class EmployeeRequestCard extends StatelessWidget {
  final VacationRequest request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;
  final VoidCallback? onViewBalance;

  const EmployeeRequestCard({
    super.key,
    required this.request,
    this.onApprove,
    this.onReject,
    this.onViewBalance,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);

    return Container(
      margin: EdgeInsets.only(bottom: screenHeight * 0.015),
      decoration: BoxDecoration(
        color: AdaptiveColors.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AdaptiveColors.shadowColor(context),
            blurRadius: 3,
            offset: const Offset(0, 2),
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
                // Employee info and status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: screenWidth * 0.05,
                                backgroundColor: _getAvatarColor(request.fullName),
                                child: Text(
                                  _getInitials(request.fullName),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: screenWidth * 0.035,
                                  ),
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      request.fullName,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.bold,
                                        color: AdaptiveColors.primaryTextColor(context),
                                      ),
                                    ),
                                    if (request.userEmail != null)
                                      Text(
                                        request.userEmail!,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: AdaptiveColors.secondaryTextColor(context),
                                        ),
                                      ),
                                    // Afficher le département et la désignation si disponibles
                                    if (request.userDepartment != null || request.userDesignation != null)
                                      Text(
                                        [
                                          if (request.userDepartment != null) request.userDepartment,
                                          if (request.userDesignation != null) request.userDesignation
                                        ].where((e) => e != null).join(' - '),
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.03,
                                          color: AdaptiveColors.secondaryTextColor(context),
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(context, request.status ?? 'PENDING'),
                  ],
                ),
                SizedBox(height: screenHeight * 0.015),

                // Request type
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.025,
                    vertical: screenWidth * 0.015,
                  ),
                  decoration: BoxDecoration(
                    color: AdaptiveColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    VacationType.displayNames[request.type] ?? request.type,
                    style: TextStyle(
                      color: AdaptiveColors.primaryGreen,
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
                      '${request.numberOfDays} ${request.numberOfDays != 1 ? localizations.getString('days') : localizations.getString('day')}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: AdaptiveColors.primaryTextColor(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                if (request.reason.isNotEmpty) ...[
                  SizedBox(height: screenHeight * 0.01),
                  Container(
                    padding: EdgeInsets.all(screenWidth * 0.03),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${localizations.getString('reason')}:',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            color: AdaptiveColors.secondaryTextColor(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.005),
                        Text(
                          request.reason,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Request date
                if (request.createdAt != null) ...[
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    localizations.getString('requestedOn').replaceAll('{date}', DateFormat('MMM dd, yyyy').format(request.createdAt!)),
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,
                      color: AdaptiveColors.secondaryTextColor(context),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Actions
          if (onApprove != null || onReject != null || onViewBalance != null)
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
                  if (onViewBalance != null) ...[
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onViewBalance,
                        icon: Icon(
                          Icons.account_balance_wallet,
                          size: screenWidth * 0.04,
                        ),
                        label: Text(localizations.getString('viewBalance')),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: screenHeight * 0.04,
                      color: AdaptiveColors.borderColor(context),
                    ),
                  ],
                  if (onApprove != null) ...[
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onApprove,
                        icon: Icon(
                          Icons.check_circle,
                          size: screenWidth * 0.04,
                        ),
                        label: Text(localizations.getString('approveRequest')),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: screenHeight * 0.04,
                      color: AdaptiveColors.borderColor(context),
                    ),
                  ],
                  if (onReject != null)
                    Expanded(
                      child: TextButton.icon(
                        onPressed: onReject,
                        icon: Icon(
                          Icons.cancel,
                          size: screenWidth * 0.04,
                        ),
                        label: Text(localizations.getString('rejectRequest')),
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
    final localizations = AppLocalizations.of(context);

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
        localizations.getString(displayName.toLowerCase()) ?? displayName,
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
      final formatter = DateFormat('MMM dd');
      final yearFormatter = DateFormat('yyyy');

      if (request.startDate == request.endDate) {
        String dayPart = '';
        if (request.startTime == 'AFTERNOON' || request.endTime == 'MORNING') {
          dayPart = ' (${Day.displayNames[request.startTime] ?? request.startTime})';
        }
        return '${formatter.format(startDate)}, ${yearFormatter.format(startDate)}$dayPart';
      } else {
        // Show year only on end date if different years
        if (startDate.year == endDate.year) {
          return '${formatter.format(startDate)} - ${formatter.format(endDate)}, ${yearFormatter.format(endDate)}';
        } else {
          return '${formatter.format(startDate)}, ${yearFormatter.format(startDate)} - '
              '${formatter.format(endDate)}, ${yearFormatter.format(endDate)}';
        }
      }
    } catch (e) {
      return '${request.startDate} - ${request.endDate}';
    }
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'NA';

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }

    return 'NA';
  }

  Color _getAvatarColor(String name) {
    final colors = [
      Colors.blue.shade400,
      Colors.red.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
      Colors.teal.shade400,
      Colors.pink.shade400,
    ];

    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}