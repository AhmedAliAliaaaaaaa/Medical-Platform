import 'user.dart';

class Patient {
  final int id;
  final User user;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final String? medicalHistory;
  final String? allergies;
  final String? emergencyContact;
  final DateTime createdAt;
  final DateTime updatedAt;

  Patient({
    required this.id,
    required this.user,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.medicalHistory,
    this.allergies,
    this.emergencyContact,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      user: User.fromJson(json['user']),
      dateOfBirth:
          json['date_of_birth'] != null
              ? DateTime.parse(json['date_of_birth'])
              : null,
      gender: json['gender'],
      bloodType: json['blood_type'],
      medicalHistory: json['medical_history'],
      allergies: json['allergies'],
      emergencyContact: json['emergency_contact'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'blood_type': bloodType,
      'medical_history': medicalHistory,
      'allergies': allergies,
      'emergency_contact': emergencyContact,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => user.fullName;
  String get firstName => user.firstName;
  String get lastName => user.lastName;
  String get email => user.email;

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  String getGenderDisplay() {
    switch (gender) {
      case 'male':
        return 'ذكر';
      case 'female':
        return 'أنثى';
      default:
        return gender ?? 'غير محدد';
    }
  }
}
