import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class CacheService {
  static const String _cacheBoxName = 'app_cache';
  static Box<dynamic>? _cacheBox;
  static bool _isInitialized = false;

  // تهيئة خدمة التخزين المؤقت
  static Future<void> initialize() async {
    if (_isInitialized) return;

    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    }

    // فتح صندوق التخزين المؤقت
    _cacheBox = await Hive.openBox(_cacheBoxName);
    _isInitialized = true;
  }

  // التحقق من وجود مفتاح في التخزين المؤقت
  static bool containsKey(String key) {
    _ensureInitialized();
    return _cacheBox!.containsKey(key);
  }

  // الحصول على قيمة من التخزين المؤقت
  static T? get<T>(String key) {
    _ensureInitialized();
    return _cacheBox!.get(key) as T?;
  }

  // حفظ قيمة في التخزين المؤقت
  static Future<void> put<T>(String key, T value) async {
    _ensureInitialized();
    await _cacheBox!.put(key, value);
  }

  // حذف قيمة من التخزين المؤقت
  static Future<void> delete(String key) async {
    _ensureInitialized();
    await _cacheBox!.delete(key);
  }

  // مسح جميع البيانات من التخزين المؤقت
  static Future<void> clear() async {
    _ensureInitialized();
    await _cacheBox!.clear();
  }

  // الحصول على جميع المفاتيح في التخزين المؤقت
  static Iterable<String> get keys {
    _ensureInitialized();
    return _cacheBox!.keys.cast<String>();
  }

  // التحقق من أن الخدمة مهيأة
  static void _ensureInitialized() {
    if (!_isInitialized || _cacheBox == null) {
      throw StateError('CacheService is not initialized. Call initialize() first.');
    }
  }

  // حفظ بيانات المستخدم في التخزين المؤقت
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    await put('user_data', userData);

    // تعيين وقت انتهاء الصلاحية (24 ساعة من الآن)
    final expiryTime = DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch;
    await put('user_data_expiry', expiryTime);
  }

  // الحصول على بيانات المستخدم من التخزين المؤقت
  static Map<String, dynamic>? getUserData() {
    // التحقق من انتهاء الصلاحية
    final expiryTime = get<int>('user_data_expiry');
    if (expiryTime != null && DateTime.now().millisecondsSinceEpoch > expiryTime) {
      // بيانات منتهية الصلاحية، حذفها
      delete('user_data');
      delete('user_data_expiry');
      return null;
    }

    return get<Map<String, dynamic>>('user_data');
  }

  // حفظ قائمة الأطباء في التخزين المؤقت
  static Future<void> saveDoctorsList(List<dynamic> doctorsList) async {
    await put('doctors_list', doctorsList);

    // تعيين وقت انتهاء الصلاحية (6 ساعات من الآن)
    final expiryTime = DateTime.now().add(const Duration(hours: 6)).millisecondsSinceEpoch;
    await put('doctors_list_expiry', expiryTime);
  }

  // الحصول على قائمة الأطباء من التخزين المؤقت
  static List<dynamic>? getDoctorsList() {
    // التحقق من انتهاء الصلاحية
    final expiryTime = get<int>('doctors_list_expiry');
    if (expiryTime != null && DateTime.now().millisecondsSinceEpoch > expiryTime) {
      // بيانات منتهية الصلاحية، حذفها
      delete('doctors_list');
      delete('doctors_list_expiry');
      return null;
    }

    return get<List<dynamic>>('doctors_list');
  }

  // حفظ الحالات الطبية في التخزين المؤقت
  static Future<void> saveMedicalCases(List<dynamic> casesList) async {
    await put('medical_cases', casesList);

    // تعيين وقت انتهاء الصلاحية (ساعة واحدة من الآن)
    final expiryTime = DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch;
    await put('medical_cases_expiry', expiryTime);
  }

  // الحصول على الحالات الطبية من التخزين المؤقت
  static List<dynamic>? getMedicalCases() {
    // التحقق من انتهاء الصلاحية
    final expiryTime = get<int>('medical_cases_expiry');
    if (expiryTime != null && DateTime.now().millisecondsSinceEpoch > expiryTime) {
      // بيانات منتهية الصلاحية، حذفها
      delete('medical_cases');
      delete('medical_cases_expiry');
      return null;
    }

    return get<List<dynamic>>('medical_cases');
  }

  // حفظ الإعدادات المحلية
  static Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await put('app_settings', settings);
  }

  // الحصول على الإعدادات المحلية
  static Map<String, dynamic> getAppSettings() {
    return get<Map<String, dynamic>>('app_settings') ?? {};
  }

  // حفظ حالة تسجيل الدخول
  static Future<void> saveLoginState(bool isLoggedIn) async {
    await put('is_logged_in', isLoggedIn);
  }

  // الحصول على حالة تسجيل الدخول
  static bool getLoginState() {
    return get<bool>('is_logged_in') ?? false;
  }
}
