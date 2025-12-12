class Employee {
  final String? id;
  final String username;
  final String email;
  final String? personalEmail;
  final String phoneNumber;
  final String firstName;
  final String lastName;
  final String password;
  final String role;
  final String? birthDate;
  final String? recruitmentDate;
  final String designation;
  final String gender;
  final String type;
  final String maritalStatus; // Corrected field name
  final String? companyId;
  final String? address;
  final Map<String, dynamic> attributes;
  final bool active; // Changed from enabled to active

  Employee({
    this.id,
    required this.username,
    required this.email,
    this.personalEmail,
    required this.phoneNumber,
    required this.firstName,
    required this.lastName,
    required this.password,
    required this.role,
    this.birthDate,
    this.recruitmentDate,
    required this.designation,
    required this.gender,
    required this.type,
    required this.maritalStatus,
    this.companyId,
    this.address,
    this.attributes = const {},
    this.active = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'personalEmail': personalEmail,
      'username': username,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'password': password,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'birthDate': birthDate,
      'recruitmentDate': recruitmentDate,
      'role': role,
      'type': type,
      'companyId': companyId,
      'designation': designation,
      'address': address,
      'attributes': attributes,
      'active': active,
    };
  }

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString(),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      personalEmail: json['personalEmail'],
      phoneNumber: json['phoneNumber'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'USER',
      birthDate: json['birthDate'],
      recruitmentDate: json['recruitmentDate'],
      designation: json['designation'] ?? '',
      gender: json['gender'] ?? 'MALE',
      type: json['type'] ?? 'OFFICE',
      maritalStatus: json['maritalStatus'] ?? 'SINGLE',
      companyId: json['companyId'],
      address: json['address'],
      attributes: json['attributes'] ?? {},
      active: json['active'] ?? true,
    );
  }

  // Method to create a version for EmployeeProfileScreen
  Map<String, dynamic> toProfileFormat() {
    return {
      'id': id.toString(),
      'name': '$firstName $lastName',
      'avatar': '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}',
      'avatarColor': null,
      'textColor': null,
      'department': 'N/A',
      'designation': designation,
      'type': type,
      'email': email,
      'personalEmail': personalEmail,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate,
      'recruitmentDate': recruitmentDate,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'username': username,
      'companyId': companyId,
      'address': address,
      'active': active,
    };
  }

  String get fullName => '$firstName $lastName';

  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}';
    } else if (firstName.isNotEmpty) {
      return firstName[0];
    } else if (lastName.isNotEmpty) {
      return lastName[0];
    } else {
      return '';
    }
  }
}