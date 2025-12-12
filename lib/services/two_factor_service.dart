// lib/services/two_factor_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../auth/global.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TwoFactorService {
  static final TwoFactorService _instance = TwoFactorService._internal();
  factory TwoFactorService() => _instance;
  TwoFactorService._internal();

  // Toggle 2FA Status - Entry point
  Future<Map<String, dynamic>> toggle2FAStatus({
    required bool enable,
    String? credential, // Password or OTP code
    String? requestId,
  }) async {
    // If we already have a requestId and credentials, go straight to verification
    if (requestId != null && credential != null) {
      return await _completeToggle2FA(
        enable: enable,
        requestId: requestId,
        credential: credential,
      );
    }

    // Initial request to toggle 2FA status
    return await _initiate2FAToggle(enable: enable);
  }

  // Initial API call to toggle 2FA
  Future<Map<String, dynamic>> _initiate2FAToggle({required bool enable}) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/authentication/toggle-second-factor");

    try {
      // Use default headers for first request
      final response = await http.put(
        url,
        headers: await Global.getHeaders(),
      );

      // Consider 2xx status codes as success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          "success": true,
          "statusCode": response.statusCode,
          "enabled": enable,
          "message": "L'authentification à deux facteurs a été ${enable ? 'activée' : 'désactivée'} avec succès"
        };
      }
      // If 2FA operation requires verification (412 Precondition Failed)
      else if (response.statusCode == 412) {
        final requestId = response.headers['x-request-id'];
        final policyRequired = response.headers['x-policy-required'];

        // Determine the type of verification needed
        final bool requiresOtp = policyRequired == 'one-time-password';
        final bool requiresPassword = policyRequired == 'password-policy';

        return {
          "success": false,
          "statusCode": response.statusCode,
          "requiresVerification": true,
          "requestId": requestId,
          "requiresOtp": requiresOtp,
          "requiresPassword": requiresPassword,
          "message": "Vérification requise pour ${enable ? 'activer' : 'désactiver'} la 2FA",
        };
      }
      // Handle other error cases
      else {
        String errorMessage = "Échec de l'opération 2FA";
        try {
          if (response.body.isNotEmpty) {
            final responseData = jsonDecode(response.body);
            errorMessage = responseData["message"] ?? errorMessage;
          }
        } catch (e) {
          // Ignore parsing errors
        }

        return {
          "success": false,
          "statusCode": response.statusCode,
          "message": errorMessage
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Erreur de connexion: $e"
      };
    }
  }

  // Complete 2FA toggle with verification (password or OTP)
  Future<Map<String, dynamic>> _completeToggle2FA({
    required bool enable,
    required String requestId,
    required String credential, // Password or OTP
  }) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/authentication/toggle-second-factor");

    try {
      // Get base headers
      Map<String, String> headers = await Global.getHeaders();

      // Add verification headers
      headers["X-Request-ID"] = requestId;
      headers["X-Policy-Data"] = credential;

      // Make request with headers only, no body
      final response = await http.put(
        url,
        headers: headers,
      );

      // Consider 2xx status codes as success
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {
          "success": true,
          "statusCode": response.statusCode,
          "enabled": enable,
          "message": "L'authentification à deux facteurs a été ${enable ? 'activée' : 'désactivée'} avec succès"
        };
      } else {
        String errorMessage = "Échec de la vérification";
        String? errorCode;

        try {
          if (response.body.isNotEmpty) {
            final responseData = jsonDecode(response.body);
            errorMessage = responseData["message"] ?? errorMessage;
            errorCode = responseData["errorCode"] ?? responseData["error"];
          }
        } catch (e) {
          // Ignore parsing errors
        }

        // Check for specific error types
        if (response.statusCode == 401 ||
            (errorCode != null && (errorCode == "invalid_credentials" ||
                errorCode == "invalid_otp"))) {
          if (enable) {
            // For enabling 2FA with password verification
            errorMessage = "Mot de passe incorrect";
          } else {
            // For disabling 2FA with OTP verification
            errorMessage = "Code OTP invalide";
          }
        }

        return {
          "success": false,
          "statusCode": response.statusCode,
          "errorCode": errorCode,
          "message": errorMessage
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Erreur de connexion: $e"
      };
    }
  }
}