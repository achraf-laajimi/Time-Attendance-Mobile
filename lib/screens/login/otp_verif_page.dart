import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/auth_service.dart';
import '../dashboard.dart';
import '../../theme/adaptive_colors.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String identifier;
  final String requestId;
  final int otpLength;
  final String password;
  final bool rememberMe;

  const OtpVerificationScreen({
    super.key,
    required this.identifier,
    required this.requestId,
    required this.otpLength,
    required this.password,
    this.rememberMe = false,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  bool _isLoading = false;
  bool _isOtpFilled = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.otpLength,
          (index) => TextEditingController(),
    );

    _focusNodes = List.generate(
      widget.otpLength,
          (index) => FocusNode(),
    );

    // Add listeners to check when all fields are filled
    for (var controller in _controllers) {
      controller.addListener(_checkOtpFilled);
    }
  }

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

  String _getOtpValue() {
    return _controllers.map((controller) => controller.text).join('');
  }


  void _verifyOtp() async {
    final otpCode = _getOtpValue();

    setState(() => _isLoading = true);

    print("OTP: Verifying OTP with Remember Me: ${widget.rememberMe}");

    final result = await AuthService.verifyOTP(
      widget.identifier,
      widget.requestId,
      otpCode,
      widget.password,
      context,
      rememberMe: widget.rememberMe, // Pass remember me state
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      print("OTP: Verification successful");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', widget.rememberMe);
      print("OTP: Remember Me setting saved: ${widget.rememberMe}");

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connexion réussie !"),
          backgroundColor: Colors.green,
        ),
      );

      // Verify if token is saved
      if (widget.rememberMe) {
        final token = prefs.getString('auth_token');
        print("OTP: Token in SharedPreferences: ${token != null ? 'Present' : 'Missing'}");

        if (token == null) {
          print("OTP: WARNING - Token not found in SharedPreferences despite Remember Me being enabled");

          // Try to get token from result and save it directly as fallback
          if (result.containsKey('token') && result['token'] != null) {
            final resultToken = result['token'];
            await prefs.setString('auth_token', resultToken);
            print("OTP: Saved token directly from result");
          }
        }
      }

      // Navigate to dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
    } else {
      // Handle error
      print("OTP ERROR: ${result['message']}");
      setState(() {
        _hasError = true;
        _errorMessage = result['message'];
      });
    }
  }

  void _requestNewOtp() async {
    setState(() => _isLoading = true);

    // Request a new OTP
    final result = await AuthService.requestOTP(widget.identifier, widget.password);

    setState(() => _isLoading = false);

    if (result['success'] && result['otpRequired'] == true) {
      setState(() {
        _hasError = false;
        // Clear all OTP fields
        for (var controller in _controllers) {
          controller.clear();
        }
        // Focus on first field
        if (_focusNodes.isNotEmpty) {
          _focusNodes[0].requestFocus();
        }
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Code OTP envoyé à ${widget.identifier}"),
          backgroundColor: Colors.green,
        ),
      );

      // Update requestId if needed
      if (result['requestId'] != widget.requestId) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationScreen(
              identifier: widget.identifier,
              requestId: result['requestId'],
              otpLength: result['otpLength'] ?? widget.otpLength,
              password: widget.password,
              rememberMe: widget.rememberMe,
            ),
          ),
        );
      }
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = result['message'] ?? "Échec de l'envoi d'un nouveau code OTP";
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
      backgroundColor: AdaptiveColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AdaptiveColors.primaryTextColor(context),
            size: screenHeight * 0.025,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Retour',
          style: TextStyle(
            color: AdaptiveColors.secondaryTextColor(context),
            fontSize: baseFontSize,
            fontWeight: FontWeight.normal,
          ),
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
                'Vérification par code',
                style: TextStyle(
                  fontSize: baseFontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: AdaptiveColors.primaryTextColor(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Nous avons envoyé un code à votre adresse email.',
                style: TextStyle(
                  fontSize: baseFontSize * 0.875,
                  color: AdaptiveColors.secondaryTextColor(context),
                ),
              ),
              Text(
                widget.identifier,
                style: TextStyle(
                  fontSize: baseFontSize * 0.875,
                  fontWeight: FontWeight.bold,
                  color: AdaptiveColors.primaryTextColor(context),
                ),
              ),
              SizedBox(height: screenHeight * 0.035),

              // OTP input fields
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.otpLength,
                        (index) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                      child: SizedBox(
                        width: otpFieldSize,
                        height: otpFieldSize,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: baseFontSize * 1.5,
                            fontWeight: FontWeight.bold,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                          maxLength: 1,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: _controllers[index].text.isNotEmpty
                                ? AdaptiveColors.getPrimaryColor(context).withOpacity(0.1)
                                : AdaptiveColors.cardColor(context),
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? Colors.red
                                    : AdaptiveColors.borderColor(context),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? Colors.red
                                    : AdaptiveColors.getPrimaryColor(context),
                                width: 2.0,
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < widget.otpLength - 1) {
                              _focusNodes[index + 1].requestFocus();
                            }
                          },
                        ),
                      ),
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
                      fontSize: baseFontSize * 0.875,
                    ),
                  ),
                ),

              SizedBox(height: screenHeight * 0.02),

              // Resend OTP button
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : _requestNewOtp,
                  child: Text(
                    "Je n'ai pas reçu de code. Renvoyer",
                    style: TextStyle(
                      color: AdaptiveColors.getPrimaryColor(context),
                      fontSize: baseFontSize * 0.875,
                    ),
                  ),
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Verify button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isOtpFilled && !_isLoading ? _verifyOtp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdaptiveColors.getPrimaryColor(context),
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
                      : const Text('Vérifier'),
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
                          color: AdaptiveColors.secondaryTextColor(context),
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
    // Dispose controllers and focus nodes
    for (int i = 0; i < widget.otpLength; i++) {
      _controllers[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }
}