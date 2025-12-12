import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/auth/global.dart';

class AddDepartmentScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onDepartmentAdded;

  const AddDepartmentScreen({
    super.key,
    this.onDepartmentAdded,
  });

  @override
  State<AddDepartmentScreen> createState() => _AddDepartmentScreenState();
}

class _AddDepartmentScreenState extends State<AddDepartmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';


  Future<void> _createDepartment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final String name = _nameController.text.trim();
      // Simply use the name as the key without special formatting
      final String key = name.toLowerCase().replaceAll(' ', '-');

      // Log the request payload
      print('Creating department with key: $key, name: $name');

      final response = await http.post(
        Uri.parse("${Global.baseUrl}/secure/department"),
        headers: await Global.getHeaders(),
        body: jsonEncode({
          "key": key,
          "name": name,
        }),
      );

      // Log the full response for debugging
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Create a department object to add to the list
        final newDepartment = {
          'name': name,
          'key': key,
          'attributes': {'users': []},
          'members': 0,
          'employees': [],
        };

        // Call the callback if provided
        if (widget.onDepartmentAdded != null) {
          widget.onDepartmentAdded!(newDepartment);
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).getString('departmentAddedSuccessfully')),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      } else {
        final Map<String, dynamic> responseData =
        response.body.isNotEmpty ? json.decode(response.body) : {};

        // Get more detailed error message if available
        final String serverMessage = responseData['message'] ?? 'Unknown server error';
        final String detailedError = responseData['error'] ?? '';

        setState(() {
          _errorMessage = 'Failed to create department: $serverMessage\n$detailedError';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
      // Log the exception
      print('Exception in _createDepartment: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AdaptiveColors.backgroundColor(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AdaptiveColors.primaryTextColor(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          localizations.getString('addDepartment'),
          style: TextStyle(
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: screenHeight * 0.025,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Department Name
                        Text(
                          '${localizations.getString('departmentName')} *',
                          style: TextStyle(
                            fontSize: screenHeight * 0.018,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: localizations.getString('enterDepartmentName'),
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
                            filled: true,
                            fillColor: AdaptiveColors.cardColor(context),
                            contentPadding: EdgeInsets.all(screenWidth * 0.03),
                          ),
                          style: TextStyle(
                            fontSize: screenHeight * 0.018,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.getString('departmentNameRequired');
                            }
                            return null;
                          },
                        ),

                        if (_errorMessage.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: screenHeight * 0.02),
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.03),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                _errorMessage,
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: screenHeight * 0.016,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Container(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.015,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          localizations.getString('cancel'),
                          style: TextStyle(
                            fontSize: screenHeight * 0.018,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _createDepartment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade800,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenHeight * 0.015,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                          width: screenHeight * 0.02,
                          height: screenHeight * 0.02,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          localizations.getString('addDepartment'),
                          style: TextStyle(
                            fontSize: screenHeight * 0.018,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}