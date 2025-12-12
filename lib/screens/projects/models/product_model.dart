import 'package:flutter/foundation.dart';
import 'package:objectid/objectid.dart';
import 'dart:developer' as developer;

class Product {
  final String id;
  final String name;
  final String reference;
  final String? description;
  final String category;
  final int quantity;
  final double price;
  final String? image;
  final List<ProductProjectAllocation> projects;

  Product({
    String? id,
    required this.name,
    required this.reference,
    this.description,
    required this.category,
    required this.quantity,
    required this.price,
    this.image,
    this.projects = const [],
  }) : id = _validateOrGenerateId(id);

  static String _validateOrGenerateId(String? id) {
    if (id == null || id.isEmpty) {
      return ObjectId().hexString;  
    }
    
    // Validate existing ID format
    if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id)) {
      throw ArgumentError('Invalid product ID format: $id');
    }
    
    return id;
  }


  Product copyWith({
    String? id,
    String? name,
    String? reference,
    String? description,
    String? category,
    int? quantity,
    double? price,
    String? image,
    List<ProductProjectAllocation>? projects,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      image: image ?? this.image,
      projects: projects ?? this.projects,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Map to backend's _id field
      'name': name,
      'reference': reference,
      'description': description,
      'category': category,
      'quantity': quantity,
      'price': price,
      'image': image,
      'projects': projects.map((e) => e.toJson()).toList(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String, // Expect _id from backend
      name: json['name'] as String,
      reference: json['reference'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      image: json['image'] as String?,
      projects: (json['projects'] as List<dynamic>?)
        ?.map((e) => ProductProjectAllocation.fromJson(e as Map<String, dynamic>))
        .toList() ??
        [],
    );
    
  }

  factory Product.fromDynamic(dynamic data) {
    if (data is Product) {
      return data;
    } else if (data is Map<String, dynamic>) {
      return Product.fromJson(data);
    } else {
      throw ArgumentError('Expected Product or Map<String, dynamic>, got ${data.runtimeType}');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Product &&
        other.id == id &&
        other.name == name &&
        other.reference == reference &&
        other.description == description &&
        other.category == category &&
        other.quantity == quantity &&
        other.price == price &&
        other.image == image &&
        listEquals(other.projects, projects);
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        reference.hashCode ^
        description.hashCode ^
        category.hashCode ^
        quantity.hashCode ^
        price.hashCode ^
        image.hashCode ^
        projects.hashCode;
  }
}

class ProductProjectAllocation {
  final String project; 
  final int allocatedQuantity;

  ProductProjectAllocation({
    required String project,
    required this.allocatedQuantity,
  }) : project = _validateProjectId(project);

  static String _validateProjectId(String project) {
  if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(project)) {
    developer.log('Invalid project ObjectID: $project', error: 'Invalid ObjectID format');
    throw ArgumentError('Invalid project ObjectID: $project. Expected a 24-character hexadecimal string.');
  }
  return project;
}

  Map<String, dynamic> toJson() {
    return {
      'project': project,
      'allocatedQuantity': allocatedQuantity,
    };
  }

  factory ProductProjectAllocation.fromJson(Map<String, dynamic> json) {
    return ProductProjectAllocation(
      project: json['project'] as String,
      allocatedQuantity: json['allocatedQuantity'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductProjectAllocation &&
        other.project == project &&
        other.allocatedQuantity == allocatedQuantity;
  }

  @override
  int get hashCode => project.hashCode ^ allocatedQuantity.hashCode;
}