// lib/auth/forgot_password_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'global.dart';

class ForgotPasswordService {
  static Future<Map<String, dynamic>> requestPasswordResetOTP(String identifier) async {
    final Uri url = Uri.parse("${Global.baseUrl}/public/authentication/forget-password");

    try {
      print('Requesting OTP for: $identifier');
      final requestBody = jsonEncode({});

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "X-Public-Identifier": identifier,
        },
        body: requestBody,
      );

      if (response.statusCode == 412) {
        try {
          final responseData = jsonDecode(response.body);
          final xRequestId = response.headers['x-request-id'];

          print('Request ID from header: $xRequestId');
          print('OTP length from body: ${responseData["length"]}');

          if (xRequestId != null && responseData.containsKey('length')) {
            return {
              "success": true,
              "otpLength": responseData["length"],
              "requestId": xRequestId,
              "message": "OTP sent successfully",
            };
          } else {
            return {"success": false, "message": "Invalid OTP response format"};
          }
        } catch (e) {
          print('Error parsing response: $e');
          return {"success": false, "message": "Failed to parse OTP response: $e"};
        }
      } else {
        String errorMessage = "Failed to send password reset code";
        try {
          if (response.body.isNotEmpty) {
            final responseData = jsonDecode(response.body);
            errorMessage = responseData["message"] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = "Failed to parse error message";
        }

        print('Error: $errorMessage');
        return {"success": false, "message": errorMessage};
      }
    } catch (e) {
      print('Exception: $e');
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
      String identifier, String requestId, String otpCode, String newPassword) async
  {
    final Uri url = Uri.parse("${Global.baseUrl}/public/authentication/forget-password");

    try {


      final requestBody = jsonEncode({"password": newPassword});

      print('Request body: $requestBody');

      final headers = {
        "Content-Type": "application/json",
        "X-Public-Identifier": identifier,
        "X-Request-ID": requestId,
        "X-Policy-Data": otpCode,
      };

      print('Request headers: $headers');

      final response = await http.put(
        url,
        headers: headers,
        body: requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        return {
          "success": true,
          "message": "Password reset successfully",
        };
      } else {
        String errorMessage = "Failed to reset password (Status: ${response.statusCode})";
        try {
          if (response.body.isNotEmpty) {
            final responseData = jsonDecode(response.body);
            errorMessage = responseData["message"] ?? errorMessage;
          }
        } catch (e) {
          errorMessage = "Failed to parse error message: $e";
        }

        return {
          "success": false,
          "message": errorMessage,
        };
      }
    } catch (e) {
      return {"success": false, "message": "Cannot connect to server: $e"};
    }
  }
}