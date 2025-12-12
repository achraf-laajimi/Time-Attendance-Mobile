class VacationBalance {
  final double totalDays;
  final double usedDays;
  final double remainingDays;
  final double pendingDays;
  final Map<String, BalanceDetail>? typeBreakdown;

  VacationBalance({
    required this.totalDays,
    required this.usedDays,
    required this.remainingDays,
    required this.pendingDays,
    this.typeBreakdown,
  });

  factory VacationBalance.fromJson(Map<String, dynamic> json) {
    Map<String, BalanceDetail>? breakdown;

    if (json['typeBreakdown'] != null) {
      breakdown = {};
      json['typeBreakdown'].forEach((key, value) {
        breakdown![key] = BalanceDetail.fromJson(value);
      });
    }

    return VacationBalance(
      totalDays: (json['totalDays'] ?? 0).toDouble(),
      usedDays: (json['usedDays'] ?? 0).toDouble(),
      remainingDays: (json['balance'] ?? 0).toDouble(),
      pendingDays: (json['pendingDays'] ?? 0).toDouble(),
      typeBreakdown: breakdown,
    );
  }

  double get availableDays => remainingDays - pendingDays;
  double get usagePercentage => availableDays > 0 ? (usedDays / availableDays) * 100 : 0;
}

class BalanceDetail {
  final double total;
  final double used;
  final double remaining;

  BalanceDetail({
    required this.total,
    required this.used,
    required this.remaining,
  });

  factory BalanceDetail.fromJson(Map<String, dynamic> json) {
    return BalanceDetail(
      total: (json['total'] ?? 0).toDouble(),
      used: (json['used'] ?? 0).toDouble(),
      remaining: (json['remaining'] ?? 0).toDouble(),
    );
  }
}