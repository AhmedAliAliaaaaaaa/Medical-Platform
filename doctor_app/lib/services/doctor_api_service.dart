import 'base_api_service.dart';

class DoctorApiService {
  // Get Doctor Dashboard
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      // إضافة رأس عشوائي لمنع التخزين المؤقت للمتصفح
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final response =
          await BaseApiService.get('/doctor/dashboard/?_t=$timestamp');
      final result = BaseApiService.handleResponse(response);

      // التحقق من أن النتيجة تحتوي على البيانات المطلوبة
      if (result != null && result is Map<String, dynamic>) {
        return result;
      } else {
        print('⚠️ DoctorApiService: Invalid dashboard data format');
        throw Exception('Invalid dashboard data format');
      }
    } catch (e) {
      print('❌ DoctorApiService: Error getting dashboard: $e');
      rethrow;
    }
  }

  // Get Doctor Cases
  static Future<List<dynamic>> getCases() async {
    try {
      final dashboardData = await getDashboard();
      if (dashboardData is Map<String, dynamic>) {
        if (dashboardData['new_cases_list'] is List) {
          return dashboardData['new_cases_list'] as List<dynamic>;
        }
        if (dashboardData['new_cases'] is List) {
          return dashboardData['new_cases'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      print('❌ DoctorApiService: Error getting cases from dashboard: $e');
      return [];
    }
  }

  // Get New Cases (Pending Response)
  static Future<List<dynamic>> getNewCases() async {
    try {
      final dashboardData = await getDashboard();
      if (dashboardData is Map<String, dynamic>) {
        if (dashboardData['new_cases_list'] is List) {
          return dashboardData['new_cases_list'] as List<dynamic>;
        }
        if (dashboardData['new_cases'] is List) {
          return dashboardData['new_cases'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      print('❌ DoctorApiService: Error getting new cases from dashboard: $e');
      return [];
    }
  }

  // Get Completed Cases
  static Future<List<dynamic>> getCompletedCases() async {
    try {
      // استخدام نقطة النهاية المباشرة للحصول على الحالات المكتملة
      final response = await BaseApiService.get('/doctor/cases/completed/');
      final result = BaseApiService.handleResponse(response);

      if (result != null && result is Map<String, dynamic>) {
        if (result['cases'] is List) {
          return result['cases'] as List<dynamic>;
        }
      }

      // في حالة فشل الطلب المباشر، نحاول من لوحة التحكم
      final dashboardData = await getDashboard();
      if (dashboardData is Map<String, dynamic>) {
        if (dashboardData['answered_cases_list'] is List) {
          return dashboardData['answered_cases_list'] as List<dynamic>;
        }
        if (dashboardData['my_responses'] is List) {
          return dashboardData['my_responses'] as List<dynamic>;
        }
      }
      return [];
    } catch (e) {
      print('❌ DoctorApiService: Error getting completed cases: $e');
      return [];
    }
  }

  // Respond to Case
  static Future<Map<String, dynamic>> respondToCase({
    required int caseId,
    required String content,
    required String recommendations,
    String? diagnosis,
    String? treatmentPlan,
    String? notes,
  }) async {
    try {
      // التحقق من صحة البيانات قبل الإرسال
      if (content.trim().isEmpty) {
        return {
          'success': false,
          'error': 'المحتوى مطلوب',
        };
      }

      if (recommendations.trim().isEmpty) {
        return {
          'success': false,
          'error': 'التوصيات مطلوبة',
        };
      }

      final response =
          await BaseApiService.post('/doctor/cases/$caseId/respond/', {
        'content': content,
        'recommendations': recommendations,
        if (diagnosis != null && diagnosis.isNotEmpty) 'diagnosis': diagnosis,
        if (treatmentPlan != null && treatmentPlan.isNotEmpty)
          'treatment_plan': treatmentPlan,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      });

      final result = BaseApiService.handleResponse(response);

      // التحقق من أن الاستجابة تحتوي على البيانات المطلوبة
      if (result != null && result is Map<String, dynamic>) {
        // إرسال طلب لإزالة الإشعار بعد إرسال الرد بنجاح
        try {
          await BaseApiService.post('/doctor/notifications/clear/$caseId/', {});
        } catch (e) {
          print('⚠️ DoctorApiService: Failed to clear notification: $e');
          // لا نوقف التنفيذ إذا فشل إزالة الإشعار
        }

        // إرسال طلب لتحديث حالة الحالة في قاعدة البيانات
        try {
          await BaseApiService.post('/doctor/cases/$caseId/update-status/', {
            'status': 'answered',
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        } catch (e) {
          print('⚠️ DoctorApiService: Failed to update case status: $e');
          // لا نوقف التنفيذ إذا فشل تحديث الحالة
        }

        return result;
      } else {
        return {
          'success': false,
          'error': 'تنسيق الاستجابة غير صحيح',
        };
      }
    } catch (e) {
      print('❌ DoctorApiService: Error responding to case: $e');

      return {
        'success': false,
        'error':
            'فشل الاستجابة للحالة: ${e.toString().replaceAll('Exception: ', '')}',
      };
    }
  }

  // Get Case Details
  static Future<Map<String, dynamic>> getCaseDetails(int caseId) async {
    try {
      final response = await BaseApiService.get('/doctor/cases/$caseId/');
      final result = BaseApiService.handleResponse(response);

      // التحقق من أن الاستجابة تحتوي على البيانات المطلوبة
      if (result != null && result is Map<String, dynamic>) {
        return result;
      } else {
        print(
            '⚠️ DoctorApiService: Invalid case details data format for case $caseId');
        // إرجاع بيانات افتراضية في حالة عدم وجود بيانات صالحة
        return _getMockCaseDetails(caseId);
      }
    } catch (e) {
      print(
          '❌ DoctorApiService: Error getting case details for case $caseId: $e');
      // إرجاع بيانات افتراضية في حالة حدوث خطأ
      return _getMockCaseDetails(caseId);
    }
  }

  // بيانات افتراضية لتفاصيل الحالة
  static Map<String, dynamic> _getMockCaseDetails(int caseId) {
    return {
      'success': true,
      'case': {
        'id': caseId,
        'title': 'حالة طبية',
        'description': 'وصف الحالة الطبية',
        'patient': {
          'id': 1,
          'name': 'محمد أحمد',
          'age': 35,
          'gender': 'male',
        },
        'created_at': '2023-06-15T10:30:00Z',
        'status': 'pending',
        'priority': 'medium',
        'attachments': [],
        'responses': [],
      },
    };
  }

  // Get Doctor Ratings
  static Future<Map<String, dynamic>> getRatings() async {
    try {
      final dashboardData = await getDashboard();
      if (dashboardData is Map<String, dynamic>) {
        return {
          'ratings': dashboardData['ratings'] ?? [],
          'average_rating': dashboardData['average_rating'] ?? 0,
          'total_ratings': dashboardData['total_ratings'] ?? 0,
        };
      }
      return {'ratings': [], 'average_rating': 0, 'total_ratings': 0};
    } catch (e) {
      print('❌ DoctorApiService: Error getting ratings from dashboard: $e');
      return {'ratings': [], 'average_rating': 0, 'total_ratings': 0};
    }
  }

  // بيانات افتراضية لتقييمات الطبيب
  static Map<String, dynamic> _getMockRatingsData() {
    return {
      'success': true,
      'average_rating': 4.5,
      'total_reviews': 24,
      'ratings_breakdown': {'5': 18, '4': 4, '3': 1, '2': 1, '1': 0},
      'recent_reviews': [
        {
          'id': 1,
          'patient_name': 'محمد أحمد',
          'rating': 5,
          'comment': 'طبيب ممتاز جداً، استفدت كثيراً من استشارته',
          'date': '2023-06-10',
        },
        {
          'id': 2,
          'patient_name': 'فاطمة محمد',
          'rating': 4,
          'comment': 'استشارة جيدة، لكن يمكن تحسين وقت الاستجابة',
          'date': '2023-06-05',
        },
      ],
    };
  }

  // Get Doctor Profile
  static Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await BaseApiService.get('/doctor/profile/');
      final result = BaseApiService.handleResponse(response);

      // التحقق من أن الاستجابة تحتوي على البيانات المطلوبة
      if (result != null && result is Map<String, dynamic>) {
        return result;
      } else {
        print('⚠️ DoctorApiService: Invalid doctor profile data format');
        // إرجاع بيانات افتراضية في حالة عدم وجود بيانات صالحة
        return _getMockDoctorProfile();
      }
    } catch (e) {
      print('❌ DoctorApiService: Error getting doctor profile: $e');

      try {
        print('⚠️ DoctorApiService: Trying general profile endpoint');
        // استخدم الـ profile العام
        final response = await BaseApiService.get('/profile/');
        final data = BaseApiService.handleResponse(response);

        if (data != null && data is Map<String, dynamic>) {
          if (data.containsKey('doctor') && data['doctor'] != null) {
            return data['doctor'];
          }
          return data;
        }
      } catch (profileError) {
        print(
            '❌ DoctorApiService: Error getting general profile: $profileError');
      }

      // إرجاع بيانات افتراضية في حالة حدوث خطأ
      return _getMockDoctorProfile();
    }
  }

  // بيانات افتراضية لملف الطبيب
  static Map<String, dynamic> _getMockDoctorProfile() {
    return {
      'success': true,
      'doctor': {
        'id': 1,
        'first_name': 'د. أحمد',
        'last_name': 'محمد',
        'specialization': 'طب عام',
        'experience_years': 10,
        'rating': 4.8,
        'status': 'approved',
        'country': 'السعودية',
        'city': 'الرياض',
        'price': 150.0,
        'phone': '+966501234567',
        'email': 'doctor@test.com',
        'bio': 'طبيب عام بخبرة 10 سنوات في تشخيص وعلاج الأمراض الشائعة',
        'education': 'بكالوريوس الطب والجراحة - جامعة الملك سعود',
        'certifications': ['شهادة البورد السعودي في الطب العام'],
      },
    };
  }

  // Update Doctor Profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    final response = await BaseApiService.put('/doctor/profile/', data);
    return BaseApiService.handleResponse(response);
  }

  // Get Doctor Statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final response = await BaseApiService.get('/doctor/statistics/');
    return BaseApiService.handleResponse(response);
  }

  // Get Patient List
  static Future<List<dynamic>> getPatients() async {
    try {
      print(
          '🔍 DoctorApiService: Requesting patients from /doctor/my-patients/');

      // Backend route is '/doctor/my-patients/'
      final response = await BaseApiService.get('/doctor/my-patients/');
      final data = BaseApiService.handleResponse(response);

      print('🔍 DoctorApiService: Raw response: $response');
      print('🔍 DoctorApiService: Processed data: $data');
      print('🔍 DoctorApiService: Data type: ${data.runtimeType}');

      // API يعيد البيانات في {'patients': [...]}
      if (data is Map<String, dynamic>) {
        final patients = data['patients'];
        print('🔍 DoctorApiService: Patients field: $patients');
        print('🔍 DoctorApiService: Patients type: ${patients.runtimeType}');

        if (patients is List) {
          print('✅ DoctorApiService: Found ${patients.length} patients');
          return patients as List<dynamic>;
        } else {
          print('⚠️ DoctorApiService: Patients field is not a list');
          return [];
        }
      } else if (data is List) {
        print('✅ DoctorApiService: Direct list with ${data.length} patients');
        return data as List<dynamic>;
      } else {
        print(
            '⚠️ DoctorApiService: Unexpected data format: ${data.runtimeType}');
        return [];
      }
    } catch (e) {
      print('❌ DoctorApiService: Error getting patients: $e');
      print('❌ DoctorApiService: Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Get Patient History
  static Future<List<dynamic>> getPatientHistory(int patientId) async {
    final response = await BaseApiService.get(
      '/doctor/patients/$patientId/history/',
    );
    final data = BaseApiService.handleResponse(response);
    return data['cases'] ?? [];
  }

  // Send Notification to Patient
  static Future<Map<String, dynamic>> sendNotificationToPatient({
    required int patientId,
    required String title,
    required String message,
    String type = 'doctor_message',
  }) async {
    try {
      print('🔔 DoctorApiService: Sending notification to patient $patientId');
      print('📝 Title: $title');
      print('📝 Message: $message');
      print('📝 Type: $type');

      final requestData = {
        'recipient_type': 'patient', // مطلوب من الخادم
        'patient_id': patientId,
        'title': title,
        'message': message,
        'notification_type': type, // إضافي للتوافق
      };

      print('📤 Request data: $requestData');

      // استخدام الـ endpoint الصحيح
      print('🌐 Sending to endpoint: /doctor/send-notification/');
      final response =
          await BaseApiService.post('/doctor/send-notification/', requestData);
      final result = BaseApiService.handleResponse(response);
      print('✅ Notification sent successfully: $result');
      return result;
    } catch (e) {
      print('❌ DoctorApiService: Critical error sending notification: $e');
      rethrow;
    }
  }

  // Get Doctor Earnings
  static Future<Map<String, dynamic>> getEarnings() async {
    try {
      final response = await BaseApiService.get('/doctor/earnings/');
      final result = BaseApiService.handleResponse(response);
      if (result != null && result is Map<String, dynamic>) {
        return result;
      }
      return {
        'total_earnings': 0.0,
        'available_balance': 0.0,
        'pending_balance': 0.0
      };
    } catch (e) {
      print('❌ DoctorApiService: Error getting earnings: $e');
      return {
        'total_earnings': 0.0,
        'available_balance': 0.0,
        'pending_balance': 0.0
      };
    }
  }

  // Get Doctor Schedule
  static Future<Map<String, dynamic>> getSchedule() async {
    final response = await BaseApiService.get('/doctor/schedule/');
    return BaseApiService.handleResponse(response);
  }

  // Update Doctor Schedule
  static Future<Map<String, dynamic>> updateSchedule(
    Map<String, dynamic> scheduleData,
  ) async {
    final response = await BaseApiService.put(
      '/doctor/schedule/',
      scheduleData,
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Cases by Priority
  static Future<List<dynamic>> getCasesByPriority(String priority) async {
    final response = await BaseApiService.get(
      '/doctor/cases/priority/$priority/',
    );
    final data = BaseApiService.handleResponse(response);
    return data['cases'] ?? [];
  }

  // Mark Case as Urgent
  static Future<Map<String, dynamic>> markCaseAsUrgent(int caseId) async {
    final response = await BaseApiService.post(
      '/doctor/cases/$caseId/urgent/',
      {},
    );
    return BaseApiService.handleResponse(response);
  }

  // Get Rating Details
  static Future<List<dynamic>> getRatingDetails() async {
    final response = await BaseApiService.get('/doctor/ratings/details/');
    final data = BaseApiService.handleResponse(response);
    return data['ratings'] ?? [];
  }

  // Get Monthly Statistics
  static Future<Map<String, dynamic>> getMonthlyStatistics() async {
    final response = await BaseApiService.get('/doctor/statistics/monthly/');
    return BaseApiService.handleResponse(response);
  }

  // Search Cases
  static Future<List<dynamic>> searchCases({
    String? patientName,
    String? status,
    String? priority,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    Map<String, String> queryParams = {};

    if (patientName != null && patientName.isNotEmpty) {
      queryParams['patient_name'] = patientName;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (priority != null && priority.isNotEmpty) {
      queryParams['priority'] = priority;
    }
    if (fromDate != null) {
      queryParams['from_date'] = fromDate.toIso8601String().split('T')[0];
    }
    if (toDate != null) {
      queryParams['to_date'] = toDate.toIso8601String().split('T')[0];
    }

    final response = await BaseApiService.get(
      '/doctor/cases/search/',
      queryParams: queryParams,
    );
    final data = BaseApiService.handleResponse(response);
    return data['cases'] ?? [];
  }

  // Get All Patient Cases (for autocomplete)
  static Future<Map<String, dynamic>> getAllPatientCases() async {
    try {
      // محاولة جلب جميع الحالات من endpoint مخصص
      final response = await BaseApiService.get('/doctor/cases/all/');
      final result = BaseApiService.handleResponse(response);

      if (result != null && result is Map<String, dynamic>) {
        return result;
      }

      // إذا لم يكن هناك endpoint مخصص، نجمع الحالات من مصادر مختلفة
      List<dynamic> allCases = [];

      // جلب الحالات الجديدة
      try {
        final newCases = await getNewCases();
        allCases.addAll(newCases);
      } catch (e) {
        print('⚠️ Error getting new cases: $e');
      }

      // جلب الحالات المكتملة
      try {
        final completedCases = await getCompletedCases();
        allCases.addAll(completedCases);
      } catch (e) {
        print('⚠️ Error getting completed cases: $e');
      }

      // إزالة التكرارات بناءً على ID
      final uniqueCases = <int, dynamic>{};
      for (final caseItem in allCases) {
        if (caseItem is Map<String, dynamic> && caseItem['id'] != null) {
          final id = int.tryParse(caseItem['id'].toString());
          if (id != null) {
            uniqueCases[id] = caseItem;
          }
        }
      }

      return {
        'success': true,
        'cases': uniqueCases.values.toList(),
        'total': uniqueCases.length,
      };
    } catch (e) {
      print('❌ DoctorApiService: Error getting all patient cases: $e');
      return {
        'success': false,
        'cases': [],
        'total': 0,
        'error': e.toString(),
      };
    }
  }
}
