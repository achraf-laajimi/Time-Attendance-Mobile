// lib/auth/auth_wrapper.dart
import 'package:flutter/material.dart';
import 'package:in_out/auth/auth_service.dart';
import 'package:in_out/screens/login/login_page.dart';
import 'package:in_out/screens/dashboard.dart';
import 'package:in_out/provider/user_settings_provider.dart';
import 'package:in_out/provider/profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      print("AUTH: Checking authentication status");
      final prefs = await SharedPreferences.getInstance();

      // First check if Remember Me is enabled
      final rememberMe = prefs.getBool('remember_me') ?? false;
      print("AUTH: Remember Me enabled: $rememberMe");

      if (rememberMe) {
        // Try to get stored token
        final token = prefs.getString('auth_token');
        print("AUTH: Stored token: ${token != null ? 'Found' : 'Not Found'}");

        if (token != null && token.isNotEmpty) {
          // Initialize user data
          print("AUTH: Token found, loading user data");
          await _loadUserData();

          setState(() {
            _isAuthenticated = true;
            _isLoading = false;
          });
          return;
        } else {
          print("AUTH: No valid token found despite Remember Me enabled");
        }
      } else {
        print("AUTH: Remember Me disabled, requiring login");
      }

      // No valid token found or Remember Me disabled
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    } catch (e) {
      print("AUTH: Error checking auth status: $e");
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserData() async {
    try {
      print("AUTH: Loading user data");
      // Initialize profile provider
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      await profileProvider.loadProfile();
      print("AUTH: Profile loaded");

      // Initialize user settings
      final userId = await AuthService.getCurrentUserId();
      if (userId != null) {
        print("AUTH: User ID found: $userId");
        final userSettingsProvider = Provider.of<UserSettingsProvider>(context, listen: false);
        await userSettingsProvider.setCurrentUser(userId);
        print("AUTH: User settings initialized");
      } else {
        print("AUTH: No user ID found");
      }
    } catch (e) {
      print("AUTH: Error loading user data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginPage();
    }
  }
}