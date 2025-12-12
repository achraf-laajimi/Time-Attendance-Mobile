import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/screens/Login/reset_password.dart';

import '../../auth/forgot_password_service.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final String requestId;
  final int otpLength;

  const OtpVerificationPage({
    super.key,
    required this.email,
    required this.requestId,
    required this.otpLength,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(
      6,
          (index) => TextEditingController()
  );

  // Focus nodes pour chaque champ OTP
  final List<FocusNode> _focusNodes = List.generate(
      6,
          (index) => FocusNode()
  );

  // Suivi si OTP est rempli
  bool _isOtpFilled = false;

  // État d'erreur
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Ajouter des écouteurs pour vérifier quand tous les champs sont remplis
    for (var controller in _controllers) {
      controller.addListener(_checkOtpFilled);
    }

    // Log pour le débogage
    print('OTP Verification Page initialized with:');
    print('Identifier: ${widget.email}');
    print('RequestId: ${widget.requestId}');
    print('OTP Length: ${widget.otpLength}');
  }

  // Vérifier si tous les champs OTP sont remplis
  void _checkOtpFilled() {
    bool filled = true;
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        filled = false;
        break;
      }
    }

    if (filled != _isOtpFilled) {
      setState(() {
        _isOtpFilled = filled;
        if (_hasError) _hasError = false;
      });
    }
  }

  void _verifyOtp() {
    final otp = _controllers.map((c) => c.text).join();

    print('OTP entered: $otp');
    print('Proceeding to reset password screen');

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ResetPasswordPage(
          email: widget.email,
          requestId: widget.requestId,
          otpCode: otp,
        ),
      ),
    );
  }

  // Renvoyer OTP
  void _resendOtp() async {
    setState(() => _isLoading = true);

    try {
      // Appel API pour demander un nouveau OTP
      final result = await ForgotPasswordService.requestPasswordResetOTP(widget.email);

      setState(() => _isLoading = false);

      if (result["success"]) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('OTP resent successfully',
              style: TextStyle(fontSize: MediaQuery.of(context).size.height * 0.018))),
        );

        // Mettre à jour requestId si nécessaire
        final newRequestId = result["requestId"];
        if (newRequestId != null && newRequestId != widget.requestId) {
          // Remplacer cette page avec une nouvelle instance contenant le nouveau requestId
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                email: widget.email,
                requestId: newRequestId,
                otpLength: result["otpLength"] ?? widget.otpLength,
              ),
            ),
          );
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = result["message"] ?? "Failed to resend OTP";
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = "An error occurred: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenHeight * 0.018;
    final otpFieldSize = screenWidth * 0.12;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
                fontWeight: FontWeight.normal
            )
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.025),
              Text(
                'Enter OTP',
                style: TextStyle(
                  fontSize: baseFontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'We have sent a verification code to your registered contact method.',
                style: TextStyle(
                  fontSize: baseFontSize * 0.875,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: screenHeight * 0.035),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  _controllers.length,
                      (index) => SizedBox(
                    width: otpFieldSize,
                    height: otpFieldSize,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: baseFontSize * 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLength: 1,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: _controllers[index].text.isNotEmpty
                            ? Colors.green.withOpacity(0.1)
                            : Colors.white,
                        contentPadding: EdgeInsets.zero,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Colors.grey.shade300,
                            width: 1.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _hasError ? Colors.red : Colors.green.shade800,
                            width: 2.0,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < _controllers.length - 1) {
                          _focusNodes[index + 1].requestFocus();
                        }
                      },
                    ),
                  ),
                ),
              ),
              if (_hasError)
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.01),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: baseFontSize * 0.875
                    ),
                  ),
                ),

              SizedBox(height: screenHeight * 0.01),

              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _resendOtp,
                  child: Text(
                    'Didn\'t receive the code? Resend',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: baseFontSize * 0.875,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isOtpFilled ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade800,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
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
                      : const Text('Verify OTP'),
                ),
              ),

              const Spacer(),
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
      ),
    );
  }

  @override
  void dispose() {
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }
}