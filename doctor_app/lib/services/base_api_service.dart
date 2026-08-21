import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import '../core/config/app_config.dart';
import '../core/config/server_settings.dart';

class BaseApiService {
  static String? _baseUrl;
  static String? _apiUrl;
  
  static Future<String> get baseUrl async {
    if (_baseUrl == null) {
      _baseUrl = await ServerSettings.getCurrentServerUrl();
    }
    return _baseUrl!;
  }
  
  static Future<String> get apiUrl async {
    if (_apiUrl == null) {
      _apiUrl = await ServerSettings.getApiUrl();
    }
    return _apiUrl!;
  }
  
  // Getters متزامنة للاستخدام في الأماكن التي تتطلب قيمة فورية
  static String get baseUrlSync {
    return ServerSettings.currentServerUrl;
  }
  
  static String get apiUrlSync {
    return ServerSettings.currentApiUrl;
  }
  
  // إعادة تعيين العناوين عند تغيير الإعدادات
  static void resetUrls() {
    _baseUrl = null;
    _apiUrl = null;
  }
  
  // تحميل عناوين API
  static Future<void> _loadApiUrls() async {
    if (_baseUrl == null) {
      _baseUrl = await ServerSettings.getCurrentServerUrl();
    }
    if (_apiUrl == null) {
      _apiUrl = await ServerSettings.getApiUrl();
    }
  }

  // استخدام التخزين الآمن بدلاً من SharedPreferences
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static String? token;
  static Dio? _dio;
  static bool _isInitialized = false;

  // Initialize the API service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Dio with caching and interceptors
    final appDocDir = await getApplicationDocumentsDirectory();
    final hiveCacheDir = '${appDocDir.path}/dio_cache';

    // تحميل عناوين API
    await _loadApiUrls();

