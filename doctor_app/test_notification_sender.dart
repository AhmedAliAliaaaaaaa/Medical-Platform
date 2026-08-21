import 'package:flutter/material.dart';
import 'package:doctor_app/screens/doctor/dashboard/notification_sender.dart';

void main() {
  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Notification Sender',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NotificationSender(),
    );
  }
}
