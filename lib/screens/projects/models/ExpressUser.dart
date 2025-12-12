class ExpressUser {
  final String id;
  final String name;
  final String email;
  final String role;
  final int? matriculeNumber;
  final String? image;
  final String? phoneNumber;
  final String? address;
  final bool isActive;

  ExpressUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.matriculeNumber,
    this.image,
    this.phoneNumber,
    this.address,
    this.isActive = true,
  });

  factory ExpressUser.fromJson(Map<String, dynamic> json) {
    return ExpressUser(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? 'unknown',
      name: json['name']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? 'unknown',
      matriculeNumber: json['matriculeNumber'] is int 
          ? json['matriculeNumber'] 
          : int.tryParse(json['matriculeNumber']?.toString() ?? '0'),
      image: json['image']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      address: json['address']?.toString(),
      isActive: json['isActive'] is bool 
          ? json['isActive'] 
          : json['isActive']?.toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'role': role,
        if (matriculeNumber != null) 'matriculeNumber': matriculeNumber,
        if (image != null) 'image': image,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (address != null) 'address': address,
        'isActive': isActive,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExpressUser && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}