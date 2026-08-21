import 'base_api_service.dart';

class AdminApiService {
  // Get Admin Dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final response = await BaseApiService.get('/admin/dashboard/');
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.getDashboard fallback: $e');
      return {'success': false, 'widgets': [], 'counts': {}};
    }
  }

  // Get Pending Doctor Applications
  static Future<List<dynamic>> getPendingDoctorApplications() async {
    try {
      final response = await BaseApiService.get('/admin/pending-doctors/');
      final data = BaseApiService.handleResponse(response);
      return data['doctors'] ?? [];
    } catch (e) {
      print('⚠️ AdminApiService.getPendingDoctorApplications fallback: $e');
      return [];
    }
  }

  // Aggregate Doctor Responses for Admin (via completed cases)
  static Future<List<dynamic>> getDoctorResponses() async {
    try {
      // If there is no dedicated endpoint, fallback to all cases and extract responses
      final response = await BaseApiService.get('/admin/cases/');
      final data = BaseApiService.handleResponse(response);
      final cases = (data['cases'] as List?) ?? [];
      final List<dynamic> responses = [];
      for (final c in cases) {
        if (c is Map) {
          final m = Map<String, dynamic>.from(c as Map);
          final caseResponses = (m['responses'] as List?) ?? [];
          for (final r in caseResponses) {
            if (r is Map) {
              final rm = Map<String, dynamic>.from(r as Map);
              rm['case'] = {
                'id': m['id'],
                'title': m['title'],
                'patient': m['patient'],
                'status': m['status'],
              };
              responses.add(rm);
            }
          }
        }
      }
      return responses;
    } catch (e) {
      print('⚠️ AdminApiService.getDoctorResponses fallback: $e');
      return [];
    }
  }

  // Approve Doctor Application
  static Future<Map<String, dynamic>> approveDoctorApplication({
    required int applicationId,
    String? notes,
  }) async {
    try {
      final response = await BaseApiService.post('/admin/approve-doctor/', {
        'application_id': applicationId,
        if (notes != null) 'notes': notes,
      });
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.approveDoctorApplication fallback: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Reject Doctor Application
  static Future<Map<String, dynamic>> rejectDoctorApplication({
    required int applicationId,
    required String reason,
  }) async {
    try {
      final response = await BaseApiService.post('/admin/reject-doctor/', {
        'application_id': applicationId,
        'reason': reason,
      });
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.rejectDoctorApplication fallback: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get All Doctors
  static Future<List<dynamic>> getAllDoctors() async {
    try {
      final response = await BaseApiService.get('/admin/doctors/');
      final data = BaseApiService.handleResponse(response);
      return data['doctors'] ?? [];
    } catch (e) {
      print('⚠️ AdminApiService.getAllDoctors fallback: $e');
      return [];
    }
  }

  // Get Doctor Details
  static Future<Map<String, dynamic>> getDoctorDetails(int doctorId) async {
    try {
      final response = await BaseApiService.get('/admin/doctors/$doctorId/');
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.getDoctorDetails fallback: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Get All Patients
  static Future<List<dynamic>> getAllPatients() async {
    try {
      final response = await BaseApiService.get('/admin/patients/');
      final data = BaseApiService.handleResponse(response);
      return data['patients'] ?? [];
    } catch (e) {
      print('⚠️ AdminApiService.getAllPatients fallback: $e');
      return [];
    }
  }

  // Get Pending Doctors (alias for getPendingDoctorApplications)
  static Future<List<dynamic>> getPendingDoctors() async {
    return getPendingDoctorApplications();
  }

  // Get Doctors (for notifications)
  static Future<Map<String, dynamic>> getDoctors() async {
    try {
      final response = await BaseApiService.get('/admin/doctors/');
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.getDoctors error: $e');
      return {'doctors': []};
    }
  }

  // Get Patients (for notifications)
  static Future<Map<String, dynamic>> getPatients() async {
    try {
      final response = await BaseApiService.get('/admin/patients/');
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.getPatients error: $e');
      return {'patients': []};
    }
  }

  // Approve Doctor (simplified)
  static Future<Map<String, dynamic>> approveDoctor(int doctorId) async {
    try {
      final response = await BaseApiService.post(
        '/admin/doctors/$doctorId/approve/',
        {},
      );
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.approveDoctor fallback: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Reject Doctor (simplified)
  static Future<Map<String, dynamic>> rejectDoctor(int doctorId) async {
    try {
      final response = await BaseApiService.post(
        '/admin/doctors/$doctorId/reject/',
        {},
      );
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.rejectDoctor fallback: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update Doctor Status
  static Future<Map<String, dynamic>> updateDoctorStatus(
    int doctorId,
    String status,
  ) async {
    try {
      final response = await BaseApiService.put(
        '/admin/doctors/$doctorId/status/',
        {'status': status},
      );
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.updateDoctorStatus fallback: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update Doctor Profile (edit doctor details)
  static Future<Map<String, dynamic>> updateDoctor(
    int doctorId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await BaseApiService.put(
        '/admin/doctors/$doctorId/',
        data,
      );
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.updateDoctor fallback: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Delete Doctor
  static Future<Map<String, dynamic>> deleteDoctor(int doctorId) async {
    try {
      final response =
          await BaseApiService.delete('/admin/doctors/$doctorId/delete/');
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('⚠️ AdminApiService.deleteDoctor fallback: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // Update Patient Profile
  static Future<Map<String, dynamic>> updatePatient(
    int patientId,
    Map<String, dynamic> data,
  ) async {
    final response =
        await BaseApiService.put('/admin/patients/$patientId/', data);
    return BaseApiService.handleResponse(response);
  }

  // Delete Patient
  static Future<Map<String, dynamic>> deletePatientAdmin(int patientId) async {
    final response =
        await BaseApiService.delete('/admin/patients/$patientId/delete/');
    return BaseApiService.handleResponse(response);
  }

  // Send Notification to All Users
  static Future<Map<String, dynamic>> sendBroadcastNotification({
    required String title,
    required String message,
    String? userType, // 'patient', 'doctor', or null for all
  }) async {
    final response = await BaseApiService.post(
      '/admin/notifications/broadcast/',
      {
        'title': title,
        'message': message,
        if (userType != null) 'user_type': userType,
      },
    );
    return BaseApiService.handleResponse(response);
  }

  // Get All Cases
  static Future<List<dynamic>> getAllCases() async {
    final response = await BaseApiService.get('/admin/cases/');
    final data = BaseApiService.handleResponse(response);
    return data['cases'] ?? [];
  }

  // Block/Unblock User
  static Future<Map<String, dynamic>> updateUserStatus(
    int userId,
    String userType,
    String status,
  ) async {
    final response = await BaseApiService.put('/admin/users/$userId/status/', {
      'user_type': userType,
      'status': status,
    });
    return BaseApiService.handleResponse(response);
  }

  // Delete User
  static Future<Map<String, dynamic>> deleteUser(
    int userId,
    String userType,
  ) async {
    final response = await BaseApiService.delete(
      '/admin/users/$userId/?user_type=$userType',
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Patient Details
  static Future<Map<String, dynamic>> getPatientDetails(int patientId) async {
    final response = await BaseApiService.get('/admin/patients/$patientId/');
    return BaseApiService.handleResponse(response);
  }

  // Block/Unblock Patient
  static Future<Map<String, dynamic>> updatePatientStatus(
    int patientId,
    String status,
  ) async {
    final response = await BaseApiService.put(
      '/admin/patients/$patientId/status/',
      {'status': status},
    );
    return BaseApiService.handleResponse(response);
  }

  // Delete Patient
  static Future<Map<String, dynamic>> deletePatient(int patientId) async {
    final response = await BaseApiService.delete('/admin/patients/$patientId/');
    return BaseApiService.handleResponse(response);
  }

  // Get Case Details for Admin
  static Future<Map<String, dynamic>> getCaseDetails(int caseId) async {
    final response = await BaseApiService.get('/admin/cases/$caseId/');
    return BaseApiService.handleResponse(response);
  }

  // Update Case Status
  static Future<Map<String, dynamic>> updateCaseStatus(
    int caseId,
    String status,
  ) async {
    final response = await BaseApiService.put('/admin/cases/$caseId/status/', {
      'status': status,
    });
    return BaseApiService.handleResponse(response);
  }

  // Respond to Case (for Admin)
  static Future<Map<String, dynamic>> respondToCase({
    required int caseId,
    required String content,
    required String recommendations,
    String? diagnosis,
    String? treatmentPlan,
    String? notes,
  }) async {
    final response =
        await BaseApiService.post('/admin/cases/$caseId/respond/', {
      'content': content,
      'recommendations': recommendations,
      if (diagnosis != null && diagnosis.isNotEmpty) 'diagnosis': diagnosis,
      if (treatmentPlan != null && treatmentPlan.isNotEmpty)
        'treatment_plan': treatmentPlan,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
    return BaseApiService.handleResponse(response);
  }

  // Rate Doctor (for Admin)
  static Future<Map<String, dynamic>> rateDoctor({
    required int caseId,
    required int rating,
    required String comment,
  }) async {
    final response = await BaseApiService.post('/admin/cases/$caseId/rate/', {
      'rating': rating,
      'comment': comment,
    });
    return BaseApiService.handleResponse(response);
  }

  // Get Notification History
  static Future<List<dynamic>> getNotificationHistory() async {
    final response = await BaseApiService.get('/admin/notifications/history/');
    final data = BaseApiService.handleResponse(response);
    return data['notifications'] ?? [];
  }

  // Get Dashboard Data
  static Future<Map<String, dynamic>> getDashboardData() async {
    final response = await BaseApiService.get('/admin/dashboard/');
    return BaseApiService.handleResponse(response);
  }

  // Send Individual Notification
  static Future<Map<String, dynamic>> sendIndividualNotification({
    required String title,
    required String message,
    required String recipientType,
    required int recipientId,
  }) async {
    final response =
        await BaseApiService.post('/admin/send-individual-notification/', {
      'title': title,
      'message': message,
      'recipient_type': recipientType,
      'recipient_id': recipientId,
    });
    return BaseApiService.handleResponse(response);
  }

  // Get System Statistics
  static Future<Map<String, dynamic>> getSystemStatistics() async {
    try {
      // استخدام بيانات لوحة التحكم مباشرة
      final dashboardData = await getDashboardData();
      return {
        'total_cases': dashboardData['total_cases'] ?? 0,
        'patients_count': dashboardData['patients_count'] ?? 0,
        'approved_doctors': dashboardData['approved_doctors'] ?? 0,
        'total_users': dashboardData['total_users'] ?? 0,
        'pending_doctors': dashboardData['pending_doctors'] ?? 0,
        'completed_cases': dashboardData['completed_cases'] ?? 0,
        'pending_cases': dashboardData['pending_cases'] ?? 0,
      };
    } catch (e) {
      print('⚠️ AdminApiService.getSystemStatistics error: $e');
      // في حالة الفشل، نعيد قيم افتراضية
      return {
        'total_cases': 0,
        'patients_count': 0,
        'approved_doctors': 0,
        'total_users': 0,
        'pending_doctors': 0,
        'completed_cases': 0,
        'pending_cases': 0,
      };
    }
  }
}
