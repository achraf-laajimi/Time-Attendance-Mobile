import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_out/ai/camera_service.dart';
import 'package:in_out/ai/remote_pointing_service.dart';
import 'package:in_out/ai/recognition_result.dart';
import 'package:in_out/localization/app_localizations.dart';
import 'package:in_out/services/navigation_service.dart';
import 'package:in_out/theme/adaptive_colors.dart';
import 'package:in_out/widget/responsive_navigation_scaffold.dart';
import 'package:in_out/widget/user_profile_header.dart';
import 'package:intl/intl.dart';

import '../ai/face_registration_screen.dart';

class RemotePointageScreen extends StatefulWidget {
  const RemotePointageScreen({super.key});

  @override
  State<RemotePointageScreen> createState() => _RemotePointageScreenState();
}

class _RemotePointageScreenState extends State<RemotePointageScreen>
    with WidgetsBindingObserver {
  int _selectedIndex = 7;
  bool _isHeaderVisible = true;
  final ScrollController _scrollController = ScrollController();

// Services
  final CameraService _cameraService = CameraService();
  final RemotePointageService _aiService = RemotePointageService();

// States
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  String _step = "initial"; // initial, recognition, recognized, unrecognized
  String _message = "";
  String _status = "";
  String _recognizedUserName = "";

// Time tracking states
  bool _isCheckedIn = false;
  String _lastCheckTime = "";
  String _checkType = "in"; // "in" or "out"

// Current time
  DateTime _currentTime = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_scrollListener);

// Set preferred orientation to portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

// Initialize timer to update current time
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });

