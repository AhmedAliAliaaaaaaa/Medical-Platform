import 'package:flutter/foundation.dart';
import '../models/notification.dart';
import '../services/notification_api_service.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  bool _isLoading = false;
  String? _error;
  int _unreadCount = 0;

  List<AppNotification> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _unreadCount;

  // Get unread notifications
  List<AppNotification> get unreadNotifications =>
      _notifications.where((notification) => !notification.isRead).toList();

  // Get read notifications
  List<AppNotification> get readNotifications =>
      _notifications.where((notification) => notification.isRead).toList();

  // Get notifications by type
  List<AppNotification> getNotificationsByType(String type) => _notifications
      .where((notification) => notification.type == type)
      .toList();

  // Load notifications
  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final notifications =
          await NotificationApiService.getDoctorNotifications();
      _notifications = notifications
          .map((item) =>
              AppNotification.fromJson(Map<String, dynamic>.from(item)))
          .toList();

      _unreadCount = _notifications.where((n) => !n.isRead).length;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1 && !_notifications[index].isRead) {
        await NotificationApiService.markAsRead(int.parse(notificationId));
        _notifications[index] = _notifications[index].copyWith(isRead: true);
        _unreadCount--;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await NotificationApiService.markAllDoctorNotificationsRead();
      _notifications =
          _notifications.map((n) => n.copyWith(isRead: true)).toList();
      _unreadCount = 0;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Add new notification
  void addNotification(AppNotification notification) {
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  // Remove notification
  void removeNotification(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      if (!_notifications[index].isRead) {
        _unreadCount--;
      }
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    _unreadCount = 0;
    notifyListeners();
  }

  // Add refresh method for compatibility
  Future<void> refresh() async {
    await loadNotifications();
  }
}
