// // lib/utils/token_checker.dart - fixed version
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../auth/global.dart';
//
// class TokenChecker {
//   // Show dialog with detailed token information
//   static void showTokenInfo(BuildContext context) async {
//     try {
//       // Get information from SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       final storedToken = prefs.getString(Global.TOKEN_KEY);
//       final rememberMe = prefs.getBool(Global.REMEMBER_ME_KEY) ?? false;
//
//       // Get memory token through the public method
//       final memoryToken = await Global.getAuthToken();
//
//       // Format token previews for display
//       String storedPreview = storedToken != null ?
//       "${storedToken.substring(0, storedToken.length > 10 ? 10 : storedToken.length)}..." :
//       "Not found";
//
//       String memoryPreview = memoryToken != null ?
//       "${memoryToken.substring(0, memoryToken.length > 10 ? 10 : memoryToken.length)}..." :
//       "Not found";
//
//       // Get authentication headers
//       final headers = await Global.getHeaders();
//       final hasAuthHeader = headers.containsKey("Authorization");
//
//       // Show detailed dialog
//       showDialog(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: const Text("Token Diagnostic"),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text("Remember Me Enabled: $rememberMe",
//                     style: const TextStyle(fontWeight: FontWeight.bold)),
//                 const SizedBox(height: 12),
//
//                 const Text("Token in SharedPreferences:",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(storedToken != null ? "Present: $storedPreview" : "Not Found"),
//                 const SizedBox(height: 12),
//
//                 const Text("Token in Memory:",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(memoryToken != null ? "Present: $memoryPreview" : "Not Found"),
//                 const SizedBox(height: 12),
//
//                 const Text("Auth Header for Requests:",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(hasAuthHeader ? "Present in headers" : "Missing from headers"),
//                 const SizedBox(height: 12),
//
//                 const Text("Token Match:",
//                     style: TextStyle(fontWeight: FontWeight.bold)),
//                 Text(storedToken == memoryToken ?
//                 "Tokens Match" :
//                 "Tokens Don't Match or Missing"),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text("Close"),
//             ),
//             TextButton(
//               onPressed: () async {
//                 // Force token reload from storage
//                 await Global.getAuthToken();
//                 Navigator.of(context).pop();
//                 // Show dialog again with updated info
//                 showTokenInfo(context);
//               },
//               child: const Text("Reload Token"),
//             ),
//           ],
//         ),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Error checking token: $e")),
//       );
//     }
//   }
//
//   // Add a button to any widget tree to open the token checker
//   static Widget createCheckerButton(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: () => showTokenInfo(context),
//       icon: const Icon(Icons.security),
//       label: const Text("Check Token"),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//       ),
//     );
//   }
// }