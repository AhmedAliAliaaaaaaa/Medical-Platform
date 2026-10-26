import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/base_api_service.dart';

class ServerSettings {
  // متغيرات ثابتة لعنوان الخادم
  static String _currentServerUrl = 'http://127.0.0.1:8000';
  static String _currentApiUrl = 'http://127.0.0.1:8000/api';
  // تخزين آمن للإعدادات
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // مفتاح التخزين
  static const String _serverUrlKey = 'server_url';

  // القيم الافتراضية
  static const String _defaultServerUrl = 'http://127.0.0.1:8000';
  static const String _androidEmulatorUrl = 'http://192.168.0.194:8000';
  static const String _productionUrl = String.fromEnvironment('API_BASE_URL');

  // الحصول على عنوان الخادم الحالي
  static Future<String> getCurrentServerUrl() async {
    try {
      // محاولة الحصول على عنوان الخادم المخزن
      final storedUrl = await _secureStorage.read(key: _serverUrlKey);

      if (storedUrl != null && storedUrl.isNotEmpty) {
        _currentServerUrl = storedUrl;
        _currentApiUrl = '$storedUrl/api';
        return storedUrl;
      }

      // إذا لم يكن هناك عنوان مخزن، استخدم العنوان الافتراضي حسب المنصة
      final defaultUrl = getDefaultServerUrl();
      _currentServerUrl = defaultUrl;
      _currentApiUrl = '$defaultUrl/api';
      return defaultUrl;
    } catch (e) {
      print('❌ ServerSettings: Error getting server URL: \$e');
      return _defaultServerUrl;
    }
  }

  // الحصول على العنوان الافتراضي حسب المنصة
  static String getDefaultServerUrl() {
    try {
      if (_productionUrl.isNotEmpty) {
        return _productionUrl;
      }
      if (Platform.isAndroid || Platform.isIOS) {
        // على الجهاز الحقيقي: استخدام IP الكمبيوتر المحلي
        // على المحاكي: استخدام 10.0.2.2
        return _androidEmulatorUrl;
      }
    } catch (_) {
      // Platform غير متاح على بعض المنصات (مثل الويب)
    }
    return _defaultServerUrl;
  }

  // حفظ عنوان الخادم
  static Future<void> saveServerUrl(String url) async {
    try {
      await _secureStorage.write(key: _serverUrlKey, value: url);
      print('✅ ServerSettings: Server URL saved: \$url');

      // تحديث المتغيرات الثابتة
      _updateStaticUrls(url);

      // تحديث العناوين في BaseApiService
      try {
        _resetBaseApiServiceUrls();
      } catch (e) {
        print('⚠️ ServerSettings: Could not reset BaseApiService URLs: \$e');
      }
    } catch (e) {
      print('❌ ServerSettings: Error saving server URL: \$e');
      throw Exception('فشل حفظ إعدادات الخادم');
    }
  }

  // استدعاء resetUrls في BaseApiService
  static void _resetBaseApiServiceUrls() {
    try {
      // استدعاء دالة resetUrls بشكل مباشر
      BaseApiService.resetUrls();
      print('✅ ServerSettings: BaseApiService URLs reset successfully');
    } catch (e) {
      print('❌ ServerSettings: Error resetting BaseApiService URLs: \$e');
    }
  }

  // إعادة تعيين عنوان الخادم إلى القيمة الافتراضية
  static Future<void> resetToDefault() async {
    try {
      await _secureStorage.delete(key: _serverUrlKey);
      print('✅ ServerSettings: Server URL reset to default');

      // تحديث العناوين في BaseApiService
      try {
        _resetBaseApiServiceUrls();
      } catch (e) {
        print('⚠️ ServerSettings: Could not reset BaseApiService URLs: \$e');
      }
    } catch (e) {
      print('❌ ServerSettings: Error resetting server URL: \$e');
      throw Exception('فشل إعادة تعيين إعدادات الخادم');
    }
  }

  // الحصول على عنوان API
  static Future<String> getApiUrl() async {
    await getCurrentServerUrl(); // لتحديث المتغيرات الثابتة
    return _currentApiUrl;
  }

  // تحديث المتغيرات الثابتة
  static void _updateStaticUrls(String url) {
    _currentServerUrl = url;
    _currentApiUrl = '$url/api';
  }

  // الحصول على عنوان الخادم الحالي بشكل متزامن
  static String get currentServerUrl => _currentServerUrl;

  // الحصول على عنوان API الحالي بشكل متزامن
  static String get currentApiUrl => _currentApiUrl;

  // التحقق من أن العنوان صالح
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.host.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
