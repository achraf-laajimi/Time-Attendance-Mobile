import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../auth/global.dart';
import 'auth_service.dart';
import '../models/project_model.dart';

class ProjectService {
  static final ProjectService _instance = ProjectService._internal();
  factory ProjectService() => _instance;
  ProjectService._internal();

  Future<Map<String, dynamic>> getProjects({
    int page = 1,
    int limit = 10,
    String search = "",
    String? status,
    String? clientId,
    String? projectManagerId,
    String? stockManagerId,
    DateTime? startDate,
    DateTime? endDate,
    String sort = "createdAt",
    String order = "desc",
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _fetchProjectsWithToken(
      page: page,
      limit: limit,
      search: search,
      status: status,
      clientId: clientId,
      projectManagerId: projectManagerId,
      stockManagerId: stockManagerId,
      startDate: startDate,
      endDate: endDate,
      sort: sort,
      order: order,
    );

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _fetchProjectsWithToken(
        page: page,
        limit: limit,
        search: search,
        status: status,
        clientId: clientId,
        projectManagerId: projectManagerId,
        stockManagerId: stockManagerId,
        startDate: startDate,
        endDate: endDate,
        sort: sort,
        order: order,
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> getProjectById(String id) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _getProjectByIdWithToken(id);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _getProjectByIdWithToken(id);
    }

    return result;
  }

  Future<Map<String, dynamic>> createProject(Map<String, dynamic> project) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _createProjectWithToken(project);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _createProjectWithToken(project);
    }

    return result;
  }

  Future<Map<String, dynamic>> updateProject(String id, Map<String, dynamic> project) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _updateProjectWithToken(id, project);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _updateProjectWithToken(id, project);
    }

    return result;
  }

  Future<Map<String, dynamic>> deleteProject(String id) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _deleteProjectWithToken(id);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _deleteProjectWithToken(id);
    }

    return result;
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

  Future<Map<String, dynamic>> _fetchProjectsWithToken({
    required int page,
    required int limit,
    required String search,
    String? status,
    String? clientId,
    String? projectManagerId,
    String? stockManagerId,
    DateTime? startDate,
    DateTime? endDate,
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

      final uri = Uri.parse('${Global.baseUrl2}/projects').replace(
        queryParameters: {
          'page': page.toString(),
          'limit': limit.toString(),
          if (search.isNotEmpty) 'search': search,
          if (status != null) 'status': status,
          if (clientId != null) 'client': clientId,
          if (projectManagerId != null) 'projectManager': projectManagerId,
          if (stockManagerId != null) 'stockManager': stockManagerId,
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          'sort': sort,
          'order': order,
        },
      );

      final response = await http.get(uri, headers: headers);
      print('Response body: ${response.body}');  

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': {
            'projects': (data['data']['projects'] as List)
                .map((json) => Project.fromJson(json))
                .toList(),
            'pagination': data['data']['pagination'] ?? {
              'total': data['data']['projects'].length,
              'page': page,
              'pages': 1,
              'limit': limit,
            },
          },
          'message': 'Projects loaded successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'fetch projects', response.body),
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

  Future<Map<String, dynamic>> _getProjectByIdWithToken(String id) async {
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
        Uri.parse('${Global.baseUrl2}/projects/$id'),
        headers: headers,
      );

      print('Response body: ${response.body}'); 

      if (_isSuccessStatusCode(response.statusCode)) {
        final json = jsonDecode(response.body);
        final project = Project.fromJson(json['data']);

        return {
          'success': true,
          'data': project,
          'message': 'Project fetched successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'fetch project', response.body),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _createProjectWithToken(Map<String, dynamic> project) async {
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
        Uri.parse('${Global.baseUrl2}/projects'),
        headers: headers,
        body: jsonEncode(project),
      );
      print('Response body: ${response.body}'); 
      if (_isSuccessStatusCode(response.statusCode)) {
        final json = jsonDecode(response.body);
        
        return {
          'success': true,
          'data': json['data'],
          'message': 'Project created successfully',
          'statusCode': response.statusCode,
        };
      } else {
        String errorMessage = 'Failed to create project';
        if (response.statusCode == 400) {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } else if (response.statusCode == 403) {
          errorMessage = 'Only admins can create projects';
        }
        
        return {
          'success': false,
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _updateProjectWithToken(String id, Map<String, dynamic> project) async {
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
        Uri.parse('${Global.baseUrl2}/projects/$id'),
        headers: headers,
        body: jsonEncode(project),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return {
          'success': true,
          'data': json['data'],
          'message': json['message'] ?? 'Project updated successfully',
          'statusCode': response.statusCode,
        };
      } else {
        final errorJson = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorJson['message'] ?? 'Failed to update project',
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server: $e',
      };
    }
  }
  
  Future<Map<String, dynamic>> _deleteProjectWithToken(String id) async {
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
        Uri.parse('${Global.baseUrl2}/projects/$id'),
        headers: headers,
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        return {
          'success': true,
          'message': 'Project deleted successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'delete project', response.body),
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server: $e',
      };
    }
  }

  bool _isSuccessStatusCode(int statusCode) {
    return statusCode >= 200 && statusCode < 300;
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