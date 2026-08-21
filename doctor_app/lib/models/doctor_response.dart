import 'doctor.dart';

class DoctorResponse {
  final int id;
  final int caseId;
  final Doctor doctor;
  final String diagnosis;
  final String treatmentPlan;
  final String? notes;
  final String? diagnosisTranslated;
  final String? treatmentPlanTranslated;
  final String? notesTranslated;
  final String responseLanguage;
  final String? responseFile;
  final String? responseVideo;
  final DateTime createdAt;
  final List<ResponseAttachment> attachments;

  DoctorResponse({
    required this.id,
    required this.caseId,
    required this.doctor,
    required this.diagnosis,
    required this.treatmentPlan,
    this.notes,
    this.diagnosisTranslated,
    this.treatmentPlanTranslated,
    this.notesTranslated,
    required this.responseLanguage,
    this.responseFile,
    this.responseVideo,
    required this.createdAt,
    required this.attachments,
  });

  factory DoctorResponse.fromJson(Map<String, dynamic> json) {
    return DoctorResponse(
      id: json['id'],
      caseId: json['case'],
      doctor: Doctor.fromJson(json['doctor']),
      diagnosis: json['diagnosis'],
      treatmentPlan: json['treatment_plan'],
      notes: json['notes'],
      diagnosisTranslated: json['diagnosis_translated'],
      treatmentPlanTranslated: json['treatment_plan_translated'],
      notesTranslated: json['notes_translated'],
      responseLanguage: json['response_language'],
      responseFile: json['response_file'],
      responseVideo: json['response_video'],
      createdAt: DateTime.parse(json['created_at']),
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => ResponseAttachment.fromJson(attachment))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'case': caseId,
      'doctor': doctor.toJson(),
      'diagnosis': diagnosis,
      'treatment_plan': treatmentPlan,
      'notes': notes,
      'diagnosis_translated': diagnosisTranslated,
      'treatment_plan_translated': treatmentPlanTranslated,
      'notes_translated': notesTranslated,
      'response_language': responseLanguage,
      'response_file': responseFile,
      'response_video': responseVideo,
      'created_at': createdAt.toIso8601String(),
      'attachments':
          attachments.map((attachment) => attachment.toJson()).toList(),
    };
  }

  bool get hasFile => responseFile != null && responseFile!.isNotEmpty;
  bool get hasVideo => responseVideo != null && responseVideo!.isNotEmpty;
  bool get hasAttachments => attachments.isNotEmpty;
}

class ResponseAttachment {
  final int id;
  final int responseId;
  final String file;
  final String fileType;
  final DateTime uploadedAt;

  ResponseAttachment({
    required this.id,
    required this.responseId,
    required this.file,
    required this.fileType,
    required this.uploadedAt,
  });

  factory ResponseAttachment.fromJson(Map<String, dynamic> json) {
    return ResponseAttachment(
      id: json['id'],
      responseId: json['response'],
      file: json['file'],
      fileType: json['file_type'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'response': responseId,
      'file': file,
      'file_type': fileType,
      'uploaded_at': uploadedAt.toIso8601String(),
    };
  }

  bool get isImage => fileType == 'image';
  bool get isPdf => fileType == 'pdf';
  bool get isVideo => fileType == 'video';
  bool get isOther => fileType == 'other';
}
