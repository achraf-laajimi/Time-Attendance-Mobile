import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../localization/app_localizations.dart';
import '../../theme/adaptive_colors.dart';
import '../../services/locales_service.dart';

class AddHolidayScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onHolidayAdded;

  const AddHolidayScreen({
    super.key,
    this.onHolidayAdded,
  });

  @override
  State<AddHolidayScreen> createState() => _AddHolidayScreenState();
}

class _AddHolidayScreenState extends State<AddHolidayScreen> {
  // Controllers for text fields - dynamic based on supported languages
  final Map<String, TextEditingController> _nameControllers = {};
  final TextEditingController _descriptionController = TextEditingController();

  // Supported languages
  List<String> _supportedLanguages = [];
  bool _isLoadingLanguages = true;

  // Selected values
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String _holidayType = 'Public'; // Public or Company
  int _count = 1;

  // Form validation
  final _formKey = GlobalKey<FormState>();
  bool _formIsValid = false;

  @override
  void initState() {
    super.initState();
    _loadSupportedLanguages();
  }

  Future<void> _loadSupportedLanguages() async {
    try {
      final localesService = LocalesService();
      final languages = await localesService.getSupportedLocales();

      setState(() {
        _supportedLanguages = languages;
        _isLoadingLanguages = false;

        // Create controllers for each supported language
        for (final lang in languages) {
          _nameControllers[lang] = TextEditingController();
        }
      });
    } catch (e) {
      print('Error loading supported languages: $e');
      // Fallback to English only if service fails
      setState(() {
        _supportedLanguages = ['en'];
        _isLoadingLanguages = false;
        _nameControllers['en'] = TextEditingController();
      });
    }
  }

  @override
  void dispose() {
    _nameControllers.forEach((_, controller) => controller.dispose());
    _descriptionController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // At least one language name must be filled (preferably the primary language)
      _formIsValid = _nameControllers.entries
          .any((entry) => entry.value.text.isNotEmpty);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 5),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitHoliday() {
    if (!_formIsValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).getString('pleaseFillRequiredFields')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Create holiday data with names for all supported languages
    final Map<String, String> labels = {};
    _nameControllers.forEach((lang, controller) {
      if (controller.text.isNotEmpty) {
        labels[lang] = controller.text;
      }
    });

    final Map<String, dynamic> holidayData = {
      'name': labels,
      'description': _descriptionController.text,
      'date': _selectedDate,
      'count': _count,
      'recurring': _isRecurring,
      'type': _holidayType,
    };

    // Debug info
    print('Submitting holiday with labels: $labels');
    print('Recurring: $_isRecurring');

    // Call callback if exists
    if (widget.onHolidayAdded != null) {
      widget.onHolidayAdded!(holidayData);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).getString('holidayAddedSuccessfully')),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back
    Navigator.pop(context);
  }

  String _getLanguageDisplayName(String langCode) {
    final localeInfo = LocalesService.getLocaleInfo();
    return localeInfo[langCode]?['nativeName'] ?? langCode.toUpperCase();
  }

  Widget _buildLanguageFields(double screenWidth, double screenHeight, double baseFontSize) {
    if (_isLoadingLanguages) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      children: _supportedLanguages.map((langCode) {
        final isFirstLanguage = langCode == _supportedLanguages.first;
        final displayName = _getLanguageDisplayName(langCode);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Holiday Name ($displayName) ${isFirstLanguage ? '*' : ''}',
              style: TextStyle(
                fontSize: baseFontSize,
                fontWeight: FontWeight.w500,
                color: AdaptiveColors.primaryTextColor(context),
              ),
            ),
            SizedBox(height: screenHeight * 0.01),
            TextFormField(
              controller: _nameControllers[langCode],
              decoration: InputDecoration(
                hintText: 'Enter holiday name in $displayName',
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
                fontSize: baseFontSize,
                color: AdaptiveColors.primaryTextColor(context),
              ),
              validator: isFirstLanguage
                  ? (value) {
                if (value == null || value.isEmpty) {
                  return 'Holiday name is required in at least one language';
                }
                return null;
              }
                  : null,
              onChanged: (value) => _validateForm(),
            ),
            SizedBox(height: screenHeight * 0.02),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);
    final baseFontSize = screenHeight * 0.018;

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
          localizations.getString('addHoliday'),
          style: TextStyle(
            color: AdaptiveColors.primaryTextColor(context),
            fontSize: baseFontSize * 1.2,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Form(
            key: _formKey,
            onChanged: _validateForm,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dynamic language fields
                        _buildLanguageFields(screenWidth, screenHeight, baseFontSize),

                        // Holiday Description
                        Text(
                          localizations.getString('description'),
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            hintText: localizations.getString('enterDescription'),
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
                            fontSize: baseFontSize,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                          maxLines: 3,
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Holiday Date
                        Text(
                          '${localizations.getString('holidayDate')} *',
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        InkWell(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.03),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                              color: AdaptiveColors.cardColor(context),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('yyyy-MM-dd').format(_selectedDate),
                                  style: TextStyle(
                                    fontSize: baseFontSize,
                                    color: AdaptiveColors.primaryTextColor(context),
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  color: Colors.green.shade800,
                                  size: baseFontSize * 1.2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Number of days (count)
                        Text(
                          'Number of days',
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: AdaptiveColors.cardColor(context),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: _count,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.green.shade800,
                              ),
                              isExpanded: true,
                              dropdownColor: AdaptiveColors.cardColor(context),
                              items: [1, 2, 3, 4, 5, 6, 7].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(
                                    value.toString(),
                                    style: TextStyle(
                                      fontSize: baseFontSize,
                                      color: AdaptiveColors.primaryTextColor(context),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (int? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _count = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Holiday Type
                        Text(
                          localizations.getString('holidayType'),
                          style: TextStyle(
                            fontSize: baseFontSize,
                            fontWeight: FontWeight.w500,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03,
                            vertical: screenWidth * 0.01,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: AdaptiveColors.cardColor(context),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _holidayType,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Colors.green.shade800,
                              ),
                              isExpanded: true,
                              dropdownColor: AdaptiveColors.cardColor(context),
                              items: ['Public', 'Company'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: baseFontSize,
                                      color: AdaptiveColors.primaryTextColor(context),
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _holidayType = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Recurring Yearly Option
                        Row(
                          children: [
                            Checkbox(
                              value: _isRecurring,
                              activeColor: Colors.green.shade800,
                              onChanged: (bool? value) {
                                setState(() {
                                  _isRecurring = value ?? false;
                                });
                                print('Recurring checkbox changed to: $_isRecurring');
                              },
                            ),
                            Text(
                              localizations.getString('recurringYearly'),
                              style: TextStyle(
                                fontSize: baseFontSize,
                                color: AdaptiveColors.primaryTextColor(context),
                              ),
                            ),
                          ],
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
                            fontSize: baseFontSize,
                            color: AdaptiveColors.primaryTextColor(context),
                          ),
                        ),
                      ),
                      SizedBox(width: screenWidth * 0.02),
                      ElevatedButton(
                        onPressed: _isLoadingLanguages ? null : _submitHoliday,
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
                        child: Text(
                          localizations.getString('addHoliday'),
                          style: TextStyle(
                            fontSize: baseFontSize,
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