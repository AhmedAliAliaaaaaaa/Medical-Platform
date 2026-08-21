import 'dart:async';
import 'package:flutter/material.dart';
import 'package:doctor_app/services/api_service.dart';
import 'package:doctor_app/utils/app_theme.dart';
import 'package:doctor_app/utils/responsive_helper.dart';
import 'package:doctor_app/screens/auth/login_screen.dart';
import 'package:doctor_app/screens/patient/cases/create_case_screen.dart';
import 'package:doctor_app/screens/patient/cases/cases_list_screen.dart';
import 'package:doctor_app/screens/patient/doctors/doctor_list_screen.dart';
import 'package:doctor_app/screens/notifications/notifications_screen.dart';
import 'package:doctor_app/screens/profile/profile_screen.dart';
import 'package:doctor_app/screens/patient/cases/responses_screen.dart';

/// شاشة لوحة تحكم المريض بتصميم مستوحى من الصورة المرسلة (برتقالي + أزرق داكن + بطاقات ناعمة).
class ProfessionalPatientDashboard extends StatefulWidget {
  const ProfessionalPatientDashboard({super.key});
  @override
  State<ProfessionalPatientDashboard> createState() =>
      _ProfessionalPatientDashboardState();
}

class _ProfessionalPatientDashboardState
    extends State<ProfessionalPatientDashboard> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController(viewportFraction: 0.85);

  Map<String, dynamic>? _dashboardData;
  bool _isLoading = true;
  String? _errorMessage;
  int _currentBanner = 0;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final ScrollController _scrollController;
  String? _userName; // اسم المريض للترحيب

  // ألوان مستلهمة من التصميم
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

    // Start with a small delay to ensure everything is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
      // Auto refresh every 20 seconds to reflect cross-updates
      _autoRefreshTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        if (mounted) _loadDashboard();
      });
    });
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await ApiService.initializeToken();
      if (!ApiService.isAuthenticated) {
        _handleUnauthorizedError();
        return;
      }
      final data = await ApiService.getPatientDashboard();
      // جلب اسم المستخدم للترحيب
      final profile = await ApiService.getUserProfile();
      final user = (profile['user'] as Map<String, dynamic>?) ?? {};
      if (!mounted) return;
      setState(() {
        _dashboardData = data;
        _userName = user['first_name'] ?? user['username'] ?? 'المريض';
        _isLoading = false;
      });

      // Start the animation after data is loaded
      if (!_animationController.isCompleted) {
        _animationController.forward();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      if (e.toString().contains('Unauthorized access') ||
          e.toString().contains('لا يوجد توكن مصادقة')) {
        _handleUnauthorizedError();
      }
    }
  }

  void _handleUnauthorizedError() {
    ApiService.removeToken().then((_) {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _scrollController.dispose();
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  int _unread() {
    final n = _dashboardData?['unread_notifications'];
    if (n is int) return n;
    if (n is num) return n.toInt();
    if (n is String) return int.tryParse(n) ?? 0;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: _softBg,
        endDrawer: _buildEndDrawer(),
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

  // ============ UI ============
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      color: AppTheme.primaryBlue,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              children: [
                _headerBar(),
                const SizedBox(height: 12),
                _welcomePanel(),
                const SizedBox(height: 12),
                _walletCarousel(),
                const SizedBox(height: 12),
                _softCardCTA(),
                const SizedBox(height: 16),
                _quickActions(),
                const SizedBox(height: 80), // مساحة آمنة أسفل لتفادي أي تراكب
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Header bar مطابق للصورة
  Widget _headerBar() {
    final unread = _unread();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _shadowSoft,
      ),
      child: Row(
        children: [
          // أيقونة القائمة
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: _darkBlue),
            onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
          ),

          // الجرس مع الشارة
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded,
                    color: _darkBlue),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationsScreen())),
              ),
              if (unread > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10)),
                    child: Text('$unread',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),

          // شعار الخدمة (Placeholder مربع صغير)
          Expanded(
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _softBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color.fromARGB(255, 145, 147, 152)
                          .withOpacity(0.08)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.local_hospital_rounded,
                      color: _darkBlue, size: 18),
                  SizedBox(width: 6),
                  Text('خدمتنا',
                      style: TextStyle(
                          color: _darkBlue, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ),

          // ملف المريض
          IconButton(
            tooltip: 'ملف المريض',
            icon: const Icon(Icons.assignment_ind_rounded, color: _darkBlue),
            onPressed: _openProfile,
          ),
        ],
      ),
    );
  }

  // لوحة ترحيبية باسم المريض مع أيقونة الطب
  Widget _welcomePanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, _lightOrange.withOpacity(0.6)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: _shadowSoft,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child:
                const Icon(Icons.health_and_safety_rounded, color: _darkBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً ${_userName ?? 'بك'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('نتمنى لك صحة دائمة. يمكنك إدارة حالاتك من هنا.',
                    style: _subtitle),
              ],
            ),
          ),
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: _openNotifications,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_none_rounded, color: _darkBlue),
                if (_unread() > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 156, 206, 182),
                          borderRadius: BorderRadius.circular(10)),
                      child: Text('${_unread()}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Carousel لبطاقات إحصاءات التطبيق
  Widget _walletCarousel() {
    final totalCases = _dashboardData?['stats']?['total_cases'] ??
        _dashboardData?['total_cases'] ??
        0;
    final pending = _dashboardData?['stats']?['pending_cases'] ??
        _dashboardData?['pending'] ??
        0;
    final responded = _dashboardData?['stats']?['responded_cases'] ??
        _dashboardData?['completed'] ??
        0;

    final items = [
      _walletCard(
        title: 'إجمالي الحالات',
        hint: '$totalCases',
        icon: Icons.library_add_check_rounded,
        onTap: _openCases,
      ),
      _walletCard(
        title: 'قيد الانتظار',
        hint: '$pending',
        icon: Icons.schedule_rounded,
        onTap: () => _openCasesTab(1),
      ),
      _walletCard(
        title: 'تم الرد عليها',
        hint: '$responded',
        icon: Icons.check_circle_outline_rounded,
        onTap: () => _openCasesTab(2),
      ),
      _walletCard(
        title: 'ردود الأطباء',
        hint: 'عرض الكل',
        icon: Icons.forum_outlined,
        onTap: _openDoctorResponses,
      ),
    ];

    return Column(
      children: [
        SizedBox(
          height: 140,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentBanner = i),
            itemCount: items.length,
            itemBuilder: (_, i) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_pageController.position.haveDimensions) {
                    final page =
                        _pageController.page ?? _currentBanner.toDouble();
                    final diff = (page - i).abs();
                    scale = (1 - (diff * 0.12)).clamp(0.88, 1.0);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: Opacity(
                        opacity: scale,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: items[i],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == _currentBanner;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 10 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? _orange : _darkBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        )
      ],
    );
  }

  Widget _walletCard({
    required String title,
    required String hint,
    VoidCallback? onTap,
    IconData icon = Icons.insert_chart_outlined,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [const Color(0xFFFFF3EA), _lightOrange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _shadowSoft,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: _orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, color: _textPrimary)),
                    const SizedBox(height: 6),
                    Text(hint,
                        style: const TextStyle(
                            letterSpacing: 1.2, color: _textSecondary)),
                  ]),
            ),
          ],
        ),
      ),
    );
  }

  // بانر ترويجي بسيط

  // بطاقة نصيحة صحية أو CTA متعلق بالتطبيق
  Widget _softCardCTA() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [const Color(0xFFFFF7F0), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _shadowSoft,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: _softBg, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.tips_and_updates_rounded, color: _orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('نصيحة صحية',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, color: _textPrimary)),
                  SizedBox(height: 6),
                  Text('اشرب الماء بانتظام وتابع حالتك من خلال التطبيق.',
                      style: TextStyle(color: _textSecondary, fontSize: 12)),
                ]),
          ),
          // زر برتقالي ثابت داخل البطاقة بدلاً من زر عائم أسفل الشاشة
          ElevatedButton(
            onPressed: _openCreateCase,
            style: ElevatedButton.styleFrom(
                backgroundColor: _orange,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            child: const Text('إنشاء حالة', style: _btn),
          )
        ],
      ),
    );
  }

  // أزرار سريعة (شبكة 2x2)
  Widget _quickActions() {
    final isTablet = ResponsiveHelper.isTablet(context);
    final cross = isTablet ? 4 : 2;

    final actions = <_ActionItem>[
      _ActionItem(
          icon: Icons.add_box_rounded,
          color: _orange,
          label: 'إنشاء حالة جديدة',
          onTap: _openCreateCase),
      _ActionItem(
          icon: Icons.description_rounded,
          color: _darkBlue,
          label: 'كل الحالات',
          onTap: _openCases),
      _ActionItem(
          icon: Icons.notifications_none_rounded,
          color: _darkBlue,
          label: 'الإشعارات',
          onTap: _openNotifications),
      _ActionItem(
          icon: Icons.forum_outlined,
          color: _orange,
          label: 'ردود الأطباء',
          onTap: _openDoctorResponses),
    ];

    return GridView.builder(
      itemCount: actions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cross,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      itemBuilder: (_, i) => _actionCard(actions[i]),
    );
  }

  Widget _actionCard(_ActionItem a) {
    return InkWell(
      onTap: a.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _shadowSoft),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: _softBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(a.icon, color: a.color),
            ),
            const SizedBox(height: 10),
            Text(a.label,
                style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ============ عناصر مشتركة ============
  Drawer _buildEndDrawer() {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // رأس بسيط
            ListTile(
              leading: const Icon(Icons.dashboard_customize_rounded,
                  color: _darkBlue),
              title: const Text('لوحة تحكم المريض',
                  style: TextStyle(fontWeight: FontWeight.w800)),
            ),
            const Divider(height: 16),
            // خيارات مطلوبة
            _drawerItem(
                Icons.home_rounded, 'الرئيسية', () => Navigator.pop(context)),
            _drawerItem(
                Icons.add_box_rounded, 'إنشاء حالة جديدة', _openCreateCase),
            _drawerItem(
                Icons.description_rounded, 'إجمالي الحالات', _openCases),
            _drawerItem(
                Icons.schedule_rounded, 'قيد الانتظار', () => _openCasesTab(1)),
            _drawerItem(Icons.check_circle_outline_rounded, 'تم الرد عليها',
                () => _openCasesTab(2)),
            _drawerItem(Icons.notifications_none_rounded, 'الإشعارات',
                _openNotifications),
            _drawerItem(Icons.person_outline, 'الملف الشخصي', _openProfile),
            _drawerItem(
                Icons.forum_outlined, 'ردود الأطباء', _openDoctorResponses),
            const Divider(height: 24),
            // روابط أسفل
            _drawerItem(Icons.info_outline_rounded, 'من نحن', () {}),
            _drawerItem(Icons.call_rounded, 'تواصل معنا', () {}),
            _drawerItem(Icons.help_outline_rounded, 'الأسئلة الشائعة', () {}),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text('تسجيل الخروج'),
              onTap: _showLogoutDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _shadowSoft),
          child: Row(children: [
            Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                    color: _softBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: _darkBlue)),
            const SizedBox(width: 12),
            Expanded(
                child: Text(label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: _textPrimary))),
            const Icon(Icons.arrow_back_ios_new_rounded,
                color: _textSecondary, size: 16),
          ]),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 12),
          Text(_errorMessage!.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          ElevatedButton(
              onPressed: _loadDashboard, child: const Text('إعادة المحاولة')),
        ]),
      ),
    );
  }

  // ============ تنقلات ============
  void _openCreateCase() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CreateCaseScreen()));
  }

  void _openCases() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CasesListScreen()));
  }

  void _openCasesTab(int index) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CasesListScreen(initialTabIndex: index)));
  }

  void _openDoctors() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const DoctorListScreen()));
  }

  void _openNotifications() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
  }

  void _openProfile() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
  }

  void _openDoctorResponses() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const ResponsesScreen()));
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد أنك تريد تسجيل الخروج؟'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              await ApiService.removeToken();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _ActionItem(
      {required this.icon,
      required this.color,
      required this.label,
      required this.onTap});
}
