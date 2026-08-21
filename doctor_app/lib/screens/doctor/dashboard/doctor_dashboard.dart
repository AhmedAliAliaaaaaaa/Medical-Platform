import 'dart:async';
import 'package:flutter/material.dart';
import 'package:doctor_app/services/api_service.dart';
import 'package:doctor_app/services/doctor_api_service.dart';
import 'package:doctor_app/services/websocket_service.dart';
import 'package:doctor_app/utils/app_theme.dart';
import 'package:doctor_app/screens/notifications/notifications_screen.dart';
import '../cases/respond_to_case_screen.dart';
import '../responses/my_responses_screen.dart';
import '../responses/doctor_responses_screen.dart';
import '../cases/all_patient_cases_screen.dart';
import '../ratings/my_ratings_screen.dart';
import '../profile/doctor_profile_screen.dart';
import '../../auth/login_screen.dart';
import 'notification_sender_fixed.dart';

/// لوحة تحكم الطبيب المحسنة - مبسطة ومنظمة
class ImprovedDoctorDashboard extends StatefulWidget {
  const ImprovedDoctorDashboard({super.key});

  @override
  State<ImprovedDoctorDashboard> createState() =>
      _ImprovedDoctorDashboardState();
}

class _ImprovedDoctorDashboardState extends State<ImprovedDoctorDashboard> {
  // البيانات الأساسية
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;
  String? _doctorName;
  Timer? _refreshTimer;
  late final WebSocketService _ws;

  @override
  void initState() {
    super.initState();
    _initializeWebSocket();
    _loadDashboard();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _ws.disconnect();
    super.dispose();
  }

  // تهيئة WebSocket للتحديثات المباشرة
  void _initializeWebSocket() {
    _ws = WebSocketService()
      ..onEvent = (event) {
        final type = event['type'];
        if (['new_case', 'case_updated', 'new_response', 'notification']
            .contains(type)) {
          _refreshDashboardData();
        }
      };
    _ws.connect();
  }

  // تحميل بيانات لوحة التحكم
  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiService.initializeToken();
      if (!ApiService.isAuthenticated) {
        setState(() {
          _errorMessage = 'يرجى تسجيل الدخول';
          _isLoading = false;
        });
        return;
      }

      // جلب بيانات لوحة التحكم
      final data = await ApiService.getDoctorDashboard();

