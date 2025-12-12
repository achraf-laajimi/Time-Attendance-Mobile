// lib/models/user_model.dart

class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String? avatar;
  final String? firstName;
  final String? lastName;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.avatar,
    this.firstName,
    this.lastName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? json['userName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? json['userRole'] ?? 'employee', // Default to employee if no role is specified
      avatar: json['avatar'] ?? json['profileImage'],
      firstName: json['firstName'] ?? json['first_name'],
      lastName: json['lastName'] ?? json['last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
      'avatar': avatar,
      'firstName': firstName,
      'lastName': lastName,
    };
  }

  // Helper method to get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return "$firstName $lastName";
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }
}