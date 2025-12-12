import 'package:flutter/material.dart';
import '../../auth/forgot_password_service.dart';
import 'otp_verification.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _identifierController = TextEditingController();
  bool _isLoading = false;

  // Vérifie si l'identifiant est valide (email ou nom d'utilisateur)


  void _sendOtp() async {
    final identifier = _identifierController.text.trim();

    if (identifier.isEmpty) {
      _showError("Enter your email or username.");
      return;
    }



    setState(() => _isLoading = true);

    try {
      // Appel API pour demander l'OTP
      final result = await ForgotPasswordService.requestPasswordResetOTP(identifier);

      setState(() => _isLoading = false);

      if (result["success"]) {
        _showSuccess("OTP code sent to your registered contact method");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: identifier, // Identifiant (email ou username)
              requestId: result["requestId"],
              otpLength: result["otpLength"] ?? 6,
            ),
          ),
        );
      } else {
        _showError(result["message"] ?? "Failed to send OTP");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError("An error occurred: $e");
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenHeight * 0.018;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.06),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.black54, size: screenHeight * 0.025),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Back',
            style: TextStyle(
              color: Colors.black54,
              fontSize: baseFontSize,
              fontWeight: FontWeight.normal,
            ),
          ),
          titleSpacing: 0,
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.only(top: screenHeight * 0.05),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: baseFontSize * 1.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Description
                    Text(
                      'Enter your username or email address, we\'ll send you a code to reset your password.',
                      style: TextStyle(
                        fontSize: baseFontSize * 0.875,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.025),
                    // Identifier Field Label
                    Text(
                      'Username or Email',
                      style: TextStyle(
                        fontSize: baseFontSize * 0.875,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Identifier TextField
                    TextField(
                      controller: _identifierController,
                      style: TextStyle(fontSize: baseFontSize),
                      decoration: InputDecoration(
                        hintText: 'Enter your username or email',
                        hintStyle: TextStyle(fontSize: baseFontSize),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.green.shade800),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      keyboardType: TextInputType.text, // Accepte tout type de texte
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    // Send OTP Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _sendOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                          textStyle: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Send OTP'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: screenHeight * 0.03),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Powered By ',
                      style: TextStyle(
                        fontSize: baseFontSize * 0.875,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      'Sotupub',
                      style: TextStyle(
                        fontSize: baseFontSize * 0.875,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF7240),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifierController.dispose();
    super.dispose();
  }
}