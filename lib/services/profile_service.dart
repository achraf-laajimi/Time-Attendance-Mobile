import 'dart:convert';
import 'package:http/http.dart' as http;
import '../auth/global.dart';
import '../models/profile_model.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  Future<Map<String, dynamic>> getProfile() async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/profile");

    try {
      final response = await http.get(
        url,
        headers: await Global.getHeaders(),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          "success": true,
          "profile": ProfileModel.fromJson(responseData),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to get profile: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  Future<Map<String, dynamic>> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async
  {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/authentication/password");

    try {
      final Map<String, dynamic> requestData = {
        "password": newPassword,
        "oldPassword": oldPassword,
      };

      print("Updating password with data: ${jsonEncode(requestData)}");

      final response = await http.put(
        url,
        headers: await Global.getHeaders(),
        body: jsonEncode(requestData),
      );

      print("Update password response status: ${response.statusCode}");
      print("Update password response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 202) {
        return {
          "success": true,
          "statusCode": response.statusCode,
          "message": "Password updated successfully",
        };
      } else if (response.statusCode == 400) {
        // Bad Request - Check for invalid credentials
        final Map<String, dynamic> responseData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {};

        if (responseData["error"] == "invalid_credentials") {
          return {
            "success": false,
            "statusCode": response.statusCode,
            "errorCode": "invalid_credentials",
            "message": "Current password is incorrect",
          };
        } else {
          return {
            "success": false,
            "statusCode": response.statusCode,
            "message": responseData["message"] ?? "Bad request: ${response.statusCode}",
            "errorCode": responseData["error"] ?? responseData["errorCode"],
          };
        }
      } else if (response.statusCode == 412) {
        final Map<String, dynamic> responseData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {};

        return {
          "success": false,
          "statusCode": response.statusCode,
          "requiresOtp": true,
          "requestId": responseData["requestId"] ?? _generateRequestId(),
          "message": "OTP verification required",
        };
      } else {
        final Map<String, dynamic> responseData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {};

        return {
          "success": false,
          "statusCode": response.statusCode,
          "message": responseData["message"] ?? "Failed to update password: ${response.statusCode}",
          "errorCode": responseData["error"] ?? responseData["errorCode"],
        };
      }
    } catch (e) {
      print("Error updating password: $e");
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  Future<Map<String, dynamic>> verifyPasswordUpdateOtp({
    required String requestId,
    required String otpCode,
  }) async
  {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/authentication/password");

    try {
      final headers = await Global.getHeaders();
      headers['X-Policy-Data'] = otpCode;

      print("Verifying password update OTP with request ID: $requestId");
      print("OTP Code: $otpCode");

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({"requestId": requestId}),
      );

      print("Verify OTP response status: ${response.statusCode}");
      print("Verify OTP response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 202) {
        return {
          "success": true,
          "statusCode": response.statusCode,
          "message": "Password updated successfully",
        };
      } else if (response.statusCode == 400 || response.statusCode == 401) {
        final Map<String, dynamic> responseData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {};

        return {
          "success": false,
          "statusCode": response.statusCode,
          "errorCode": "invalid_otp",
          "message": responseData["message"] ?? "Invalid OTP code",
        };
      } else if (response.statusCode == 410) {
        final Map<String, dynamic> responseData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {};

        return {
          "success": false,
          "statusCode": response.statusCode,
          "errorCode": "expired_otp",
          "message": responseData["message"] ?? "OTP code has expired",
        };
      } else {
        final Map<String, dynamic> responseData = response.body.isNotEmpty
            ? json.decode(response.body)
            : {};

        return {
          "success": false,
          "statusCode": response.statusCode,
          "message": responseData["message"] ?? "Failed to verify OTP: ${response.statusCode}",
          "errorCode": responseData["errorCode"],
        };
      }
    } catch (e) {
      print("Error verifying OTP: $e");
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  String _generateRequestId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Future<Map<String, dynamic>> updateProfile(ProfileModel profile) async {
    final Uri url = Uri.parse("${Global.baseUrl}/secure/profile");

    try {
      final Map<String, dynamic> updateData = {
        "personalEmail": profile.personalEmail,
        "address": profile.address,
        "phoneNumber": profile.phoneNumber,
        "gender": profile.gender,
        "maritalStatus": profile.maritalStatus,
        "birthDate": profile.birthDate,
        "locale": profile.locale,
        "secondFactorEnabled": profile.secondFactorEnabled
      };

      print("Updating profile with data: ${jsonEncode(updateData)}");

      final response = await http.put(
        url,
        headers: await Global.getHeaders(),
        body: jsonEncode(updateData),
      );

      print("Update profile response status: ${response.statusCode}");
      print("Update profile response body: ${response.body}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          "success": true,
          "profile": ProfileModel.fromJson(responseData),
        };
      } else {
        return {
          "success": false,
          "message": "Failed to update profile: ${response.statusCode}",
        };
      }
    } catch (e) {
      print("Error updating profile: $e");
      return {
        "success": false,
        "message": "Error connecting to server: $e",
      };
    }
  }

  Future<Map<String, dynamic>> updateProfileField(int profileId, String field, dynamic value) async {
    final profileResult = await getProfile();

    if (!profileResult["success"]) {
      return profileResult;
    }

    final ProfileModel currentProfile = profileResult["profile"];

    ProfileModel updatedProfile;

    switch (field) {
      case 'secondFactorEnabled':
        updatedProfile = currentProfile.copyWith(secondFactorEnabled: value);
        print("Updating 2FA setting to: $value");
        break;
      case 'locale':
        updatedProfile = currentProfile.copyWith(locale: value);
        print("Updating language setting to: $value");
        break;
      case 'personalEmail':
        updatedProfile = currentProfile.copyWith(personalEmail: value);
        print("Updating personal email to: $value");
        break;
      case 'address':
        updatedProfile = currentProfile.copyWith(address: value);
        print("Updating address to: $value");
        break;
      case 'phoneNumber':
        updatedProfile = currentProfile.copyWith(phoneNumber: value);
        print("Updating phone number to: $value");
        break;
      case 'gender':
        updatedProfile = currentProfile.copyWith(gender: value);
        print("Updating gender to: $value");
        break;
      case 'maritalStatus':
        updatedProfile = currentProfile.copyWith(maritalStatus: value);
        print("Updating marital status to: $value");
        break;
      case 'birthDate':
        updatedProfile = currentProfile.copyWith(birthDate: value);
        print("Updating birth date to: $value");
        break;
      default:
        return {
          "success": false,
          "message": "Unsupported field: $field",
        };
    }
    return updateProfile(updatedProfile);
  }

  Future<Map<String, dynamic>> updateLanguage(String languageCode) async {
    final profileResult = await getProfile();

    if (!profileResult["success"]) {
      return profileResult;
    }

    final ProfileModel currentProfile = profileResult["profile"];

    if (currentProfile.locale == languageCode) {
      return {
        "success": true,
        "profile": currentProfile,
        "message": "Language already set to $languageCode",
      };
    }
    final updatedProfile = currentProfile.copyWith(locale: languageCode);

    return updateProfile(updatedProfile);
  }

  Future<Map<String, dynamic>> updateTwoFactorAuth(bool enabled) async {
    final profileResult = await getProfile();

    if (!profileResult["success"]) {
      return profileResult;
    }

    final ProfileModel currentProfile = profileResult["profile"];

    // Only update if setting is actually different
    if (currentProfile.secondFactorEnabled == enabled) {
      return {
        "success": true,
        "profile": currentProfile,
        "message": "2FA already ${enabled ? 'enabled' : 'disabled'}",
      };
    }

    // Create a new profile with updated 2FA setting
    final updatedProfile = currentProfile.copyWith(secondFactorEnabled: enabled);

    // Send the update to the API with all required fields
    return updateProfile(updatedProfile);
  }

}