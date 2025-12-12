import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:in_out/auth/global.dart';
import 'package:in_out/screens/projects/services/auth_service.dart';
import 'package:in_out/screens/projects/models/task_model.dart';
import 'package:mime_type/mime_type.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  Future<Map<String, dynamic>> getProjectTasks(String projectId) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _fetchTasksWithToken(projectId);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _fetchTasksWithToken(projectId);
    }

    return result;
  }

  Future<Map<String, dynamic>> createTask({
    required String name,
    required String description,
    required DateTime beginDate,
    required DateTime endDate,
    required String projectId,
    required String assignedTo,
    TaskPriority priority = TaskPriority.Medium,
    TaskStatus status = TaskStatus.ToDo,
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    final result = await _createTaskWithToken(
      name: name,
      description: description,
      beginDate: beginDate,
      endDate: endDate,
      projectId: projectId,
      assignedTo: assignedTo,
      priority: priority,
      status: status,
    );

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      return await _createTaskWithToken(
        name: name,
        description: description,
        beginDate: beginDate,
        endDate: endDate,
        projectId: projectId,
        assignedTo: assignedTo,
        priority: priority,
        status: status,
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> updateTask({
    required String taskId,
    String? name,
    String? description,
    DateTime? beginDate,
    DateTime? endDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo,
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _updateTaskWithToken(
      taskId: taskId,
      name: name,
      description: description,
      beginDate: beginDate,
      endDate: endDate,
      priority: priority,
      status: status,
      assignedTo: assignedTo,
    );

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _updateTaskWithToken(
        taskId: taskId,
        name: name,
        description: description,
        beginDate: beginDate,
        endDate: endDate,
        priority: priority,
        status: status,
        assignedTo: assignedTo,
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required TaskStatus status,
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _updateTaskStatusWithToken(
      taskId: taskId,
      status: status,
    );

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _updateTaskStatusWithToken(
        taskId: taskId,
        status: status,
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> deleteTask(String taskId) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _deleteTaskWithToken(taskId);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _deleteTaskWithToken(taskId);
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

  Future<Map<String, dynamic>> _fetchTasksWithToken(String projectId) async {
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
        Uri.parse('${Global.baseUrl2}/projects/$projectId/tasks'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Convert grouped tasks to Task objects
        final Map<String, List<Task>> groupedTasks = {};
        final groupedData = data['data']['tasks'] as Map<String, dynamic>;
        
        groupedData.forEach((status, tasks) {
          groupedTasks[status] = (tasks as List)
              .map((json) => Task.fromJson(json))
              .toList();
        });

        return {
          'success': true,
          'data': {
            'tasks': groupedTasks,
            'totalCount': data['data']['totalCount'],
          },
          'message': 'Tasks fetched successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'fetch tasks', response.body),
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

  Future<Map<String, dynamic>> _createTaskWithToken({
    required String name,
    required String description,
    required DateTime beginDate,
    required DateTime endDate,
    required String projectId,
    required String assignedTo,
    TaskPriority priority = TaskPriority.Medium,
    TaskStatus status = TaskStatus.ToDo,
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
        Uri.parse('${Global.baseUrl2}/tasks'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'beginDate': beginDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'priority': _priorityToString(priority),
          'status': _statusToString(status),
          'assignedTo': assignedTo,
          'projectId': projectId,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': Task.fromJson(data['data']),
          'message': 'Task created successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'create task', response.body),
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

  Future<Map<String, dynamic>> _updateTaskWithToken({
    required String taskId,
    String? name,
    String? description,
    DateTime? beginDate,
    DateTime? endDate,
    TaskPriority? priority,
    TaskStatus? status,
    String? assignedTo,
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

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;
      if (beginDate != null) body['beginDate'] = beginDate.toIso8601String();
      if (endDate != null) body['endDate'] = endDate.toIso8601String();
      if (priority != null) body['priority'] = _priorityToString(priority);
      if (status != null) body['status'] = _statusToString(status);
      if (assignedTo != null) body['assignedTo'] = assignedTo;

      final response = await http.put(
        Uri.parse('${Global.baseUrl2}/tasks/$taskId'),
        headers: headers,
        body: jsonEncode(body),
      );
      print('Update Task Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': Task.fromJson(data['data']),
          'message': 'Task updated successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'update task', response.body),
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

  Future<Map<String, dynamic>> _updateTaskStatusWithToken({
    required String taskId,
    required TaskStatus status,
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

      final response = await http.patch(
        Uri.parse('${Global.baseUrl2}/tasks/$taskId/position'),
        headers: headers,
        body: jsonEncode({
          'status': _statusToString(status),
        }),
      );
      print('Update Task Response: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': Task.fromJson(data['data']),
          'message': 'Task status updated successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'update task status', response.body),
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

  Future<Map<String, dynamic>> _deleteTaskWithToken(String taskId) async {
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
        Uri.parse('${Global.baseUrl2}/tasks/$taskId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Task deleted successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'delete task', response.body),
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

  Future<Map<String, dynamic>> addTaskAttachments({
    required String taskId,
    required List<String> filePaths,
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _addAttachmentsWithToken(taskId: taskId, filePaths: filePaths);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _addAttachmentsWithToken(taskId: taskId, filePaths: filePaths);
    }

    return result;
  }

  Future<Map<String, dynamic>> removeTaskAttachments({
    required String taskId,
    required List<String> attachmentIds,
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _removeAttachmentsWithToken(
      taskId: taskId,
      attachmentIds: attachmentIds,
    );

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _removeAttachmentsWithToken(
        taskId: taskId,
        attachmentIds: attachmentIds,
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> addWorkEvidence({
    required String taskId,
    required List<String> imagePaths,
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _addWorkEvidenceWithToken(
      taskId: taskId,
      imagePaths: imagePaths,
    );

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _addWorkEvidenceWithToken(
        taskId: taskId,
        imagePaths: imagePaths,
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> removeWorkEvidence({
    required String taskId,
    required List<String> evidenceIds,
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _removeWorkEvidenceWithToken(
      taskId: taskId,
      evidenceIds: evidenceIds,
    );

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _removeWorkEvidenceWithToken(
        taskId: taskId,
        evidenceIds: evidenceIds,
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> addComment({
    required String taskId,
    required String content,
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _addCommentWithToken(
      taskId: taskId,
      content: content,
    );

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _addCommentWithToken(
        taskId: taskId,
        content: content,
      );
    }

    return result;
  }

  // Private helper methods for new endpoints
  Future<Map<String, dynamic>> _addAttachmentsWithToken({
    required String taskId,
    required List<String> filePaths,
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

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Global.baseUrl2}/tasks/$taskId/attachments'),
      );

      // Add headers
      request.headers.addAll(headers);

      // Add files
      for (var filePath in filePaths) {
        var mimeType = mime(filePath) ?? 'application/octet-stream';
        var file = await http.MultipartFile.fromPath(
          'files',
          filePath,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(file);
      }

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return {
          'success': true,
          'data': Task.fromJson(data['data']),
          'message': 'Attachments added successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'add attachments', responseData),
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

  Future<Map<String, dynamic>> _removeAttachmentsWithToken({
    required String taskId,
    required List<String> attachmentIds,
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

      final response = await http.delete(
        Uri.parse('${Global.baseUrl2}/tasks/$taskId/attachments'),
        headers: headers,
        body: jsonEncode({
          'attachmentIds': attachmentIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': Task.fromJson(data['data']),
          'message': 'Attachments removed successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'remove attachments', response.body),
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

  Future<Map<String, dynamic>> _addWorkEvidenceWithToken({
    required String taskId,
    required List<String> imagePaths,
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

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Global.baseUrl2}/tasks/$taskId/work-evidence'),
      );

      // Add headers
      request.headers.addAll(headers);

      // Add files
      for (var imagePath in imagePaths) {
        var mimeType = mime(imagePath) ?? 'image/jpeg';
        var file = await http.MultipartFile.fromPath(
          'files',
          imagePath,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(file);
      }

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseData);
        return {
          'success': true,
          'data': Task.fromJson(data['data']),
          'message': 'Work evidence added successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'add work evidence', responseData),
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

  Future<Map<String, dynamic>> _removeWorkEvidenceWithToken({
    required String taskId,
    required List<String> evidenceIds,
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

      final response = await http.delete(
        Uri.parse('${Global.baseUrl2}/tasks/$taskId/work-evidence'),
        headers: headers,
        body: jsonEncode({
          'evidenceIds': evidenceIds,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': Task.fromJson(data['data']),
          'message': 'Work evidence removed successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'remove work evidence', response.body),
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

  Future<Map<String, dynamic>> _addCommentWithToken({
    required String taskId,
    required String content,
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
        Uri.parse('${Global.baseUrl2}/tasks/$taskId/comments'),
        headers: headers,
        body: jsonEncode({
          'content': content,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': Task.fromJson(data['data']),
          'message': 'Comment added successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'add comment', response.body),
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

  String _priorityToString(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.Low:
        return 'Low';
      case TaskPriority.Medium:
        return 'Medium';
      case TaskPriority.High:
        return 'High';
      case TaskPriority.Urgent:
        return 'Urgent';
    }
  }

  String _statusToString(TaskStatus status) {
    switch (status) {
      case TaskStatus.ToDo:
        return 'To Do';
      case TaskStatus.InProgress:
        return 'In Progress';
      case TaskStatus.InReview:
        return 'In Review';
      case TaskStatus.Completed:
        return 'Completed';
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