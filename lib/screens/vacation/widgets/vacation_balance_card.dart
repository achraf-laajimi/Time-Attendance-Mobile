import 'package:flutter/material.dart';
import '../../../models/vacation_balance_model.dart';
import '../../../theme/adaptive_colors.dart';

class VacationBalanceCard extends StatelessWidget {
  final VacationBalance balance;

  const VacationBalanceCard({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AdaptiveColors.cardColor(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AdaptiveColors.shadowColor(context),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vacation Balance',
            style: TextStyle(
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
              color: AdaptiveColors.primaryTextColor(context),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: balance.availableDays / 100,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                balance.availableDays > 80
                    ? Colors.orange
                    : AdaptiveColors.primaryGreen,
              ),
              minHeight: screenHeight * 0.01,
            ),
          ),
          SizedBox(height: screenHeight * 0.01),

          Text(
            '${balance.availableDays.toStringAsFixed(0)}% used',
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: AdaptiveColors.secondaryTextColor(context),
            ),
          ),
          SizedBox(height: screenHeight * 0.02),

          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  context,
                  'Total',
                  balance.totalDays,
                  Icons.calendar_month,
                  Colors.blue,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: _buildBalanceItem(
                  context,
                  'Used',
                  balance.usedDays,
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: screenHeight * 0.02),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  context,
                  'Available',
                  balance.availableDays,
                  Icons.event_available,
                  Colors.teal,
                ),
              ),
              SizedBox(width: screenWidth * 0.02),
              Expanded(
                child: _buildBalanceItem(
                  context,
                  'Pending',
                  balance.pendingDays,
                  Icons.pending,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(
      BuildContext context,
      String label,
      double days,
      IconData icon,
      Color color,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: screenWidth * 0.06,
          ),
          SizedBox(width: screenWidth * 0.02),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03,
                    color: AdaptiveColors.secondaryTextColor(context),
                  ),
                ),
                Text(
                  '${days.toStringAsFixed(days % 1 == 0 ? 0 : 1)} days',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: AdaptiveColors.primaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}