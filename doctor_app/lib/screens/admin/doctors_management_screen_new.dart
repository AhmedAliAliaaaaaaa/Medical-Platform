import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/admin_api_service.dart';
import '../../services/api_service.dart';
import '../../services/base_api_service.dart';
import '../../core/config/app_config.dart';
import '../../utils/app_theme.dart';
import '../../widgets/enhanced_card.dart';
import 'doctor_details_enhanced_screen.dart';

class DoctorsManagementScreen extends StatefulWidget {
  final int initialTabIndex; // 0: المعتمدون، 1: المعلقة
  const DoctorsManagementScreen({super.key, this.initialTabIndex = 0});

  @override
  State<DoctorsManagementScreen> createState() =>
      _DoctorsManagementScreenState();
}

class _DoctorsManagementScreenState extends State<DoctorsManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _doctors = [];
  List<Map<String, dynamic>> _pendingDoctors = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Controllers
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final ScrollController _scrollController;

  // Search
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // ألوان مستلهمة من تصميم صفحة المرضى
  static const Color _orange = Color(0xFFF97316); // برتقالي واضح
  static const Color _lightOrange = Color(0xFFFFE6D1);
  static const Color _darkBlue = Color(0xFF1E3A8A);
  static const Color _softBg = Color(0xFFF6F8FB);
  static const Color _card = Colors.white;
  static const Color _textPrimary = Color(0xFF101828);
  static const Color _textSecondary = Color(0xFF475467);

  static const TextStyle _title =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _textPrimary);
  static const TextStyle _subtitle = TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600, color: _textSecondary);
  static const TextStyle _btn =
      TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white);

  static List<BoxShadow> get _shadowSoft => [
        BoxShadow(
            color: const Color(0xFF101828).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8)),
      ];

  // خريطة تحويل التخصصات إلى العربية
  static const Map<String, String> _specMap = {
    'general': 'طب عام',
    'cardiology': 'أمراض القلب',
    'dermatology': 'الأمراض الجلدية',
    'neurology': 'الأمراض العصبية',
    'orthopedics': 'العظام',
    'pediatrics': 'طب الأطفال',
    'psychiatry': 'الطب النفسي',
    'gynecology': 'أمراض النساء',
    'urology': 'المسالك البولية',
    'ophthalmology': 'طب العيون',
    'ent': 'الأنف والأذن والحنجرة',
    'dentistry': 'طب الأسنان',
  };

  String _arabicSpecialization(String? code) {
    if (code == null || code.trim().isEmpty) return 'طبيب عام';
    final c = code.trim().toLowerCase();
    return _specMap[c] ?? code;
  }

  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnimation =
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut);
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOutCubic));
    _scrollController = ScrollController();

    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );

    _loadData();
    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    // تحديث البيانات تلقائيًا كل 30 ثانية
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _autoRefreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // جلب بيانات الأطباء المعتمدين
      final Object? approvedResponse = await AdminApiService.getAllDoctors();
      // جلب بيانات الأطباء المعلقين
      final Object? pendingResponse = await AdminApiService.getPendingDoctors();

      setState(() {
        final List<Map<String, dynamic>> approvedList =
            (approvedResponse is List)
                ? approvedResponse
                    .whereType<Map>()
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList()
                : (approvedResponse is Map)
                    ? (((approvedResponse as Map)['doctors'] as List?) ?? [])
                        .whereType<Map>()
                        .map((e) => Map<String, dynamic>.from(e))
                        .toList()
                    : <Map<String, dynamic>>[];

        final List<Map<String, dynamic>> pendingList = (pendingResponse is List)
            ? pendingResponse
                .whereType<Map>()
                .map((e) => Map<String, dynamic>.from(e))
                .toList()
            : (pendingResponse is Map)
                ? (((pendingResponse as Map)['doctors'] as List?) ?? [])
                    .whereType<Map>()
                    .map((e) => Map<String, dynamic>.from(e))
                    .toList()
                : <Map<String, dynamic>>[];

        _doctors = approvedList;
        _pendingDoctors = pendingList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // عرض تفاصيل الطبيب - مطابق لصفحة التفاصيل في الويب
  void _viewDoctorDetails(Map<String, dynamic> doctor) async {
    final idValue = (doctor['id'] ?? doctor['user']?['id']);
    if (idValue == null) return;
    final doctorId = int.parse(idValue.toString());
    
    // جلب بيانات الطبيب الكاملة من الـ API
    try {
      // استخدام BaseApiService مباشرة للحصول على بيانات أكثر تفصيلاً
      final response = await BaseApiService.get('/admin/doctors/$doctorId/');
      final fullDoctorData = BaseApiService.handleResponse(response);
      
      // طباعة البيانات للتحقق منها
      print('بيانات الطبيب الكاملة: $fullDoctorData');
      
      // دمج البيانات الأصلية مع البيانات الجديدة
      final mergedData = Map<String, dynamic>.from(doctor);
      mergedData.addAll(fullDoctorData);
      
      // التأكد من وجود الحقول المطلوبة
      if (mergedData['license_number'] == null) {
        mergedData['license_number'] = 'غير محدد';
      }
      if (mergedData['bio'] == null || mergedData['bio'].toString().isEmpty) {
        mergedData['bio'] = 'لا توجد نبذة متاحة';
      }
      if (mergedData['license_image'] == null) {
        mergedData['license_image'] = '';
      }

      // التأكد من وجود حقول الأسعار
      if (mergedData['regular_consultation_price'] == null) {
        mergedData['regular_consultation_price'] = 0;
      }
      if (mergedData['emergency_consultation_price'] == null) {
        mergedData['emergency_consultation_price'] = 0;
      }
      if (mergedData['follow_up_consultation_price'] == null) {
        mergedData['follow_up_consultation_price'] = 0;
      }
      if (mergedData['currency'] == null) {
        mergedData['currency'] = 'ريال سعودي';
      }
      
      // طباعة البيانات النهائية قبل عرضها
      print('البيانات النهائية التي سيتم عرضها: $mergedData');
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DoctorDetailsEnhancedScreen(doctor: mergedData),
        ),
      );
    } catch (e) {
      print('خطأ في جلب بيانات الطبيب: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل في جلب بيانات الطبيب: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }



  // بناء بطاقة الطبيب
  Widget _buildDoctorCard(Map<String, dynamic> doctor, bool isPending) {
    final user = doctor['user'] ?? {};
    final String name = (doctor['name'] as String?)?.trim().isNotEmpty == true
        ? (doctor['name'] as String)
        : ((user['get_full_name'] as String?)?.trim().isNotEmpty == true
            ? user['get_full_name']
            : '${(user['first_name'] ?? '').toString()} ${(user['last_name'] ?? '').toString()}'
                .trim());
    final String email = (doctor['email'] ?? user['email'] ?? '').toString();
    final String phone =
        (doctor['phone'] ?? user['phone'] ?? user['phone_number'] ?? 'غير محدد')
            .toString();
    final specialization =
        _arabicSpecialization(doctor['specialization']?.toString());
    final status = doctor['status'] ?? 'approved';
    final rating = doctor['rating']?.toString() ?? '0.0';
    final casesCount = doctor['cases_count']?.toString() ?? '0';
    final experienceYears = doctor['experience_years']?.toString() ?? '0';
    final licenseNumber = doctor['license_number'] ?? 'غير محدد';
    final country = doctor['country'] ?? 'غير محدد';
    final bio = doctor['bio'] ?? 'لا توجد نبذة متاحة';
    final profileImage = doctor['profile_image'];
    final licenseImage = doctor['license_image'] ?? '';
    final isAvailable = doctor['is_available'] ?? true;
    final createdAt = doctor['created_at'] ?? '';
    final totalReviews = doctor['total_reviews'] ?? 0;
    final consultationFee =
        doctor['consultation_fee']?.toString() ?? 'غير محدد';
    final emergencyFee = doctor['emergency_fee']?.toString() ?? 'غير محدد';
    final followUpFee = doctor['follow_up_fee']?.toString() ?? 'غير محدد';
    final currency = doctor['currency'] ?? 'SAR';
    final acceptsInsurance = doctor['accepts_insurance'] ?? false;
    
    // التأكد من وجود جميع الحقول المطلوبة
    doctor['phone'] = phone;
    doctor['license_number'] = licenseNumber;
    doctor['bio'] = bio;
    doctor['license_image'] = licenseImage;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _viewDoctorDetails(doctor),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            // الجزء العلوي من البطاقة
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // صورة الطبيب
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: _darkBlue,
                    backgroundImage: (() {
                      final img =
                          (profileImage is String && profileImage.isNotEmpty)
                              ? profileImage
                              : (user['profile_image']?.toString() ?? '');
                      if (img.isNotEmpty) {
                        return NetworkImage(_resolveImageUrl(img));
                      }
                      return null;
                    })(),
                    child: (() {
                      final img =
                          (profileImage is String && profileImage.isNotEmpty)
                              ? profileImage
                              : (user['profile_image']?.toString() ?? '');
                      if (img.isEmpty) {
                        return Text(
                          name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }
                      return null;
                    })(),
                  ),
                  const SizedBox(width: 16),
                  // معلومات الطبيب
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          specialization,
                          style: const TextStyle(
                            fontSize: 14,
                            color: _textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // أزرار الإجراءات للأطباء المعلقين
                  if (isPending)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // زر التفاصيل
                        IconButton(
                          onPressed: () => _viewDoctorDetails(doctor),
                          icon:
                              const Icon(Icons.visibility, color: Colors.blue),
                          tooltip: 'التفاصيل',
                        ),
                        // زر الموافقة
                        IconButton(
                          onPressed: () => _approveDoctor(doctor),
                          icon: const Icon(Icons.check, color: Colors.green),
                          tooltip: 'الموافقة',
                        ),
                        // زر الرفض
                        IconButton(
                          onPressed: () => _rejectDoctor(doctor),
                          icon: const Icon(Icons.close, color: Colors.red),
                          tooltip: 'رفض',
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // معلومات إضافية
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // حالة الطبيب
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: status == 'approved'
                              ? Colors.green.shade100
                              : status == 'pending'
                                  ? Colors.orange.shade100
                                  : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          status == 'approved'
                              ? 'معتمد'
                              : status == 'pending'
                                  ? 'قيد المراجعة'
                                  : 'مرفوض',
                          style: TextStyle(
                            color: status == 'approved'
                                ? Colors.green.shade700
                                : status == 'pending'
                                    ? Colors.orange.shade700
                                    : Colors.red.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // متاح للاستشارات
                      if (!isPending)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isAvailable
                                ? Colors.green.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isAvailable ? 'متاح' : 'غير متاح',
                            style: TextStyle(
                              color: isAvailable
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const Spacer(),
                      // التقييم
                      if (!isPending)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$rating ($totalReviews)',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      const Spacer(),
                      // عدد الحالات
                      if (!isPending)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.folder,
                                color: Colors.blue, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$casesCount حالة',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء قائمة الأطباء
  Widget _buildDoctorsList(List<Map<String, dynamic>> doctors, bool isPending) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Text(_errorMessage!),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isPending ? Icons.hourglass_empty : Icons.person_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              isPending
                  ? 'لا يوجد أطباء في انتظار الموافقة'
                  : 'لا يوجد أطباء معتمدون',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    // تصفية الأطباء حسب البحث
    final List<Map<String, dynamic>> filteredDoctors = doctors.where((doctor) {
      final user = doctor['user'] ?? {};
      final name = (doctor['name'] as String?)?.trim().isNotEmpty == true
          ? (doctor['name'] as String)
          : ((user['get_full_name'] as String?)?.trim().isNotEmpty == true
              ? user['get_full_name']
              : '${(user['first_name'] ?? '').toString()} ${(user['last_name'] ?? '').toString()}'
                  .trim());
      final specialization =
          _arabicSpecialization(doctor['specialization']?.toString());
      final email = (doctor['email'] ?? user['email'] ?? '').toString();
      final phone =
          (doctor['phone'] ?? user['phone'] ?? user['phone_number'] ?? '')
              .toString();

      final query = _searchQuery.toLowerCase();
      return name.toLowerCase().contains(query) ||
          specialization.toLowerCase().contains(query) ||
          email.toLowerCase().contains(query) ||
          phone.toLowerCase().contains(query);
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: filteredDoctors.length,
        itemBuilder: (context, index) {
          return _buildDoctorCard(filteredDoctors[index], isPending);
        },
      ),
    );
  }

  // بناء صفحة الأطباء المعتمدين
  Widget _buildApprovedDoctorsTab() {
    return _buildDoctorsList(_doctors, false);
  }

  // بناء صفحة الأطباء المعلقين
  Widget _buildPendingDoctorsTab() {
    return _buildDoctorsList(_pendingDoctors, true);
  }

  // بناء شريط البحث
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadowSoft,
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'ابحث عن طبيب...',
          hintStyle: TextStyle(color: _textSecondary),
          prefixIcon: Icon(Icons.search, color: _textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                  icon: Icon(Icons.clear, color: _textSecondary),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _animationController.forward();

    return Scaffold(
      backgroundColor: _softBg,
      appBar: AppBar(
        title: const Text('إدارة الأطباء'),
        backgroundColor: _darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'المعتمدون'),
            Tab(text: 'قيد المراجعة'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildApprovedDoctorsTab(),
                    _buildPendingDoctorsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة لتحويل عناوين URL
  String _resolveImageUrl(String url) {
    if (url.startsWith('http')) {
      return url;
    }
    // إذا كان الرابط نسبي، أضف اسم النطاق الأساسي
    return '${AppConfig.getBaseUrl()}${url.startsWith('/') ? '' : '/'}$url';
  }

  // الموافقة على طبيب
  Future<void> _approveDoctor(Map<String, dynamic> doctor) async {
    final idValue = (doctor['id'] ?? doctor['user']?['id']);
    if (idValue == null) return;
    final doctorId = int.parse(idValue.toString());
    
    try {
      // عرض مربع حوار للتأكيد
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد الموافقة'),
          content: Text('هل أنت متأكد من الموافقة على الطبيب؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('موافقة'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      // إظهار مؤشر التحميل
      setState(() => _isLoading = true);
      
      // إرسال طلب الموافقة
      final response = await AdminApiService.approveDoctorApplication(applicationId: doctorId);
      
      if (response['success'] == true) {
        // إزالة الطبيب من قائمة المعلقين
        setState(() {
          _pendingDoctors.removeWhere((d) => (d['id'] ?? d['user']?['id']).toString() == idValue.toString());
          
          // إضافة الطبيب إلى قائمة المعتمدين مع تحديث حالته
          final approvedDoctor = Map<String, dynamic>.from(doctor);
          approvedDoctor['status'] = 'approved';
          _doctors.add(approvedDoctor);
        });
        
        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الموافقة على الطبيب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // إظهار رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشلت الموافقة على الطبيب: ${response['message'] ?? 'خطأ غير معروف'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // إظهار رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // إخفاء مؤشر التحميل
      setState(() => _isLoading = false);
    }
  }

  // رفض طبيب
  Future<void> _rejectDoctor(Map<String, dynamic> doctor) async {
    final idValue = (doctor['id'] ?? doctor['user']?['id']);
    if (idValue == null) return;
    final doctorId = int.parse(idValue.toString());
    
    try {
      // عرض مربع حوار للتأكيد
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('تأكيد الرفض'),
          content: Text('هل أنت متأكد من رفض الطبيب؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('رفض'),
            ),
          ],
        ),
      );
      
      if (confirmed != true) return;
      
      // إظهار مؤشر التحميل
      setState(() => _isLoading = true);
      
      // إرسال طلب الرفض
      final response = await AdminApiService.rejectDoctorApplication(applicationId: doctorId, reason: 'تم رفض الطلب من قبل الإدارة');
      
      if (response['success'] == true) {
        // إزالة الطبيب من قائمة المعلقين
        setState(() {
          _pendingDoctors.removeWhere((d) => (d['id'] ?? d['user']?['id']).toString() == idValue.toString());
        });
        
        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض الطبيب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // إظهار رسالة خطأ
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل رفض الطبيب: ${response['message'] ?? 'خطأ غير معروف'}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // إظهار رسالة خطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // إخفاء مؤشر التحميل
      setState(() => _isLoading = false);
    }
  }
}
