import 'base_api_service.dart';

class MessagingApiService {
  static Future<Map<String, dynamic>> getMessages(String userType) async {
    final response = await BaseApiService.get('/$userType/messages/');
    return BaseApiService.handleResponse(response);
  }

  static Future<Map<String, dynamic>> sendMessage({
    required String userType,
    required int recipientId,
    required String subject,
    required String body,
  }) async {
    final response = await BaseApiService.post('/$userType/messages/', {
      'recipient_id': recipientId,
      'subject': subject,
      'body': body,
    });
    return BaseApiService.handleResponse(response);
  }

  static Future<void> markAsRead({
    required String userType,
    required int messageId,
  }) async {
    final response = await BaseApiService.post(
      '/$userType/messages/$messageId/read/',
      {},
    );
    BaseApiService.handleResponse(response);
  }
}
