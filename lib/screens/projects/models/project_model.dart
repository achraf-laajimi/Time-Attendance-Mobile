import 'package:flutter/foundation.dart';
import 'package:objectid/objectid.dart';
import 'dart:developer' as developer;
import 'task_model.dart';
import 'product_model.dart';
import 'package:in_out/screens/projects/models/ExpressUser.dart';

class Project {
  final String id;
  final String name;
  final String entreprise;
  final String? description;
  final DateTime beginDate;
  final DateTime endDate;
  final ProjectStatus status;
  final ExpressUser client;
  final ExpressUser projectManager;
  final ExpressUser? stockManager;
  final List<Task> tasks;
  final List<ProductAllocation> products;

  Project({
    String? id,
    required this.name,
    required this.entreprise,
    this.description,
    required this.beginDate,
    required this.endDate,
    required this.status,
    required this.client,
    required this.projectManager,
    this.stockManager,
    this.tasks = const [],
    this.products = const [],
  }) : id = _validateOrGenerateId(id);

  static String _validateOrGenerateId(String? id) {
  if (id == null || id.isEmpty) {
    final newId = ObjectId().hexString;
    developer.log('Generated new ObjectId for Project: $newId');
    return newId;
  }
  
  if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id)) {
    developer.log('Invalid project ObjectID: $id', 
                 error: 'Invalid ObjectID format');
    throw ArgumentError('Invalid project ObjectID: $id. '
                      'Expected a 24-character hexadecimal string.');
  }
  
  return id;
}

  factory Project.fromJson(Map<String, dynamic> json) {
    // Helper function to safely parse users with null checks
    ExpressUser _parseUser(dynamic userData) {
      if (userData == null) {
        return ExpressUser(
          id: 'unknown',
          name: 'Unknown User',
          email: '',
          role: 'unknown',
        );
      }
      if (userData is ExpressUser) return userData;
      if (userData is Map<String, dynamic>) {
        return ExpressUser.fromJson(userData);
      }
      return ExpressUser(
        id: userData.toString(),
        name: 'Unknown User',
        email: '',
        role: 'unknown',
      );
    }

    // Helper function to safely parse dates with null checks
    DateTime _parseDate(dynamic date) {
      try {
        return date == null 
            ? DateTime.now() 
            : DateTime.parse(date.toString());
      } catch (e) {
        return DateTime.now();
      }
    }

    // Safely parse tasks list
    List<Task> _parseTasks(dynamic tasksData) {
      if (tasksData is! List) return [];
      return tasksData.map((taskJson) {
        try {
          return Task.fromJson(taskJson);
        } catch (e) {
          return Task(
            id: 'error-task',
            name: 'Invalid Task',
            description: '',
            beginDate: DateTime.now(),
            endDate: DateTime.now(),
            assignedTo: '',
            project: json['_id']?.toString() ?? '',
          );
        }
      }).toList();
    }

    List<ProductAllocation> _parseProducts(dynamic productsData) {
      if (productsData is! List) return [];
      final validProducts = <ProductAllocation>[];
      for (var item in productsData) {
        try {
          final productAllocation = ProductAllocation.fromJson(item);
          if (productAllocation.product.id.isNotEmpty &&
              productAllocation.product.name.isNotEmpty &&
              RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(productAllocation.product.id) &&
              productAllocation.allocatedQuantity > 0) {
            validProducts.add(productAllocation);
          } else {
            developer.log('Skipped invalid product allocation: id=${productAllocation.product.id}, name=${productAllocation.product.name}, quantity=${productAllocation.allocatedQuantity}');
          }
        } catch (e) {
          developer.log('Failed to parse product allocation: $e');
        }
      }
      return validProducts;
    }
    return Project(
      id: json['_id']?.toString() ?? '001',
      name: json['name']?.toString() ?? 'Unnamed Project', // Default value
      entreprise: json['entreprise']?.toString() ?? 'No Company', // Default value
      description: json['description']?.toString(),
      beginDate: _parseDate(json['beginDate']),
      endDate: _parseDate(json['endDate']),
      status: ProjectStatus.fromString(json['status']?.toString() ?? 'To Do'), // Default status
      client: _parseUser(json['client']),
      projectManager: _parseUser(json['projectManager']),
      stockManager: json['stockManager'] != null 
          ? _parseUser(json['stockManager']) 
          : null,
      tasks: _parseTasks(json['tasks']),
      products: _parseProducts(json['products']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'entreprise': entreprise,
      if (description != null) 'description': description,
      'beginDate': beginDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'status': status.value,
      'client': client is ExpressUser ? client.toJson() : client,
      'projectManager': projectManager is ExpressUser ? projectManager.toJson() : projectManager,
      if (stockManager != null) 
        'stockManager': stockManager is ExpressUser ? stockManager!.toJson() : stockManager,
      'tasks': tasks.map((task) => task.toJson()).toList(),
      'products': products.map((product) => product.toJson()).toList(),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    String? entreprise,
    String? description,
    DateTime? beginDate,
    DateTime? endDate,
    ProjectStatus? status,
    ExpressUser? client,
    ExpressUser? projectManager,
    ExpressUser? stockManager,
    List<Task>? tasks,
    List<ProductAllocation>? products,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      entreprise: entreprise ?? this.entreprise,
      description: description ?? this.description,
      beginDate: beginDate ?? this.beginDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      client: client ?? this.client,
      projectManager: projectManager ?? this.projectManager,
      stockManager: stockManager ?? this.stockManager,
      tasks: tasks ?? this.tasks,
      products: products ?? this.products,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Project &&
        other.id == id &&
        other.name == name &&
        other.entreprise == entreprise &&
        other.description == description &&
        other.beginDate == beginDate &&
        other.endDate == endDate &&
        other.status == status &&
        other.client == client &&
        other.projectManager == projectManager &&
        other.stockManager == stockManager &&
        listEquals(other.tasks, tasks) &&
        listEquals(other.products, products);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        entreprise.hashCode ^
        description.hashCode ^
        beginDate.hashCode ^
        endDate.hashCode ^
        status.hashCode ^
        client.hashCode ^
        projectManager.hashCode ^
        stockManager.hashCode ^
        tasks.hashCode ^
        products.hashCode;
  }
}

enum ProjectStatus {
  toDo('To Do'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  final String value;
  const ProjectStatus(this.value);

  factory ProjectStatus.fromString(String? value) {
    if (value == null) return ProjectStatus.toDo;
    return ProjectStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => ProjectStatus.toDo,
    );
  }

  @override
  String toString() => value;
}

class ProductAllocation {
  final Product product;
  final int allocatedQuantity;

  ProductAllocation({
    required this.product,
    required this.allocatedQuantity,
  });

  factory ProductAllocation.fromJson(Map<String, dynamic> json) {
    final productData = json['product'];
    String productId;
    String productName;

    if (productData is String) {
      productId = productData;
      productName = ''; 
    } else if (productData is Map<String, dynamic>) {
      productId = productData['_id']?.toString() ?? '';
      productName = productData['name']?.toString() ?? '';
    } else {
      throw ArgumentError('Invalid product data: $productData');
    }

    if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(productId) || productName.isEmpty) {
      throw ArgumentError('Invalid product: id=$productId, name=$productName');
    }

    return ProductAllocation(
      product: Product(
        id: productId,
        name: productName,
        reference: productData is Map ? (productData['reference']?.toString() ?? '') : '',
        category: productData is Map ? (productData['category']?.toString() ?? '') : '',
        quantity: productData is Map ? (productData['quantity'] as num?)?.toInt() ?? 0 : 0,
        price: productData is Map ? (productData['price'] as num?)?.toDouble() ?? 0.0 : 0.0,
        description: productData is Map ? productData['description']?.toString() : null,
        image: productData is Map ? productData['image']?.toString() : null,
        projects: productData is Map && productData['projects'] is List
            ? (productData['projects'] as List)
                .map((e) => ProductProjectAllocation.fromJson(e as Map<String, dynamic>))
                .toList()
            : [],
      ),
      allocatedQuantity: (json['quantity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.id,
      'quantity': allocatedQuantity,
    };
  }
}