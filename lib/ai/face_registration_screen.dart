import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:in_out/ai/remote_pointing_service.dart';
import 'package:in_out/ai/recognition_result.dart';
import 'package:in_out/theme/adaptive_colors.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({super.key});

  @override
  _FaceRegistrationScreenState createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  bool _permissionDenied = false;
  bool _isProcessing = false;
  String _statusMessage = '';
  String _step = 'initial'; // initial, registering, registered, recognition

  final RemotePointageService _aiService = RemotePointageService();

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
    _checkServerConnection();
  }

  Future<void> _checkServerConnection() async {
    final isConnected = await _aiService.checkServerConnection();
    if (!isConnected && mounted) {
      setState(() {
        _statusMessage = '⚠️ Cannot connect to AI server. Please ensure the server is running.';
      });
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();
      if (!mounted) return;
      setState(() => _cameraController = controller);
    } on CameraException catch (e) {
      print('Camera exception: $e');
      setState(() => _permissionDenied = true);
      _showPermissionDeniedDialog();
    } catch (e) {
      print('Error initializing camera: $e');
      setState(() {
        _permissionDenied = true;
        _statusMessage = 'Error initializing camera: $e';
      });
    }
  }

  void _showPermissionDeniedDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Camera access is required to register and recognize faces. Please enable camera permission in settings.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  /// Prompt the user to enter registration details
  Future<Map<String, String>?> _promptForRegistrationDetails() async {
    String name = '';
    String userId = '';

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text("Register New User"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Full Name',
                  labelText: 'Name',
                ),
                onChanged: (val) => name = val,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'User ID',
                  labelText: 'ID',
                ),
                onChanged: (val) => userId = val,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (name.trim().isEmpty || userId.trim().isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Please fill in all fields')),
                );
                return;
              }
              Navigator.of(ctx).pop({
                'name': name.trim(),
                'userId': userId.trim(),
              });
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Capture a single image from camera
  Future<Uint8List?> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return null;
    }

    try {
      final picture = await _cameraController!.takePicture();
      final bytes = await File(picture.path).readAsBytes();
      return bytes;
    } catch (e) {
      print('Error capturing image: $e');
      return null;
    }
  }

  /// Register new user (following web pattern with multiple images)
  Future<void> _onRegister() async {
    if (_cameraController == null || _isProcessing) return;

    // Get registration details
    final details = await _promptForRegistrationDetails();
    if (details == null) return;

    setState(() {
      _isProcessing = true;
      _step = 'registering';
      _statusMessage = '📸 Capturing images...';
    });

    try {
      final userName = details['name']!;
      final userId = int.tryParse(details['userId']!) ?? DateTime.now().millisecondsSinceEpoch;

      // Capture multiple images (similar to web version)
      final images = await _aiService.captureMultipleImagesFromCamera(
        _captureImage,
        count: 10,
        delayMs: 300,
      );

      if (images.isEmpty) {
        setState(() {
          _statusMessage = '❌ Failed to capture images';
          _isProcessing = false;
          _step = 'initial';
        });
        return;
      }

      setState(() {
        _statusMessage = '✅ Captured ${images.length} images. Processing...';
      });

      // Register the user
      final result = await _aiService.registerUser(userId, userName, images);

      setState(() {
        _isProcessing = false;
        if (result.toLowerCase().contains('error')) {
          _statusMessage = '❌ Registration failed: $result';
          _step = 'initial';
        } else {
          _statusMessage = '✅ $result';
          _step = 'registered';
        }
      });

      // Show result in snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result),
            backgroundColor: result.toLowerCase().contains('error') ? Colors.red : Colors.green,
          ),
        );
      }

    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '❌ Error during registration: $e';
        _step = 'initial';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering user: $e')),
        );
      }
    }
  }

  /// Test face recognition
  Future<void> _onRecognize() async {
    if (_cameraController == null || _isProcessing) return;

    setState(() {
      _isProcessing = true;
      _step = 'recognition';
      _statusMessage = '🔍 Recognizing face...';
    });

    try {
      final imageBytes = await _captureImage();
      if (imageBytes == null) {
        setState(() {
          _statusMessage = '❌ Failed to capture image';
          _isProcessing = false;
          _step = 'initial';
        });
        return;
      }

      final result = await _aiService.recognizeFace(imageBytes);

      setState(() {
        _isProcessing = false;
        if (result.recognized && result.displayName.isNotEmpty) {
          _statusMessage = '✅ Recognized: ${result.displayName} at ${result.displayDateTime}';
          _step = 'recognized';
        } else {
          _statusMessage = '❌ Face not recognized';
          _step = 'initial';
        }
      });

      // Show result in snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.recognized
                ? 'Recognized: ${result.displayName}'
                : 'Face not recognized'),
            backgroundColor: result.recognized ? Colors.green : Colors.orange,
          ),
        );
      }

    } catch (e) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '❌ Error during recognition: $e';
        _step = 'initial';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error recognizing face: $e')),
        );
      }
    }
  }

  /// Reset to initial state
  void _onReset() {
    setState(() {
      _step = 'initial';
      _statusMessage = '';
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_permissionDenied) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Face Registration & Recognition'),
          backgroundColor: AdaptiveColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: screenWidth * 0.2,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Camera permission denied. Please enable it in settings.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                if (_statusMessage.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Registration & Recognition'),
        backgroundColor: AdaptiveColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          if (_step != 'initial')
            IconButton(
              onPressed: _onReset,
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset',
            ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              _cameraController == null ||
              !_cameraController!.value.isInitialized) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: screenWidth * 0.2,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to access the camera.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  if (snapshot.hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ],
                ],
              ),
            );
          }

          return Column(
            children: [
              // Camera preview with overlay
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    // Camera preview
                    SizedBox(
                      width: double.infinity,
                      child: CameraPreview(_cameraController!),
                    ),

                    // Processing overlay
                    if (_isProcessing)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),

                    // Face guide overlay
                    if (!_isProcessing)
                      Center(
                        child: Container(
                          width: screenWidth * 0.6,
                          height: screenWidth * 0.6,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _step == 'recognized' ? Colors.green : Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(screenWidth * 0.3),
                          ),
                        ),
                      ),

                    // Step indicator
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getStepIndicator(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Status message
              if (_statusMessage.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: _getStatusColor(),
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Action buttons
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _onRegister,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Register Face'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _onRecognize,
                      icon: const Icon(Icons.face),
                      label: const Text('Recognize Face'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Instructions:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Position your face within the circle\n'
                          '2. Ensure good lighting\n'
                          '3. Use "Register Face" to add a new person\n'
                          '4. Use "Recognize Face" to test recognition',
                      style: TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getStepIndicator() {
    switch (_step) {
      case 'registering':
        return '📸 Registering...';
      case 'registered':
        return '✅ Registration Complete';
      case 'recognition':
        return '🔍 Recognizing...';
      case 'recognized':
        return '✅ Face Recognized';
      default:
        return '📱 Ready for Face Registration';
    }
  }

  Color _getStatusColor() {
    if (_statusMessage.contains('✅')) return Colors.green;
    if (_statusMessage.contains('❌')) return Colors.red;
    if (_statusMessage.contains('⚠️')) return Colors.orange;
    return Colors.blue;
  }
}