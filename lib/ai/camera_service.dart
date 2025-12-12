import 'dart:typed_data';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  // Singleton instance
  static final CameraService _instance = CameraService._internal();
  factory CameraService() => _instance;
  CameraService._internal();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;

  // Getters
  bool get isInitialized => _isInitialized;
  CameraController? get cameraController => _cameraController;
  List<CameraDescription>? get cameras => _cameras;

  /// Initialize the camera
  Future<bool> initializeCamera({
    CameraLensDirection preferredDirection = CameraLensDirection.front,
    ResolutionPreset resolution = ResolutionPreset.medium,
  }) async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        debugPrint('No cameras available');
        return false;
      }

      // Find preferred camera or use first available
      CameraDescription selectedCamera;
      try {
        selectedCamera = _cameras!.firstWhere(
              (camera) => camera.lensDirection == preferredDirection,
        );
      } catch (e) {
        selectedCamera = _cameras!.first;
        debugPrint('Preferred camera not found, using first available');
      }

      _cameraController = CameraController(
        selectedCamera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();
      _isInitialized = true;
      debugPrint('Camera initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Switch between front and back camera
  Future<bool> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      debugPrint('Cannot switch camera - not enough cameras available');
      return false;
    }

    try {
      final currentDirection = _cameraController?.description.lensDirection;
      CameraLensDirection newDirection;

      if (currentDirection == CameraLensDirection.front) {
        newDirection = CameraLensDirection.back;
      } else {
        newDirection = CameraLensDirection.front;
      }

      // Dispose current controller
      await dispose();

      // Initialize with new direction
      return await initializeCamera(preferredDirection: newDirection);
    } catch (e) {
      debugPrint('Error switching camera: $e');
      return false;
    }
  }

  /// Dispose the camera controller
  Future<void> dispose() async {
    try {
      if (_cameraController != null) {
        if (_cameraController!.value.isInitialized) {
          await _cameraController!.dispose();
        }
        _cameraController = null;
      }
      _isInitialized = false;
      debugPrint('Camera disposed successfully');
    } catch (e) {
      debugPrint('Error disposing camera: $e');
    }
  }

  /// Capture an image and return it as bytes - FIXED VERSION
  Future<Uint8List?> captureImage() async {
    if (!_isInitialized || _cameraController == null) {
      debugPrint('Camera not initialized');
      return null;
    }

    if (!_cameraController!.value.isInitialized) {
      debugPrint('Camera controller not initialized');
      return null;
    }

    try {
      debugPrint('Taking picture...');
      final XFile image = await _cameraController!.takePicture();
      debugPrint('Picture taken: ${image.path}');

      // Convert XFile to bytes
      final Uint8List bytes = await image.readAsBytes();
      debugPrint('Image converted to bytes: ${bytes.length} bytes');

      // Clean up the temporary file
      try {
        final File imageFile = File(image.path);
        if (await imageFile.exists()) {
          await imageFile.delete();
          debugPrint('Temporary file deleted');
        }
      } catch (e) {
        debugPrint('Warning: Could not delete temporary file: $e');
      }

      return bytes;
    } catch (e) {
      debugPrint('Error capturing image: $e');
      // Print the full error details
      debugPrint('Error type: ${e.runtimeType}');
      debugPrint('Error string: ${e.toString()}');
      return null;
    }
  }

  /// Alternative capture method using different approach
  Future<Uint8List?> captureImageAlternative() async {
    if (!_isInitialized || _cameraController == null) {
      debugPrint('Camera not initialized');
      return null;
    }

    try {
      debugPrint('Taking picture with alternative method...');

      // Ensure camera is ready
      if (!_cameraController!.value.isInitialized) {
        debugPrint('Camera not ready, reinitializing...');
        await _cameraController!.initialize();
      }

      final XFile picture = await _cameraController!.takePicture();
      debugPrint('Picture path: ${picture.path}');

      // Read file directly
      final File file = File(picture.path);
      if (!await file.exists()) {
        debugPrint('Picture file does not exist');
        return null;
      }

      final List<int> imageBytes = await file.readAsBytes();
      final Uint8List bytes = Uint8List.fromList(imageBytes);

      debugPrint('Image bytes length: ${bytes.length}');

      // Clean up
      try {
        await file.delete();
      } catch (e) {
        debugPrint('Could not delete temp file: $e');
      }

      return bytes;
    } catch (e) {
      debugPrint('Alternative capture error: $e');
      return null;
    }
  }

  /// Capture multiple images with a delay between captures
  Future<List<Uint8List>> captureMultipleImages(
      int count,
      Duration delay, {
        Function(int current, int total)? onProgress,
      }) async {
    List<Uint8List> images = [];

    for (int i = 0; i < count; i++) {
      try {
        onProgress?.call(i + 1, count);

        // Try primary method first, then alternative
        Uint8List? image = await captureImage();
        image ??= await captureImageAlternative();

        if (image != null) {
          images.add(image);
          debugPrint('Captured image ${i + 1}/$count (${image.length} bytes)');
        } else {
          debugPrint('Failed to capture image ${i + 1}/$count');
        }

        // Wait for the specified delay before capturing the next image
        if (i < count - 1) {
          await Future.delayed(delay);
        }
      } catch (e) {
        debugPrint('Error capturing image $i: $e');
      }
    }

    return images;
  }

  /// Test camera functionality
  Future<bool> testCamera() async {
    try {
      debugPrint('Testing camera functionality...');

      if (!_isInitialized) {
        debugPrint('Camera not initialized, initializing now...');
        final success = await initializeCamera();
        if (!success) {
          debugPrint('Camera initialization failed');
          return false;
        }
      }

      debugPrint('Camera state: initialized=${_cameraController?.value.isInitialized}');
      debugPrint('Camera preview size: ${_cameraController?.value.previewSize}');

      // Try to capture a test image
      final testImage = await captureImage();
      if (testImage != null) {
        debugPrint('Test capture successful: ${testImage.length} bytes');
        return true;
      } else {
        debugPrint('Test capture failed');
        return false;
      }
    } catch (e) {
      debugPrint('Camera test error: $e');
      return false;
    }
  }

  /// Get camera info
  Map<String, dynamic> getCameraInfo() {
    return {
      'isInitialized': _isInitialized,
      'controllerInitialized': _cameraController?.value.isInitialized ?? false,
      'cameraCount': _cameras?.length ?? 0,
      'currentDirection': _cameraController?.description.lensDirection.toString(),
      'previewSize': _cameraController?.value.previewSize.toString(),
      'hasError': _cameraController?.value.hasError ?? false,
      'errorDescription': _cameraController?.value.errorDescription,
    };
  }

  /// Reinitialize camera if needed
  Future<bool> reinitializeIfNeeded() async {
    try {
      if (!_isInitialized || _cameraController == null || !_cameraController!.value.isInitialized) {
        debugPrint('Camera needs reinitialization');
        await dispose();
        return await initializeCamera();
      }
      return true;
    } catch (e) {
      debugPrint('Error reinitializing camera: $e');
      return false;
    }
  }

  /// Simple capture method for debugging
  Future<Uint8List?> captureSimple() async {
    debugPrint('=== Starting simple capture ===');

    try {
      // Check camera state
      final info = getCameraInfo();
      debugPrint('Camera info: $info');

      if (!_isInitialized || _cameraController == null) {
        debugPrint('Camera not initialized, attempting to initialize...');
        final success = await initializeCamera();
        if (!success) {
          debugPrint('Failed to initialize camera');
          return null;
        }
      }

      if (!_cameraController!.value.isInitialized) {
        debugPrint('Controller not initialized, waiting...');
        await Future.delayed(const Duration(milliseconds: 500));

        if (!_cameraController!.value.isInitialized) {
          debugPrint('Controller still not ready after wait');
          return null;
        }
      }

      debugPrint('Taking picture...');
      final XFile file = await _cameraController!.takePicture();
      debugPrint('Picture taken successfully: ${file.path}');

      final bytes = await file.readAsBytes();
      debugPrint('Bytes read: ${bytes.length}');

      // Cleanup
      try {
        await File(file.path).delete();
      } catch (e) {
        debugPrint('Cleanup warning: $e');
      }

      return bytes;
    } catch (e, stackTrace) {
      debugPrint('Simple capture error: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
}