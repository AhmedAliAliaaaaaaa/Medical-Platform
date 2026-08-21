import 'patient.dart';
import 'doctor.dart';

class MedicalCase {
  final int id;
  final Patient patient;
  final Doctor? doctor;
  final String title;
  final String description;
  final String? titleTranslated;
  final String? descriptionTranslated;
  final String sourceLanguage;
  final double translationConfidence;
  final String priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? expectedResponseTime;
  final List<CaseAttachment> attachments;

  MedicalCase({
    required this.id,
    required this.patient,
    this.doctor,
    required this.title,
    required this.description,
    this.titleTranslated,
    this.descriptionTranslated,
    required this.sourceLanguage,
    required this.translationConfidence,
    required this.priority,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.expectedResponseTime,
    required this.attachments,
  });

  // Helper getter for doctor name
  String? get doctorName => doctor?.user.fullName;

  factory MedicalCase.fromJson(Map<String, dynamic> json) {
    return MedicalCase(
      id: json['id'],
      patient: Patient.fromJson(json['patient']),
      doctor: json['doctor'] != null ? Doctor.fromJson(json['doctor']) : null,
      title: json['title'] ?? 'حالة طبية',
      description: json['description'] ?? '',
      titleTranslated: json['title_translated'],
      descriptionTranslated: json['description_translated'],
      sourceLanguage: json['source_language'] ?? 'ar',
      translationConfidence:
          json['translation_confidence'] != null
              ? double.parse(json['translation_confidence'].toString())
              : 0.0,
      priority: json['priority'] ?? 'normal',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      expectedResponseTime:
          json['expected_response_time'] != null
              ? DateTime.parse(json['expected_response_time'])
              : null,
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => CaseAttachment.fromJson(attachment))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patient.toJson(),
      'doctor': doctor?.toJson(),
      'title': title,
      'description': description,
      'title_translated': titleTranslated,
      'description_translated': descriptionTranslated,
      'source_language': sourceLanguage,
      'translation_confidence': translationConfidence,
      'priority': priority,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'expected_response_time': expectedResponseTime?.toIso8601String(),
      'attachments':
          attachments.map((attachment) => attachment.toJson()).toList(),
    };
  }

  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  bool get isUrgent => priority == 'urgent';
  bool get isNormal => priority == 'normal';

  String getPriorityDisplay() {
    switch (priority) {
      case 'urgent':
        return 'مستعجلة';
      case 'normal':
        return 'عادية';
      default:
        return priority;
    }
  }

  String getStatusDisplay() {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد المراجعة';
      case 'completed':
        return 'تم الرد';
      case 'cancelled':
        return 'ملغية';
      default:
        return status;
    }
  }
}

class CaseAttachment {
  final int id;
  final int caseId;
  final String file;
  final String fileType;
  final DateTime uploadedAt;

  CaseAttachment({
    required this.id,
    required this.caseId,
    required this.file,
    required this.fileType,
    required this.uploadedAt,
  });

  factory CaseAttachment.fromJson(Map<String, dynamic> json) {
    return CaseAttachment(
      id: json['id'],
      caseId: json['case'],
      file: json['file'],
      fileType: json['file_type'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'case': caseId,
      'file': file,
      'file_type': fileType,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  bool get isImage => fileType == 'image';
  bool get isPdf => fileType == 'pdf';
  bool get isOther => fileType == 'other';
}
