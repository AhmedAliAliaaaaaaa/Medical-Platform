import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/admin_api_service.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _patients = [];
  List<dynamic> _doctors = [];
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
    _tabController = TabController(length: 2, vsync: this);
    _loadUsers();
    // Auto refresh disabled due to stability issues
    // _autoRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
    //   if (mounted) _loadUsers();
    // });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _scrollController.dispose();
    _tabController.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('👥 تحميل المستخدمين...');

      // تحميل المرضى
      final patients = await AdminApiService.getAllPatients();
      print('✅ تم تحميل ${patients.length} مريض');

      // تحميل الأطباء
      final doctors = await AdminApiService.getAllDoctors();
      print('✅ تم تحميل ${doctors.length} طبيب');

      setState(() {
        _patients = patients;
        _doctors = doctors;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في تحميل المستخدمين: $e');
      // استخدام بيانات تجريبية
      setState(() {
        _patients = [
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
          },
        ];
        _doctors = [
          {
            'id': 1,
            'user': {
              'first_name': 'د. سارة',
              'last_name': 'أحمد',
              'email': 'dr.sara@example.com',
              'phone': '+966501111111',
            },
            'specialization': 'cardiology',
            'status': 'approved',
            'created_at': '2024-01-01T08:00:00Z',
            'cases_count': 25,
            'rating': 4.8,
          },
          {
            'id': 2,
            'user': {
              'first_name': 'د. محمد',
              'last_name': 'حسن',
              'email': 'dr.mohamed@example.com',
              'phone': '+966502222222',
            },
            'specialization': 'general',
            'status': 'approved',
            'created_at': '2024-01-05T12:30:00Z',
            'cases_count': 18,
            'rating': 4.6,
          },
        ];
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _softBg,
        appBar: AppBar(
          title: const Text('إدارة المستخدمين'),
          backgroundColor: _darkBlue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUsers,
              tooltip: 'تحديث',
            ),
          ],
        ),
        body: _isLoading
            ? _buildLoading()
            : _errorMessage != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  // ============ UI ============
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadUsers,
      color: AppTheme.primaryBlue,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.all(16),
                child: _buildSearchBar(),
              ),
              // Tab bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _shadowSoft,
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: _orange,
                  labelColor: _orange,
                  unselectedLabelColor: _textSecondary,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.people),
                      text: 'المرضى',
                    ),
                    Tab(
                      icon: Icon(Icons.medical_services),
                      text: 'الأطباء',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Tab content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Patients tab
                    _buildPatientsList(),
                    // Doctors tab
                    _buildDoctorsList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Search bar
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadowSoft,
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث عن مستخدم...',
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                });
              },
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }

  // Loading widget
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _orange),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل البيانات...',
            style: _subtitle,
          ),
        ],
      ),
    );
  }

  // Error widget
  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'خطأ في تحميل البيانات',
            style: TextStyle(fontSize: 18, color: Colors.red.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUsers,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // قائمة المرضى
  Widget _buildPatientsList() {
    // تطبيق البحث
    List<dynamic> filteredPatients = _patients;
    if (_searchQuery.isNotEmpty) {
      filteredPatients = _patients.where((patient) {
        final user = patient['user'] ?? {};
        final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
        final email = user['email'] ?? '';
        final phone = user['phone'] ?? '';
        final query = _searchQuery.toLowerCase();
        return name.toLowerCase().contains(query) ||
            email.toLowerCase().contains(query) ||
            phone.toLowerCase().contains(query);
      }).toList();
    }

    if (filteredPatients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'لا توجد نتائج للبحث' : 'لا يوجد مرضى',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredPatients.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final patient = filteredPatients[index];
          return _buildPatientCard(patient);
        },
      ),
    );
  }

  // بطاقة المريض
  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final user = patient['user'] ?? {};
    final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
    final email = user['email'] ?? '';
    final phone = user['phone'] ?? '';
    final status = patient['status'] ?? 'active';
    final casesCount = patient['cases_count'] ?? 0;
    final patientId = patient['id'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات المريض
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _darkBlue,
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
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
                      'مريض',
                      style: _subtitle,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'active'
                      ? Colors.green.shade100
                      : Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status == 'active' ? 'نشط' : 'محظور',
                  style: TextStyle(
                    color: status == 'active'
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // معلومات الاتصال
          Row(
            children: [
              Icon(Icons.email, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  email,
                  style: _subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.phone, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  phone,
                  style: _subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              Icon(Icons.medical_services, color: _darkBlue, size: 16),
              const SizedBox(width: 4),
              Text(
                '$casesCount حالة',
                style: _subtitle,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // أزرار الإجراءات
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewPatientDetails(patient),
                  icon: const Icon(Icons.visibility),
                  label: const Text('التفاصيل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _darkBlue,
                    side: BorderSide(color: _darkBlue),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _editPatient(patient),
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _togglePatientStatus(patientId, status),
                  icon: Icon(
                      status == 'active' ? Icons.block : Icons.check_circle),
                  label: Text(status == 'active' ? 'حظر' : 'إلغاء الحظر'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        status == 'active' ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // قائمة الأطباء
  Widget _buildDoctorsList() {
    // تطبيق البحث
    List<dynamic> filteredDoctors = _doctors;
    if (_searchQuery.isNotEmpty) {
      filteredDoctors = _doctors.where((doctor) {
        final user = doctor['user'] ?? {};
        final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
        final email = user['email'] ?? '';
        final specialization = doctor['specialization'] ?? '';
        final query = _searchQuery.toLowerCase();
        return name.toLowerCase().contains(query) ||
            email.toLowerCase().contains(query) ||
            specialization.toLowerCase().contains(query);
      }).toList();
    }

    if (filteredDoctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'لا توجد نتائج للبحث' : 'لا يوجد أطباء',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredDoctors.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doctor = filteredDoctors[index];
          return _buildDoctorCard(doctor);
        },
      ),
    );
  }

  // بطاقة الطبيب
  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    final user = doctor['user'] ?? {};
    final name = '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
    final email = user['email'] ?? '';
    final specialization = doctor['specialization'] ?? 'طبيب عام';
    final status = doctor['status'] ?? 'approved';
    final rating = doctor['rating'] ?? 0.0;
    final casesCount = doctor['cases_count'] ?? 0;
    final doctorId = int.parse(doctor['id'].toString());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // معلومات الطبيب
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: _darkBlue,
                backgroundImage: doctor['profile_image'] != null
                    ? NetworkImage(doctor['profile_image'])
                    : null,
                child: doctor['profile_image'] == null
                    ? Text(
                        name.isNotEmpty ? name[0] : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
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
                      style: _subtitle,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'approved'
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status == 'approved' ? 'معتمد' : 'قيد المراجعة',
                  style: TextStyle(
                    color: status == 'approved'
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // معلومات إضافية
          Row(
            children: [
              if (status == 'approved') ...[
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating.toString(),
                  style: _subtitle,
                ),
                const SizedBox(width: 16),
                Icon(Icons.medical_services, color: _darkBlue, size: 16),
                const SizedBox(width: 4),
                Text(
                  '$casesCount حالة',
                  style: _subtitle,
                ),
              ] else
                Icon(Icons.access_time, color: Colors.orange, size: 16),
              const Spacer(),
              Icon(Icons.email, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  email,
                  style: _subtitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // أزرار الإجراءات
          if (status == 'approved')
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDoctorDetails(doctor),
                    icon: const Icon(Icons.visibility),
                    label: const Text('التفاصيل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _darkBlue,
                      side: BorderSide(color: _darkBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editDoctor(doctor),
                    icon: const Icon(Icons.edit),
                    label: const Text('تعديل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleDoctorStatus(doctorId, status),
                    icon: Icon(
                        status == 'active' ? Icons.block : Icons.check_circle),
                    label: Text(status == 'active' ? 'تعطيل' : 'تفعيل'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          status == 'active' ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDoctorDetails(doctor),
                    icon: const Icon(Icons.visibility),
                    label: const Text('التفاصيل'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _darkBlue,
                      side: BorderSide(color: _darkBlue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rejectDoctor(doctorId),
                    icon: const Icon(Icons.close),
                    label: const Text('رفض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _approveDoctor(doctorId),
                    icon: const Icon(Icons.check),
                    label: const Text('موافقة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // عرض تفاصيل المريض
  void _viewPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
            '${patient['user']?['first_name'] ?? ''} ${patient['user']?['last_name'] ?? ''}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('الاسم',
                  '${patient['user']?['first_name'] ?? ''} ${patient['user']?['last_name'] ?? ''}'),
              _buildDetailRow('البريد الإلكتروني', patient['user']?['email']),
              _buildDetailRow('الهاتف', patient['user']?['phone']),
              _buildDetailRow(
                  'الحالة', patient['status'] == 'active' ? 'نشط' : 'محظور'),
              _buildDetailRow('عدد الحالات', '${patient['cases_count'] ?? 0}'),
              _buildDetailRow('تاريخ التسجيل', patient['created_at']),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // تعديل بيانات المريض
  void _editPatient(Map<String, dynamic> patient) {
    final user = patient['user'] ?? {};
    final firstNameController = TextEditingController(text: user['first_name']);
    final lastNameController = TextEditingController(text: user['last_name']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController = TextEditingController(text: user['phone']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات المريض'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الأول',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الأخير',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final int patientId = (patient['id'] as int);
                await AdminApiService.updatePatient(patientId, {
                  'first_name': firstNameController.text.trim(),
                  'last_name': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث بيانات المريض بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadUsers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في تحديث بيانات المريض: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // تبديل حالة المريض
  Future<void> _togglePatientStatus(int patientId, String currentStatus) async {
    final newStatus = currentStatus == 'active' ? 'blocked' : 'active';
    final action = newStatus == 'active' ? 'إلغاء حظر' : 'حظر';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد $action'),
        content: Text('هل أنت متأكد من رغبتك في $action هذا المريض؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // تحديث حالة المريض عبر API باستخدام المعرّف فقط
        await AdminApiService.updatePatientStatus(patientId, newStatus);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم $action المريض بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في $action المريض: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // عرض تفاصيل الطبيب
  void _viewDoctorDetails(Map<String, dynamic> doctor) {
    final user = doctor['user'] ?? {};
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text('د. ${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('الاسم',
                  'د. ${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'),
              _buildDetailRow('البريد الإلكتروني', user['email'] ?? ''),
              _buildDetailRow('الهاتف', doctor['phone'] ?? 'غير محدد'),
              _buildDetailRow('التخصص', doctor['specialization'] ?? 'طبيب عام'),
              _buildDetailRow('الحالة',
                  doctor['status'] == 'approved' ? 'معتمد' : 'قيد المراجعة'),
              _buildDetailRow('التقييم', '${doctor['rating'] ?? 0.0}/5.0'),
              _buildDetailRow('عدد الحالات', '${doctor['cases_count'] ?? 0}'),
              _buildDetailRow('تاريخ التسجيل', doctor['created_at'] ?? ''),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // تعديل بيانات الطبيب
  void _editDoctor(Map<String, dynamic> doctor) {
    final user = doctor['user'] ?? {};
    final firstNameController = TextEditingController(text: user['first_name']);
    final lastNameController = TextEditingController(text: user['last_name']);
    final emailController = TextEditingController(text: user['email']);
    final phoneController = TextEditingController(text: doctor['phone']);
    final specializationController =
        TextEditingController(text: doctor['specialization']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل بيانات الطبيب'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الأول',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الأخير',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specializationController,
                decoration: const InputDecoration(
                  labelText: 'التخصص',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final int doctorId = (doctor['id'] as int);
                await AdminApiService.updateDoctor(doctorId, {
                  'first_name': firstNameController.text.trim(),
                  'last_name': lastNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone': phoneController.text.trim(),
                  'specialization': specializationController.text.trim(),
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم تحديث بيانات الطبيب بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
                _loadUsers();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('خطأ في تحديث بيانات الطبيب: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  // تبديل حالة الطبيب
  Future<void> _toggleDoctorStatus(int doctorId, String currentStatus) async {
    // نبدّل حالة المستخدم للطبيب: active <-> blocked
    final newStatus = currentStatus == 'active' ? 'blocked' : 'active';
    final action = newStatus == 'active' ? 'تفعيل' : 'تعطيل';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد $action'),
        content: Text('هل أنت متأكد من رغبتك في $action هذا الطبيب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // تحديث حالة الطبيب عبر API باستخدام المعرّف فقط
        await AdminApiService.updateDoctorStatus(doctorId, newStatus);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم $action الطبيب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );

        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في $action الطبيب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // موافقة على طلب الطبيب
  Future<void> _approveDoctor(int doctorId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الموافقة'),
        content:
            const Text('هل أنت متأكد من رغبتك في الموافقة على طلب هذا الطبيب؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('موافقة'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await AdminApiService.approveDoctorApplication(applicationId: doctorId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تمت الموافقة على طلب الطبيب بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في الموافقة على طلب الطبيب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // رفض طلب الطبيب
  Future<void> _rejectDoctor(int doctorId) async {
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('رفض طلب الطبيب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('يرجى كتابة سبب الرفض:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('رفض', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && reasonController.text.isNotEmpty) {
      try {
        await AdminApiService.rejectDoctorApplication(
          applicationId: doctorId,
          reason: reasonController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم رفض طلب الطبيب بنجاح'),
            backgroundColor: Colors.orange,
          ),
        );
        _loadUsers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في رفض طلب الطبيب: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // بناء صف تفاصيل
  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(
              child: Text(value ?? 'غير محدد',
                  style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
