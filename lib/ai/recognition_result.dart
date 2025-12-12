class RecognitionResult {
  final bool recognized;
  final int? userId;
  final String? userName;
  final String? name; // Alternative field name used in some responses
  final String? datetime;
  final String message;

  RecognitionResult({
    required this.recognized,
    this.userId,
    this.userName,
    this.name,
    this.datetime,
    required this.message,
  });

  factory RecognitionResult.fromJson(Map<String, dynamic> json) {
    return RecognitionResult(
      recognized: json['recognized'] ?? false,
      userId: json['user_id'] ?? json['userId'],
      userName: json['user_name'] ?? json['userName'] ?? json['name'],
      name: json['name'],
      datetime: json['datetime'],
      message: json['message'] ?? (json['recognized'] == true
          ? 'Face recognized successfully'
          : 'Face not recognized'),
    );
  }

  factory RecognitionResult.error(String errorMessage) {
    return RecognitionResult(
      recognized: false,
      message: errorMessage,
    );
  }

  factory RecognitionResult.success({
    required int userId,
    required String userName,
    String? datetime,
  }) {
    return RecognitionResult(
      recognized: true,
      userId: userId,
      userName: userName,
      datetime: datetime ?? DateTime.now().toString().split('.')[0],
      message: 'Face recognized successfully',
    );
  }

  // Get the display name (tries different field names)
  String get displayName {
    return userName ?? name ?? 'Unknown User';
  }

  // Get the display datetime
  String get displayDateTime {
    return datetime ?? DateTime.now().toString().split('.')[0];
  }

  Map<String, dynamic> toJson() {
    return {
      'recognized': recognized,
      'user_id': userId,
      'user_name': userName,
      'name': name,
      'datetime': datetime,
      'message': message,
    };
  }

  @override
  String toString() {
    return 'RecognitionResult(recognized: $recognized, userId: $userId, userName: $userName, message: $message)';
  }
}