// Initialize camera and check server connection
    _initializeServices();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {
      _cameraService.dispose();
      setState(() {
        _isCameraInitialized = false;
      });
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _timer.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  void _scrollListener() {
    setState(() {
      _isHeaderVisible = _scrollController.offset <= 0;
    });
  }

  Future<void> _initializeServices() async {
    await _initializeCamera();
    await _checkServerConnection();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _message = "Initializing camera...";
    });

    try {
      final success = await _cameraService.initializeCamera(
        preferredDirection: CameraLensDirection.front,
        resolution: ResolutionPreset.medium,
      );

      if (mounted) {
        setState(() {
          _isCameraInitialized = success;
          _message = success ? "" : "Failed to initialize camera";
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
          _message = "Camera error: $e";
        });
      }
    }
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await _aiService.checkServerConnection();
    if (!isConnected && mounted) {
      setState(() {
        _message =
            "⚠️ Cannot connect to AI server. Please ensure the server is running.";
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    NavigationService.navigateToScreen(context, index);
  }

  /// Capture face and perform recognition (following web pattern)
  Future<void> _handlePointer() async {
    if (!_isCameraInitialized || _isProcessing) return;

    setState(() {
      _step = "recognition";
      _message = "📹 Processing face recognition...";
      _isProcessing = true;
    });

    try {
// Test camera first
      final cameraInfo = _cameraService.getCameraInfo();
      print('Camera info before capture: $cameraInfo');

// Try multiple capture methods
      Uint8List? imageBytes;

// Method 1: Simple capture
      print('Attempting simple capture...');
      imageBytes = await _cameraService.captureSimple();

// Method 2: Alternative capture if first fails
      if (imageBytes == null) {
        print('Simple capture failed, trying alternative...');
        imageBytes = await _cameraService.captureImageAlternative();
      }

// Method 3: Regular capture as last resort
      if (imageBytes == null) {
        print('Alternative capture failed, trying regular capture...');
        imageBytes = await _cameraService.captureImage();
      }

      if (imageBytes == null || imageBytes.isEmpty) {
        setState(() {
          _isProcessing = false;
          _message = "❌ Failed to capture image from camera";
          _step = "initial";
        });

// Try to reinitialize camera
        print('Attempting to reinitialize camera...');
        await _cameraService.reinitializeIfNeeded();
        return;
      }

      print('Successfully captured image: ${imageBytes.length} bytes');

// Send to recognition service
      final result = await _aiService.recognizeFace(imageBytes);
      print('Recognition result: ${result.toString()}');

      if (mounted) {
        setState(() {
          _isProcessing = false;
          if (result.recognized && result.displayName.isNotEmpty) {
            _status =
                "✅ Recognized: ${result.displayName} at ${result.displayDateTime}";
            _recognizedUserName = result.displayName;
            _step = "recognized";
            _message = "";
          } else {
            _status = "❌ Face not recognized";
            _step = "unrecognized";
            _message = "";
          }
        });

// Show result in snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.recognized
                ? "Face recognized: ${result.displayName}"
                : "Face not recognized: ${result.message}"),
            backgroundColor: result.recognized ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error in _handlePointer: $e');
      print('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _message = "❌ Error during recognition: $e";
          _step = "initial";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error recognizing face: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Perform check in/out after successful recognition
  Future<void> _performCheckInOut() async {
    if (_step != "recognized" || _isProcessing || _recognizedUserName.isEmpty)
      return;

    setState(() {
      _isProcessing = true;
      _message = "Recording attendance...";
    });

    try {
// Capture image for attendance record with multiple attempts
      Uint8List? imageBytes;

// Try multiple capture methods
      imageBytes = await _cameraService.captureSimple();
      imageBytes ??= await _cameraService.captureImageAlternative();
      imageBytes ??= await _cameraService.captureImage();

      if (imageBytes == null || imageBytes.isEmpty) {
        setState(() {
          _isProcessing = false;
          _message = "❌ Failed to capture image for attendance";
        });
        return;
      }

      print('Captured attendance image: ${imageBytes.length} bytes');

// Record attendance
      final result = await _aiService.recordAttendance(
          imageBytes, !_isCheckedIn // true for check-in, false for check-out
          );

      print('Attendance result: $result');

      if (mounted) {
        if (result['success']) {
          setState(() {
            _isCheckedIn = !_isCheckedIn;
            _lastCheckTime = DateFormat('HH:mm:ss').format(_currentTime);
            _checkType = _isCheckedIn ? "in" : "out";
            _isProcessing = false;
            _message = "";

// Reset face detection state for next scan
            _step = "initial";
            _status = "";
            _recognizedUserName = "";
          });

// Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        } else {
          setState(() {
            _isProcessing = false;
            _message = "❌ ${result['message']}";
          });

// Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _performCheckInOut: $e');

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _message = "❌ Error recording attendance: $e";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error recording attendance: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _navigateToRegistration() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FaceRegistrationScreen(),
      ),
    );
  }

  void _resetState() {
    setState(() {
      _step = "initial";
      _message = "";
      _status = "";
      _recognizedUserName = "";
      _isProcessing = false;
    });
  }

  /// Debug function to test camera functionality
  Future<void> _testCamera() async {
    setState(() {
      _message = "Testing camera...";
    });

    final success = await _cameraService.testCamera();
    final info = _cameraService.getCameraInfo();

    print('Camera test result: $success');
    print('Camera info: $info');

    setState(() {
      _message = success
          ? "✅ Camera test successful"
          : "❌ Camera test failed - check console for details";
    });

// Show detailed info in a dialog
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Camera Test Results'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Test Result: ${success ? "SUCCESS" : "FAILED"}'),
              const SizedBox(height: 10),
              const Text('Camera Info:'),
              ...info.entries.map((e) => Text('${e.key}: ${e.value}')),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            if (!success)
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _cameraService.reinitializeIfNeeded();
                  setState(() {
                    _message = "Camera reinitialized";
                  });
                },
                child: const Text('Reinitialize'),
              ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

// Format current time
    final formattedTime = DateFormat('HH:mm:ss').format(_currentTime);
    final formattedDate = DateFormat('EEEE, MMMM d, yyyy').format(_currentTime);

    return ResponsiveNavigationScaffold(
      selectedIndex: _selectedIndex,
      onItemTapped: _onItemTapped,
      body: SafeArea(
        child: Column(
          children: [
// Header
            UserProfileHeader(
              isHeaderVisible: _isHeaderVisible,
            ),

// Main content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
// Title
                      Text(
                        "Remote Attendance",
                        style: TextStyle(
                          fontSize: screenWidth * 0.06,
                          fontWeight: FontWeight.bold,
                          color: AdaptiveColors.primaryTextColor(context),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.01),

// Current Date and Time
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: AdaptiveColors.cardColor(context),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          boxShadow: [
                            BoxShadow(
                              color: AdaptiveColors.shadowColor(context),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              formattedTime,
                              style: TextStyle(
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                                color: AdaptiveColors.primaryGreen,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.005),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                color:
                                    AdaptiveColors.secondaryTextColor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

// Status indicator
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.01,
                        ),
                        decoration: BoxDecoration(
                          color: _isCheckedIn
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          border: Border.all(
                            color: _isCheckedIn ? Colors.green : Colors.orange,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _isCheckedIn
                                  ? Icons.check_circle
                                  : Icons.info_outline,
                              color:
                                  _isCheckedIn ? Colors.green : Colors.orange,
                            ),
                            SizedBox(width: screenWidth * 0.02),
                            Text(
                              _isCheckedIn
                                  ? "Checked in at $_lastCheckTime"
                                  : _lastCheckTime.isEmpty
                                      ? "Not checked in"
                                      : "Checked out at $_lastCheckTime",
                              style: TextStyle(
                                fontSize: screenWidth * 0.04,
                                fontWeight: FontWeight.bold,
                                color:
                                    _isCheckedIn ? Colors.green : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

// Camera preview
                      Container(
                        width: screenWidth * 0.8,
                        height: screenWidth * 0.8,
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          border: Border.all(
                            color: _step == "recognized"
                                ? Colors.green
                                : AdaptiveColors.borderColor(context),
                            width: _step == "recognized" ? 3 : 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          child: _isCameraInitialized &&
                                  _cameraService.cameraController != null
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
// Camera preview
                                    CameraPreview(
                                        _cameraService.cameraController!),

// Face overlay when recognized
                                    if (_step == "recognized")
                                      Icon(
                                        Icons.face,
                                        size: screenWidth * 0.4,
                                        color: Colors.green.withOpacity(0.5),
                                      ),

// Processing indicator
                                    if (_isProcessing)
                                      Container(
                                        color: Colors.black54,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                                height: screenHeight * 0.02),
                                            Text(
                                              _message,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),

// Face frame guide when not processing
                                    if (!_isProcessing && _step == "initial")
                                      Container(
                                        width: screenWidth * 0.5,
                                        height: screenWidth * 0.5,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),

// Status message display
                                    if (_status.isNotEmpty && !_isProcessing)
                                      Positioned(
                                        bottom: 10,
                                        left: 10,
                                        right: 10,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            _status,
                                            style: const TextStyle(
                                                color: Colors.white),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_message.isEmpty ||
                                          _message == "Initializing camera...")
                                        const CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      if (_message.isNotEmpty) ...[
                                        SizedBox(height: screenHeight * 0.02),
                                        Text(
                                          _message,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

// Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
// Scan face button
                          ElevatedButton.icon(
                            onPressed: _isCameraInitialized &&
                                    !_isProcessing &&
                                    _step == "initial"
                                ? _handlePointer
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                              ),
                            ),
                            icon: const Icon(Icons.face_retouching_natural),
                            label: Text(
                              "🎥 Scan Face",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          SizedBox(width: screenWidth * 0.04),

// Check in/out button
                          ElevatedButton.icon(
                            onPressed: _step == "recognized" && !_isProcessing
                                ? _performCheckInOut
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdaptiveColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.04,
                                vertical: screenHeight * 0.015,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.02),
                              ),
                            ),
                            icon:
                                Icon(_isCheckedIn ? Icons.logout : Icons.login),
                            label: Text(
                              _isCheckedIn ? "Check Out" : "Check In",
                              style: TextStyle(
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.01),

// Additional action buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
// Registration button
                          TextButton.icon(
                            onPressed: _navigateToRegistration,
                            icon: const Icon(Icons.person_add),
                            label: const Text("📷 Register New Face"),
                          ),

                          SizedBox(width: screenWidth * 0.04),

// Reset button
                          if (_step != "initial")
                            TextButton.icon(
                              onPressed: _resetState,
                              icon: const Icon(Icons.refresh),
                              label: const Text("Reset"),
                            ),
                        ],
                      ),

                      SizedBox(height: screenHeight * 0.02),

// Instructions
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: AdaptiveColors.cardColor(context),
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
                          boxShadow: [
                            BoxShadow(
                              color: AdaptiveColors.shadowColor(context),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AdaptiveColors.primaryGreen,
                                  size: screenWidth * 0.05,
                                ),
                                SizedBox(width: screenWidth * 0.02),
                                Text(
                                  "Instructions",
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.045,
                                    fontWeight: FontWeight.bold,
                                    color: AdaptiveColors.primaryTextColor(
                                        context),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            _buildInstructionStep(
                                context,
                                "1",
                                "Position your face within the circle",
                                screenWidth),
                            SizedBox(height: screenHeight * 0.01),
                            _buildInstructionStep(
                                context,
                                "2",
                                "Ensure good lighting for better recognition",
                                screenWidth),
                            SizedBox(height: screenHeight * 0.01),
                            _buildInstructionStep(context, "3",
                                "Press 'Scan Face' to recognize", screenWidth),
                            SizedBox(height: screenHeight * 0.01),
                            _buildInstructionStep(
                                context,
                                "4",
                                "Once recognized, press 'Check In/Out'",
                                screenWidth),
                          ],
                        ),
                      ),

// Last check records
                      SizedBox(height: screenHeight * 0.02),
                      if (_lastCheckTime.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(screenWidth * 0.04),
                          decoration: BoxDecoration(
                            color: AdaptiveColors.cardColor(context),
                            borderRadius:
                                BorderRadius.circular(screenWidth * 0.02),
                            boxShadow: [
                              BoxShadow(
                                color: AdaptiveColors.shadowColor(context),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.history,
                                    color: AdaptiveColors.primaryGreen,
                                    size: screenWidth * 0.05,
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Text(
                                    "Recent Activity",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: AdaptiveColors.primaryTextColor(
                                          context),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Today",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: AdaptiveColors.secondaryTextColor(
                                          context),
                                    ),
                                  ),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      color: AdaptiveColors.secondaryTextColor(
                                          context),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Last ${_isCheckedIn ? "Check In" : "Check Out"}",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.w500,
                                      color: AdaptiveColors.primaryTextColor(
                                          context),
                                    ),
                                  ),
                                  Text(
                                    _lastCheckTime,
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: _isCheckedIn
                                          ? Colors.green
                                          : Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              if (_recognizedUserName.isNotEmpty)
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: screenHeight * 0.01),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "User",
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w500,
                                          color:
                                              AdaptiveColors.primaryTextColor(
                                                  context),
                                        ),
                                      ),
                                      Text(
                                        _recognizedUserName,
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              AdaptiveColors.primaryTextColor(
                                                  context),
                                        ),
                                      ),
                                    ],
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
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(
      BuildContext context, String step, String text, double screenWidth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: screenWidth * 0.06,
          height: screenWidth * 0.06,
          decoration: BoxDecoration(
            color: AdaptiveColors.primaryGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: TextStyle(
                fontSize: screenWidth * 0.035,
                fontWeight: FontWeight.bold,
                color: AdaptiveColors.primaryGreen,
              ),
            ),
          ),
        ),
        SizedBox(width: screenWidth * 0.02),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AdaptiveColors.primaryTextColor(context),
            ),
          ),
        ),
      ],
    );
  }
}
