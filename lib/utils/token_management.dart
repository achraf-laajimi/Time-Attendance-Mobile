// // lib/utils/token_management.dart
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../auth/global.dart';
//
// class TokenManagement {
//   // Direct force enable remember me and save current token
//   static Future<bool> forceEnableRememberMe(BuildContext context) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//
//       // First, get current token from memory
//       final token = await Global.getAuthToken();
//
//       if (token == null || token.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Error: No token available in memory"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return false;
//       }
//
//       // Force enable Remember Me
//       await prefs.setBool(Global.REMEMBER_ME_KEY, true);
//
//       // Force save token
//       await prefs.setString(Global.TOKEN_KEY, token);
//
//       // Verify token was saved
//       final verifyToken = prefs.getString(Global.TOKEN_KEY);
//       final rememberMe = prefs.getBool(Global.REMEMBER_ME_KEY) ?? false;
//
//       if (verifyToken != null && rememberMe) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Remember Me enabled and token saved successfully"),
//             backgroundColor: Colors.green,
//           ),
//         );
//         return true;
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Failed to save token"),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return false;
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Error: $e"),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return false;
//     }
//   }
//
//   // Add emergency token management button to settings screen
//   static Widget createEmergencyTokenButton(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.all(16.0),
//       child: ElevatedButton(
//         onPressed: () => forceEnableRememberMe(context),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: Colors.red,
//           foregroundColor: Colors.white,
//           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         ),
//         child: const Text(
//           "EMERGENCY: Force Enable Remember Me & Save Token",
//           textAlign: TextAlign.center,
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }