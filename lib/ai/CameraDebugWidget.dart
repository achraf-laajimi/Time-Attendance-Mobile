import 'package:flutter/material.dart';
import 'package:in_out/ai/camera_service.dart';

class CameraDebugWidget extends StatefulWidget {
  const CameraDebugWidget({super.key});

  @override
  State<CameraDebugWidget> createState() => _CameraDebugWidgetState();
}

class _CameraDebugWidgetState extends State<CameraDebugWidget> {
  final CameraService _cameraService = CameraService();
  String _debugInfo = 'Press "Test Camera" to start debugging';
  bool _isLoading = false;

  Future<void> _testCamera() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing camera...';
    });

    try {
      StringBuffer buffer = StringBuffer();
      buffer.writeln('=== Camera Debug Test ===');

      // Test 1: Camera Info
      buffer.writeln('1. Getting camera info...');
      final info = _cameraService.getCameraInfo();
      info.forEach((key, value) {
        buffer.writeln('   $key: $value');
      });

      // Test 2: Initialize Camera
      buffer.writeln('\n2. Testing camera initialization...');
      final initSuccess = await _cameraService.initializeCamera();
      buffer.writeln('   Initialization: ${initSuccess ? "SUCCESS" : "FAILED"}');

      if (initSuccess) {
        // Test 3: Camera State After Init
        buffer.writeln('\n3. Camera state after initialization...');
        final infoAfterInit = _cameraService.getCameraInfo();
        infoAfterInit.forEach((key, value) {
          buffer.writeln('   $key: $value');
        });

        // Test 4: Simple Capture
        buffer.writeln('\n4. Testing simple capture...');
        final simpleCapture = await _cameraService.captureSimple();
        if (simpleCapture != null) {
          buffer.writeln('   Simple capture: SUCCESS (${simpleCapture.length} bytes)');
        } else {
          buffer.writeln('   Simple capture: FAILED');
        }

        // Test 5: Alternative Capture
        buffer.writeln('\n5. Testing alternative capture...');
        final altCapture = await _cameraService.captureImageAlternative();
        if (altCapture != null) {
          buffer.writeln('   Alternative capture: SUCCESS (${altCapture.length} bytes)');
        } else {
          buffer.writeln('   Alternative capture: FAILED');
        }

        // Test 6: Regular Capture
        buffer.writeln('\n6. Testing regular capture...');
        final regularCapture = await _cameraService.captureImage();
        if (regularCapture != null) {
          buffer.writeln('   Regular capture: SUCCESS (${regularCapture.length} bytes)');
        } else {
          buffer.writeln('   Regular capture: FAILED');
        }
      }

      buffer.writeln('\n=== Debug Test Complete ===');

      setState(() {
        _debugInfo = buffer.toString();
        _isLoading = false;
      });

    } catch (e, stackTrace) {
      setState(() {
        _debugInfo = 'ERROR: $e\n\nStack Trace:\n$stackTrace';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Debug'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testCamera,
                  icon: _isLoading
                      ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2)
                  )
                      : const Icon(Icons.play_arrow),
                  label: Text(_isLoading ? 'Testing...' : 'Test Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _debugInfo = 'Debug info cleared';
                    });
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _debugInfo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
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
    _cameraService.dispose();
    super.dispose();
  }
}