// lib/services/vacation_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/global.dart';
import '../models/vacation_model.dart';
import '../models/vacation_balance_model.dart';

class VacationService {
  static final VacationService _instance = VacationService._internal();
  factory VacationService() => _instance;
  VacationService._internal();

  // Employee APIs

  // Get vacation balance for current user
  Future<Map<String, dynamic>> getMyBalance() async {
    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/vocations/balance"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "balance": VacationBalance.fromJson(data),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load balance: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Get my vacation requests
  Future<Map<String, dynamic>> getMyRequests() async {
    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/vocations"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final requests = data.map((item) => VacationRequest.fromJson(item)).toList();

        return {
          "success": true,
          "requests": requests,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load requests: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Create new vacation request
  Future<Map<String, dynamic>> createRequest(VacationRequest request) async {
    try {
      print('VacationService: Creating request with data: ${request.toJson()}');

      final response = await http.post(
        Uri.parse("${Global.baseUrl}/secure/vocations"),
        headers: await Global.getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      print('VacationService: Response status: ${response.statusCode}');
      print('VacationService: Response body: ${response.body}');

      // Accept both 200 and 202 as success codes
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        // Determine success message based on status code
        String successMessage;
        switch (response.statusCode) {
          case 200:
            successMessage = "Vacation request created successfully";
            break;
          case 201:
            successMessage = "Vacation request created successfully";
            break;
          case 202:
            successMessage = "Vacation request submitted and is being processed";
            break;
          default:
            successMessage = "Vacation request submitted successfully";
        }

        return {
          "success": true,
          "message": successMessage,
          "statusCode": response.statusCode,
        };
      } else {
        // Handle error responses
        String errorMessage = "Failed to create vacation request";
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (parseError) {
          // If we can't parse the error response, use a generic message with status code
          errorMessage = "Failed to create vacation request (Status: ${response.statusCode})";
        }

        return {
          "success": false,
          "message": errorMessage,
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      print('VacationService: Exception occurred: $e');
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Cancel vacation request
  Future<Map<String, dynamic>> cancelRequest(int requestId) async {
    try {
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/vocations?id=$requestId"),
        headers: await Global.getHeaders(),
      );

      print('VacationService: Cancel request status: ${response.statusCode}');

      // Accept 200, 202, and 204 as success codes for cancellation
      if (response.statusCode == 200 || response.statusCode == 202 || response.statusCode == 204) {
        String successMessage;
        switch (response.statusCode) {
          case 200:
            successMessage = "Vacation request cancelled successfully";
            break;
          case 202:
            successMessage = "Vacation request cancellation is being processed";
            break;
          case 204:
            successMessage = "Vacation request cancelled successfully";
            break;
          default:
            successMessage = "Vacation request cancelled successfully";
        }

        return {
          "success": true,
          "message": successMessage,
          "statusCode": response.statusCode,
        };
      } else {
        String errorMessage = "Failed to cancel vacation request";
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (parseError) {
          errorMessage = "Failed to cancel vacation request (Status: ${response.statusCode})";
        }

        return {
          "success": false,
          "message": errorMessage,
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  Future<Map<String, dynamic>> getEmployeeBalance(int userId) async {
    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/user-vocation/balance?userId=$userId"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          "success": true,
          "balance": VacationBalance.fromJson(data),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load employee balance: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  Future<Map<String, dynamic>> getEmployeeRequests() async {
    try {
      final response = await http.get(
        Uri.parse("${Global.baseUrl}/secure/user-vocation/list"),
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('Received employee requests data: $data');

        final requests = data.map((item) => VacationRequest.fromJson(item)).toList();

        return {
          "success": true,
          "requests": requests,
        };
      } else {
        print('Failed to load employee requests: ${response.statusCode}');
        print('Response body: ${response.body}');

        return {
          "success": false,
          "message": "Failed to load employee requests: ${response.statusCode}",
        };
      }
    } catch (e) {
      print('Error connecting to server: $e');
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  Future<Map<String, dynamic>> manageRequest(int requestId, String status) async {
    try {
      final response = await http.put(
        Uri.parse("${Global.baseUrl}/secure/user-vocation?id=$requestId"),
        headers: await Global.getHeaders(),
        body: jsonEncode({
          "id": requestId.toString(),
          "status": status,
        }),
      );

      print('VacationService: Manage request status: ${response.statusCode}');

      // Accept 200, 201, and 202 as success codes for management actions
      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202) {
        String successMessage;
        switch (response.statusCode) {
          case 200:
            successMessage = "Request $status successfully";
            break;
          case 201:
            successMessage = "Request $status successfully";
            break;
          case 202:
            successMessage = "Request $status and is being processed";
            break;
          default:
            successMessage = "Request $status successfully";
        }

        return {
          "success": true,
          "message": successMessage,
          "statusCode": response.statusCode,
        };
      } else {
        String errorMessage = "Failed to update request";
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          }
        } catch (parseError) {
          errorMessage = "Failed to update request (Status: ${response.statusCode})";
        }

        return {
          "success": false,
          "message": errorMessage,
          "statusCode": response.statusCode,
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
  }

  String _getSuccessMessage(int statusCode, String operation) {
    switch (statusCode) {
      case 200:
        return "$operation completed successfully";
      case 201:
        return "$operation created successfully";
      case 202:
        return "$operation accepted and is being processed";
      case 204:
        return "$operation completed successfully";
      default:
        return "$operation completed successfully";
    }
  }

  String _getErrorMessage(int statusCode, String operation, String? responseBody) {
    String baseMessage = "Failed to $operation";

    try {
      if (responseBody != null && responseBody.isNotEmpty) {
        final errorData = json.decode(responseBody);
        return errorData['message'] ?? "$baseMessage (Status: $statusCode)";
      }
    } catch (e) {
      // Ignore JSON parsing errors
    }

    return "$baseMessage (Status: $statusCode)";
  }

}