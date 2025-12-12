// // lib/widgets/token_management_widget.dart
//
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../auth/global.dart';
// import '../utils/token_checker.dart';
//
// class TokenManagementWidget extends StatelessWidget {
//   const TokenManagementWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(16.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               "Session Management",
//               style: TextStyle(
//                 fontSize: 18.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8.0),
//             const Text(
//               "Manage your login session and remember me settings",
//               style: TextStyle(
//                 fontSize: 14.0,
//                 color: Colors.grey,
//               ),
//             ),
//             const SizedBox(height: 16.0),
//             _buildRememberMeStatus(),
//             const SizedBox(height: 16.0),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => TokenChecker.showTokenInfo(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.blue,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text("Check Token Status"),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8.0),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _toggleRememberMe(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text("Toggle Remember Me"),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8.0),
//             Row(
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () => _reloadToken(context),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.orange,
//                       foregroundColor: Colors.white,
//                     ),
//                     child: const Text("Reload Token"),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildRememberMeStatus() {
//     return FutureBuilder<bool>(
//       future: _getRememberMeStatus(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CircularProgressIndicator();
//         }
//
//         final rememberMe = snapshot.data ?? false;
//         return Row(
//           children: [
//             Icon(
//               rememberMe ? Icons.check_circle : Icons.cancel,
//               color: rememberMe ? Colors.green : Colors.red,
//             ),
//             const SizedBox(width: 8.0),
//             Text(
//               "Remember Me: ${rememberMe ? 'Enabled' : 'Disabled'}",
//               style: TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: rememberMe ? Colors.green : Colors.red,
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<bool> _getRememberMeStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getBool(Global.REMEMBER_ME_KEY) ?? false;
//   }
//
//   Future<void> _toggleRememberMe(BuildContext context) async {
//     final prefs = await SharedPreferences.getInstance();
//     final currentValue = prefs.getBool(Global.REMEMBER_ME_KEY) ?? false;
//     await prefs.setBool(Global.REMEMBER_ME_KEY, !currentValue);
//
//     // Show confirmation
//     if (context.mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text("Remember Me is now ${!currentValue ? 'enabled' : 'disabled'}"),
//           backgroundColor: !currentValue ? Colors.green : Colors.orange,
//         ),
//       );
//
//       // Refresh the widget
//       (context as Element).markNeedsBuild();
//     }
//   }
//
//   Future<void> _reloadToken(BuildContext context) async {
//     try {
//       // Force token reload from storage
//       await Global.getAuthToken();
//
//       // Show confirmation
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text("Token reloaded from storage"),
//             backgroundColor: Colors.blue,
//           ),
//         );
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text("Error: $e"),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }
// }