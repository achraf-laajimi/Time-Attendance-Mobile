import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:in_out/ai/recognition_result.dart';

class RemotePointageService {
  // Singleton instance
  static final RemotePointageService _instance = RemotePointageService._internal();
  factory RemotePointageService() => _instance;
  RemotePointageService._internal();

  final String baseUrl = 'http://127.0.0.1:8000';

  /// Collect face data for training
  /// [userId] - User ID
  /// [userName] - User name
  /// [imageBytes] - List of image byte arrays
  Future<String> collectFaceData(int userId, String userName, List<Uint8List> imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/collect/'));

      // Add user fields
      request.fields['user_id'] = userId.toString();
      request.fields['user_name'] = userName;

      // Add image files
      for (int i = 0; i < imageBytes.length; i++) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            imageBytes[i],
            filename: 'face_${i + 1}.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Collect response status: ${response.statusCode}');
      print('Collect response body: $responseBody');

      var jsonResult = json.decode(responseBody);

      if (response.statusCode == 200) {
        return jsonResult['message'] ?? 'Face data collected successfully';
      } else {
        throw Exception(jsonResult['detail'] ?? 'Failed to collect face data');
      }
    } catch (e) {
      print('Error in collectFaceData: $e');
      return 'Error: $e';
    }
  }

  /// Train the face recognition model
  Future<String> trainModel() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/train/'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Train response status: ${response.statusCode}');
      print('Train response body: ${response.body}');

      final jsonResult = json.decode(response.body);

      if (response.statusCode == 200) {
        return jsonResult['message'] ?? 'Model trained successfully';
      } else {
        throw Exception(jsonResult['detail'] ?? 'Failed to train model');
      }
    } catch (e) {
      print('Error in trainModel: $e');
      return 'Error: $e';
    }
  }

  /// Recognize a face from image data (for single image)
  /// [imageBytes] - Image data as bytes
  Future<RecognitionResult> recognizeFace(Uint8List imageBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/recognize/'));

      // Add image file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: 'face.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Recognize response status: ${response.statusCode}');
      print('Recognize response body: $responseBody');

      var jsonResult = json.decode(responseBody);

      if (response.statusCode == 200) {
        return RecognitionResult.fromJson(jsonResult);
      } else {
        return RecognitionResult.error(jsonResult['detail'] ?? 'Failed to recognize face');
      }
    } catch (e) {
      print('Error in recognizeFace: $e');
      return RecognitionResult.error('Error: $e');
    }
  }

  /// Recognize a face from video data (following the web pattern)
  /// [videoBytes] - Video data as bytes
  Future<RecognitionResult> recognizeFaceFromVideo(Uint8List videoBytes) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/recognize/'));

      // Add video file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          videoBytes,
          filename: 'video.webm',
          contentType: MediaType('video', 'webm'),
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      print('Video recognize response status: ${response.statusCode}');
      print('Video recognize response body: $responseBody');

      var jsonResult = json.decode(responseBody);

      if (response.statusCode == 200) {
        return RecognitionResult.fromJson(jsonResult);
      } else {
        return RecognitionResult.error(jsonResult['detail'] ?? 'Failed to recognize face from video');
      }
    } catch (e) {
      print('Error in recognizeFaceFromVideo: $e');
      return RecognitionResult.error('Error: $e');
    }
  }

  /// Delete a user from the face recognition system
  /// [userId] - User ID to delete
  Future<String> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/delete/?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      final jsonResult = json.decode(response.body);

      if (response.statusCode == 200) {
        return jsonResult['message'] ?? 'User deleted successfully';
      } else {
        throw Exception(jsonResult['detail'] ?? 'Failed to delete user');
      }
    } catch (e) {
      print('Error in deleteUser: $e');
      return 'Error: $e';
    }
  }

  /// Register a new user for face recognition (following the web pattern)
  /// [userId] - User ID
  /// [userName] - User name
  /// [imageBytes] - List of image byte arrays (multiple images for better training)
  Future<String> registerUser(int userId, String userName, List<Uint8List> imageBytes) async {
    try {
      print('Starting registration for user $userId: $userName with ${imageBytes.length} images');

      // Step 1: Collect face data
      String collectResult = await collectFaceData(userId, userName, imageBytes);
      print('Collect result: $collectResult');

      if (collectResult.toLowerCase().contains('error')) {
        return collectResult;
      }

      // Step 2: Train the model with the new data
      print('Training model with new face data');
      String trainResult = await trainModel();
      print('Train result: $trainResult');

      // Return combined message
      return 'Registration successful: $collectResult. Training: $trainResult';
    } catch (e) {
      print('Error in registerUser: $e');
      return 'Error registering user: $e';
    }
  }

  /// Capture multiple images with delay (similar to web version)
  /// This should be called from the UI layer
  Future<List<Uint8List>> captureMultipleImagesFromCamera(
      Future<Uint8List?> Function() captureFunction,
      {int count = 10, int delayMs = 300}
      ) async {
    List<Uint8List> images = [];

    for (int i = 0; i < count; i++) {
      try {
        final imageBytes = await captureFunction();
        if (imageBytes != null) {
          images.add(imageBytes);
          print('Captured image ${i + 1}/$count');
        }

        // Add delay between captures (except for the last one)
        if (i < count - 1) {
          await Future.delayed(Duration(milliseconds: delayMs));
        }
      } catch (e) {
        print('Error capturing image ${i + 1}: $e');
      }
    }

    return images;
  }

  /// Record attendance using face recognition
  /// [imageBytes] - Image data as bytes
  /// [isCheckIn] - Whether this is a check-in (true) or check-out (false)
  Future<Map<String, dynamic>> recordAttendance(Uint8List imageBytes, bool isCheckIn) async {
    try {
      // First, recognize the face
      RecognitionResult result = await recognizeFace(imageBytes);

      // If face is recognized
      if (result.recognized && result.userId != null) {
        // Here you would normally send a request to your backend API to record the attendance
        // For now, we'll just return a success response with the user details
        final now = DateTime.now();

        return {
          'success': true,
          'userId': result.userId,
          'userName': result.userName,
          'timestamp': now.toIso8601String(),
          'datetime': now.toString().split('.')[0], // Format similar to web version
          'type': isCheckIn ? 'check_in' : 'check_out',
          'message': '${isCheckIn ? 'Check-in' : 'Check-out'} successful for ${result.userName}',
        };
      } else {
        // Face not recognized
        return {
          'success': false,
          'message': result.message,
        };
      }
    } catch (e) {
      // Error processing request
      print('Error in recordAttendance: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Check server connectivity
  Future<bool> checkServerConnection() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(
        const Duration(seconds: 5),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Server connection check failed: $e');
      return false;
    }
  }
}