class ProfileModel {
  final int id;
  final String firstName;
  final String lastName;
  final String? companyId;
  final String? designation;
  final bool active;
  final String? type;
  final Map<String, dynamic>? attributes;
  final String username;
  final String email;
  final String? personalEmail;
  final String? phoneNumber;
  final String? address;
  final String? birthDate;
  final String? recruitmentDate;
  final String role;
  final String? gender;
  final String? maritalStatus;
  final String locale;
  final bool secondFactorEnabled;

  ProfileModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.companyId,
    this.designation,
    required this.active,
    this.type,
    this.attributes,
    required this.username,
    required this.email,
    this.personalEmail,
    this.phoneNumber,
    this.address,
    this.birthDate,
    this.recruitmentDate,
    required this.role,
    this.gender,
    this.maritalStatus,
    required this.locale,
    required this.secondFactorEnabled,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      companyId: json['companyId'],
      designation: json['designation'],
      active: json['active'] ?? true,
      type: json['type'],
      attributes: json['attributes'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      personalEmail: json['personalEmail'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      birthDate: json['birthDate'],
      recruitmentDate: json['recruitmentDate'],
      role: json['role'] ?? 'USER',
      gender: json['gender'],
      maritalStatus: json['maritalStatus'],
      locale: json['locale'] ?? 'en',
      secondFactorEnabled: json['secondFactorEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'companyId': companyId,
      'designation': designation,
      'active': active,
      'type': type,
      'attributes': attributes,
      'username': username,
      'email': email,
      'personalEmail': personalEmail,
      'phoneNumber': phoneNumber,
      'address': address,
      'birthDate': birthDate,
      'recruitmentDate': recruitmentDate,
      'role': role,
      'gender': gender,
      'maritalStatus': maritalStatus,
      'locale': locale,
      'secondFactorEnabled': secondFactorEnabled,
    };
  }

  // Create a copy with updated fields
  ProfileModel copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? companyId,
    String? designation,
    bool? active,
    String? type,
    Map<String, dynamic>? attributes,
    String? username,
    String? email,
    String? personalEmail,
    String? phoneNumber,
    String? address,
    String? birthDate,
    String? recruitmentDate,
    String? role,
    String? gender,
    String? maritalStatus,
    String? locale,
    bool? secondFactorEnabled,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyId: companyId ?? this.companyId,
      designation: designation ?? this.designation,
      active: active ?? this.active,
      type: type ?? this.type,
      attributes: attributes ?? this.attributes,
      username: username ?? this.username,
      email: email ?? this.email,
      personalEmail: personalEmail ?? this.personalEmail,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      recruitmentDate: recruitmentDate ?? this.recruitmentDate,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      locale: locale ?? this.locale,
      secondFactorEnabled: secondFactorEnabled ?? this.secondFactorEnabled,
    );
  }
}