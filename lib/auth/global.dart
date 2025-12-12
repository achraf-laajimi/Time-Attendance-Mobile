// lib/auth/global.dart - Secure version
import '../screens/projects/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Global {
  // Backend URL
  static const String baseUrl = "http://148.113.42.38:8081";
  static const String baseUrl2 = "http://10.0.2.2:5000/api";

  // Storage keys
  static const String TOKEN_KEY = "auth_token";
  static const String EXPRESS_TOKEN_KEY = "express_auth_token";
  static const String EXPRESS_REFRESH_TOKEN_KEY = "express_refresh_token";
  static const String REMEMBER_ME_KEY = "remember_me";

  // In-memory token cache
  static String? _authToken;
  static String? _expressToken;
  static String? _expressRefreshToken;

  // Secure storage instance
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  // Get auth token with enhanced security
  static Future<String?> getAuthToken() async {
    // Check memory cache first for performance
    if (_authToken != null) {
      return _authToken;
    }

    // Check if remember me is enabled
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(REMEMBER_ME_KEY) ?? false;

    if (rememberMe) {
      try {
        // Get token from secure storage
        _authToken = await _secureStorage.read(key: TOKEN_KEY);
      } catch (e) {
        print("Error reading token from secure storage: $e");
      }
    }

    return _authToken;
  }

  // Get Express auth token
  static Future<String?> getExpressToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _expressToken != null) return _expressToken;
    
    _expressToken = await _secureStorage.read(key: EXPRESS_TOKEN_KEY);
    return _expressToken;
  }

  static Future<void> clearExpressTokens() async {
    _expressToken = null;
    _expressRefreshToken = null;
    await _secureStorage.delete(key: EXPRESS_TOKEN_KEY);
    await _secureStorage.delete(key: EXPRESS_REFRESH_TOKEN_KEY);
  }

  static Future<String?> getRefreshToken() async {
    if (_expressRefreshToken != null) return _expressRefreshToken;
    _expressRefreshToken = await _secureStorage.read(key: EXPRESS_REFRESH_TOKEN_KEY);
    return _expressRefreshToken;
  }

  static Future<void> setExpressTokens({
    required String accessToken,
    required String refreshToken,
    bool rememberMe = false,
  }) async {
    _expressToken = accessToken;
    _expressRefreshToken = refreshToken;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(REMEMBER_ME_KEY, rememberMe);

    if (rememberMe) {
      await _secureStorage.write(key: EXPRESS_TOKEN_KEY, value: accessToken);
      await _secureStorage.write(key: EXPRESS_REFRESH_TOKEN_KEY, value: refreshToken);
    }
  }

  // Set auth token with enhanced security
  static Future<void> setAuthToken(String? token, {bool rememberMe = false}) async {
    _authToken = token;  // Always set in memory
    final prefs = await SharedPreferences.getInstance();

    // Save remember me setting in regular SharedPreferences (not sensitive)
    await prefs.setBool(REMEMBER_ME_KEY, rememberMe);

    if (token != null && token.isNotEmpty) {
      if (rememberMe) {
        try {
          // Store token in secure storage
          await _secureStorage.write(key: TOKEN_KEY, value: token);
        } catch (e) {
          print("Error saving token to secure storage: $e");
        }
      } else {
        // Clear from storage but keep in memory
        try {
          await _secureStorage.delete(key: TOKEN_KEY);
        } catch (e) {
          print("Error removing token from secure storage: $e");
        }
      }
    } else {
      // Clear token if null
      try {
        await _secureStorage.delete(key: TOKEN_KEY);
      } catch (e) {
        print("Error clearing token from secure storage: $e");
      }
    }
  }

  // Check if token exists and is valid
  static Future<bool> isTokenValid() async {
    final token = await getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // Clear auth token
  static Future<void> clearAuthToken() async {
    _authToken = null;
    try {
      await _secureStorage.delete(key: TOKEN_KEY);
    } catch (e) {
      print("Error clearing token from secure storage: $e");
    }
  }

  // Get request headers with token
  static Future<Map<String, String>> getHeaders() async {
    Map<String, String> headers = {
      "Content-Type": "application/json"
    };

    final token = await getAuthToken();
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  /// Get headers for Express backend
  static Future<Map<String, String>> getProjectHeaders() async {
    final headers = {
      "Content-Type": "application/json",
      "X-API-Source": "backend2",
    };

    // This will automatically handle token refresh if needed
    final token = await getExpressToken();
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  // Headers for OTP verification
  static Map<String, String> otpVerificationHeaders(
      String identifier,
      String requestId,
      String otpCode
      ) {
    return {
      "Content-Type": "application/json",
      "X-Public-Identifier": identifier,
      "X-Request-ID": requestId,
      "X-Policy-Data": otpCode,
    };
  }

  // Current request ID for OTP verification
  static String? currentRequestId;
} 