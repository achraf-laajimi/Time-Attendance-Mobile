import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:in_out/screens/dashboard.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../provider/user_settings_provider.dart';
import 'global.dart';

class AuthService {
  // Token storage key
  static const String TOKEN_KEY = "auth_token";
  static const String USER_ID_KEY = "user_id";
  static const String REMEMBER_ME_KEY = "remember_me";
  static const String FIRST_NAME_KEY = "first_name";
  static const String LAST_NAME_KEY = "last_name";
  static const String USER_ROLE_KEY = "user_role";

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static Future<Map<String, dynamic>> requestOTP(
      String identifier, String password,
      {bool rememberMe = false}) async {
    final Uri url = Uri.parse("${Global.baseUrl}/public/authentication/login");

    try {
      print("REQUEST OTP: Called with Remember Me = $rememberMe");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(REMEMBER_ME_KEY, rememberMe);
      print("REQUEST OTP: Remember Me preference saved: $rememberMe");

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Public-Identifier": identifier
        },
        body: jsonEncode({"password": password}),
      );
      if (response.statusCode == 412) {
        try {
          final responseData = jsonDecode(response.body);
          final xRequestId = response.headers['x-request-id'];

          if (xRequestId != null && responseData.containsKey('length')) {
            return {
              "success": true,
              "otpRequired": true,
              "otpLength": responseData["length"],
              "requestId": xRequestId,
              "identifier": identifier,
              "password": password,
              "rememberMe": rememberMe
            };
          } else {
            return {"success": false, "message": "Invalid OTP response format"};
          }
        } catch (e) {
          return {
            "success": false,
            "message": "Failed to parse OTP response: $e"
          };
        }
      } else if (response.statusCode == 200) {
        print(
            "REQUEST OTP: Direct login success, passing Remember Me = $rememberMe");
        return handleSuccessfulLogin(response, identifier, null,
            rememberMe: rememberMe);
      } else {
        String errorMessage = "Authentication failed";
        try {
          if (response.body.isNotEmpty) {
            final responseData = jsonDecode(response.body);
            errorMessage = responseData["message"] ?? errorMessage;

            if (responseData.containsKey("error") &&
                responseData["error"] == "invalid_credentials") {
              errorMessage = "Invalid username or password";
            }
          }
        } catch (e) {
          errorMessage = "Failed to parse error message";
        }

        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(
      String identifier,
      String requestId,
      String otpCode,
      String password,
      BuildContext context, {
        bool rememberMe = false,
      }
      ) async {
    final userSettingsProvider =
    Provider.of<UserSettingsProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final Uri url =
    Uri.parse("${Global.baseUrl}/public/authentication/login");

    try {
      print("OTP: Verifying OTP for $identifier…");
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Public-Identifier": identifier,
          "X-Request-ID": requestId,
          "X-Policy-Data": otpCode,
        },
        body: jsonEncode({"password": password}),
      );

      print("OTP: status ${response.statusCode}");
      final prefs = await SharedPreferences.getInstance();

      if (response.statusCode == 200) {
        // ←─ 1) Save the remember-me flag early
        await prefs.setBool(REMEMBER_ME_KEY, rememberMe);

        // ←─ 2) Use the full login handler so we pick up header/body token
        final result = await handleSuccessfulLogin(
          response,
          identifier,
          context,
          rememberMe: rememberMe,
        );

        // ←─ 3) **Immediately** guard against missing token**
        final String? token = result["token"] as String?;
        if (result["success"] != true || token == null) {
          // **If there’s no token**, bail out with a clear message
          return {
            "success": false,
            "message": "OTP verified, but no token was returned by the server."
          };
        }

        // At this point we have a real token:
        messenger.showSnackBar(
          const SnackBar(content: Text("Welcome back!")),
        );

        // Update your user provider
        await userSettingsProvider.setCurrentUser(identifier);

        // Save the token in your global helper (and prefs if needed)
        await Global.setAuthToken(token, rememberMe: rememberMe);
        if (rememberMe) {
          final stored = prefs.getString(Global.TOKEN_KEY);
          if (stored == null) {
            await prefs.setString(Global.TOKEN_KEY, token);
          }
        }

        // Finally: navigate to your dashboard screen
        await navigator.pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );

        return result;
      } else {
        final body = response.body.isNotEmpty
            ? jsonDecode(response.body) as Map<String, dynamic>
            : {};
        final message = body["message"] ?? "OTP verification failed";
        return {"success": false, "message": message, "errorCode": body["error"]};
      }
    } catch (e) {
      print("OTP: Exception: $e");
      return {"success": false, "message": "Cannot connect: $e"};
    }
  }


  static Future<Map<String, dynamic>> _handleSuccessfulLoginNoContext(
    http.Response response,
    String identifier, {
    required bool rememberMe,
    required SharedPreferences prefs,
  }) async {
    final data = jsonDecode(response.body);
    final token = data["token"] as String?;
    if (rememberMe && token != null) {
      await prefs.setString(Global.TOKEN_KEY, token);
    }
    return {"success": true, "token": token};
  }

  static Future<Map<String, dynamic>> handleSuccessfulLogin(
      http.Response response, String identifier, BuildContext? context,
      {bool rememberMe = false}) async {
    try {
      print("LOGIN: Processing successful login response");
      print("LOGIN: Response status: ${response.statusCode}");
      print("LOGIN: REMEMBER ME PARAMETER VALUE: $rememberMe");
      String? token;
      final authHeader = response.headers['authorization'];
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        token = authHeader.substring(7);
        print("LOGIN: Token found in authorization header");
      }
      try {
        if (response.body.isNotEmpty) {
          final responseData = jsonDecode(response.body);
          print("LOGIN: Response body decoded");
          if (token == null && responseData["token"] != null) {
            token = responseData["token"];
            print("LOGIN: Token found in response body");
          }
          final userId = responseData["id"]?.toString() ?? identifier;
          final prefs = await SharedPreferences.getInstance();

          print("LOGIN: Setting Remember Me to: $rememberMe");
          await prefs.setBool(REMEMBER_ME_KEY, rememberMe);

          // Save user info
          await prefs.setString(
              FIRST_NAME_KEY, responseData["firstName"] ?? "");
          await prefs.setString(LAST_NAME_KEY, responseData["lastName"] ?? "");
          await prefs.setString(USER_ROLE_KEY, responseData["role"] ?? "");
          await prefs.setString(USER_ID_KEY, userId);

          print("LOGIN: User details saved with Remember Me: $rememberMe");

          if (token != null) {
            print("LOGIN: About to save token with Remember Me: $rememberMe");
            await Global.setAuthToken(token, rememberMe: rememberMe);

            if (rememberMe) {
              final storedToken = prefs.getString(Global.TOKEN_KEY);
              print(
                  "LOGIN: Verification - Token in SharedPreferences: ${storedToken != null ? 'YES' : 'NO'}");

              if (storedToken == null) {
                print("LOGIN: Token not saved properly, saving directly");
                await prefs.setString(Global.TOKEN_KEY, token);
              }
            }

            if (context != null) {
              try {
                final userSettingsProvider =
                    Provider.of<UserSettingsProvider>(context, listen: false);
                await userSettingsProvider.setCurrentUser(userId);
                print("LOGIN: User settings updated");
              } catch (e) {
                print("LOGIN: Error updating user settings: $e");
              }
            }

            return {
              "success": true,
              "token": token,
              "userId": userId,
              "firstName": responseData["firstName"],
              "lastName": responseData["lastName"],
              "role": responseData["role"],
              "sessionSaved": rememberMe
            };
          }
        }
      } catch (e) {
        print("LOGIN: Error processing response body: $e");
      }

      if (token == null) {
        print("LOGIN: ERROR - No token found in response");
        print("LOGIN: Headers: ${response.headers}");
        return {"success": false, "message": "No token received in response"};
      }

      return {"success": false, "message": "Invalid login response"};
    } catch (e) {
      print("LOGIN: Exception during login processing: $e");
      return {
        "success": false,
        "message": "Error processing login response: $e"
      };
    }
  }

  static Future<bool> shouldAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool(REMEMBER_ME_KEY) ?? false;

      if (!rememberMe) return false;

      return await Global.isTokenValid();
    } catch (e) {
      print("Error checking auto login: $e");
      return false;
    }
  }

  static Future<Map<String, dynamic>> autoLogin(BuildContext context) async {
    try {
      final userSettingsProvider =
          Provider.of<UserSettingsProvider>(context, listen: false);

      if (await shouldAutoLogin()) {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString(USER_ID_KEY);

        if (userId != null) {
          await userSettingsProvider.setCurrentUser(userId);

          return {
            "success": true,
            "message": "Session restored",
            "userId": userId
          };
        }
      }
    } catch (e) {
      print("Session restore error: $e");
    }

    return {"success": false, "message": "Session expired or invalid"};
  }

  static Future<Map<String, dynamic>> login(
      String identifier, String password, BuildContext context,
      {bool rememberMe = false}) async {
    return requestOTP(identifier, password);
  }

  static Future<Map<String, String>> getUserDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString(FIRST_NAME_KEY) ?? '',
      'lastName': prefs.getString(LAST_NAME_KEY) ?? '',
      'role': prefs.getString(USER_ROLE_KEY) ?? '',
    };
  }

  static Future<bool> isLoggedIn() async {
    final token = await Global.getAuthToken();
    return token != null;
  }

  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(USER_ID_KEY);
  }

  static Future<void> logout(BuildContext context) async {
    try {
      final userSettingsProvider =
          Provider.of<UserSettingsProvider>(context, listen: false);

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(FIRST_NAME_KEY);
      await prefs.remove(LAST_NAME_KEY);
      await prefs.remove(USER_ROLE_KEY);
      await prefs.remove(USER_ID_KEY);
      await _secureStorage.delete(key: TOKEN_KEY);
      await _secureStorage.delete(key: 'login_username');
      await _secureStorage.delete(key: 'login_password');
      await Global.clearAuthToken();

      userSettingsProvider.clearCurrentUser();
    } catch (e) {
      print("Error during logout: $e");
    }
  }

// // token storage
  // static Future<void> _saveToken(String token) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString(TOKEN_KEY, token);
  // }
  //
  // static Future<String?> _getToken() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getString(TOKEN_KEY);
  // }

  // //Save user ID

  /*static Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(USER_ID_KEY, userId);
  }*/
}
