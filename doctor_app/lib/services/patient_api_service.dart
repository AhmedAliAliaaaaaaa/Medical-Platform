import 'dart:io';
import 'package:dio/dio.dart';
import 'base_api_service.dart';
import '../core/config/server_settings.dart';

class PatientApiService {
  // Get Patient Notifications
  static Future<Map<String, dynamic>> getNotifications({
    bool? isRead,
    int page = 1,
  }) async {
    Map<String, String> queryParams = {'page': page.toString()};
    if (isRead != null) {
      queryParams['is_read'] = isRead.toString();
    }

    final response = await BaseApiService.get(
      '/patient/notifications/',
      queryParams: queryParams,
    );
    return BaseApiService.handleResponse(response);
  }

  // Mark Notification as Read
  static Future<Map<String, dynamic>> markNotificationRead(
    int notificationId,
  ) async {
    final response = await BaseApiService.post(
      '/patient/notifications/$notificationId/mark-read/',
      {},
    );
    return BaseApiService.handleResponse(response);
  }

  // Mark All Notifications as Read
  static Future<Map<String, dynamic>> markAllNotificationsRead() async {
    final response = await BaseApiService.post(
      '/patient/notifications/mark-all-read/',
      {},
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Patient Dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await BaseApiService.get('/patient/dashboard/');
    return BaseApiService.handleResponse(response);
  }

  // Create Medical Case
  static Future<Map<String, dynamic>> createCase({
    required String title,
    required String description,
    required String symptoms,
    required int doctorId,
    required String priority,
  }) async {
    final response = await BaseApiService.post('/patient/cases/', {
      'title': title,
      'description': description,
      'symptoms': symptoms,
      'doctor_id': doctorId,
      'priority': priority,
    });
    return BaseApiService.handleResponse(response);
  }

  // Upload attachments for a case (multi-part)
  static Future<void> uploadCaseAttachments({
    required int caseId,
    required List<File> files,
  }) async {
    final dio = Dio(BaseOptions(
      baseUrl: BaseApiService.apiUrlSync,
      headers: BaseApiService.fileHeaders,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ));

    final formData = FormData();
    for (final f in files) {
      formData.files.add(MapEntry(
        'files',
        await MultipartFile.fromFile(
          f.path,
          filename: f.path.split(Platform.pathSeparator).last,
        ),
      ));
    }

    final resp =
        await dio.post('/patient/cases/$caseId/attachments/', data: formData);
    if (resp.statusCode == null || resp.statusCode! >= 300) {
      throw Exception('Upload failed with status: ${resp.statusCode}');
    }
  }

  // Get Patient Cases
  static Future<Map<String, dynamic>> getCases({
    String? status,
    int page = 1,
  }) async {
    Map<String, String> queryParams = {'page': page.toString()};
    if (status != null) {
      queryParams['status'] = status;
    }

    final response = await BaseApiService.get(
      '/patient/cases/',
      queryParams: queryParams,
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Case Details
  static Future<Map<String, dynamic>> getCaseDetails(int caseId) async {
    final response = await BaseApiService.get('/patient/cases/$caseId/');
    return BaseApiService.handleResponse(response);
  }

  // Rate Doctor
  static Future<Map<String, dynamic>> rateDoctor({
    required int caseId,
    required int rating,
    required String comment,
  }) async {
    final response = await BaseApiService.post('/patient/cases/$caseId/rate/', {
      'rating': rating,
      'comment': comment,
    });
    return BaseApiService.handleResponse(response);
  }

  // Get Available Doctors
  static Future<List<dynamic>> getAvailableDoctors() async {
    final response = await BaseApiService.get('/doctors/available/');
    final data = BaseApiService.handleResponse(response);
    return data['doctors'] ?? [];
  }

  // Get Doctor Profile
  static Future<Map<String, dynamic>> getDoctorProfile(int doctorId) async {
    final response = await BaseApiService.get('/doctors/$doctorId/');
    return BaseApiService.handleResponse(response);
  }

  // Get Patient Profile
  static Future<Map<String, dynamic>> getProfile() async {
    final response = await BaseApiService.get('/patient/profile/');
    return BaseApiService.handleResponse(response);
  }

  // Update Patient Profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await BaseApiService.put('/patient/profile/', data);
    return BaseApiService.handleResponse(response);
  }

  // Get Patient Statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final response = await BaseApiService.get('/patient/statistics/');
    return BaseApiService.handleResponse(response);
  }

  // Search Doctors
  static Future<List<dynamic>> searchDoctors({
    String? specialization,
    String? name,
    double? minRating,
  }) async {
    Map<String, String> queryParams = {};

    if (specialization != null && specialization.isNotEmpty) {
      queryParams['specialization'] = specialization;
    }
    if (name != null && name.isNotEmpty) {
      queryParams['name'] = name;
    }
    if (minRating != null) {
      queryParams['min_rating'] = minRating.toString();
    }

    final response = await BaseApiService.get(
      '/doctors/search/',
      queryParams: queryParams,
    );
    final data = BaseApiService.handleResponse(response);
    return data['doctors'] ?? [];
  }

  // Get Case History
  static Future<List<dynamic>> getCaseHistory() async {
    final response = await BaseApiService.get('/patient/cases/');
    final data = BaseApiService.handleResponse(response);
    return data['cases'] ?? [];
  }

  // Cancel Case
  static Future<Map<String, dynamic>> cancelCase(int caseId) async {
    final response = await BaseApiService.post(
      '/patient/cases/$caseId/cancel/',
      {},
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Pending Cases
  static Future<List<dynamic>> getPendingCases() async {
    final response = await BaseApiService.get(
      '/patient/cases/',
      queryParams: {'status': 'pending'},
    );
    final data = BaseApiService.handleResponse(response);
    return data['cases'] ?? [];
  }

  // Get Completed Cases
  static Future<List<dynamic>> getCompletedCases() async {
    final response = await BaseApiService.get(
      '/patient/cases/',
      queryParams: {'status': 'answered'},
    );
    final data = BaseApiService.handleResponse(response);
    return data['cases'] ?? [];
  }

  // Get Doctor Ratings
  static Future<List<dynamic>> getDoctorRatings(int doctorId) async {
    final response = await BaseApiService.get('/doctors/$doctorId/ratings/');
    final data = BaseApiService.handleResponse(response);
    return data['ratings'] ?? [];
  }
}
