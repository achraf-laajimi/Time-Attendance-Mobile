import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui';

import 'login_page.dart';

class PasswordSuccessDialog extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const PasswordSuccessDialog({super.key, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenHeight * 0.018;

    return Stack(
      children: [
        // Blurred background
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ),

        // Dialog content
        Center(
          child: Container(
            width: screenWidth * 0.75,
            padding: EdgeInsets.symmetric(
                vertical: screenHeight * 0.04, horizontal: screenWidth * 0.06),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'images/confetti.svg',
                  height: screenHeight * 0.08,
                ),

                SizedBox(height: screenHeight * 0.02),

                // Title text
                Text(
                  'Password Update\nSuccessfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: baseFontSize * 1.3,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: screenHeight * 0.01),

                // Subtitle text
                Text(
                  'Your password has been updated successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: baseFontSize * 0.9,
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: screenHeight * 0.03),

                // Back to login button
                SizedBox(
                  width: double.infinity,
                  height: screenHeight * 0.05,
                  child: ElevatedButton(
                    onPressed: onBackToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006D3B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text('Back to Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Method to show the success dialog
void showPasswordSuccessDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation1, animation2) {
      return PasswordSuccessDialog(
        onBackToLogin: () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
          );
        },
      );
    },
  );
}
