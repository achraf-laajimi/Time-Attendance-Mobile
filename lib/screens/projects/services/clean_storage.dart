import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

Future<void> checkAndCleanLocalStorage() async {
  developer.log('Starting checkAndCleanLocalStorage');
  try {
    final prefs = await SharedPreferences.getInstance();
    final keys = ['tasks', 'products', 'projects'];
    developer.log('SharedPreferences keys available: ${prefs.getKeys()}');

    for (var key in keys) {
      final json = prefs.getString(key) ?? '[]';
      developer.log('Checking $key in SharedPreferences: $json');

      List<Map<String, dynamic>> items;
      try {
        items = List<Map<String, dynamic>>.from(jsonDecode(json));
      } catch (e) {
        developer.log('Error decoding JSON for $key: $e, JSON: $json');
        await prefs.remove(key);
        developer.log('Cleared $key due to JSON decode error');
        continue;
      }

      bool hasInvalidIds = false;

      for (var item in items) {
        // Check _id
        final id = item['_id']?.toString() ?? '';
        if (id.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id)) {
          developer.log('Found invalid ID in $key: $id');
          hasInvalidIds = true;
        }

        // Check reference fields
        if (key == 'products') {
          final projects = item['projects'] as List<dynamic>? ?? [];
          for (var allocation in projects) {
            final projectId = allocation['project']?.toString() ?? '';
            if (projectId.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(projectId)) {
              developer.log('Found invalid project ID in $key allocation: $projectId');
              hasInvalidIds = true;
            }
          }
        } else if (key == 'tasks') {
          final projectId = item['project']?.toString() ?? '';
          if (projectId.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(projectId)) {
            developer.log('Found invalid project ID in $key: $projectId');
            hasInvalidIds = true;
          }
          final assignedTo = item['assignedTo']?.toString() ?? '';
          if (assignedTo.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(assignedTo)) {
            developer.log('Found invalid assignedTo ID in $key: $assignedTo');
            hasInvalidIds = true;
          }
        } else if (key == 'projects') {
          final clientId = item['client']?['_id']?.toString() ?? item['client']?.toString() ?? '';
          if (clientId.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(clientId)) {
            developer.log('Found invalid client ID in $key: $clientId');
            hasInvalidIds = true;
          }
          final projectManagerId = item['projectManager']?['_id']?.toString() ?? item['projectManager']?.toString() ?? '';
          if (projectManagerId.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(projectManagerId)) {
            developer.log('Found invalid projectManager ID in $key: $projectManagerId');
            hasInvalidIds = true;
          }
          final stockManagerId = item['stockManager']?['_id']?.toString() ?? item['stockManager']?.toString() ?? '';
          if (stockManagerId.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(stockManagerId)) {
            developer.log('Found invalid stockManager ID in $key: $stockManagerId');
            hasInvalidIds = true;
          }
          final projectProducts = item['products'] as List<dynamic>? ?? [];
          for (var product in projectProducts) {
            final productId = product['product']?['_id']?.toString() ?? product['product']?.toString() ?? '';
            if (productId.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(productId)) {
              developer.log('Found invalid product ID in $key: $productId');
              hasInvalidIds = true;
            }
          }
          final projectTasks = item['tasks'] as List<dynamic>? ?? [];
          for (var task in projectTasks) {
            final taskId = task['_id']?.toString() ?? task?.toString() ?? '';
            if (taskId.isNotEmpty && !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(taskId)) {
              developer.log('Found invalid task ID in $key: $taskId');
              hasInvalidIds = true;
            }
          }
        }
      }

      if (hasInvalidIds) {
        await prefs.remove(key);
        developer.log('Cleared $key in SharedPreferences due to invalid IDs');
      } else {
        developer.log('No invalid IDs found in $key');
      }
    }
    developer.log('Finished checkAndCleanLocalStorage');
  } catch (e) {
    developer.log('Unexpected error in checkAndCleanLocalStorage: $e');
  }
}