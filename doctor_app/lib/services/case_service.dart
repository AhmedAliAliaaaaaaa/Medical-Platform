import 'dart:io';

import '../models/medical_case.dart';
import '../models/doctor_response.dart';
import 'doctor_api_service.dart';
import 'patient_api_service.dart';

/// Adapter service to keep CaseProvider stable.
/// It maps high-level case operations to existing API services
/// and normalizes responses to a unified shape containing 'success'.
class CaseService {
  // Get cases assigned to the doctor (or generally visible to the doctor)
  static Future<Map<String, dynamic>> getAssignedCases({
    String? status,
    String? priority,
    int page = 1,
  }) async {
    try {
      final rawCases = await DoctorApiService.getCases();
      List<MedicalCase> cases = [];

      for (final c in rawCases) {
        if (c is Map<String, dynamic>) {
          try {
            cases.add(MedicalCase.fromJson(c));
          } catch (e) {
            print('Error parsing case: $e');
            continue;
          }
        }
      }

      // Client-side filtering since API may not support these filters directly
      if (status != null && status.isNotEmpty) {
        cases = cases.where((e) => e.status == status).toList();
      }
      if (priority != null && priority.isNotEmpty) {
        cases = cases.where((e) => e.priority == priority).toList();
      }

      // No pagination info from API; expose single page
      return {
        'success': true,
        'cases': cases,
        'total': cases.length,
        'hasNext': false,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Create a new case (patient flow)
  static Future<Map<String, dynamic>> createCase({
    required String title,
    required String description,
    required String priority,
    required int doctorId,
    List<File>?
        attachments, // Not handled by current API, kept for compatibility
  }) async {
    try {
      final data = await PatientApiService.createCase(
        title: title,
        description: description,
        symptoms: description, // fallback since symptoms is required by API
        doctorId: doctorId,
        priority: priority,
      );

      // API might return either { case: {...} } or the case object directly
      final caseJson = (data['case'] ?? data) as Map<String, dynamic>;
      final newCase = MedicalCase.fromJson(caseJson);

      return {'success': true, 'case': newCase};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get cases for current doctor (alias for assigned cases to keep provider intact)
  static Future<Map<String, dynamic>> getMyCases({
    String? status,
    String? priority,
    int page = 1,
  }) async {
    return getAssignedCases(status: status, priority: priority, page: page);
  }

  // Load case details
  static Future<Map<String, dynamic>> getCaseDetails(int caseId) async {
    try {
      final data = await DoctorApiService.getCaseDetails(caseId);
      final caseJson = (data['case'] ?? data) as Map<String, dynamic>;
      final medicalCase = MedicalCase.fromJson(caseJson);
      return {'success': true, 'case': medicalCase};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Accept case (not supported by current API — return proper error)
  static Future<Map<String, dynamic>> acceptCase(int caseId) async {
    return {
      'success': false,
      'error': 'Accepting a case is not supported by the current API.',
    };
  }

  // Send response to a case
  static Future<Map<String, dynamic>> sendResponse({
    required int caseId,
    required String diagnosis,
    required String treatmentPlan,
    String? notes,
    String responseLanguage = 'ar', // kept for compatibility
    dynamic responseFile,
    dynamic responseVideo,
    List<File>? attachments, // not supported in current API
  }) async {
    try {
      final data = await DoctorApiService.respondToCase(
        caseId: caseId,
        content: diagnosis, // map to content
        recommendations: treatmentPlan, // map to recommendations
        diagnosis: diagnosis,
        treatmentPlan: treatmentPlan,
        notes: notes,
      );

      final responseJson = (data['response'] ?? data) as Map<String, dynamic>;
      final response = DoctorResponse.fromJson(responseJson);

      return {'success': true, 'response': response};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get doctor's responses (no direct endpoint; return empty set gracefully)
  static Future<Map<String, dynamic>> getMyResponses({int page = 1}) async {
    try {
      // If later an endpoint is added, wire it here
      return {'success': true, 'responses': <DoctorResponse>[], 'next': null};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Get case statistics for doctor
  static Future<Map<String, dynamic>> getCaseStatistics() async {
    try {
      final data = await DoctorApiService.getStatistics();
      return {'success': true, 'statistics': data};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Search cases for doctor
  static Future<Map<String, dynamic>> searchCases({
    String? query,
    String? status,
    String? priority,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
  }) async {
    try {
      final results = await DoctorApiService.searchCases(
        patientName: query,
        status: status,
        priority: priority,
        fromDate: dateFrom,
        toDate: dateTo,
      );

      final cases = results
          .map<MedicalCase>(
            (c) => MedicalCase.fromJson(c as Map<String, dynamic>),
          )
          .toList();

      return {
        'success': true,
        'cases': cases,
        'count': cases.length,
        'next': null,
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
