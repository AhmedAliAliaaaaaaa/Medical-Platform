import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'base_api_service.dart';
import '../core/config/app_config.dart';
import '../core/config/server_settings.dart';

class AuthApiService {
  // تخزين آمن للمعلومات الحساسة
  static const _secureStorage = FlutterSecureStorage();

  // عدد محاولات تسجيل الدخول الفاشلة
  static int _failedLoginAttempts = 0;

  // قائمة بالعناوين المحظورة بعد عدة محاولات فاشلة
  static final Set<String> _blockedIps = {};

  // Login with enhanced authentication
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    username = username.trim();
    password = password.trim();
    print('🔐 AuthApiService: Attempting login for: $username');

    // التحقق من صحة المدخلات
    if (username.isEmpty) {
      throw Exception('اسم المستخدم مطلوب');
    }

    if (password.isEmpty) {
      throw Exception('كلمة المرور مطلوبة');
    }

    // التحقق من وجود محاولات فاشلة كثيرة
    if (_failedLoginAttempts >= 5) {
      // في تطبيق حقيقي، يمكن استخدام عنوان IP هنا
      final String deviceIdentifier = await _getDeviceIdentifier();
      if (_blockedIps.contains(deviceIdentifier)) {
        throw Exception(
            'تم حظر الجهاز مؤقتاً بسبب محاولات دخول متكررة. يرجى المحاولة لاحقاً.');
      }
    }

    // محاولة تسجيل الدخول عبر API
    try {
      // اختر المفتاح الصحيح بناءً على ما يدخله المستخدم (بريد أو اسم مستخدم)
      final deviceInfo = await _getDeviceInfo();
      final bool looksLikeEmail = username.contains('@');
      final Map<String, dynamic> payload = {
        'password': password,
        'device_info': deviceInfo,
      };
      if (looksLikeEmail) {
        payload['email'] = username;
      } else {
        payload['username'] = username;
      }

      final response = await BaseApiService.post('/auth/login/', payload);

      final data = BaseApiService.handleResponse(response);
      print('🔐 AuthApiService: API login response handled successfully');

      // التحقق من صحة البيانات المستلمة
      if (data == null || !(data is Map<String, dynamic>)) {
        throw Exception('استجابة غير صالحة من الخادم');
      }

      // Save token if login successful
      if (data['access'] != null) {
        print('🔐 AuthApiService: Saving access token...');
        await _secureTokenStorage(data['access']);

        // حفظ معلومات إضافية
        if (data['refresh'] != null) {
          await _secureStorage.write(
              key: 'refresh_token', value: data['refresh']);
        }

        // حفظ معلومات المستخدم
        if (data['user'] != null && data['user'] is Map<String, dynamic>) {
          final user = data['user'] as Map<String, dynamic>;

          if (user['user_type'] != null) {
            await _secureStorage.write(
              key: 'user_type',
              value: user['user_type'],
            );

            if (user['id'] != null) {
              await _secureStorage.write(
                key: 'user_id',
                value: user['id'].toString(),
              );
            }

            // حفظ بيانات المستخدم الكاملة
            await _secureStorage.write(
              key: 'user_data',
              value: jsonEncode(data),
            );

            // حفظ البيانات الخاصة بنوع المستخدم
            final userType = user['user_type'];
            if (userType == 'doctor' && data.containsKey('doctor')) {
              await _secureStorage.write(
                key: 'doctor_data',
                value: jsonEncode(data['doctor']),
              );
            } else if (userType == 'patient' && data.containsKey('patient')) {
              await _secureStorage.write(
                key: 'patient_data',
                value: jsonEncode(data['patient']),
              );
            } else if (userType == 'admin' && data.containsKey('admin')) {
              await _secureStorage.write(
                key: 'admin_data',
                value: jsonEncode(data['admin']),
              );
            }

            print('🔐 AuthApiService: User data saved successfully');
          } else {
            print('❌ AuthApiService: user_type is null in response');
            throw Exception('بيانات المستخدم غير مكتملة في الاستجابة');
          }
        } else {
          print('❌ AuthApiService: User data is null or invalid in response');
          throw Exception('بيانات المستخدم غير مكتملة في الاستجابة');
        }

        print('🔐 AuthApiService: Token saved successfully');
      } else {
        print('❌ AuthApiService: No access token in response');
        // حاول استخراج رسالة خطأ من الاستجابة إن وُجدت
        final backendMsg = (data is Map<String, dynamic>)
            ? (data['error'] ?? data['message'])
            : null;
        throw Exception(
            backendMsg?.toString() ?? 'بيانات تسجيل الدخول غير صحيحة');
      }

      // إعادة تعيين عدد المحاولات الفاشلة
      _failedLoginAttempts = 0;

      return data;
    } catch (e) {
      print('❌ AuthApiService: API login failed: $e');

      // زيادة عدد المحاولات الفاشلة
      _failedLoginAttempts++;

      // حظر الجهاز مؤقتاً بعد 5 محاولات فاشلة
      if (_failedLoginAttempts >= 5) {
        final String deviceIdentifier = await _getDeviceIdentifier();
        _blockedIps.add(deviceIdentifier);

        // إزالة الحظر بعد 15 دقيقة
        Future.delayed(const Duration(minutes: 15), () {
          _blockedIps.remove(deviceIdentifier);
          _failedLoginAttempts = 0;
        });

        throw Exception(
            'تم حظر الجهاز مؤقتاً بسبب محاولات دخول متكررة. يرجى المحاولة بعد 15 دقيقة.');
      }

      // تحسين رسالة الخطأ بناءً على نوع الخطأ
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.isEmpty || errorMessage == 'Exception') {
        errorMessage = 'بيانات تسجيل الدخول غير صحيحة';
      }
      if (e.toString().contains('SocketException')) {
        errorMessage = 'فشل الاتصال بالخادم، يرجى التحقق من اتصال الإنترنت';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'استغرق الطلب وقتاً طويلاً، يرجى المحاولة مرة أخرى';
      } else if (e.toString().contains('401')) {
        errorMessage = 'بيانات الاعتماد غير صحيحة';
      } else if (e.toString().contains('403')) {
        errorMessage = 'الوصول ممنوع';
      } else if (e.toString().contains('500')) {
        errorMessage = 'خطأ في الخادم، يرجى المحاولة مرة أخرى لاحقاً';
      }