      // جلب اسم الطبيب
      String? name;
      try {
        final userData = await ApiService.getUserData();
        final user = (userData?['user'] as Map<String, dynamic>?) ?? {};
        name = (user['first_name'] ?? user['username'])?.toString();
      } catch (_) {}

      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _doctorName = name ?? 'الطبيب';
        _isLoading = false;
      });

      _startPeriodicRefresh();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // تحديث دوري للبيانات
  void _startPeriodicRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _refreshDashboardData();
      } else {
        timer.cancel();
      }
    });
  }

  // تحديث البيانات بدون loading
  Future<void> _refreshDashboardData() async {
    try {
      final data = await ApiService.getDoctorDashboard();
      if (mounted) {
        setState(() {
          _dashboardData = data;
        });
      }
    } catch (e) {
      debugPrint('❌ Error refreshing dashboard data: $e');
    }
  }

  // عرض نافذة تأكيد الخروج
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تأكيد الخروج'),
          content: const Text('هل أنت متأكد من أنك تريد تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('تسجيل الخروج'),
            ),
          ],
        );
      },
    );
  }

  // تنفيذ عملية الخروج
  Future<void> _logout() async {
    try {
      // إظهار مؤشر التحميل
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // قطع اتصال WebSocket
      _ws.disconnect();

      // إلغاء المؤقت
      _refreshTimer?.cancel();

      // تسجيل الخروج من API
      await ApiService.logout();

      // إخفاء مؤشر التحميل
      if (mounted) Navigator.of(context).pop();

      // الانتقال إلى شاشة تسجيل الدخول
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // إخفاء مؤشر التحميل في حالة الخطأ
      if (mounted) Navigator.of(context).pop();

      // عرض رسالة خطأ
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في تسجيل الخروج: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // حساب عدد الحالات الجديدة
  int _getNewCasesCount() {
    final list = (_dashboardData?['new_cases_list'] ?? []);
    return list.where((item) {
      if (item is! Map) return false;
      final m = Map<String, dynamic>.from(item);
      final status = (m['status']?.toString().toLowerCase() ?? '');
      final hasResp = m['has_response'] == true;
      final responses = m['responses'];
      final noResponses = responses is List && responses.isEmpty;
      return status == 'new' || status == 'جديد' || !hasResp || noResponses;
    }).length;
  }

  // جلب الحالات الجديدة الفعلية
  List<Map<String, dynamic>> _getNewCases() {
    final list = (_dashboardData?['new_cases_list'] ?? []);
    final List<Map<String, dynamic>> result = [];

    for (final item in list) {
      if (item is! Map) continue;

      final m = Map<String, dynamic>.from(item);
      final status = (m['status']?.toString().toLowerCase() ?? '');
      final hasResp = m['has_response'] == true;
      final responses = m['responses'];
      final noResponses = responses is List && responses.isEmpty;

      if (status == 'new' || status == 'جديد' || !hasResp || noResponses) {
        result.add(m);
      }
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightGray,
        appBar: _buildAppBar(),
        endDrawer: _buildDrawer(),
        body: SafeArea(
          child: _isLoading
              ? _buildLoading()
              : _errorMessage != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  // شريط التطبيق العلوي
  AppBar _buildAppBar() {
    final newCasesCount = _getNewCasesCount();
    final unreadNotifications = (_dashboardData?['unread_notifications'] ?? 0);

    return AppBar(
      title: const Text('لوحة تحكم الطبيب'),
      backgroundColor: const Color.fromARGB(255, 118, 156, 222),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // إشعارات الحالات الجديدة
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.mark_unread_chat_alt_rounded),
              onPressed: _openFirstNewCase,
              tooltip: 'حالات جديدة',
            ),
            if (newCasesCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$newCasesCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // إشعارات الإدارة
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ).then((_) => _loadDashboard()),
              tooltip: 'إشعارات الإدارة',
            ),
            if (unreadNotifications > 0)
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // الملف الشخصي
        IconButton(
          icon: const Icon(Icons.person_outline_rounded),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DoctorProfileScreen()),
          ),
          tooltip: 'الملف الشخصي',
        ),

        // زر الخروج
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          onPressed: _showLogoutDialog,
          tooltip: 'تسجيل الخروج',
        ),
      ],
    );
  }

  // المحتوى الرئيسي
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 16),
            _buildStatsCards(),
            const SizedBox(height: 16),
            _buildQuickActions(),
            const SizedBox(height: 16),
            _buildNewCasesSection(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // بطاقة الترحيب
  Widget _buildWelcomeCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, AppTheme.primaryBlue.withValues(alpha: 0.1)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'مرحباً د. $_doctorName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'يمكنك إدارة حالاتك والاطلاع على الإشعارات من هنا',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بطاقات الإحصائيات
  Widget _buildStatsCards() {
    final newCasesCount = _getNewCasesCount();
    final totalResponses = (_dashboardData?['total_responses'] ?? 0);
    final rating = (_dashboardData?['average_rating'] ?? 0.0).toDouble();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'حالات جديدة',
            '$newCasesCount',
            Icons.assignment_turned_in_rounded,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'ردودي',
            '$totalResponses',
            Icons.forum_outlined,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'تقييمي',
            '${rating.toStringAsFixed(1)}⭐',
            Icons.star_border_rounded,
            Colors.amber,
          ),
        ),
      ],
    );
  }

  // بطاقة إحصائية واحدة
  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // الإجراءات السريعة
  Widget _buildQuickActions() {
    final actions = [
      _ActionItem('الحالات الجديدة', Icons.assignment_turned_in_rounded,
          _openFirstNewCase),
      _ActionItem('ردودي السابقة', Icons.forum_outlined, _openMyResponses),
      _ActionItem('جميع الحالات', Icons.folder_open, _openAllCases),
      _ActionItem('تقييمي', Icons.star_border_rounded, _openMyRatings),
      _ActionItem(
          'إشعارات المرضى', Icons.notification_add, _openNotificationSender),
      _ActionItem(
          'الحالات المجابة', Icons.check_circle_outline, _openRespondedCases),
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإجراءات السريعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: actions.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (_, index) {
                final action = actions[index];
                return _buildActionItem(action);
              },
            ),
          ],
        ),
      ),
    );
  }

  // عنصر إجراء واحد
  Widget _buildActionItem(_ActionItem action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightGray,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(action.icon, color: AppTheme.primaryBlue, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              action.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // قسم الحالات الجديدة
  Widget _buildNewCasesSection() {
    final newCases = _getNewCases();

    if (newCases.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'الحالات الجديدة',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.green[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لا توجد حالات جديدة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'جميع الحالات تم الرد عليها',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الحالات الجديدة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${newCases.length}',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: newCases.take(3).length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final caseData = newCases[index];
                return _buildCaseCard(caseData);
              },
            ),
            if (newCases.length > 3) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _openAllCases,
                  child: Text(
                    'عرض جميع الحالات (${newCases.length})',
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // بطاقة حالة واحدة
  Widget _buildCaseCard(Map<String, dynamic> caseData) {
    final title = caseData['title'] ?? caseData['subject'] ?? 'حالة طبية';
    final patientName = caseData['patient_name'] ?? 'مريض';
    final createdAt = caseData['created_at'] ?? '';
    final priority = caseData['priority'] ?? 'عادي';

    Color priorityColor = Colors.grey;
    if (priority.toString().toLowerCase().contains('عالي') ||
        priority.toString().toLowerCase().contains('high')) {
      priorityColor = Colors.red;
    } else if (priority.toString().toLowerCase().contains('متوسط') ||
        priority.toString().toLowerCase().contains('medium')) {
      priorityColor = Colors.orange;
    }

    return InkWell(
      onTap: () => _openCase(caseData),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  patientName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                if (createdAt.isNotEmpty) ...[
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // تنسيق التاريخ
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} دقيقة';
      } else {
        return 'الآن';
      }
    } catch (e) {
      return dateStr;
    }
  }

  // شاشة التحميل
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // شاشة الخطأ
  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'حدث خطأ في تحميل البيانات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'خطأ غير معروف',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDashboard,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // القائمة الجانبية
  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'د. $_doctorName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'طبيب',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('لوحة التحكم'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.assignment),
                  title: const Text('جميع الحالات'),
                  onTap: () {
                    Navigator.pop(context);
                    _openAllCases();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.forum),
                  title: const Text('ردودي'),
                  onTap: () {
                    Navigator.pop(context);
                    _openMyResponses();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: const Text('تقييماتي'),
                  onTap: () {
                    Navigator.pop(context);
                    _openMyRatings();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('الملف الشخصي'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DoctorProfileScreen()),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('تسجيل الخروج',
                      style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // فتح أول حالة جديدة
  void _openFirstNewCase() {
    final newCases = _getNewCases();
    if (newCases.isNotEmpty) {
      _openCase(newCases.first);
    } else {
      _openAllCases();
    }
  }

  // فتح حالة محددة
  void _openCase(Map<String, dynamic> caseData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RespondToCaseScreen(caseData: caseData),
      ),
    ).then((_) => _loadDashboard());
  }

  // فتح جميع الحالات
  void _openAllCases() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AllPatientCasesScreen()),
    ).then((_) => _loadDashboard());
  }

  // فتح ردودي السابقة
  void _openMyResponses() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyResponsesScreen()),
    ).then((_) => _loadDashboard());
  }

  // فتح تقييماتي
  void _openMyRatings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyRatingsScreen()),
    );
  }

  void _openNotificationSender() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotificationSenderFixed()),
    );
  }

  void _openRespondedCases() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyResponsesScreen()),
    ).then((_) => _loadDashboard());
  }
}

// كلاس مساعد للإجراءات
class _ActionItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  _ActionItem(this.title, this.icon, this.onTap);
}
