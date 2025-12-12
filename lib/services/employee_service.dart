import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/global.dart';
import '../models/employee_model.dart';

class EmployeeService {
  // Get all employees with pagination
  static Future<Map<String, dynamic>> getEmployees({int page = 0, int size = 10}) async {
    final Uri url = Uri.parse(
        "${Global.baseUrl}/secure/users?page=$page&size=$size");

    try {
      final response = await http.get(
        url,
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> content = responseData['content'] ?? [];
        final List<Employee> employees =
        content.map<Employee>((item) => Employee.fromJson(item)).toList();


        return {
          "success": true,
          "employees": employees,
          "totalElements": responseData['totalElements'] ?? 0,
          "totalPages": responseData['totalPages'] ?? 0,
          "currentPage": responseData['pageable']?['pageNumber'] ?? 0,
          "size": responseData['pageable']?['pageSize'] ?? size,
          "first": responseData['first'] ?? false,
          "last": responseData['last'] ?? false,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to load employees: ${response.statusCode}",
          "employees": <Employee>[],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
        "employees": <Employee>[],
      };
    }
  }

  // Search employees with pagination
  static Future<Map<String, dynamic>> searchEmployees(String query, {int page = 0, int size = 10}) async {
    final Uri url = Uri.parse(
        "${Global.baseUrl}/secure/users/search?query=$query&page=$page&size=$size");

    try {
      final response = await http.get(
        url,
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> content = responseData['content'] ?? [];

        final List<Employee> employees =
        content.map<Employee>((item) => Employee.fromJson(item)).toList();

        return {
          "success": true,
          "employees": employees,
          "totalElements": responseData['totalElements'] ?? 0,
          "totalPages": responseData['totalPages'] ?? 0,
          "currentPage": responseData['pageable']?['pageNumber'] ?? 0,
          "size": responseData['pageable']?['pageSize'] ?? size,
          "first": responseData['first'] ?? false,
          "last": responseData['last'] ?? false,
        };
      } else {
        return {
          "success": false,
          "message": "Failed to search employees: ${response.statusCode}",
          "employees": <Employee>[],
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
        "employees": <Employee>[],
      };
    }
  }

  // Create a new employee
  static Future<Map<String, dynamic>> createEmployee(Employee employee) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/users");

    try {
      // Create payload with updated fields
      final Map<String, dynamic> employeeData = employee.toJson();

      print("Sending modified employee data: ${jsonEncode(employeeData)}");

      final response = await http.post(
        url,
        headers: await Global.getHeaders(),
        body: jsonEncode(employeeData),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check for success status codes (both 200 and 201)
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Check if the response body is empty
        if (response.body.isEmpty || response.body.trim().isEmpty) {
          // If empty but status is success, return success with the sent employee data
          return {
            "success": true,
            "employee": employee, // Return the original employee object since we don't have a response
            "message": "Employee created successfully"
          };
        }

        // If response has content, try to decode it
        try {
          final responseData = jsonDecode(response.body);
          return {
            "success": true,
            "employee": Employee.fromJson(responseData),
            "message": "Employee created successfully"
          };
        } catch (e) {
          // If JSON parsing fails but status is success, still return success
          print("Warning: Could not parse response body: $e");
          return {
            "success": true,
            "employee": employee, // Return the original employee object
            "message": "Employee created successfully, but response parsing failed"
          };
        }
      } else {
        // Handle error responses
        String errorMessage = "Failed to create employee: ${response.statusCode}";
        try {
          if (response.body.isNotEmpty) {
            final responseData = jsonDecode(response.body);
            errorMessage = responseData["message"] ?? errorMessage;
          }
        } catch (e) {
          // Ignore parsing errors for error responses
        }

        return {
          "success": false,
          "message": errorMessage
        };
      }
    } catch (e) {
      print("Error creating employee: $e");
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }

  // Get employee by ID
  static Future<Map<String, dynamic>> getEmployeeById(int employeeId) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/users/$employeeId");

    try {
      final response = await http.get(
        url,
        headers: await Global.getHeaders()
        ,
      );

      // Print for debugging
      print("API Response status: ${response.statusCode}");
      print("API Response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        print("Parsed response data: $responseData");

        try {
          // More safe approach - don't immediately create an Employee object
          return {
            "success": true,
            "employee": responseData,
            "rawData": responseData
          };
        } catch (e) {
          print("Error parsing employee data: $e");
          return {
            "success": false,
            "message": "Error parsing employee data: $e"
          };
        }
      } else {
        // Handle error responses with status codes
        try {
          final responseData = jsonDecode(response.body);
          return {
            "success": false,
            "message": responseData["message"] ?? "Failed to get employee details. Error code: ${response.statusCode}"
          };
        } catch (e) {
          return {
            "success": false,
            "message": "Failed to parse error response. Status code: ${response.statusCode}"
          };
        }
      }
    } catch (e) {
      // Handle network or parsing errors
      print("Network error: $e");
      return {"success": false, "message": "Error connecting to server: $e"};
    }
  }

  // Update an employee
  static Future<Map<String, dynamic>> updateEmployee(Employee employee) async {
    final Uri url =
    Uri.parse("${Global.baseUrl}/secure/users/${employee.id}");

    try {
      // Create payload with updated fields for update operation
      // Note: username is removed from update payload as per requirements
      final Map<String, dynamic> updateData = {
        'email': employee.email,
        'personalEmail': employee.personalEmail,
        'phoneNumber': employee.phoneNumber,
        'firstName': employee.firstName,
        'lastName': employee.lastName,
        'gender': employee.gender,
        'maritalStatus': employee.maritalStatus,
        'birthDate': employee.birthDate,
        'recruitmentDate': employee.recruitmentDate,
        'role': employee.role,
        'type': employee.type,
        'companyId': employee.companyId,
        'designation': employee.designation,
        'address': employee.address, // Added address field
        'active': employee.active
      };

      final response = await http.put(
        url,
        headers: await Global.getHeaders(),
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
        return {
          "success": true,
          "employee": Employee.fromJson(jsonDecode(response.body)),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to update employee: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Delete an employee
  static Future<Map<String, dynamic>> deleteEmployee(int id) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/users/$id");

    try {
      final response = await http.delete(
        url,
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          "success": true,
        };
      } else {
        // Safely parse the response body
        try {
          final responseBody = jsonDecode(response.body);
          return {
            "success": false,
            "message": responseBody['message'] ?? "Failed to delete employee: ${response.statusCode}",
          };
        } catch (e) {
          return {
            "success": false,
            "message": "Failed to delete employee: ${response.statusCode}",
          };
        }
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  // Extract department info
  static Map<String, dynamic> extractDepartmentInfo(Map<String, dynamic>? employeeData) {
    String departmentName = 'Unknown';
    String departmentKey = '';
    bool hasDepartmentInfo = false;

    if (employeeData != null) {
      if (employeeData['attributes'] != null &&
          employeeData['attributes']['department'] != null) {
        // Extract from new structure
        Map<String, dynamic> deptData = employeeData['attributes']['department'];
        departmentName = deptData['name'] ?? 'Unknown';
        departmentKey = deptData['key']?.toString() ?? '';
        hasDepartmentInfo = true;
      } else if (employeeData['department'] != null) {
        // Extract from old structure
        departmentName = employeeData['department'];
        hasDepartmentInfo = true;
      } else if (employeeData['designation'] != null &&
          employeeData['designation'].toString().contains(' ')) {
        // Legacy fallback - extract from designation
        departmentName = employeeData['designation'].toString().split(' ').last;
      }
    }

    return {
      'name': departmentName,
      'key': departmentKey,
      'hasInfo': hasDepartmentInfo,
    };
  }

// Usage example:
// Map<String, dynamic> departmentInfo = EmployeeService.extractDepartmentInfo(employeeData);
// String departmentName = departmentInfo['name'];
// String departmentKey = departmentInfo['key'];
// bool hasDepartmentInfo = departmentInfo['hasInfo'];
}