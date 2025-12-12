// lib/screens/settings/two_factor_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/adaptive_colors.dart';

class TwoFactorDialog {
  static Future<String?> showPasswordDialog(
      BuildContext context,
      String? errorMessage
      ) async {
    final TextEditingController passwordController = TextEditingController();
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    bool obscurePassword = true;

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text('Confirmer votre mot de passe'),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Pour activer l\'authentification à deux facteurs, veuillez confirmer votre mot de passe.',
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          // Afficher une bordure rouge si erreur
                          errorBorder: errorMessage != null ? OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.red),
                          ) : null,
                          // Afficher le message d'erreur si présent
                          errorText: errorMessage,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Annuler'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('Confirmer'),
                    onPressed: () {
                      Navigator.of(context).pop(passwordController.text);
                    },
                  ),
                ],
              );
            }
        );
      },
    ).then((value) {
      passwordController.dispose();
      return value;
    });
  }

  static Future<String?> showOtpDialog(
      BuildContext context,
      String? errorMessage,
      [Future<String?> Function()? onResendOtp]
      ) async {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // Controllers for each OTP digit
    final List<TextEditingController> controllers = List.generate(
      6,
          (index) => TextEditingController(),
    );

    // Focus nodes for each OTP field
    final List<FocusNode> focusNodes = List.generate(
      6,
          (index) => FocusNode(),
    );

    // Loading state for resend button
    bool isResending = false;
    // Current request ID - may be updated if OTP is resent
    String? currentRequestId;

    try {
      return await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) { // Utiliser le nouveau context ici
          return StatefulBuilder(
              builder: (dialogContext, setState) {
                // Function to handle resend OTP
                void resendOtp() async {
                  if (onResendOtp == null || isResending) return;

                  // Update UI to show loading
                  setState(() {
                    isResending = true;
                  });

                  // Request new OTP
                  final newRequestId = await onResendOtp();

                  // Update request ID if successful
                  if (newRequestId != null) {
                    currentRequestId = newRequestId;

                    // Clear current OTP fields
                    for (var controller in controllers) {
                      controller.clear();
                    }

                    // Focus on first field
                    if (focusNodes.isNotEmpty) {
                      focusNodes[0].requestFocus();
                    }

                    // Show success message
                    if (dialogContext.mounted) { // Vérifier si le contexte est toujours valide
                      ScaffoldMessenger.of(dialogContext).clearSnackBars();
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text("Nouveau code envoyé par email"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  } else {
                    // Show error message
                    if (dialogContext.mounted) { // Vérifier si le contexte est toujours valide
                      ScaffoldMessenger.of(dialogContext).clearSnackBars();
                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                        const SnackBar(
                          content: Text("Échec de l'envoi du nouveau code"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }

                  // Update UI to hide loading
                  if (dialogContext.mounted) { // Vérifier si le contexte est toujours valide
                    setState(() {
                      isResending = false;
                    });
                  }
                }

                return WillPopScope(
                  // Empêcher la fermeture du dialogue avec le bouton retour
                  onWillPop: () async => false,
                  child: AlertDialog(
                    title: const Text('Vérification par code'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Pour désactiver l\'authentification à deux facteurs, veuillez entrer le code qui a été envoyé à votre adresse e-mail.',
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          if (errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                errorMessage,
                                style: const TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(
                              6,
                                  (index) => SizedBox(
                                width: screenWidth * 0.08,
                                height: screenWidth * 0.12,
                                child: TextField(
                                  controller: controllers[index],
                                  focusNode: focusNodes[index],
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLength: 1,
                                  decoration: InputDecoration(
                                    counterText: '',
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        // Rouge si erreur, gris sinon
                                        color: errorMessage != null ? Colors.red : Colors.grey.shade300,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: errorMessage != null ? Colors.red : AdaptiveColors.primaryGreen,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty && index < 5) {
                                      focusNodes[index + 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          if (onResendOtp != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: TextButton(
                                onPressed: isResending ? null : resendOtp,
                                child: isResending
                                    ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Text('Envoi en cours...'),
                                  ],
                                )
                                    : const Text('Renvoyer un nouveau code'),
                              ),
                            ),
                        ],
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Annuler'),
                        onPressed: () {
                          // Utiliser Navigator.of(dialogContext) pour éviter des problèmes avec le contexte
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                      ),
                      TextButton(
                        child: const Text('Vérifier'),
                        onPressed: () {
                          final otp = controllers.map((c) => c.text).join();
                          // Utiliser Navigator.of(dialogContext) pour éviter des problèmes avec le contexte
                          if (dialogContext.mounted) {
                            Navigator.of(dialogContext).pop(otp);
                          }
                        },
                      ),
                    ],
                  ),
                );
              }
          );
        },
      ).then((value) {
        // Dispose controllers and focus nodes when dialog is closed
        for (var controller in controllers) {
          controller.dispose();
        }
        for (var node in focusNodes) {
          node.dispose();
        }
        return value;
      });
    } catch (e) {
      // En cas d'erreur, nettoyer proprement les ressources
      for (var controller in controllers) {
        controller.dispose();
      }
      for (var node in focusNodes) {
        node.dispose();
      }
      print("Erreur dans showOtpDialog: $e");
      rethrow; // Relancer l'erreur pour qu'elle soit traitée par l'appelant
    }
  }
}