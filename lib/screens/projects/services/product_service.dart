import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime_type/mime_type.dart';
import 'package:in_out/auth/global.dart';
import 'package:in_out/screens/projects/services/auth_service.dart';
import 'package:in_out/screens/projects/models/product_model.dart';

class ProductService {
  static final ProductService _instance = ProductService._internal();
  factory ProductService() => _instance;
  ProductService._internal();

  Future<Map<String, dynamic>> getProducts({
    int page = 1,
    int limit = 10,
    String search = "",
    String sort = "createdAt",
    String order = "desc",
  }) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _fetchProductsWithToken(
      page: page,
      limit: limit,
      search: search,
      sort: sort,
      order: order,
    );

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _fetchProductsWithToken(
        page: page,
        limit: limit,
        search: search,
        sort: sort,
        order: order,
      );
    }

    return result;
  }

  Future<Map<String, dynamic>> getProductById(String id) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _getProductByIdWithToken(id);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _getProductByIdWithToken(id);
    }

    return result;
  }

  Future<Map<String, dynamic>> createProduct(Product product, {String? imagePath}) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _createProductWithToken(product, imagePath: imagePath);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _createProductWithToken(product, imagePath: imagePath);
    }

    return result;
  }

  Future<Map<String, dynamic>> updateProduct(String id, Product product, {String? imagePath}) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _updateProductWithToken(id, product, imagePath: imagePath);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _updateProductWithToken(id, product, imagePath: imagePath);
    }

    return result;
  }

  Future<Map<String, dynamic>> deleteProduct(String id) async {
    final authResult = await _ensureAuthenticated();
    if (!authResult['authenticated']) {
      return authResult['response']!;
    }

    var result = await _deleteProductWithToken(id);

    if (result['statusCode'] == 401) {
      await Global.clearExpressTokens();
      final retryAuth = await _ensureAuthenticated();
      if (!retryAuth['authenticated']) {
        return retryAuth['response']!;
      }
      result = await _deleteProductWithToken(id);
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

  Future<Map<String, dynamic>> _fetchProductsWithToken({
  required int page,
  required int limit,
  required String search,
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

    final uri = Uri.parse('${Global.baseUrl2}/products').replace(
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
        if (search.isNotEmpty) 'search': search,
        'sort': sort,
        'order': order,
      },
    );

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final productsList = data['data']['products'] as List;
      final products = productsList.map((item) {
        try {
          if (item is Map<String, dynamic>) {
            return Product.fromJson(item); // Parse only if it's a map
          } else if (item is Product) {
            return item; // Use existing Product object
          } else {
            return null; // Skip invalid types
          }
        } catch (e) {
          return null; // Skip on error
        }
      }).whereType<Product>().toList();
      return {
        'success': true,
        'data': {
          'products': products,
          'pagination': data['data']['pagination'] ?? {
            'total': data['data']['products'].length,
            'page': page,
            'pages': 1,
            'limit': limit,
          },
        },
        'message': 'Products loaded successfully',
        'statusCode': response.statusCode,
      };
    } else {
      return {
        'success': false,
        'message': _getErrorMessage(response.statusCode, 'fetch products', response.body),
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

  Future<Map<String, dynamic>> _getProductByIdWithToken(String id) async {
    try {
      // Validate ID first
      if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id)) {
        return {
          'success': false,
          'message': 'Invalid product ID format',
          'statusCode': 400,
        };
      }

      final headers = await Global.getProjectHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'shouldLogout': true,
        };
      }

      final response = await http.get(
        Uri.parse('${Global.baseUrl2}/products/$id'),
        headers: headers,
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        final json = jsonDecode(response.body);
        final product = Product.fromJson(json['data']);
        return {
          'success': true,
          'data': product,
          'message': 'Product fetched successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'fetch product', response.body),
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

  Future<Map<String, dynamic>> _createProductWithToken(Product product, {String? imagePath}) async {
    try {
      final headers = await Global.getProjectHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'shouldLogout': true,
        };
      }

      if (imagePath != null) {
        // Create multipart request for image upload
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${Global.baseUrl2}/products'),
        );

        // Add headers
        request.headers.addAll(headers);

        // Add product data
        request.fields['name'] = product.name;
        request.fields['reference'] = product.reference;
        if (product.description != null) {
          request.fields['description'] = product.description!;
        }
        request.fields['category'] = product.category;
        request.fields['quantity'] = product.quantity.toString();
        request.fields['price'] = product.price.toString();

        // Add image file
        var mimeType = mime(imagePath) ?? 'image/jpeg';
        var file = await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(file);

        // Send request
        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        if (response.statusCode == 201) {
          final data = jsonDecode(responseData);
          final createdProduct = Product.fromJson(data['data']);
          
          return {
            'success': true,
            'data': createdProduct,
            'message': 'Product created successfully',
            'statusCode': response.statusCode,
          };
        } else {
          return {
            'success': false,
            'message': _getErrorMessage(response.statusCode, 'create product', responseData),
            'statusCode': response.statusCode,
          };
        }
      } else {
        // No image upload, regular JSON request
        final response = await http.post(
          Uri.parse('${Global.baseUrl2}/products'),
          headers: headers,
          body: jsonEncode(product.toJson()),
        );

        if (response.statusCode == 201) {
          final data = jsonDecode(response.body);
          final createdProduct = Product.fromJson(data['data']);
          
          return {
            'success': true,
            'data': createdProduct,
            'message': 'Product created successfully',
            'statusCode': response.statusCode,
          };
        } else {
          String errorMessage = 'Failed to create product';
          if (response.statusCode == 400) {
            final errorData = jsonDecode(response.body);
            errorMessage = errorData['message'] ?? errorMessage;
          } else if (response.statusCode == 403) {
            errorMessage = 'Only admins can create products';
          }
          
          return {
            'success': false,
            'message': errorMessage,
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _updateProductWithToken(String id, Product product, {String? imagePath}) async {
    try {
      final headers = await Global.getProjectHeaders();
      if (!headers.containsKey('Authorization')) {
        return {
          'success': false,
          'message': 'Not authenticated',
          'shouldLogout': true,
        };
      }

      if (imagePath != null) {
        // Create multipart request for image upload
        var request = http.MultipartRequest(
          'PUT',
          Uri.parse('${Global.baseUrl2}/products/$id'),
        );

        // Add headers
        request.headers.addAll(headers);

        // Add product data
        request.fields['name'] = product.name;
        request.fields['reference'] = product.reference;
        if (product.description != null) {
          request.fields['description'] = product.description!;
        }
        request.fields['category'] = product.category;
        request.fields['quantity'] = product.quantity.toString();
        request.fields['price'] = product.price.toString();

        // Add image file
        var mimeType = mime(imagePath) ?? 'image/jpeg';
        var file = await http.MultipartFile.fromPath(
          'image',
          imagePath,
          contentType: MediaType.parse(mimeType),
        );
        request.files.add(file);

        // Send request
        var response = await request.send();
        var responseData = await response.stream.bytesToString();

        if (response.statusCode == 200) {
          final data = jsonDecode(responseData);
          final updatedProduct = Product.fromJson(data['data']);
          
          return {
            'success': true,
            'data': updatedProduct,
            'message': 'Product updated successfully',
            'statusCode': response.statusCode,
          };
        } else {
          return {
            'success': false,
            'message': _getErrorMessage(response.statusCode, 'update product', responseData),
            'statusCode': response.statusCode,
          };
        }
      } else {
        // No image upload, regular JSON request
        final response = await http.put(
          Uri.parse('${Global.baseUrl2}/products/$id'),
          headers: headers,
          body: jsonEncode(product.toJson()),
        );

        if (_isSuccessStatusCode(response.statusCode)) {
          final json = jsonDecode(response.body);
          final updatedProduct = Product.fromJson(json['data']);
          
          return {
            'success': true,
            'data': updatedProduct,
            'message': 'Product updated successfully',
            'statusCode': response.statusCode,
          };
        } else {
          return {
            'success': false,
            'message': _getErrorMessage(response.statusCode, 'update product', response.body),
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error connecting to server: $e',
      };
    }
  }

  Future<Map<String, dynamic>> _deleteProductWithToken(String id) async {
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
        Uri.parse('${Global.baseUrl2}/products/$id'),
        headers: headers,
      );

      if (_isSuccessStatusCode(response.statusCode)) {
        return {
          'success': true,
          'message': 'Product deleted successfully',
          'statusCode': response.statusCode,
        };
      } else {
        return {
          'success': false,
          'message': _getErrorMessage(response.statusCode, 'delete product', response.body),
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