    _dio = Dio(BaseOptions(
      baseUrl: apiUrlSync,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ))
      ..interceptors.add(
        DioCacheInterceptor(
          options: CacheOptions(
            store: HiveCacheStore(hiveCacheDir),
            policy: CachePolicy.request,
            hitCacheOnErrorExcept: [401, 403],
            maxStale: const Duration(days: 7),
            priority: CachePriority.normal,
          ),
        ),
      )
      ..interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            // Add token to request headers if available
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            print('🌐 BaseApiService: Request to ${options.path}');
            return handler.next(options);
          },
          onResponse: (response, handler) {
            print(
                '📥 BaseApiService: Response from ${response.requestOptions.path} with status ${response.statusCode}');
            return handler.next(response);
          },
          onError: (error, handler) {
            print(
                '❌ BaseApiService: Error from ${error.requestOptions.path}: ${error.message}');
            return handler.next(error);
          },
        ),
      );

    // Initialize token from secure storage
    await initializeToken();
    _isInitialized = true;
  }

  // Headers for API requests
  static Map<String, String> get headers {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-App-Version': AppConfig.appVersion,
      'X-Device-Info': 'Flutter-App',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Headers for file upload
  static Map<String, String> get fileHeaders {
    Map<String, String> headers = {
      'Accept': 'application/json',
      'X-App-Version': AppConfig.appVersion,
      'X-Device-Info': 'Flutter-App',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Initialize token from secure storage
  static Future<void> initializeToken() async {
    try {
      token = await _secureStorage.read(key: 'auth_token');
      print(
        '🔑 BaseApiService: Token initialized: ${token != null ? "YES" : "NO"}',
      );

      if (token != null && token!.isNotEmpty) {
        print(
            '🔑 BaseApiService: Token preview: ${token!.substring(0, token!.length > 50 ? 50 : token!.length)}...');

        // تحقق من صلاحية التوكن
        if (token!.startsWith('mock_token_')) {
          print('🔑 BaseApiService: Using mock token');
        } else if (token!.length < 10) {
          print('⚠️ BaseApiService: Token seems invalid (too short)');
          // لا نزيل التوكن هنا، قد يكون صالحاً
        }
      } else {
        print('⚠️ BaseApiService: No token found in storage');
      }
    } catch (e) {
      print('❌ BaseApiService: Error initializing token: $e');
      token = null;
    }
  }

  // Save token to secure storage
  static Future<void> saveToken(String tokenValue) async {
    try {
      if (tokenValue.isEmpty) {
        print('⚠️ BaseApiService: Attempted to save empty token');
        return;
      }

      token = tokenValue;
      await _secureStorage.write(key: 'auth_token', value: tokenValue);
      print('💾 BaseApiService: Token saved successfully');

      if (tokenValue.isNotEmpty) {
        print(
            '💾 BaseApiService: Token preview: ${tokenValue.substring(0, tokenValue.length > 50 ? 50 : tokenValue.length)}...');

        // تحقق من نوع التوكن
        if (tokenValue.startsWith('mock_token_')) {
          print('💾 BaseApiService: Saved mock token');

          // استخراج نوع المستخدم من التوكن التجريبي وحفظه
          final parts = tokenValue.split('_');
          if (parts.length >= 3) {
            final userType = parts[2];
            await _secureStorage.write(key: 'user_type', value: userType);
            print('💾 BaseApiService: User type saved: $userType');
          }
        }
      }
    } catch (e) {
      print('❌ BaseApiService: Error saving token: $e');
      // لا نرمي استثناء هنا، نريد أن يستمر التطبيق حتى لو فشلت عملية الحفظ
    }
  }

  // Remove token from secure storage
  static Future<void> removeToken() async {
    try {
      token = null;

      // قائمة بجميع المفاتيح التي يجب حذفها
      final keysToDelete = [
        'auth_token',
        'refresh_token',
        'user_type',
        'user_id',
        'user_data',
        'doctor_data',
        'patient_data',
        'admin_data',
      ];

      // حذف كل المفتاح بشكل منفصل مع معالجة الأخطاء
      for (final key in keysToDelete) {
        try {
          await _secureStorage.delete(key: key);
          print('🗑️ BaseApiService: Removed $key from storage');
        } catch (e) {
          print('⚠️ BaseApiService: Failed to remove $key: $e');
          // نستمر في محاولة حذف بقية المفاتيح حتى لو فشل حذف أحدها
        }
      }

      print('🗑️ BaseApiService: Token removal process completed');
    } catch (e) {
      print('❌ BaseApiService: Error during token removal: $e');
      // نضمن تعيين التوكن إلى null حتى لو فشلت عملية الحذف
      token = null;
    }
  }

  // Check if user is authenticated
  static bool get isAuthenticated {
    final authenticated = token != null;
    print('🔐 BaseApiService: isAuthenticated = $authenticated');
    return authenticated;
  }

  // Get token value
  static String? get getToken {
    print('🔑 BaseApiService: Getting token');
    return token;
  }

  // Get user type from storage
  static Future<String?> getUserType() async {
    return await _secureStorage.read(key: 'user_type');
  }

  // Get user ID from storage
  static Future<String?> getUserId() async {
    return await _secureStorage.read(key: 'user_id');
  }

  // Get user data from storage
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final userDataString = await _secureStorage.read(key: 'user_data');
      if (userDataString != null) {
        try {
          final decodedData = jsonDecode(userDataString);
          if (decodedData is Map<String, dynamic>) {
            return decodedData;
          } else {
            print('⚠️ BaseApiService: User data is not a valid map');
            return null;
          }
        } catch (jsonError) {
          print('❌ BaseApiService: Error decoding user data: $jsonError');
          return null;
        }
      }

      // إذا لم يتم العثور على بيانات المستخدم، حاول الحصول على بيانات محددة حسب النوع
      final userType = await getUserType();
      if (userType != null) {
        final specificDataKey = '${userType}_data';
        final specificDataString =
            await _secureStorage.read(key: specificDataKey);

        if (specificDataString != null) {
          try {
            final decodedData = jsonDecode(specificDataString);
            if (decodedData is Map<String, dynamic>) {
              return decodedData;
            } else {
              print('⚠️ BaseApiService: Specific user data is not a valid map');
              return null;
            }
          } catch (jsonError) {
            print(
                '❌ BaseApiService: Error decoding specific user data: $jsonError');
            return null;
          }
        }
      }

      return null;
    } catch (e) {
      print('❌ BaseApiService: Error getting user data from storage: $e');
      return null;
    }
  }

  // Save user data to storage
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      if (userData.isEmpty) {
        print('⚠️ BaseApiService: Attempted to save empty user data');
        return;
      }

      // حفظ البيانات العامة للمستخدم
      await _secureStorage.write(
        key: 'user_data',
        value: jsonEncode(userData),
      );
      print('✅ BaseApiService: User data saved to storage');

      // استخراج وحفظ نوع المستخدم إذا كان موجوداً
      if (userData.containsKey('user') &&
          userData['user'] is Map<String, dynamic>) {
        final userMap = userData['user'] as Map<String, dynamic>;
        if (userMap.containsKey('user_type')) {
          final userType = userMap['user_type'];
          await _secureStorage.write(key: 'user_type', value: userType);
          print('✅ BaseApiService: User type saved: $userType');
        }

        if (userMap.containsKey('id')) {
          final userId = userMap['id']?.toString();
          if (userId != null) {
            await _secureStorage.write(key: 'user_id', value: userId);
            print('✅ BaseApiService: User ID saved: $userId');
          }
        }
      }

      // حفظ البيانات الخاصة بنوع المستخدم
      if (userData.containsKey('user') &&
          userData['user'] is Map<String, dynamic>) {
        final userMap = userData['user'] as Map<String, dynamic>;
        if (userMap.containsKey('user_type')) {
          final userType = userMap['user_type'];
          final specificDataKey = '${userType}_data';

          // تحديد البيانات الخاصة التي يجب حفظها
          Map<String, dynamic> specificData = {};
          if (userType == 'doctor' && userData.containsKey('doctor')) {
            specificData = userData['doctor'];
          } else if (userType == 'patient' && userData.containsKey('patient')) {
            specificData = userData['patient'];
          } else if (userType == 'admin' && userData.containsKey('admin')) {
            specificData = userData['admin'];
          }

          if (specificData.isNotEmpty) {
            await _secureStorage.write(
              key: specificDataKey,
              value: jsonEncode(specificData),
            );
            print(
                '✅ BaseApiService: Specific user data saved for type: $userType');
          }
        }
      }
    } catch (e) {
      print('❌ BaseApiService: Error saving user data to storage: $e');
      // لا نرمي استثناء هنا، نريد أن يستمر التطبيق حتى لو فشلت عملية الحفظ
    }
  }

  // Check network connectivity
  static Future<bool> _isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }

      // Prefer checking our API host (works offline with local server)
      try {
        await _loadApiUrls();
        final probe = Uri.parse('${apiUrlSync}/health/');
        final response =
            await http.get(probe).timeout(const Duration(seconds: 5));
        if (response.statusCode >= 200 && response.statusCode < 500) {
          return true; // server reachable even if 404
        }
      } catch (e) {
        print('⚠️ BaseApiService: API health probe failed: $e');
      }

      // Fallback probe to base URL root
      try {
        await _loadApiUrls();
        final probe = Uri.parse(apiUrlSync);
        final response =
            await http.get(probe).timeout(const Duration(seconds: 5));
        return response.statusCode >= 200 && response.statusCode < 500;
      } catch (e) {
        print('❌ BaseApiService: Connection probes failed: $e');
        return false;
      }
    } catch (e) {
      print('❌ BaseApiService: Connectivity check error: $e');
      return false;
    }
  }

  // GET request with fallback to mock data
  static Future<http.Response> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      await initializeToken();
      await _loadApiUrls();
      Uri uri = Uri.parse('${apiUrlSync}$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      print('🌐 BaseApiService: Making GET request to: $uri');
      print('🔑 BaseApiService: Headers: $headers');

      // تحقق من الاتصال بالإنترنت قبل إجراء الطلب
      if (!await _isConnected()) {
        print('⚠️ BaseApiService: No internet connection');
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15)); // زيادة timeout

      print('📥 BaseApiService: Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ BaseApiService: API Response Success');
        return response;
      } else if (response.statusCode == 401) {
        // Unauthorized - remove token
        print('🚫 BaseApiService: Unauthorized - removing token');
        await removeToken();
        throw Exception('غير مصرح بالوصول، يرجى تسجيل الدخول مرة أخرى');
      } else if (response.statusCode == 404) {
        print('🚫 BaseApiService: Resource not found');
        throw Exception('المورد المطلوب غير موجود');
      } else if (response.statusCode >= 500) {
        print('🚫 BaseApiService: Server error');
        throw Exception('خطأ في الخادم، يرجى المحاولة مرة أخرى لاحقاً');
      } else {
        print('⚠️ BaseApiService: API Error ${response.statusCode}');
        throw Exception('خطأ في الاتصال: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('❌ BaseApiService: Socket error: $e');
      throw Exception('فشل الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت');
    } catch (e) {
      if (e.toString().contains('timeout') ||
          e.toString().contains('TimeoutException')) {
        print('❌ BaseApiService: Timeout error: $e');
        throw Exception('استغرق الطلب وقتاً طويلاً، يرجى المحاولة مرة أخرى');
      } else if (e is HttpException) {
        print('❌ BaseApiService: HTTP error: $e');
        throw Exception('خطأ في الاتصال: ${e.message}');
      } else if (e is FormatException) {
        print('❌ BaseApiService: Format error: $e');
        throw Exception('تنسيق البيانات غير صحيح');
      } else {
        print('❌ BaseApiService: Network error: $e');
        print(
            '🔄 BaseApiService: Creating empty response due to connection error...');

        // إرجاع استجابة فارغة عند فشل الاتصال
        return _createEmptyResponse(endpoint);
      }
    }
  }

  // إنشاء استجابة فارغة عند فشل الاتصال
  static http.Response _createEmptyResponse(String endpoint) {
    print(
        '⚠️ BaseApiService: Creating empty response for failed request to: $endpoint');

    Map<String, dynamic> emptyData = {
      'message': 'No connection to server',
      'success': false,
      'data': null
    };

    print('⚠️ BaseApiService: Empty response created');

    return http.Response(
      json.encode(emptyData),
      503, // Service Unavailable
      headers: {'content-type': 'application/json'},
    );
  }

  // POST request with fallback
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      await initializeToken();
      await _loadApiUrls();
      print('🌐 BaseApiService: Making POST request to: ${apiUrlSync}$endpoint');
      print('📤 BaseApiService: Data: $data');

      // تحقق من الاتصال بالإنترنت قبل إجراء الطلب
      if (!await _isConnected()) {
        print('⚠️ BaseApiService: No internet connection');
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      final response = await http
          .post(
            Uri.parse('${apiUrlSync}$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      print('📥 BaseApiService: POST Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ BaseApiService: POST Success');
        return response;
      } else {
        // حاول استخراج رسالة خطأ مفصلة من جسم الاستجابة
        String fallbackMessage;
        if (response.statusCode == 401) {
          fallbackMessage =
              'غير مصرح بالوصول، يرجى التحقق من بيانات تسجيل الدخول';
        } else if (response.statusCode == 404) {
          fallbackMessage = 'المورد المطلوب غير موجود';
        } else if (response.statusCode >= 500) {
          fallbackMessage = 'خطأ في الخادم، يرجى المحاولة مرة أخرى لاحقاً';
        } else {
          fallbackMessage = 'خطأ في الاتصال: ${response.statusCode}';
        }

        String detailedMessage = fallbackMessage;
        try {
          if (response.body.isNotEmpty) {
            final parsed = jsonDecode(response.body);
            if (parsed is Map<String, dynamic>) {
              detailedMessage = (parsed['error'] ??
                      parsed['message'] ??
                      parsed['detail'] ??
                      fallbackMessage)
                  .toString();
            }
          }
        } catch (e) {
          // تجاهل أخطاء فك التشفير واستخدم الرسالة الافتراضية
        }

        if (response.statusCode == 401) {
          print('🚫 BaseApiService: Unauthorized - removing token');
          await removeToken();
        }

        throw Exception(detailedMessage);
      }
    } on SocketException catch (e) {
      print('❌ BaseApiService: Socket error: $e');
      throw Exception('فشل الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        print('❌ BaseApiService: Timeout error: $e');
        throw Exception('استغرق الطلب وقتاً طويلاً، يرجى المحاولة مرة أخرى');
      } else if (e is HttpException) {
        print('❌ BaseApiService: HTTP error: $e');
        throw Exception('خطأ في الاتصال: ${e.message}');
      } else if (e is FormatException) {
        print('❌ BaseApiService: Format error: $e');
        throw Exception('تنسيق البيانات غير صحيح');
      } else {
        print('❌ BaseApiService: POST Error: $e');
        print(
            '🔄 BaseApiService: Creating empty response due to connection error...');

        // إرجاع استجابة فارغة عند فشل الاتصال
        return _createEmptyResponse('$apiUrl$endpoint');
      }
    }
  }

  // PUT request with fallback
  static Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      await initializeToken();
      await _loadApiUrls();
      print('🌐 BaseApiService: Making PUT request to: ${apiUrlSync}$endpoint');
      print('📤 BaseApiService: Data: $data');

      // تحقق من الاتصال بالإنترنت قبل إجراء الطلب
      if (!await _isConnected()) {
        print('⚠️ BaseApiService: No internet connection');
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      final response = await http
          .put(
            Uri.parse('${apiUrlSync}$endpoint'),
            headers: headers,
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      print('📥 BaseApiService: PUT Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ BaseApiService: PUT Success');
        return response;
      } else if (response.statusCode == 401) {
        // Unauthorized - remove token
        print('🚫 BaseApiService: Unauthorized - removing token');
        await removeToken();
        throw Exception('غير مصرح بالوصول، يرجى تسجيل الدخول مرة أخرى');
      } else if (response.statusCode == 404) {
        print('🚫 BaseApiService: Resource not found');
        throw Exception('المورد المطلوب غير موجود');
      } else if (response.statusCode >= 500) {
        print('🚫 BaseApiService: Server error');
        throw Exception('خطأ في الخادم، يرجى المحاولة مرة أخرى لاحقاً');
      } else {
        throw Exception('خطأ في الاتصال: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('❌ BaseApiService: Socket error: $e');
      throw Exception('فشل الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        print('❌ BaseApiService: Timeout error: $e');
        throw Exception('استغرق الطلب وقتاً طويلاً، يرجى المحاولة مرة أخرى');
      } else if (e is HttpException) {
        print('❌ BaseApiService: HTTP error: $e');
        throw Exception('خطأ في الاتصال: ${e.message}');
      } else if (e is FormatException) {
        print('❌ BaseApiService: Format error: $e');
        throw Exception('تنسيق البيانات غير صحيح');
      } else {
        print('❌ BaseApiService: PUT Error: $e');
        print(
            '🔄 BaseApiService: Creating empty response due to connection error...');

        // إرجاع استجابة فارغة عند فشل الاتصال
        return _createEmptyResponse('$apiUrl$endpoint');
      }
    }
  }

  // DELETE request with fallback
  static Future<http.Response> delete(String endpoint) async {
    try {
      await initializeToken();
      await _loadApiUrls();
      print('🌐 BaseApiService: Making DELETE request to: ${apiUrlSync}$endpoint');

      // تحقق من الاتصال بالإنترنت قبل إجراء الطلب
      if (!await _isConnected()) {
        print('⚠️ BaseApiService: No internet connection');
        throw Exception('لا يوجد اتصال بالإنترنت');
      }

      final response = await http
          .delete(Uri.parse('${apiUrlSync}$endpoint'), headers: headers)
          .timeout(const Duration(seconds: 15));

      print(
          '📥 BaseApiService: DELETE Response status: ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        print('✅ BaseApiService: DELETE Success');
        return response;
      } else if (response.statusCode == 401) {
        // Unauthorized - remove token
        print('🚫 BaseApiService: Unauthorized - removing token');
        await removeToken();
        throw Exception('غير مصرح بالوصول، يرجى تسجيل الدخول مرة أخرى');
      } else if (response.statusCode == 404) {
        print('🚫 BaseApiService: Resource not found');
        throw Exception('المورد المطلوب غير موجود');
      } else if (response.statusCode >= 500) {
        print('🚫 BaseApiService: Server error');
        throw Exception('خطأ في الخادم، يرجى المحاولة مرة أخرى لاحقاً');
      } else {
        throw Exception('خطأ في الاتصال: ${response.statusCode}');
      }
    } on SocketException catch (e) {
      print('❌ BaseApiService: Socket error: $e');
      throw Exception('فشل الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        print('❌ BaseApiService: Timeout error: $e');
        throw Exception('استغرق الطلب وقتاً طويلاً، يرجى المحاولة مرة أخرى');
      } else if (e is HttpException) {
        print('❌ BaseApiService: HTTP error: $e');
        throw Exception('خطأ في الاتصال: ${e.message}');
      } else if (e is FormatException) {
        print('❌ BaseApiService: Format error: $e');
        throw Exception('تنسيق البيانات غير صحيح');
      } else {
        print('❌ BaseApiService: DELETE Error: $e');
        print(
            '🔄 BaseApiService: Creating empty response due to connection error...');

        // إرجاع استجابة فارغة عند فشل الاتصال
        return _createEmptyResponse('$apiUrl$endpoint');
      }
    }
  }

  // File upload request
  static Future<http.StreamedResponse> uploadFile(
    String endpoint,
    File file,
    String fieldName, {
    Map<String, String>? additionalFields,
  }) async {
    try {
      await _loadApiUrls();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiUrlSync}$endpoint'),
      );

      // Add headers
      request.headers.addAll(fileHeaders);

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      return await request.send();
    } catch (e) {
      throw Exception('File upload error: $e');
    }
  }

  // Handle API response
  static Map<String, dynamic> handleResponse(http.Response response) {
    print('📥 BaseApiService: Response Status: ${response.statusCode}');
    if (response.body.isNotEmpty) {
      print(
        '📥 BaseApiService: Response Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decodedData = jsonDecode(response.body);

        // التحقق من أن البيانات تم فك تشفيرها بشكل صحيح
        if (decodedData is Map<String, dynamic>) {
          return decodedData;
        } else {
          print('⚠️ BaseApiService: Response is not a valid JSON object');
          // إرجاع خريطة فارغة مع رسالة نجاح
          return {'success': true, 'data': decodedData};
        }
      } catch (e) {
        print('❌ BaseApiService: Error decoding JSON response: $e');
        // إرجاع خريطة فارغة مع رسالة نجاح في حالة فشل فك التشفير
        return {
          'success': true,
          'message': 'Response received but could not be parsed'
        };
      }
    } else if (response.statusCode == 401) {
      // Unauthorized - remove token
      print('🚫 BaseApiService: Unauthorized - removing token');
      removeToken();
      throw Exception('غير مصرح بالوصول، يرجى تسجيل الدخول مرة أخرى');
    } else if (response.statusCode == 403) {
      print('🚫 BaseApiService: Access forbidden');
      throw Exception('الوصول ممنوع');
    } else if (response.statusCode == 404) {
      print('🚫 BaseApiService: Resource not found');
      throw Exception('المورد المطلوب غير موجود');
    } else if (response.statusCode >= 500) {
      print('🚫 BaseApiService: Server error');
      throw Exception('خطأ في الخادم، يرجى المحاولة مرة أخرى لاحقاً');
    } else {
      try {
        final errorData = jsonDecode(response.body);
        print('🚫 BaseApiService: Error data: $errorData');

        // محاولة استخراج رسالة الخطأ من أماكن مختلفة
        String errorMessage = 'حدث خطأ غير معروف';
        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('message')) {
            errorMessage = errorData['message'];
          } else if (errorData.containsKey('error')) {
            errorMessage = errorData['error'];
          } else if (errorData.containsKey('detail')) {
            errorMessage = errorData['detail'];
          }
        }

        throw Exception(errorMessage);
      } catch (e) {
        print('🚫 BaseApiService: Failed to parse error response: $e');
        throw Exception('حدث خطأ في الاتصال بالخادم');
      }
    }
  }

  // Handle file upload response
  static Future<Map<String, dynamic>> handleFileResponse(
    http.StreamedResponse response,
  ) async {
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseBody);
    } else if (response.statusCode == 401) {
      removeToken();
      throw Exception('Unauthorized access');
    } else if (response.statusCode == 403) {
      throw Exception('Access forbidden');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error');
    } else {
      final errorData = jsonDecode(responseBody);
      throw Exception(errorData['message'] ?? 'File upload failed');
    }
  }

  // Test Connection
  static Future<bool> testConnection() async {
    try {
      await _loadApiUrls();
      final response = await http.get(Uri.parse('${apiUrlSync}/'), headers: {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 5));

      return response.statusCode == 401 || response.statusCode == 200;
    } catch (e) {
      print('Connection test failed: $e');
      return false;
    }
  }
}
