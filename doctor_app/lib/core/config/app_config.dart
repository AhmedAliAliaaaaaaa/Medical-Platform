import 'dart:io' show Platform;
import 'server_settings.dart';

class AppConfig {
  // إعدادات الخادم
  static const String _defaultBaseUrl =
      'http://127.0.0.1:8000'; // تم تغييره للسيرفر المحلي
  static const String _fallbackUrl =
      'https://api.medical-platform.com'; // السيرفر الاحتياطي

  // إعدادات التطبيق
  static const String appName = 'تطبيق الاستشارات الطبية';
  static const String appVersion = '1.0.0';
  static const bool debugMode = true;

  // إعدادات API
  static const int apiTimeout = 30; // seconds
  static const int maxRetries = 3;

  // إعدادات الملفات
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif'];

  // إعدادات التشفير
  static const String encryptionKey = 'your_encryption_key_here';

  // Getters
  static Future<String> getBaseUrl() async {
    // استخدام ServerSettings للحصول على عنوان الخادم الحالي
    return await ServerSettings.getCurrentServerUrl();
  }

  static Future<String> getApiUrl() async {
    // إذا تم ضبط عنوان مخصص عبر setCustomApiUrl فسنستخدمه كما هو
    if (_customApiUrl != null && _customApiUrl!.isNotEmpty) {
      return _customApiUrl!;
    }
    // استخدام ServerSettings للحصول على عنوان API
    return await ServerSettings.getApiUrl();
  }

  // إعدادات البيئة
  static bool get isProduction => !debugMode;
  static bool get isDevelopment => debugMode;

  // إعدادات الشبكة
  static Duration get timeoutDuration => Duration(seconds: apiTimeout);

  // إعدادات التخزين المحلي
  static const String tokenKey = 'auth_token';
  static const String userTypeKey = 'user_type';
  static const String userIdKey = 'user_id';

  // إعدادات الإشعارات
  static const String fcmServerKey = 'your_fcm_server_key';
  static const bool enablePushNotifications = true;

  // إعدادات قاعدة البيانات المحلية
  static const String dbName = 'medical_app.db';
  static const int dbVersion = 1;

  // إعدادات التحليلات
  static const String googleAnalyticsId = 'your_ga_id';
  static const bool enableAnalytics = false;

  // إعدادات الأمان
  static const bool enableSSLPinning = false;
  static const List<String> trustedCertificates = [];

  // إعدادات التطبيق حسب البيئة
  static Map<String, dynamic> getEnvironmentConfig() {
    if (isProduction) {
      return {
        'baseUrl': 'https://your-production-domain.com',
        'apiUrl': 'https://your-production-domain.com/api',
        'enableLogging': false,
        'enableSSL': true,
      };
    } else {
      return {
        'baseUrl': getBaseUrl(),
        'apiUrl': getApiUrl(),
        'enableLogging': true,
        'enableSSL': false,
      };
    }
  }

  // تحديث إعدادات الخادم (للاختبار)
  static String? _customApiUrl;

  static void setCustomApiUrl(String url) {
    _customApiUrl = url;
  }

  static Future<String> getCurrentApiUrl() async {
    return _customApiUrl ?? await ServerSettings.getApiUrl();
  }

  // إعدادات اللغة
  static const String defaultLanguage = 'ar';
  static const List<String> supportedLanguages = ['ar', 'en'];

  // إعدادات الواجهة
  static const bool enableDarkMode = false;
  static const String defaultTheme = 'light';

  // إعدادات الكاش
  static const Duration cacheExpiration = Duration(hours: 24);
  static const int maxCacheSize = 50 * 1024 * 1024; // 50MB
}
