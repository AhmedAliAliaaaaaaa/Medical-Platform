class MockDataService {
  // بيانات تجريبية للأطباء
  static List<Map<String, dynamic>> getMockDoctors() {
    return [
      {
        'id': 1,
        'user': {
          'first_name': 'د. سارة',
          'last_name': 'أحمد',
          'email': 'dr.sara@example.com',
          'phone': '+966501234567',
        },
        'specialization': 'cardiology',
        'country': 'السعودية',
        'city': 'الرياض',
        'price': 150.0,
        'rating': 4.8,
        'reviews_count': 245,
        'experience_years': 12,
        'status': 'approved',
        'created_at': '2024-01-01T08:00:00Z',
        'cases_count': 156,
        'profile_image': null,
        'bio':
            'استشاري أمراض القلب مع خبرة 12 سنة في علاج أمراض القلب والشرايين',
        'education': 'دكتوراه في أمراض القلب - جامعة الملك سعود',
        'certifications': ['البورد السعودي', 'البورد الأمريكي'],
        'languages': ['العربية', 'الإنجليزية'],
        'available_times': ['09:00-12:00', '14:00-17:00'],
      },
      {
        'id': 2,
        'user': {
          'first_name': 'د. محمد',
          'last_name': 'حسن',
          'email': 'dr.mohamed@example.com',
          'phone': '+20101234567',
        },
        'specialization': 'general',
        'country': 'مصر',
        'city': 'القاهرة',
        'price': 100.0,
        'rating': 4.6,
        'reviews_count': 189,
        'experience_years': 8,
        'status': 'approved',
        'created_at': '2024-01-05T12:30:00Z',
        'cases_count': 98,
        'profile_image': null,
        'bio': 'طبيب عام متخصص في الطب الباطني والأمراض المزمنة',
        'education': 'بكالوريوس الطب والجراحة - جامعة القاهرة',
        'certifications': ['دبلوم الطب الباطني'],
        'languages': ['العربية', 'الإنجليزية'],
        'available_times': ['10:00-13:00', '15:00-18:00'],
      },
      {
        'id': 3,
        'user': {
          'first_name': 'د. فاطمة',
          'last_name': 'علي',
          'email': 'dr.fatima@example.com',
          'phone': '+971501234567',
        },
        'specialization': 'pediatrics',
        'country': 'الإمارات',
        'city': 'دبي',
        'price': 120.0,
        'rating': 4.9,
        'reviews_count': 312,
        'experience_years': 15,
        'status': 'approved',
        'created_at': '2023-12-15T09:15:00Z',
        'cases_count': 203,
        'profile_image': null,
        'bio': 'استشاري طب الأطفال وحديثي الولادة مع خبرة واسعة',
        'education': 'دكتوراه في طب الأطفال - الجامعة الأمريكية',
        'certifications': ['البورد الأمريكي', 'البورد الإماراتي'],
        'languages': ['العربية', 'الإنجليزية', 'الفرنسية'],
        'available_times': ['08:00-11:00', '16:00-19:00'],
      },
      {
        'id': 4,
        'user': {
          'first_name': 'د. أحمد',
          'last_name': 'الخالدي',
          'email': 'dr.ahmed@example.com',
          'phone': '+962791234567',
        },
        'specialization': 'dermatology',
        'country': 'الأردن',
        'city': 'عمان',
        'price': 80.0,
        'rating': 4.4,
        'reviews_count': 156,
        'experience_years': 6,
        'status': 'approved',
        'created_at': '2024-01-10T14:20:00Z',
        'cases_count': 67,
        'profile_image': null,
        'bio': 'طبيب جلدية متخصص في علاج الأمراض الجلدية والتجميل',
        'education': 'ماجستير الأمراض الجلدية - الجامعة الأردنية',
        'certifications': ['البورد الأردني'],
        'languages': ['العربية', 'الإنجليزية'],
        'available_times': ['09:00-12:00', '14:00-17:00'],
      },
      {
        'id': 5,
        'user': {
          'first_name': 'د. ليلى',
          'last_name': 'المنصوري',
          'email': 'dr.layla@example.com',
          'phone': '+212661234567',
        },
        'specialization': 'orthopedics',
        'country': 'المغرب',
        'city': 'الرباط',
        'price': 90.0,
        'rating': 4.7,
        'reviews_count': 98,
        'experience_years': 10,
        'status': 'approved',
        'created_at': '2023-12-20T11:45:00Z',
        'cases_count': 45,
        'profile_image': null,
        'bio': 'استشاري جراحة العظام والمفاصل',
        'education': 'دكتوراه في جراحة العظام - جامعة محمد الخامس',
        'certifications': ['البورد المغربي', 'البورد الفرنسي'],
        'languages': ['العربية', 'الفرنسية', 'الإنجليزية'],
        'available_times': ['08:00-11:00', '15:00-18:00'],
      },
    ];
  }

  // بيانات تجريبية للمرضى
  static List<Map<String, dynamic>> getMockPatients() {
    return [
      {
        'id': 1,
        'user': {
          'first_name': 'أحمد',
          'last_name': 'محمد',
          'email': 'ahmed@example.com',
          'phone': '+966501234567',
        },
        'status': 'active',
        'created_at': '2024-01-15T10:30:00Z',
        'cases_count': 5,
        'age': 35,
        'gender': 'male',
        'city': 'الرياض',
        'country': 'السعودية',
      },
      {
        'id': 2,
        'user': {
          'first_name': 'فاطمة',
          'last_name': 'علي',
          'email': 'fatima@example.com',
          'phone': '+966507654321',
        },
        'status': 'active',
        'created_at': '2024-01-18T14:20:00Z',
        'cases_count': 3,
        'age': 28,
        'gender': 'female',
        'city': 'جدة',
        'country': 'السعودية',
      },
      {
        'id': 3,
        'user': {
          'first_name': 'خالد',
          'last_name': 'السعد',
          'email': 'khalid@example.com',
          'phone': '+966509876543',
        },
        'status': 'blocked',
        'created_at': '2024-01-10T09:15:00Z',
        'cases_count': 1,
        'age': 42,
        'gender': 'male',
        'city': 'الدمام',
        'country': 'السعودية',
      },
    ];
  }

  // بيانات تجريبية للحالات الطبية
  static List<Map<String, dynamic>> getMockCases() {
    return [
      {
        'id': 1,
        'patient_name': 'أحمد محمد',
        'doctor_name': 'د. سارة أحمد',
        'doctor_id': 1,
        'patient_id': 1,
        'title': 'ألم في الصدر',
        'description': 'أعاني من ألم في الصدر منذ يومين، خاصة عند بذل مجهود',
        'status': 'pending',
        'priority': 'high',
        'created_at': '2024-01-21T10:30:00Z',
        'updated_at': '2024-01-21T10:30:00Z',
        'specialization': 'cardiology',
        'files': [
          {
            'id': 1,
            'name': 'تخطيط_القلب.pdf',
            'type': 'pdf',
            'url': '/files/ecg_report.pdf',
          },
        ],
        'response': null,
        'rating': null,
        'review': null,
      },
      {
        'id': 2,
        'patient_name': 'فاطمة علي',
        'doctor_name': 'د. محمد حسن',
        'doctor_id': 2,
        'patient_id': 2,
        'title': 'صداع مستمر',
        'description': 'أعاني من صداع مستمر منذ أسبوع مع دوخة خفيفة',
        'status': 'in_progress',
        'priority': 'medium',
        'created_at': '2024-01-20T14:15:00Z',
        'updated_at': '2024-01-21T09:20:00Z',
        'specialization': 'general',
        'files': [],
        'response': null,
        'rating': null,
        'review': null,
      },
      {
        'id': 3,
        'patient_name': 'خالد السعد',
        'doctor_name': 'د. فاطمة علي',
        'doctor_id': 3,
        'patient_id': 3,
        'title': 'حمى عند الطفل',
        'description': 'طفلي عمره 5 سنوات يعاني من حمى 38.5 درجة منذ يومين',
        'status': 'completed',
        'priority': 'high',
        'created_at': '2024-01-18T16:45:00Z',
        'updated_at': '2024-01-19T11:30:00Z',
        'specialization': 'pediatrics',
        'files': [
          {
            'id': 2,
            'name': 'صورة_الطفل.jpg',
            'type': 'image',
            'url': '/files/child_photo.jpg',
          },
        ],
        'response': {
          'id': 1,
          'content':
              'بناءً على الأعراض المذكورة، أنصح بإعطاء الطفل خافض حرارة مناسب لعمره...',
          'type': 'text',
          'files': [
            {'name': 'وصفة_طبية.pdf', 'url': '/responses/prescription.pdf'},
          ],
          'created_at': '2024-01-19T11:30:00Z',
        },
        'rating': 5,
        'review': 'طبيبة ممتازة وسريعة في الرد',
      },
    ];
  }

  // بيانات تجريبية للإحصائيات
  static Map<String, dynamic> getMockStatistics() {
    return {
      'total_users': 1250,
      'total_patients': 980,
      'total_doctors': 85,
      'active_doctors': 72,
      'pending_doctors': 8,
      'total_cases': 2340,
      'pending_cases': 45,
      'in_progress_cases': 23,
      'completed_cases': 2272,
      'cancelled_cases': 12,
      'average_response_time': 18.5,
      'patient_satisfaction': 4.6,
      'doctor_satisfaction': 4.4,
      'revenue': {'total': 125000, 'this_month': 15600, 'last_month': 14200},
      'growth': {'users': 12.5, 'cases': 8.3, 'revenue': 9.8},
      'top_specializations': [
        {'name': 'طب عام', 'count': 450},
        {'name': 'طب الأطفال', 'count': 320},
        {'name': 'أمراض القلب', 'count': 280},
        {'name': 'الأمراض الجلدية', 'count': 210},
        {'name': 'العظام', 'count': 180},
      ],
      'monthly_cases': [
        {'month': 'يناير', 'cases': 180},
        {'month': 'فبراير', 'cases': 195},
        {'month': 'مارس', 'cases': 220},
        {'month': 'أبريل', 'cases': 205},
        {'month': 'مايو', 'cases': 240},
        {'month': 'يونيو', 'cases': 260},
      ],
    };
  }

  // بيانات تجريبية للإشعارات
  static List<Map<String, dynamic>> getMockNotifications() {
    return [
      {
        'id': 1,
        'title': 'رد طبي جديد',
        'message': 'تم الرد على حالتك الطبية من قبل د. سارة أحمد',
        'type': 'medical_response',
        'is_read': false,
        'created_at': '2024-01-21T14:30:00Z',
        'data': {'case_id': 1, 'doctor_name': 'د. سارة أحمد'},
      },
      {
        'id': 2,
        'title': 'حالة جديدة',
        'message': 'تم تعيين حالة طبية جديدة لك',
        'type': 'new_case',
        'is_read': false,
        'created_at': '2024-01-21T10:15:00Z',
        'data': {'case_id': 2, 'patient_name': 'فاطمة علي'},
      },
      {
        'id': 3,
        'title': 'تقييم جديد',
        'message': 'تم تقييمك بـ 5 نجوم من قبل مريض',
        'type': 'rating',
        'is_read': true,
        'created_at': '2024-01-20T16:45:00Z',
        'data': {'rating': 5, 'case_id': 3},
      },
    ];
  }

  // بيانات تجريبية لسجل الإشعارات
  static List<Map<String, dynamic>> getMockNotificationHistory() {
    return [
      {
        'id': 1,
        'title': 'تحديث النظام',
        'message': 'تم تحديث النظام بميزات جديدة',
        'sent_to': 'جميع المستخدمين',
        'sent_at': '2024-01-21T14:30:00Z',
        'recipients_count': 1250,
      },
      {
        'id': 2,
        'title': 'صيانة مجدولة',
        'message': 'سيتم إجراء صيانة للنظام غداً من الساعة 2-4 صباحاً',
        'sent_to': 'جميع المستخدمين',
        'sent_at': '2024-01-20T10:15:00Z',
        'recipients_count': 1250,
      },
      {
        'id': 3,
        'title': 'تذكير للأطباء',
        'message': 'يرجى الرد على الحالات المعلقة في أسرع وقت ممكن',
        'sent_to': 'الأطباء فقط',
        'sent_at': '2024-01-19T16:45:00Z',
        'recipients_count': 85,
      },
    ];
  }

  // بيانات تجريبية لمراجعات الأطباء
  static List<Map<String, dynamic>> getMockDoctorReviews(int doctorId) {
    return [
      {
        'id': 1,
        'patient_name': 'أحمد محمد',
        'rating': 5,
        'review': 'طبيبة ممتازة وسريعة في الرد، أنصح بها بشدة',
        'case_title': 'ألم في الصدر',
        'created_at': '2024-01-20T15:30:00Z',
      },
      {
        'id': 2,
        'patient_name': 'فاطمة علي',
        'rating': 4,
        'review': 'تشخيص دقيق ونصائح مفيدة',
        'case_title': 'صداع مستمر',
        'created_at': '2024-01-18T12:20:00Z',
      },
      {
        'id': 3,
        'patient_name': 'خالد السعد',
        'rating': 5,
        'review': 'خبرة واسعة وتعامل ممتاز مع الأطفال',
        'case_title': 'حمى عند الطفل',
        'created_at': '2024-01-15T09:45:00Z',
      },
    ];
  }

  // بيانات تجريبية لحالات الطبيب
  static List<Map<String, dynamic>> getMockDoctorCases(int doctorId) {
    return getMockCases()
        .where((case_) => case_['doctor_id'] == doctorId)
        .toList();
  }

  // بيانات تجريبية لحالات المريض
  static List<Map<String, dynamic>> getMockPatientCases(int patientId) {
    return getMockCases()
        .where((case_) => case_['patient_id'] == patientId)
        .toList();
  }
}
