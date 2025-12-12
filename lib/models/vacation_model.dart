// lib/models/vacation_model.dart
import 'dart:ui';

class VacationRequest {
  final int? id;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String type;
  final String reason;
  final String? status;
  final int? userId;
  final String? userName;
  final String? userEmail;
  final String? userFirstName;  // Ajout du prénom de l'utilisateur
  final String? userLastName;   // Ajout du nom de famille de l'utilisateur
  final String? userDepartment; // Ajout du département de l'utilisateur
  final String? userDesignation; // Ajout de la désignation de l'utilisateur
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VacationRequest({
    this.id,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.reason,
    this.status,
    this.userId,
    this.userName,
    this.userEmail,
    this.userFirstName,
    this.userLastName,
    this.userDepartment,
    this.userDesignation,
    this.createdAt,
    this.updatedAt,
  });

  factory VacationRequest.fromJson(Map<String, dynamic> json) {
    // Récupérer les détails de l'utilisateur
    String? userFirstName;
    String? userLastName;
    String? userDepartment;
    String? userDesignation;
    String? userFullName;
    String? userEmail;

    // Extraire les informations de l'utilisateur si disponibles
    if (json['user'] != null) {
      final user = json['user'];
      userFirstName = user['firstName'];
      userLastName = user['lastName'];
      userEmail = user['email'];

      // Déterminer le nom complet
      if (userFirstName != null && userLastName != null) {
        userFullName = '$userFirstName $userLastName';
      }

      // Extraire le département et la désignation si disponibles
      if (user['attributes'] != null) {
        final attributes = user['attributes'];
        if (attributes['department'] != null) {
          userDepartment = attributes['department']['name'];
        }
        userDesignation = user['designation'];
      }
    }

    return VacationRequest(
      id: json['id'],
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      startTime: json['startTime'] ?? 'MORNING',
      endTime: json['endTime'] ?? 'MORNING',
      type: json['type'] ?? 'ANNUAL_LEAVE',
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'PENDING',
      userId: json['userId'] ?? (json['user'] != null ? json['user']['id'] : null),
      userName: userFullName ?? json['userName'],
      userEmail: userEmail ?? json['userEmail'],
      userFirstName: userFirstName,
      userLastName: userLastName,
      userDepartment: userDepartment,
      userDesignation: userDesignation,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Create the payload that exactly matches the API expectation
    final Map<String, dynamic> json = {
      'startDate': startDate,
      'endDate': endDate,
      'startTime': startTime,
      'endTime': endTime,
      'type': type,
      'reason': reason,
    };

    // Only include optional fields if they exist
    if (id != null) {
      json['id'] = id;
    }
    if (status != null) {
      json['status'] = status;
    }
    if (userId != null) {
      json['userId'] = userId;
    }

    return json;
  }

  // Calculate number of days
  int get numberOfDays {
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);
      int days = end.difference(start).inDays + 1;

      // Adjust for half days
      if (startTime == 'AFTERNOON' && startDate == endDate) {
        return 0.5.round();
      }
      if (endTime == 'MORNING' && startDate == endDate) {
        return 0.5.round();
      }
      if (startTime == 'AFTERNOON') {
        days -= 0.5.round();
      }
      if (endTime == 'MORNING') {
        days -= 0.5.round();
      }

      return days;
    } catch (e) {
      return 0;
    }
  }

  // Get the user's full name or fallback to userName
  String get fullName {
    if (userFirstName != null && userLastName != null) {
      return '$userFirstName $userLastName';
    }
    return userName ?? 'Unknown Employee';
  }

  bool get canEdit => status == 'PENDING';
  bool get canCancel => status == 'PENDING';
}

// Enums for vacation types and statuses
class VacationType {
  static const String sickLeave = 'SICK_LEAVE';
  static const String regularLeave = 'REGULAR_LEAVE';
  static const String unpaidLeave = 'UNPAID_LEAVE';
  static const String annualLeave = 'ANNUAL_LEAVE';   // Ajout du type de congé annuel
  static const String maternityLeave = 'MATERNITY_LEAVE'; // Ajout du congé maternité
  static const String paternityLeave = 'PATERNITY_LEAVE'; // Ajout du congé paternité
  static const String personalLeave = 'PERSONAL_LEAVE'; // Ajout du congé personnel

  static Map<String, String> get displayNames => {
    sickLeave: 'Sick Leave',
    regularLeave: 'Regular Leave',
    unpaidLeave: 'Unpaid Leave',
    annualLeave: 'Annual Leave',
    maternityLeave: 'Maternity Leave',
    paternityLeave: 'Paternity Leave',
    personalLeave: 'Personal Leave',
  };
}

class VacationStatus {
  static const String pending = 'PENDING';
  static const String approved = 'APPROVED';
  static const String rejected = 'REJECTED';
  static const String cancelled = 'CANCELLED';

  static Map<String, String> get displayNames => {
    pending: 'Pending',
    approved: 'Approved',
    rejected: 'Rejected',
    cancelled: 'Cancelled',
  };

  static Map<String, Color> get colors => {
    pending: const Color(0xFFF57C00),
    approved: const Color(0xFF2E7D32),
    rejected: const Color(0xFFD32F2F),
    cancelled: const Color(0xFF757575),
  };
}

class Day {
  static const String morning = 'MORNING';
  static const String afternoon = 'AFTERNOON';

  static Map<String, String> get displayNames => {
    morning: 'Morning',
    afternoon: 'Afternoon',
  };
}