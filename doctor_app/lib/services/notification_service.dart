import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:rxdart/rxdart.dart';

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String> behaviorSubject = BehaviorSubject<String>();

  // تهيئة خدمة الإشعارات
  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
      onDidReceiveLocalNotification: onDidReceiveLocalNotification,
    );

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    tz.initializeTimeZones();

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        onSelectNotification(notificationResponse.payload);
      },
    );
  }

  // معالجة النقر على الإشعار في iOS
  Future<void> onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // عرض حوار للمستخدم عند تلقي إشعار في iOS
    behaviorSubject.add(payload ?? '');
  }

  // معالجة النقر على الإشعار
  void onSelectNotification(String? payload) {
    if (payload != null) {
      behaviorSubject.add(payload);
    }
  }

  // إظهار إشعار فوري
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'medical_app_channel',
      'Medical App Notifications',
      channelDescription: 'Notifications for medical app',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // جدولة إشعار مستقبلي
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medical_app_channel',
          'Medical App Notifications',
          channelDescription: 'Notifications for medical app',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // إلغاء إشعار مجدول
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // إلغاء جميع الإشعارات
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // إظهار إشعار للحالة الطبية الجديدة
  Future<void> showNewCaseNotification(String caseTitle, String patientName) async {
    await showNotification(
      id: 1,
      title: 'حالة طبية جديدة',
      body: 'لديك حالة جديدة من المريض $patientName: $caseTitle',
      payload: 'new_case',
    );
  }

  // إظهار إشعار للاستجابة على حالة
  Future<void> showCaseResponseNotification(String doctorName) async {
    await showNotification(
      id: 2,
      title: 'استجابة على حالتك الطبية',
      body: 'الدكتور $doctorName قدم استجابة على حالتك الطبية',
      payload: 'case_response',
    );
  }

  // إظهار إشعار للموعد القادم
  Future<void> showAppointmentReminder(String appointmentDetails) async {
    await showNotification(
      id: 3,
      title: 'تذكير بموعد',
      body: 'لديك موعد قريب: $appointmentDetails',
      payload: 'appointment_reminder',
    );
  }

  // جدولة تذكير يومي لتناول الدواء
  Future<void> scheduleMedicationReminder(
    String medicationName,
    TimeOfDay time,
  ) async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // إذا كان الوقت قد مر، جدوله لليوم التالي
    if (scheduledTime.isBefore(now)) {
      scheduledTime.add(const Duration(days: 1));
    }

    await scheduleNotification(
      id: medicationName.hashCode,
      title: 'تذكير بالدواء',
      body: 'حان وقت تناول دواء: $medicationName',
      scheduledTime: scheduledTime,
      payload: 'medication_reminder',
    );
  }
}
