import 'dart:async';
import 'package:doctor_app/services/base_api_service.dart';

/// Simple translation service wrapper.
/// Tries backend first at /utils/translate/ then falls back to echo.
class TranslationService {
  /// targetLang: 'ar' | 'en' | 'zh'
  static Future<String> translateText({
    required String text,
    required String targetLang,
  }) async {
    final String cleaned = text.trim();
    if (cleaned.isEmpty) return '';

    try {
      // Correct backend path is under /api/utils/translate/ and response key is translated_text
      final response = await BaseApiService.post(
        '/utils/translate/',
        {
          'text': cleaned,
          'target_lang': targetLang,
          'use_medical_dict': true,
        },
      );
      final data = BaseApiService.handleResponse(response);
      if (data is Map<String, dynamic>) {
        // Prefer translated_text if present, otherwise try translated
        final String? translated =
            (data['translated_text'] ?? data['translated'])?.toString();
        if (translated != null && translated.isNotEmpty) {
          return translated;
        }
      }
    } catch (e) {
      // Fall through to return original text
    }

    // Fallback: return original text when translation backend is not available
    return cleaned;
  }
}
