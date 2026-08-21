import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../base_api_service.dart';
import '../../core/config/app_config.dart';
import '../../core/config/server_settings.dart';

/// Generic WebSocket service with auto-reconnect and auth token support
class WsService {
  final String path; // e.g. /ws/admin/dashboard/
  final void Function(Map<String, dynamic> message) onMessage;
  final void Function()? onConnected;
  final void Function()? onDisconnected;
  final Duration reconnectDelay;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;
  bool _manuallyClosed = false;

  WsService({
    required this.path,
    required this.onMessage,
    this.onConnected,
    this.onDisconnected,
    this.reconnectDelay = const Duration(seconds: 3),
  });

  Future<void> connect() async {
    _manuallyClosed = false;
    await _open();
  }

  Future<void> _open() async {
    try {
      await BaseApiService.initializeToken();
      final token = BaseApiService.getToken;

      // Build ws URL based on ServerSettings
      final httpBase = ServerSettings.currentServerUrl;
      final isSecure = httpBase.startsWith('https');
      final scheme = isSecure ? 'wss' : 'ws';
      final baseNoScheme = httpBase.replaceFirst(RegExp('^https?://'), '');
      final url = Uri.parse(
          '$scheme://$baseNoScheme$path?token=${Uri.encodeComponent(token ?? '')}');

      _channel = WebSocketChannel.connect(url);
      _sub = _channel!.stream.listen(
        (event) {
          try {
            final data = event is String ? jsonDecode(event) : event;
            if (data is Map<String, dynamic>) onMessage(data);
          } catch (_) {}
        },
        onDone: _handleClose,
        onError: (e, st) {
          _handleClose();
        },
        cancelOnError: true,
      );
      onConnected?.call();
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _handleClose() {
    onDisconnected?.call();
    if (!_manuallyClosed) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    Future.delayed(reconnectDelay, () {
      if (!_manuallyClosed) {
        _open();
      }
    });
  }

  void send(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }

  Future<void> close() async {
    _manuallyClosed = true;
    await _sub?.cancel();
    await _channel?.sink.close(status.normalClosure);
    _sub = null;
    _channel = null;
  }
}
