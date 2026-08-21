import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<ConnectivityResult> _connectivityController =
      StreamController<ConnectivityResult>.broadcast();

  Stream<ConnectivityResult> get connectivityStream =>
      _connectivityController.stream;

  ConnectivityResult? _lastResult;
  bool _hasShownOfflineMessage = false;

  // تهيئة خدمة الاتصال
  void initialize() {
    _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      _lastResult = result;
      _connectivityController.add(result);

      // إظهار رسالة عند فقدان الاتصال
      if (result == ConnectivityResult.none && !_hasShownOfflineMessage) {
        _hasShownOfflineMessage = true;
      } else if (result != ConnectivityResult.none && _hasShownOfflineMessage) {
        _hasShownOfflineMessage = false;
      }
    });
  }

  // التحقق من وجود اتصال بالإنترنت
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // الحصول على حالة الاتصال الحالية
  ConnectivityResult? get currentStatus => _lastResult;

  // التحقق من وجود اتصال بالإنترنت مع إمكانية إظهار رسالة
  Future<bool> checkConnectionWithMessage(BuildContext context) async {
    final connected = await isConnected();

    if (!connected && !_hasShownOfflineMessage) {
      _hasShownOfflineMessage = true;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد اتصال بالإنترنت. يتم العمل في وضع عدم الاتصال.'),
          duration: Duration(seconds: 5),
        ),
      );
    } else if (connected && _hasShownOfflineMessage) {
      _hasShownOfflineMessage = false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم استعادة الاتصال بالإنترنت.'),
          duration: Duration(seconds: 3),
        ),
      );
    }

    return connected;
  }

  // إغلاق الخدمة
  void dispose() {
    _connectivityController.close();
  }
}

// ويدجت للتعامل مع حالة الاتصال
class ConnectivityBuilder extends StatelessWidget {
  final Widget Function(BuildContext, bool) builder;
  final Widget? offlineWidget;

  const ConnectivityBuilder({
    Key? key,
    required this.builder,
    this.offlineWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final connectivityService = ConnectivityService();

    return StreamBuilder<ConnectivityResult>(
      stream: connectivityService.connectivityStream,
      builder: (context, snapshot) {
        final isConnected = snapshot.data != ConnectivityResult.none;

        if (!isConnected && offlineWidget != null) {
          return offlineWidget!;
        }

        return builder(context, isConnected);
      },
    );
  }
}
