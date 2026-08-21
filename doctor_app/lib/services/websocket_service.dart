// Simple WebSocket client for real-time updates
import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;
import '../core/config/app_config.dart';
import 'base_api_service.dart';
import '../core/config/server_settings.dart';

typedef EventHandler = void Function(Map<String, dynamic> event);

class WebSocketService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  EventHandler? onEvent;
  bool _isConnecting = false;

  Future<void> connect() async {
    if (_isConnecting) return;
    _isConnecting = true;
    try {
      // Ensure token is loaded before connecting
      await BaseApiService.initializeToken();
      final token = BaseApiService.getToken;
      if (token == null || token.isEmpty) {
        _isConnecting = false;
        return;
      }

      final httpBase = ServerSettings.currentServerUrl;
      final isSecure = httpBase.startsWith('https');
      final scheme = isSecure ? 'wss' : 'ws';
      final baseNoScheme = httpBase.replaceFirst(RegExp('^https?://'), '');
      final uri = Uri.parse(
          '$scheme://$baseNoScheme/ws/stream/?token=${Uri.encodeComponent(token)}');

      _channel = WebSocketChannel.connect(uri);
      _subscription = _channel!.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message as String);
            if (data is Map<String, dynamic>) {
              onEvent?.call(data);
            }
          } catch (_) {}
        },
        onError: (_) => _reconnectWithDelay(),
        onDone: _reconnectWithDelay,
        cancelOnError: true,
      );
    } catch (_) {
      _reconnectWithDelay();
    } finally {
      _isConnecting = false;
    }
  }

  void _reconnectWithDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    await disconnect();
    await connect();
  }

  Future<void> disconnect() async {
    try {
      await _subscription?.cancel();
    } catch (_) {}
    try {
      await _channel?.sink.close(status.goingAway);
    } catch (_) {}
    _subscription = null;
    _channel = null;
  }
}
