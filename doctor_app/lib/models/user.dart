class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String userType;
  final String? phoneNumber;
  final String? profilePicture;
  final String? bio;
  final String? address;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Add role getter for compatibility
  String get role => userType;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.userType,
    this.phoneNumber,
    this.profilePicture,
    this.bio,
    this.address,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      userType: json['user_type'] ?? 'patient',
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      bio: json['bio'],
      address: json['address'],
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'user_type': userType,
      'phone_number': phoneNumber,
      'profile_picture': profilePicture,
      'bio': bio,
      'address': address,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}
