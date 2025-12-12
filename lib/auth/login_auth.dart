import 'dart:convert';
import 'package:http/http.dart' as http;
import 'global.dart';

class LoginAuth {
  // First authentication call to get OTP length and request ID
  static Future<Map<String, dynamic>> initiateLogin(String email, String password) async {
    final Uri url = Uri.parse("${Global.baseUrl}/public/authentication/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Public-Identifier": email,
        },
        body: jsonEncode({"password": password}),
      );

      // If precondition failed, it means we need OTP verification
      if (response.statusCode == 412) {
        // Get the X-Request-ID from header
        final requestId = response.headers['x-request-id'];

        // Get OTP length from body
        final responseData = jsonDecode(response.body);
        final otpLength = responseData["length"] ?? 6;

        return {
          "success": true,
          "requiresOtp": true,
          "otpLength": otpLength,
          "requestId": requestId
        };
      } else if (response.statusCode == 200) {
        // In case direct login is allowed (no OTP)
        final responseData = jsonDecode(response.body);
        return {"success": true, "token": responseData["token"], "requiresOtp": false};
      } else {
        // Error handling
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {"message": "Unknown error"};

        return {"success": false, "message": responseData["message"] ?? responseData["error"] ?? "Error"};
      }
    } catch (e) {
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }

  // Second authentication call with OTP
  static Future<Map<String, dynamic>> verifyOtp(String email, String requestId, String otp) async {
    final Uri url = Uri.parse("${Global.baseUrl}/auth/login");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Public-Identifier": email,
          "X-Request-ID": requestId,
          "X-Policy-Data": otp,
        },
        body: jsonEncode({}), // Empty body as authentication is in headers
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {"success": true, "token": responseData["token"]};
      } else {
        final responseData = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {"message": "Unknown error"};

        return {
          "success": false,
          "message": responseData["message"] ?? responseData["error"] ?? "Verification failed"
        };
      }
    } catch (e) {
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }
}