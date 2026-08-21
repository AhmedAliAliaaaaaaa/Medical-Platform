// ملف تجميع لجميع خدمات API
// يوفر واجهة موحدة للوصول لجميع الخدمات

export 'base_api_service.dart';
export 'auth_api_service.dart';
export 'patient_api_service.dart';
export 'doctor_api_service.dart';
export 'notification_api_service.dart';
export 'admin_api_service.dart';

// للتوافق مع الكود الموجود، نوفر واجهة مبسطة
import 'dart:io';
import 'base_api_service.dart';
import 'auth_api_service.dart';
import 'patient_api_service.dart';
import 'doctor_api_service.dart';
import 'notification_api_service.dart';
import 'admin_api_service.dart';

class ApiService {
  // ==================== BASE METHODS ====================

  static Future<void> initializeToken() async {
    await BaseApiService.initialize();
    await BaseApiService.initializeToken();
  }

  static Future<void> saveToken(String token) =>
      BaseApiService.saveToken(token);
  static Future<void> removeToken() => BaseApiService.removeToken();
  static bool get isAuthenticated => BaseApiService.isAuthenticated;
  static Future<bool> testConnection() => BaseApiService.testConnection();

  // ==================== USER DATA METHODS ====================

  static Future<String?> getUserType() async {
    return await BaseApiService.getUserType();
  }

  static Future<String?> getUserId() async {
    return await BaseApiService.getUserId();
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    return await BaseApiService.getUserData();
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await BaseApiService.saveUserData(userData);
  }

  // ==================== AUTH METHODS ====================

  static Future<Map<String, dynamic>> login(String username, String password) =>
      AuthApiService.login(username, password);

  static Future<Map<String, dynamic>> registerPatient({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required int age,
    required String gender,
  }) =>
      AuthApiService.registerPatient(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        phone: phone,
        age: age,
        gender: gender,
      );

  static Future<Map<String, dynamic>> registerDoctor({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String phone,
    required String specialization,
    required String country,
    required int experienceYears,
    required String licenseNumber,
    required File licenseImage,
    required double regularConsultationPrice,
    required double emergencyConsultationPrice,
    required double followUpConsultationPrice,
    required String currency,
    bool acceptsInsurance = false,
    File? profileImage,
    String? bio,
  }) =>
      AuthApiService.registerDoctor(
        fullName: fullName,
        username: username,
        email: email,
        password: password,
        phone: phone,
        specialization: specialization,
        country: country,
        experienceYears: experienceYears,
        licenseNumber: licenseNumber,
        licenseImage: licenseImage,
        regularConsultationPrice: regularConsultationPrice,
        emergencyConsultationPrice: emergencyConsultationPrice,
        followUpConsultationPrice: followUpConsultationPrice,
        currency: currency,
        acceptsInsurance: acceptsInsurance,
        profileImage: profileImage,
        bio: bio,
      );

  static Future<void> logout() async {
    await AuthApiService.logout();
  }

  static Future<Map<String, dynamic>> getUserProfile() =>
      AuthApiService.getUserProfile();

  // ==================== PATIENT METHODS ====================

  static Future<Map<String, dynamic>> getPatientDashboard() =>
      PatientApiService.getDashboard();

  static Future<Map<String, dynamic>> getPatientCases({
    String? status,
    int page = 1,
  }) =>
      PatientApiService.getCases(status: status, page: page);

  static Future<Map<String, dynamic>> createMedicalCase({
    required String title,
    required String description,
    required String symptoms,
    required int doctorId,
    required String priority,
  }) =>
      PatientApiService.createCase(
        title: title,
        description: description,
        symptoms: symptoms,
        doctorId: doctorId,
        priority: priority,
      );

  static Future<Map<String, dynamic>> getCaseDetails(int caseId) =>
      PatientApiService.getCaseDetails(caseId);

  static Future<Map<String, dynamic>> rateDoctor({
    required int caseId,
    required int rating,
    required String comment,
  }) =>
      PatientApiService.rateDoctor(
        caseId: caseId,
        rating: rating,
        comment: comment,
      );

  static Future<List<dynamic>> getAvailableDoctors() =>
      PatientApiService.getAvailableDoctors();

  static Future<Map<String, dynamic>> getDoctorProfile(int doctorId) =>
      PatientApiService.getDoctorProfile(doctorId);

  // ==================== DOCTOR METHODS ====================

  static Future<Map<String, dynamic>> getDoctorDashboard() =>
      DoctorApiService.getDashboard();

  static Future<List<dynamic>> getDoctorCases() => DoctorApiService.getCases();

