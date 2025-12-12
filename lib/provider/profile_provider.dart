import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../services/profile_service.dart';
import '../services/two_factor_service.dart';
import '../screens/settings/two_factor_dialog.dart';

class ProfileProvider with ChangeNotifier {
  ProfileModel? _userProfile;
  bool _isLoading = false;
  String _error = '';
  final ProfileService _profileService = ProfileService();
  final TwoFactorService _twoFactorService = TwoFactorService();

  // Store password update request ID for OTP verification
  String? _passwordUpdateRequestId;

  ProfileModel? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Initialize and load profile data
  Future<void> initialize() async {
    if (_userProfile != null) return; // Already initialized
    await loadProfile();
  }

  // Load or reload profile data
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final result = await _profileService.getProfile();

      if (result["success"]) {
        _userProfile = result["profile"];
        _error = '';
      } else {
        _error = result["message"];
      }
    } catch (e) {
      _error = "Error loading profile: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update password - First step of password update process
  Future<bool> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final result = await _profileService.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      // Check if we got a 412 Precondition Failed (OTP required)
      if (result["statusCode"] == 412) {
        // Password update initiated but requires OTP verification
        _passwordUpdateRequestId = result["requestId"];
        _error = '';
        return true; // Success - ready for OTP step
      }

      // Check for immediate success (200/202)
      if (result["success"] || (result["statusCode"] != null &&
          (result["statusCode"] == 200 || result["statusCode"] == 202))) {
        _error = '';
        // Password updated successfully without OTP
        return true;
      }

      // Handle error cases
      _error = result["message"] ?? "Failed to update password";
      return false;

    } catch (e) {
      _error = "Error updating password: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP for password update - Second step of password update process
  Future<bool> verifyPasswordUpdateOtp({
    required String otpCode,
  }) async {
    if (_passwordUpdateRequestId == null) {
      _error = "No password update request found. Please try again.";
      return false;
    }

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final result = await _profileService.verifyPasswordUpdateOtp(
        requestId: _passwordUpdateRequestId!,
        otpCode: otpCode,
      );

      // Check for success
      if (result["success"] || (result["statusCode"] != null &&
          (result["statusCode"] == 200 || result["statusCode"] == 202))) {
        // Clear the request ID as the process is complete
        _passwordUpdateRequestId = null;
        _error = '';
        return true;
      }

      // Handle specific error cases
      if (result["errorCode"] == "invalid_otp" ||
          result["message"]?.toString().contains("Invalid OTP") == true) {
        _error = "Invalid OTP code. Please try again.";
      } else if (result["errorCode"] == "expired_otp" ||
          result["message"]?.toString().contains("expired") == true) {
        _error = "OTP code has expired. Please request a new one.";
        _passwordUpdateRequestId = null; // Clear expired request
      } else {
        _error = result["message"] ?? "Failed to verify OTP";
      }

      return false;

    } catch (e) {
      _error = "Error verifying OTP: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resend OTP for password update
  Future<bool> resendPasswordUpdateOtp({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Re-initiate the password update to get a new OTP
      final result = await _profileService.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      // Check if we got a 412 Precondition Failed (new OTP sent)
      if (result["statusCode"] == 412) {
        _passwordUpdateRequestId = result["requestId"];
        _error = '';
        return true;
      }

      _error = result["message"] ?? "Failed to resend OTP";
      return false;

    } catch (e) {
      _error = "Error resending OTP: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel password update process
  void cancelPasswordUpdate() {
    _passwordUpdateRequestId = null;
    _error = '';
    notifyListeners();
  }

  // Update two-factor authentication setting with improved flow
  Future<bool> updateTwoFactorAuthentication(bool enabled, [BuildContext? context]) async {
    if (_userProfile == null) return false;
    if (context == null) {
      // Fallback to simple update if no context is provided
      return await _updateTwoFactorAuthSimple(enabled);
    }

    try {
      _isLoading = true;
      notifyListeners();

      // First step: Initiate 2FA toggle
      final initiateResult = await _twoFactorService.toggle2FAStatus(enable: enabled);

      // If already successful or code 200/202, update profile and return
      if (initiateResult["success"] || (initiateResult["statusCode"] != null &&
          (initiateResult["statusCode"] == 200 || initiateResult["statusCode"] == 202))) {
        // Si réussite directe, mettre à jour le profil
        await _updateProfileWith2FAStatus(enabled);
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // If verification required, handle the verification flow
      if (initiateResult["requiresVerification"] && initiateResult["requestId"] != null) {
        // Different flow based on enable/disable
        if (enabled) {
          // Enable 2FA requires password
          if (initiateResult["requiresPassword"]) {
            return await _handlePasswordVerification(context, enabled, initiateResult["requestId"]);
          }
        } else {
          // Disable 2FA requires OTP
          if (initiateResult["requiresOtp"]) {
            return await _handleOtpVerification(context, enabled, initiateResult["requestId"]);
          }
        }
      }

      // If we reach here, there was an unhandled error response
      // Check if we received a 200/202 status code anyway
      if (initiateResult["statusCode"] != null &&
          (initiateResult["statusCode"] == 200 || initiateResult["statusCode"] == 202)) {
        // Consider it a success if the API returned a successful status code
        await _updateProfileWith2FAStatus(enabled);
        _error = '';
        _isLoading = false;
        notifyListeners();
        return true;
      }

      // If we reach here, something unexpected happened
      _error = initiateResult["message"] ?? "Échec de mise à jour de l'authentification à deux facteurs";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = "Erreur lors de la mise à jour de l'authentification à deux facteurs: $e";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Handle password verification flow for enabling 2FA
  Future<bool> _handlePasswordVerification(BuildContext context, bool enabled, String requestId) async {
    bool verificationSuccess = false;
    bool canceled = false;

    // Loop until verification succeeds, is canceled, or max retries reached
    int attempts = 0;
    const int maxAttempts = 3;

    while (!verificationSuccess && !canceled && attempts < maxAttempts) {
      attempts++;

      // Show password dialog
      final password = await TwoFactorDialog.showPasswordDialog(
          context,
          attempts > 1 ? "Mot de passe incorrect. Réessayez." : null
      );

      // User canceled
      if (password == null || password.isEmpty) {
        canceled = true;
        continue;
      }

      // Try verification
      final verifyResult = await _twoFactorService.toggle2FAStatus(
        enable: enabled,
        requestId: requestId,
        credential: password,
      );

      // Check for success or 200/202 status code
      if (verifyResult["success"] || (verifyResult["statusCode"] != null &&
          (verifyResult["statusCode"] == 200 || verifyResult["statusCode"] == 202))) {
        verificationSuccess = true;
      } else {
        // Specific error for wrong password
        if (verifyResult["errorCode"] == "invalid_credentials" ||
            verifyResult["message"]?.toString().contains("Invalid credentials") == true) {
          // Continue loop for another attempt
          continue;
        } else {
          // Other error
          _error = verifyResult["message"] ?? "Échec de la vérification";
          break;
        }
      }
    }

    if (canceled) {
      _error = "Opération annulée";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (verificationSuccess) {
      await _updateProfileWith2FAStatus(enabled);
      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Voici une version corrigée de la méthode _handleOtpVerification dans ProfileProvider
// Cette correction se concentre sur la gestion sécurisée des dialogues et des états

  Future<bool> _handleOtpVerification(BuildContext context, bool enabled, String requestId) async {
    bool verificationSuccess = false;
    bool canceled = false;
    String? errorMessage;
    String currentRequestId = requestId; // Stocker l'ID de requête actuel dans une variable locale

    // Loop until verification succeeds, is canceled, or max retries reached
    int attempts = 0;
    const int maxAttempts = 3;

    while (!verificationSuccess && !canceled && attempts < maxAttempts) {
      attempts++;

      // Fonction pour demander un nouveau code OTP
      Future<String?> resendOtpFunction() async {
        try {
          // Demander un nouveau code
          final newInitResult = await _twoFactorService.toggle2FAStatus(enable: enabled);
          if (newInitResult["requiresVerification"] && newInitResult["requestId"] != null) {
            // Mettre à jour l'ID de requête actuel
            currentRequestId = newInitResult["requestId"];
            return currentRequestId;
          }
        } catch (e) {
          print("Erreur lors de la demande d'un nouveau code: $e");
        }
        return null;
      }

      // Show OTP dialog safely
      String? otp;
      if (context.mounted) {
        try {
          otp = await TwoFactorDialog.showOtpDialog(
              context,
              errorMessage,
              attempts > 1 ? resendOtpFunction : null
          );
        } catch (e) {
          print("Erreur lors de l'affichage du dialogue OTP: $e");
          // Éviter de répéter en cas d'erreur de dialogue
          canceled = true;
          continue;
        }
      } else {
        // Context n'est plus valide
        canceled = true;
        continue;
      }

      // User canceled
      if (otp == null || otp.isEmpty) {
        canceled = true;
        continue;
      }

      // Try verification with current requestId
      final verifyResult = await _twoFactorService.toggle2FAStatus(
        enable: enabled,
        requestId: currentRequestId, // Utiliser l'ID de requête actuel qui peut avoir été mis à jour
        credential: otp,
      );

      // Check for success or 200/202 status code
      if (verifyResult["success"] || (verifyResult["statusCode"] != null &&
          (verifyResult["statusCode"] == 200 || verifyResult["statusCode"] == 202))) {
        verificationSuccess = true;
      } else {
        // Set error message for next iteration
        errorMessage = "Code invalide. Veuillez réessayer.";
      }
    }

    if (canceled) {
      _error = "Opération annulée";
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (verificationSuccess) {
      // Utiliser Future.microtask pour éviter les problèmes de dépendances de widget
      await Future.microtask(() async {
        await _updateProfileWith2FAStatus(enabled);
      });
      _error = '';
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = errorMessage ?? "Échec de la vérification après plusieurs tentatives";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  // Helper to update profile with new 2FA status
  Future<void> _updateProfileWith2FAStatus(bool enabled) async {
    // Update user profile model locally
    _userProfile = _userProfile!.copyWith(secondFactorEnabled: enabled);

    // Re-fetch profile from server to ensure synchronization
    try {
      await loadProfile();
    } catch (e) {
      // Ignore errors when refreshing profile, we've already updated locally
      print("Erreur lors de la synchronisation du profil: $e");
    }

    notifyListeners();
  }

  // Simple update for 2FA without context/dialog flow (fallback only)
  Future<bool> _updateTwoFactorAuthSimple(bool enabled) async {
    try {
      // Use the dedicated method for updating 2FA
      final result = await _profileService.updateTwoFactorAuth(enabled);

      // Check for success or 200/202 status code
      if (result["success"] || (result["statusCode"] != null &&
          (result["statusCode"] == 200 || result["statusCode"] == 202))) {
        _userProfile = result["profile"];
        _error = '';
        notifyListeners();
        return true;
      } else {
        _error = result["message"];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error updating two-factor authentication: $e";
      notifyListeners();
      return false;
    }
  }

  // Update language preference
  Future<bool> updateLanguage(String languageCode) async {
    if (_userProfile == null) return false;

    try {
      // Use the dedicated method for updating language
      final result = await _profileService.updateLanguage(languageCode);

      if (result["success"]) {
        _userProfile = result["profile"];
        notifyListeners();
        return true;
      } else {
        _error = result["message"];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Error updating language: $e";
      notifyListeners();
      return false;
    }
  }

  // Method to update UI only (for immediate feedback)
  void setTwoFactorEnabledUIOnly(bool enabled) {
    if (_userProfile != null) {
      _userProfile = _userProfile!.copyWith(secondFactorEnabled: enabled);
      notifyListeners();
    }
  }

  // Force refresh profile from server
  Future<void> refreshProfile() async {
    if (_userProfile == null) return;

    // Save old profile for possible restoration
    final oldProfile = _userProfile;
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _profileService.getProfile();

      if (result["success"]) {
        _userProfile = result["profile"];
        _error = '';
      } else {
        _error = result["message"];
        // Restore old profile if loading fails
        if (_userProfile == null && oldProfile != null) {
          _userProfile = oldProfile;
        }
      }
    } catch (e) {
      _error = "Error refreshing profile: $e";
      // Restore old profile on error
      if (_userProfile == null && oldProfile != null) {
        _userProfile = oldProfile;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear profile when logging out
  void clearProfile() {
    _userProfile = null;
    _passwordUpdateRequestId = null;
    _error = '';
    notifyListeners();
  }
}