      throw Exception(errorMessage);
    }
  }

  // تخزين التوكن بشكل آمن
  static Future<void> _secureTokenStorage(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
    // تحديث التوكن في BaseApiService
    BaseApiService.token = token;
  }

  // تشفير كلمة المرور (لأغراض العرض التوضيحي فقط)
  static String _encryptPassword(String password) {
    // في تطبيق حقيقي، يجب استخدام خوارزميات تشفير أقوى
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  // الحصول على معرف الجهاز
  static Future<String> _getDeviceIdentifier() async {
    // في تطبيق حقيقي، يمكن استخدام معرف الجهاز الفعلي
    return 'device_${DateTime.now().millisecondsSinceEpoch}';
  }

  // الحصول على معلومات الجهاز
  static Future<Map<String, String>> _getDeviceInfo() async {
    // في تطبيق حقيقي، يمكن استخدام حزمة مثل device_info_plus
    return {
      'device_model': 'Flutter Device',
      'device_os': 'Flutter',
      'app_version': '1.0.0',
    };
  }

  // تم إزالة البيانات التجريبية - الاتصال بالخادم الفعلي فقط
  // هذه الدالة لم تعد مستخدمة وسيتم حذفها في الإصدارات القادمة
  static Map<String, dynamic>? _getMockUser(String username, String password) {
    // تم إزالة جميع البيانات التجريبية
    return null;
  }

  // Patient Registration
  static Future<Map<String, dynamic>> registerPatient({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String phone,
    required int age,
    required String gender,
  }) async {
    // استخدام firstName كاسم المستخدم (لأن المستخدم يدخل اسم المستخدم في حقل firstName)
    final payload = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'username': firstName, // استخدام firstName كاسم المستخدم
      'password': password,
      'phone': phone,
      'age': age,
      'gender': gender,
    };

    final response =
        await BaseApiService.post('/auth/patient-register/', payload);
    return BaseApiService.handleResponse(response);
  }

  // Doctor Registration
  static Future<Map<String, dynamic>> registerDoctor({
    required String fullName,
    required String username,
    required String email,
    required String password,
    required String phone,
    required String specialization,
    required String country,
    required int experienceYears,
    required String licenseNumber,
    required File licenseImage,
    required double regularConsultationPrice,
    required double emergencyConsultationPrice,
    required double followUpConsultationPrice,
    required String currency,
    bool acceptsInsurance = false,
    File? profileImage,
    String? bio,
  }) async {
    try {
      // تحميل عناوين API
      await ServerSettings.getCurrentServerUrl();
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${BaseApiService.apiUrlSync}/auth/doctor-register/'),
      );

      // Add headers without authentication for registration
      request.headers.addAll({
        'Accept': 'application/json',
        'X-App-Version': AppConfig.appVersion,
        'X-Device-Info': 'Flutter-App',
      });

      // Add text fields
      request.fields.addAll({
        'full_name': fullName,
        'username': username,
        'email': email,
        'password': password,
        'phone': phone,
        'specialization': specialization,
        'country': country,
        'experience_years': experienceYears.toString(),
        'regular_consultation_price': regularConsultationPrice.toString(),
        'emergency_consultation_price': emergencyConsultationPrice.toString(),
        'follow_up_consultation_price': followUpConsultationPrice.toString(),
        'currency': currency,
        'accepts_insurance': acceptsInsurance.toString(),
        'license_number': licenseNumber,
        if (bio != null && bio.isNotEmpty) 'bio': bio,
      });

      // Add license image
      request.files.add(
        await http.MultipartFile.fromPath('license_image', licenseImage.path),
      );

      // Add profile image if provided
      if (profileImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('profile_image', profileImage.path),
        );
      }

      final streamedResponse = await request.send();
      return await BaseApiService.handleFileResponse(streamedResponse);
    } catch (e) {
      throw Exception('Doctor registration error: $e');
    }
  }

  // Get User Profile
  static Future<Map<String, dynamic>> getUserProfile() async {
    print('🔍 AuthApiService: Getting user profile...');

    try {
      // محاولة الحصول على البيانات من التخزين المحلي أولاً
      final userType = await BaseApiService.getUserType();
      final userData = await BaseApiService.getUserData();

      if (userType != null && userData != null) {
        print('✅ AuthApiService: Profile retrieved from storage');
        // إضافة success flag للتوافق مع بقية الكود
        return {
          'success': true,
          'user': userData['user'] ?? userData,
          'doctor': userData['doctor'],
          'patient': userData['patient'],
        };
      }

      // محاولة الحصول على البيانات من API
      try {
        final response = await BaseApiService.get(
          '/profile/',
        ).timeout(const Duration(seconds: 10));
        final result = BaseApiService.handleResponse(response);
        print('✅ AuthApiService: Profile retrieved from API');

        // حفظ البيانات في التخزين المحلي للاستخدام المستقبلي
        if (result != null && result is Map<String, dynamic>) {
          await BaseApiService.saveUserData(result);
        }

        return result;
      } catch (apiError) {
        print('⚠️ AuthApiService: API failed: $apiError');

        // في حالة فشل API، ارجع بيانات فارغة
        return {'success': false, 'error': 'فشل الاتصال بالخادم'};
      }
    } catch (e) {
      print('❌ AuthApiService: Error getting user profile: $e');

      // في حالة حدوث أي خطأ، ارجع بيانات فارغة
      return {'success': false, 'error': 'فشل الاتصال بالخادم'};
    }
  }

  // الحصول على بيانات تجريبية حسب نوع المستخدم
  static Map<String, dynamic> _getMockProfileByType(String userType) {
    switch (userType) {
      case 'doctor':
        return {
          'success': true,
          'user': {
            'id': 1,
            'username': 'doctor@test.com',
            'email': 'doctor@test.com',
            'first_name': 'د. أحمد',
            'last_name': 'محمد',
            'user_type': 'doctor',
          },
          'doctor': {
            'id': 1,
            'specialization': 'طب عام',
            'experience_years': 10,
            'phone': '+966501234567',
            'status': 'approved',
            'rating': 4.8,
            'country': 'السعودية',
            'city': 'الرياض',
            'price': 150.0,
          },
        };
      case 'admin':
        return {
          'success': true,
          'user': {
            'id': 2,
            'username': 'admin@test.com',
            'email': 'admin@test.com',
            'first_name': 'مشرف',
            'last_name': 'النظام',
            'user_type': 'admin',
          },
          'profile': {'phone': '+966501234568'},
        };
      default: // patient
        return {
          'success': true,
          'user': {
            'id': 3,
            'username': 'patient@test.com',
            'email': 'patient@test.com',
            'first_name': 'محمد',
            'last_name': 'أحمد',
            'user_type': 'patient',
          },
          'patient': {
            'id': 1,
            'age': 30,
            'gender': 'male',
            'phone': '+966501234569',
            'cases_count': 5,
          },
        };
    }
  }

  // Update User Profile
  static Future<Map<String, dynamic>> updateUserProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await BaseApiService.put('/auth/profile/', data);
      final result = BaseApiService.handleResponse(response);

      // تحديث البيانات في التخزين المحلي
      if (result != null && result is Map<String, dynamic>) {
        // الحصول على البيانات الحالية من التخزين
        final currentData = await BaseApiService.getUserData();

        if (currentData != null) {
          // دمج البيانات الجديدة مع البيانات الحالية
          final updatedData = {
            ...currentData,
            'user': {
              ...currentData['user'],
              ...data,
            },
          };

          // حفظ البيانات المحدثة
          await BaseApiService.saveUserData(updatedData);
        }
      }

      return result;
    } catch (e) {
      print('❌ AuthApiService: Error updating user profile: $e');

      // في حالة فشل التحديث، أرجع رسالة خطأ
      return {
        'success': false,
        'error':
            'فشل تحديث الملف الشخصي: ${e.toString().replaceAll('Exception: ', '')}',
      };
    }
  }

  // Change Password
  static Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await BaseApiService.post('/auth/change-password/', {
        'current_password': currentPassword,
        'new_password': newPassword,
      });
      return BaseApiService.handleResponse(response);
    } catch (e) {
      print('❌ AuthApiService: Error changing password: $e');

      // في حالة فشل تغيير كلمة المرور، أرجع رسالة خطأ
      return {
        'success': false,
        'error':
            'فشل تغيير كلمة المرور: ${e.toString().replaceAll('Exception: ', '')}',
      };
    }
  }

  // Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      // محاولة الاتصال بالخادم لتسجيل الخروج
      await BaseApiService.post('/auth/logout/', {});

      // مسح جميع البيانات المحلية
      await BaseApiService.removeToken();

      return {
        'success': true,
        'message': 'تم تسجيل الخروج بنجاح',
      };
    } catch (e) {
      print('❌ AuthApiService: Error during logout: $e');

      // حتى لو فشل الاتصال بالخادم، مسح البيانات المحلية
      try {
        await BaseApiService.removeToken();
      } catch (storageError) {
        print('❌ AuthApiService: Error clearing local data: $storageError');
      }

      return {
        'success': true, // نعتبر الخروج ناجحاً حتى لو فشل الاتصال بالخادم
        'message': 'تم تسجيل الخروج (مع خطأ في الاتصال بالخادم)',
      };
    }
  }
}
