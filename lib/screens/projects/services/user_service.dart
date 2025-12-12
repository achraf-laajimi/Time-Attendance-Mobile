import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:in_out/auth/global.dart';
import 'auth_service.dart';
import '../models/ExpressUser.dart';

class ExpressUserService {
  static final ExpressUserService _instance = ExpressUserService._internal();
  factory ExpressUserService() => _instance;
  ExpressUserService._internal();

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int limit = 10,
    String search = "",
    String? role,
    bool? isActive,
    String sort = "createdAt",
    String order = "desc",
  }) async {
    // First ensure we have valid authentication
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    // Make the initial request
    var result = await _fetchUsersWithToken(
      page: page,
      limit: limit,
      search: search,
      role: role,
      isActive: isActive,
      sort: sort,
      order: order,
    );

    // Handle token expiration (401 status)
    if (result['statusCode'] == 401) {
      // Clear invalid tokens
      await Global.clearExpressTokens();
      
      // Retry authentication and request
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      
      result = await _fetchUsersWithToken(
        page: page,
        limit: limit,
        search: search,
        role: role,
        isActive: isActive,
        sort: sort,
        order: order,
      );
    }

    return result;
  }

  Future<List<ExpressUser>> getTechnicians() async {
    return _fetchUsersByRole('technician');
  }

  Future<List<ExpressUser>> getClients() async {
    return _fetchUsersByRole('client');
  }

  Future<List<ExpressUser>> getManagers() async {
    return _fetchUsersByRole('project manager');
  }

  Future<List<ExpressUser>> getStockManagers() async {
    return _fetchUsersByRole('stock manager');
  }

  Future<Map<String, dynamic>> getUserById(String id) async {
    try {
      final headers = await Global.getProjectHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'shouldLogout': true,
        };
      }

      final response = await http.get(
        Uri.parse('${Global.baseUrl2}/users/profile/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': ExpressUser.fromJson(data['data']),
          'message': 'User fetched successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'fetch user', response.body),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Request failed: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String role,
    String? phoneNumber,
    String? matriculeNumber,
    bool isActive = true,
  }) async {
    try {
      final headers = await Global.getProjectHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'shouldLogout': true,
        };
      }

      final response = await http.post(
        Uri.parse('${Global.baseUrl2}/users'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'role': role,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (matriculeNumber != null) 'matriculeNumber': matriculeNumber,
          'isActive': isActive,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': ExpressUser.fromJson(data['data']),
          'message': 'User created successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'create user', response.body),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Request failed: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String id,
    String? name,
    String? email,
    String? role,
    String? phoneNumber,
    String? matriculeNumber,
    bool? isActive,
  }) async {
    try {
      final headers = await Global.getProjectHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'shouldLogout': true,
        };
      }

      final response = await http.put(
        Uri.parse('${Global.baseUrl2}/users/$id'),
        headers: headers,
        body: jsonEncode({
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (role != null) 'role': role,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (matriculeNumber != null) 'matriculeNumber': matriculeNumber,
          if (isActive != null) 'isActive': isActive,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': ExpressUser.fromJson(data['data']),
          'message': 'User updated successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'update user', response.body),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Request failed: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> deleteUser(String id) async {
    try {
      final headers = await Global.getProjectHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'shouldLogout': true,
        };
      }

      final response = await http.delete(
        Uri.parse('${Global.baseUrl2}/users/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'User deleted successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'delete user', response.body),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Request failed: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> toggleUserActive(String id) async {
    try {
      final headers = await Global.getProjectHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'shouldLogout': true,
        };
      }

      final response = await http.patch(
        Uri.parse('${Global.baseUrl2}/users/$id/toggle-active'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': ExpressUser.fromJson(data['data']),
          'message': 'User status toggled successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'toggle user status', response.body),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Request failed: ${e.toString()}',
      };
    }
  }

  // Private helper methods
  Future<Map<String, dynamic>> _ensureAuthenticated() async {
    try {
      final authReady = await AuthService().ensureExpressAuth();
      if (!authReady) {
        return {
          'authenticated': false,
          'response': {
            'success': false,
            'message': 'Authentication failed',
            'shouldLogout': true
          }
        };
      }
      return {'authenticated': true};
    } catch (e) {
      return {
        'authenticated': false,
        'response': {
          'success': false,
          'message': 'Authentication error: ${e.toString()}',
          'shouldLogout': true
        }
      };
    }
  }

  Future<Map<String, dynamic>> _fetchUsersWithToken({
    required int page,
    required int limit,
    required String search,
    String? role,
    bool? isActive,
    required String sort,
    required String order,
  }) async {
    try {
      final headers = await Global.getProjectHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'shouldLogout': true,
        };
      }

      final uri = Uri.parse('${Global.baseUrl2}/users').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (search.isNotEmpty) 'search': search,
          if (role != null) 'role': role,
          if (isActive != null) 'isActive': isActive.toString(),
          'sort': sort,
          'order': order,
        },
      );

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': {
            'users': (data['data']['users'] as List)
                .map((json) => ExpressUser.fromJson(json))
                .toList(),
            'pagination': data['data']['pagination'] ?? {
              'total': data['data']['users'].length,
              'page': page,
              'pages': 1,
              'limit': limit,
            },
          },
          'message': 'Users loaded successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'fetch users', response.body),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Request failed: ${e.toString()}',
      };
    }
  }

  Future<List<ExpressUser>> _fetchUsersByRole(String role) async {
    try {
      final result = await getUsers(role: role, limit: 100);
      if (result['success'] == true) {
        return (result['data']?['users'] as List<ExpressUser>?) ?? [];
      } else {
        throw Exception(result['message'] ?? 'Failed to load $role users');
      }
    } catch (e) {
      print('Error fetching $role users: $e');
      rethrow;
    }
  }

  String _getErrorMessage(int statusCode, String operation, String responseBody) {
    try {
      final errorData = jsonDecode(responseBody);
      return errorData['message'] ?? 'Failed to $operation (Status: $statusCode)';
    } catch (_) {
      return 'Failed to $operation (Status: $statusCode)';
    }
  }
}