  static Future<Map<String, dynamic>> respondToCase({
    required int caseId,
    required String content,
    required String recommendations,
    String? diagnosis,
    String? treatmentPlan,
    String? notes,
  }) =>
      DoctorApiService.respondToCase(
        caseId: caseId,
        content: content,
        recommendations: recommendations,
        diagnosis: diagnosis,
        treatmentPlan: treatmentPlan,
        notes: notes,
      );

  static Future<Map<String, dynamic>> getDoctorRatings() =>
      DoctorApiService.getRatings();

  // Returns the authenticated doctor's profile
  static Future<Map<String, dynamic>> getMyDoctorProfile() =>
      DoctorApiService.getProfile();

  static Future<Map<String, dynamic>> sendNotificationToPatient({
    required int patientId,
    required String title,
    required String message,
    String type = 'doctor_message',
  }) =>
      DoctorApiService.sendNotificationToPatient(
        patientId: patientId,
        title: title,
        message: message,
        type: type,
      );

  static Future<Map<String, dynamic>> getAllPatientCases() =>
      DoctorApiService.getAllPatientCases();

  // ==================== NOTIFICATION METHODS ====================

  static Future<Map<String, dynamic>> getPatientNotifications({
    bool? isRead,
    int page = 1,
  }) =>
      PatientApiService.getNotifications(isRead: isRead, page: page);

  static Future<Map<String, dynamic>> markNotificationRead(
    int notificationId,
  ) =>
      PatientApiService.markNotificationRead(notificationId);

  static Future<Map<String, dynamic>> markAllNotificationsRead() async {
    final userType = await getUserType();
    if (userType == 'doctor') {
      return NotificationApiService.markAllDoctorNotificationsRead();
    } else {
      return PatientApiService.markAllNotificationsRead();
    }
  }

  static Future<List<dynamic>> getDoctorNotifications() =>
      NotificationApiService.getDoctorNotifications();

  static Future<Map<String, dynamic>> markNotificationAsRead(
    int notificationId,
  ) =>
      NotificationApiService.markAsRead(notificationId);

  static Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    required String notificationType,
    required String recipientType,
    int? recipientId,
  }) =>
      NotificationApiService.sendNotification(
        title: title,
        message: message,
        notificationType: notificationType,
        recipientType: recipientType,
        recipientId: recipientId,
      );

  // ==================== ADMIN METHODS ====================

  static Future<Map<String, dynamic>> getAdminDashboard() =>
      AdminApiService.getDashboard();

  static Future<List<dynamic>> getPendingDoctorApplications() =>
      AdminApiService.getPendingDoctorApplications();

  // إضافة الدالة المفقودة
  static Future<List<dynamic>> getPendingDoctors() =>
      AdminApiService.getPendingDoctorApplications();

  // دالة للحصول على جميع الحالات وإرجاعها بنفس البنية المتوقعة في الشاشة
  static Future<Map<String, dynamic>> getCases() async {
    final cases = await AdminApiService.getAllCases();
    return {'recent_cases': cases};
  }

  static Future<Map<String, dynamic>> approveDoctorApplication({
    required int applicationId,
    String? notes,
  }) =>
      AdminApiService.approveDoctorApplication(
        applicationId: applicationId,
        notes: notes,
      );

  static Future<Map<String, dynamic>> rejectDoctorApplication({
    required int applicationId,
    required String reason,
  }) =>
      AdminApiService.rejectDoctorApplication(
        applicationId: applicationId,
        reason: reason,
      );

  // ==================== PROFILE METHODS ====================

  static Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) =>
      AuthApiService.updateUserProfile(data);

  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      AuthApiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  // ==================== ADDITIONAL METHODS ====================

  // Patient additional methods
  static Future<List<dynamic>> getPendingCases() =>
      PatientApiService.getPendingCases();

  static Future<List<dynamic>> getCompletedCases() =>
      PatientApiService.getCompletedCases();

  // Doctor additional methods
  static Future<List<dynamic>> getNewCases() => DoctorApiService.getNewCases();

  static Future<List<dynamic>> getDoctorCompletedCases() =>
      DoctorApiService.getCompletedCases();

  static Future<List<dynamic>> getPatients() => DoctorApiService.getPatients();

  // Notification additional methods
  static Future<int> getUnreadNotificationsCount(String userType) =>
      NotificationApiService.getUnreadCount(userType);

  static Future<Map<String, dynamic>> markAllNotificationsAsRead(
    String userType,
  ) =>
      NotificationApiService.markAllAsRead(userType);

  // Admin additional methods
  static Future<List<dynamic>> getAllDoctors() =>
      AdminApiService.getAllDoctors();

  static Future<List<dynamic>> getAllPatients() =>
      AdminApiService.getAllPatients();

  static Future<Map<String, dynamic>> getSystemStatistics() =>
      AdminApiService.getSystemStatistics();
}
