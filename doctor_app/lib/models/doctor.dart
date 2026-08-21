import 'user.dart';

class Doctor {
  final int id;
  final User user;
  final String specialization;
  final String licenseNumber;
  final String licenseImage;
  final String country;
  final String bio;
  final int experienceYears;
  final double consultationFee;
  final double emergencyFee;
  final double followUpFee;
  final String currency;
  final bool acceptsInsurance;
  final double rating;
  final int totalReviews;
  final String status;
  final bool isAvailable;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Add getter for profilePicture
  String? get profilePicture => user.profilePicture;

  // Add getter for phoneNumber
  String? get phoneNumber => user.phoneNumber;

  Doctor({
    required this.id,
    required this.user,
    required this.specialization,
    required this.licenseNumber,
    required this.licenseImage,
    required this.country,
    required this.bio,
    required this.experienceYears,
    required this.consultationFee,
    required this.emergencyFee,
    required this.followUpFee,
    required this.currency,
    required this.acceptsInsurance,
    required this.rating,
    required this.totalReviews,
    required this.status,
    required this.isAvailable,
    required this.preferredLanguage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      user: User.fromJson(json['user']),
      specialization: json['specialization'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      licenseImage: json['license_image'] ?? '',
      country: json['country'] ?? '',
      bio: json['bio'] ?? '',
      experienceYears: json['experience_years'] ?? 0,
      consultationFee:
          double.tryParse(json['consultation_fee']?.toString() ?? '0') ?? 0.0,
      emergencyFee:
          double.tryParse(json['emergency_fee']?.toString() ?? '0') ?? 0.0,
      followUpFee:
          double.tryParse(json['follow_up_fee']?.toString() ?? '0') ?? 0.0,
      currency: json['currency'] ?? 'USD',
      acceptsInsurance: json['accepts_insurance'] ?? false,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      totalReviews: json['total_reviews'] ?? 0,
      status: json['status'] ?? 'pending',
      isAvailable: json['is_available'] ?? false,
      preferredLanguage: json['preferred_language'] ?? 'ar',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'specialization': specialization,
      'license_number': licenseNumber,
      'license_image': licenseImage,
      'country': country,
      'bio': bio,
      'experience_years': experienceYears,
      'consultation_fee': consultationFee,
      'emergency_fee': emergencyFee,
      'follow_up_fee': followUpFee,
      'currency': currency,
      'accepts_insurance': acceptsInsurance,
      'rating': rating,
      'total_reviews': totalReviews,
      'status': status,
      'is_available': isAvailable,
      'preferred_language': preferredLanguage,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayName => 'د. ${user.fullName}';

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isRejected => status == 'rejected';

  String getSpecializationDisplay() {
    switch (specialization) {
      case 'general':
        return 'طب عام';
      case 'cardiology':
        return 'أمراض القلب';
      case 'dermatology':
        return 'الأمراض الجلدية';
      case 'neurology':
        return 'الأمراض العصبية';
      case 'orthopedics':
        return 'العظام';
      case 'pediatrics':
        return 'طب الأطفال';
      case 'psychiatry':
        return 'الطب النفسي';
      case 'gynecology':
        return 'أمراض النساء';
      case 'urology':
        return 'المسالك البولية';
      case 'ophthalmology':
        return 'طب العيون';
      case 'ent':
        return 'الأنف والأذن والحنجرة';
      case 'dentistry':
        return 'طب الأسنان';
      default:
        return specialization;
    }
  }
}
