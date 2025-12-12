import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../auth/global.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Future<Map<String, dynamic>> loginToExpress(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Global.baseUrl2}/auth/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email.trim().toLowerCase(),
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await Global.setExpressTokens(
            accessToken: data['accessToken'],
            refreshToken: data['refreshToken'],
            rememberMe: true,
          );
          return {
            'success': true,
            'message': 'Logged in successfully',
            'user': data['user'],
          };
        }
      }
      return {
        'success': false,
        'message': 'Login failed: ${response.body}',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<bool> refreshExpressToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('${Global.baseUrl2}/auth/refresh-token'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"refreshToken": refreshToken}),
      );

      print('AuthService: Express refresh token status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await Global.setExpressTokens(
            accessToken: data['accessToken'],
            refreshToken: data['refreshToken'],
            rememberMe: true,
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      print('AuthService: Error refreshing Express token: $e');
      return false;
    }
  }

  Future<bool> _validateToken(String? token) async {
    if (token == null) return false;
    try {
      // Simple check - in production you should decode and verify expiry
      return token.split('.').length == 3;
    } catch (e) {
      return false;
    }
  }

  Future<bool> ensureExpressAuth() async {
    // 1. Check if we have a valid token in memory/storage
    var token = await Global.getExpressToken();
    if (await _validateToken(token)) return true;

    // 2. Try to refresh using existing refresh token
    final refreshToken = await Global.getRefreshToken();
    if (refreshToken != null) {
      try {
        final refreshed = await refreshExpressToken(refreshToken);
        if (refreshed) return true;
      } catch (e) {
        print('Refresh failed: $e');
      }
    }

    // 3. Clear all invalid tokens
    await Global.clearExpressTokens();

    // 4. Fallback to fresh login
    const adminEmail = "admin@sotupub.com";
    const adminPassword = "admin123";
    try {
      final loginResult = await loginToExpress(adminEmail, adminPassword);
      return loginResult['success'] == true;
    } catch (e) {
      print('Admin login failed: $e');
      return false;
    }
  }
}