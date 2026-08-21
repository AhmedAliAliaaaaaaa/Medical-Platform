import 'base_api_service.dart';

class NotificationApiService {
  // Get Patient Notifications
  static Future<List<dynamic>> getPatientNotifications() async {
    final response = await BaseApiService.get('/patient/notifications/');
    final data = BaseApiService.handleResponse(response);
    return data['notifications'] ?? [];
  }

  // Get Doctor Notifications
  static Future<List<dynamic>> getDoctorNotifications() async {
    try {
      final response = await BaseApiService.get('/doctor/notifications/');
      final data = BaseApiService.handleResponse(response);
      return data['notifications'] ?? [];
    } catch (e) {
      print(
        '⚠️ NotificationApiService: /doctor/notifications/ endpoint not available',
      );
      // إرجاع قائمة فارغة بدلاً من خطأ
      return [];
    }
  }

  // Get Admin Notifications
  static Future<List<dynamic>> getAdminNotifications() async {
    final response = await BaseApiService.get('/admin/notifications/');
    final data = BaseApiService.handleResponse(response);
    return data['notifications'] ?? [];
  }

  // Mark Notification as Read
  static Future<Map<String, dynamic>> markAsRead(int notificationId) async {
    final response = await BaseApiService.post(
      '/notifications/$notificationId/read/',
      {},
    );
    return BaseApiService.handleResponse(response);
  }

  // Mark All Notifications as Read
  static Future<Map<String, dynamic>> markAllAsRead(String userType) async {
    final response = await BaseApiService.post(
      '/$userType/notifications/mark-all-read/',
      {},
    );
    return BaseApiService.handleResponse(response);
  }

  // Mark All Doctor Notifications as Read
  static Future<Map<String, dynamic>> markAllDoctorNotificationsRead() async {
    final response = await BaseApiService.post(
      '/doctor/notifications/mark-all-read/',
      {},
    );
    return BaseApiService.handleResponse(response);
  }

  // Send Notification
  static Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    required String notificationType,
    required String recipientType,
    int? recipientId,
  }) async {
    final response = await BaseApiService.post('/notifications/send/', {
      'title': title,
      'message': message,
      'notification_type': notificationType,
      'recipient_type': recipientType,
      if (recipientId != null) 'recipient_id': recipientId,
    });
    return BaseApiService.handleResponse(response);
  }

  // Send Notification to Specific User
  static Future<Map<String, dynamic>> sendNotificationToUser({
    required int userId,
    required String userType,
    required String title,
    required String message,
    String notificationType = 'general',
  }) async {
    final response = await BaseApiService.post('/notifications/send-to-user/', {
      'user_id': userId,
      'user_type': userType,
      'title': title,
      'message': message,
      'notification_type': notificationType,
    });
    return BaseApiService.handleResponse(response);
  }

  // Send Broadcast Notification
  static Future<Map<String, dynamic>> sendBroadcastNotification({
    required String title,
    required String message,
    required String targetUserType, // 'patient', 'doctor', 'all'
    String notificationType = 'general',
  }) async {
    final response = await BaseApiService.post('/notifications/broadcast/', {
      'title': title,
      'message': message,
      'target_user_type': targetUserType,
      'notification_type': notificationType,
    });
    return BaseApiService.handleResponse(response);
  }

  // Get Unread Notifications Count
  static Future<int> getUnreadCount(String userType) async {
    final response = await BaseApiService.get(
      '/$userType/notifications/unread-count/',
    );
    final data = BaseApiService.handleResponse(response);
    return data['count'] ?? 0;
  }

  // Delete Notification
  static Future<Map<String, dynamic>> deleteNotification(
    int notificationId,
  ) async {
    final response = await BaseApiService.delete(
      '/notifications/$notificationId/',
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Notification Details
  static Future<Map<String, dynamic>> getNotificationDetails(
    int notificationId,
  ) async {
    final response = await BaseApiService.get(
      '/notifications/$notificationId/',
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Notifications by Type
  static Future<List<dynamic>> getNotificationsByType({
    required String userType,
    required String notificationType,
  }) async {
    final response = await BaseApiService.get(
      '/$userType/notifications/type/$notificationType/',
    );
    final data = BaseApiService.handleResponse(response);
    return data['notifications'] ?? [];
  }

  // Get Recent Notifications
  static Future<List<dynamic>> getRecentNotifications({
    required String userType,
    int limit = 10,
  }) async {
    final response = await BaseApiService.get(
      '/$userType/notifications/recent/',
      queryParams: {'limit': limit.toString()},
    );
    final data = BaseApiService.handleResponse(response);
    return data['notifications'] ?? [];
  }

  // Update Notification Settings
  static Future<Map<String, dynamic>> updateNotificationSettings({
    required String userType,
    required Map<String, bool> settings,
  }) async {
    final response = await BaseApiService.put(
      '/$userType/notification-settings/',
      settings,
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Notification Settings
  static Future<Map<String, dynamic>> getNotificationSettings(
    String userType,
  ) async {
    final response = await BaseApiService.get(
      '/$userType/notification-settings/',
    );
    return BaseApiService.handleResponse(response);
  }

  // Send Case Update Notification
  static Future<Map<String, dynamic>> sendCaseUpdateNotification({
    required int caseId,
    required String updateType, // 'response', 'status_change', 'rating'
    String? customMessage,
  }) async {
    final response = await BaseApiService.post('/notifications/case-update/', {
      'case_id': caseId,
      'update_type': updateType,
      if (customMessage != null) 'custom_message': customMessage,
    });
    return BaseApiService.handleResponse(response);
  }

  // Send Appointment Reminder
  static Future<Map<String, dynamic>> sendAppointmentReminder({
    required int appointmentId,
    required String reminderType, // 'day_before', 'hour_before', '15_minutes'
  }) async {
    final response = await BaseApiService.post(
      '/notifications/appointment-reminder/',
      {'appointment_id': appointmentId, 'reminder_type': reminderType},
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Notification History
  static Future<List<dynamic>> getNotificationHistory({
    required String userType,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int limit = 20,
  }) async {
    Map<String, String> queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (fromDate != null) {
      queryParams['from_date'] = fromDate.toIso8601String().split('T')[0];
    }
    if (toDate != null) {
      queryParams['to_date'] = toDate.toIso8601String().split('T')[0];
    }

    final response = await BaseApiService.get(
      '/$userType/notifications/history/',
      queryParams: queryParams,
    );
    final data = BaseApiService.handleResponse(response);
    return data['notifications'] ?? [];
  }
}
