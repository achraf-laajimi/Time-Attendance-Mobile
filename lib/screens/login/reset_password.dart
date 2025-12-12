import 'package:flutter/material.dart';
import '../../auth/forgot_password_service.dart';
import 'password_success_dialog.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email; // Peut être un email ou un nom d'utilisateur
  final String requestId;
  final String otpCode;

  const ResetPasswordPage({
    super.key,
    required this.email,
    required this.requestId,
    required this.otpCode,
  });

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Contrôleurs pour les champs de mot de passe
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Focus nodes
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  // Toggles de visibilité du mot de passe
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Validation du formulaire
  bool _isFormValid = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Ajouter des écouteurs pour vérifier quand le formulaire est valide
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);

    // Debug info
    print('Reset Password Page initialized with:');
    print('Identifier: ${widget.email}');
    print('RequestId: ${widget.requestId}');
    print('OTP Code: ${widget.otpCode}');
  }

  // Valider le formulaire de mot de passe
  void _validateForm() {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    bool isValid = false;
    String error = '';
    bool hasError = false;

    // Vérifier si les mots de passe sont saisis
    if (password.isNotEmpty && confirmPassword.isNotEmpty) {
      // Vérifier si les mots de passe correspondent
      if (password != confirmPassword) {
        hasError = true;
        error = 'Passwords do not match';
      }
      // Vérifier la force du mot de passe (au moins 8 caractères)
      else if (password.length < 8) {
        hasError = true;
        error = 'Password must be at least 8 characters';
      } else {
        isValid = true;
      }
    }

    setState(() {
      _isFormValid = isValid;
      _hasError = hasError;
      _errorMessage = error;
    });
  }

  // Réinitialiser le mot de passe en utilisant l'API
  void _resetPassword() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      // S'assurer que nous avons tous les paramètres nécessaires
      if (widget.email.isEmpty || widget.requestId.isEmpty || widget.otpCode.isEmpty) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = "Missing required parameters for password reset";
        });
        return;
      }

      final result = await ForgotPasswordService.resetPassword(
          widget.email,
          widget.requestId,
          widget.otpCode,
          _passwordController.text
      );

      setState(() => _isLoading = false);

      if (result["success"]) {
        // Afficher la boîte de dialogue de succès
        if (mounted) {
          showPasswordSuccessDialog(context);
        }
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = result["message"] ?? "Failed to reset password";
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
    // Obtenir les dimensions de l'écran pour rendre la taille responsive
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final baseFontSize = screenHeight * 0.018;

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
                'Create New Password',
                style: TextStyle(
                  fontSize: baseFontSize * 1.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Your identity has been verified. Please set your new password.',
                style: TextStyle(
                  fontSize: baseFontSize * 0.875,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: screenHeight * 0.035),

              // Champ Nouveau mot de passe
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: baseFontSize * 0.9),
                  labelStyle: TextStyle(color: Colors.black54, fontSize: baseFontSize),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.04,
                  ),
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
                    borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                  ),
                  errorBorder: _hasError ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ) : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: screenHeight * 0.025,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onEditingComplete: () => _confirmPasswordFocusNode.requestFocus(),
              ),

              SizedBox(height: screenHeight * 0.02),

              // Champ Confirmer le mot de passe
              TextField(
                controller: _confirmPasswordController,
                focusNode: _confirmPasswordFocusNode,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm your password',
                  hintStyle: TextStyle(color: Colors.grey, fontSize: baseFontSize * 0.9),
                  labelStyle: TextStyle(color: Colors.black54, fontSize: baseFontSize),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.02,
                    horizontal: screenWidth * 0.04,
                  ),
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
                    borderSide: BorderSide(color: Colors.green.shade800, width: 2),
                  ),
                  errorBorder: _hasError ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ) : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                      size: screenHeight * 0.025,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
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

              SizedBox(height: screenHeight * 0.03),

              // Exigences de mot de passe
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password Requirements:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: baseFontSize * 0.875,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    _passwordRequirementItem(
                      'At least 8 characters',
                      _passwordController.text.length >= 8,
                      baseFontSize,
                    ),
                    _passwordRequirementItem(
                      'Passwords match',
                      _passwordController.text.isNotEmpty &&
                          _passwordController.text == _confirmPasswordController.text,
                      baseFontSize,
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.03),

              // Bouton Réinitialiser
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid && !_isLoading ? _resetPassword : null,
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
                      : const Text('Reset Password'),
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

  // Méthode d'aide pour créer des éléments d'exigence de mot de passe
  Widget _passwordRequirementItem(String text, bool isMet, double baseFontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? Colors.green.shade800 : Colors.grey,
            size: baseFontSize * 1.2,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: baseFontSize * 0.8,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }
}