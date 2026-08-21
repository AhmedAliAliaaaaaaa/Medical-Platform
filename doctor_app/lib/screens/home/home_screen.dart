import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/language_switcher.dart';
import '../patient/doctors/doctor_list_screen.dart';
import '../patient/cases/create_case_screen.dart';
import '../appointments/appointments_screen.dart';
import '../profile/enhanced_profile_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;
    final user = authProvider.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: ResponsiveHelper.getScreenPadding(context),
                child: Center(
                  child: ConstrainedBox(
                    constraints: ResponsiveHelper.getMaxWidthConstraints(
                      context,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(isRTL, user),

                        const SizedBox(height: 30),

                        // Welcome Message
                        _buildWelcomeMessage(isRTL, user),

                        const SizedBox(height: 30),

                        // Quick Actions
                        _buildQuickActions(isRTL),

                        const SizedBox(height: 30),

                        // Statistics Cards
                        _buildStatisticsCards(isRTL),

                        const SizedBox(height: 30),

                        // Recent Activities
                        _buildRecentActivities(isRTL),

                        const SizedBox(height: 30),

                        // Health Tips
                        _buildHealthTips(isRTL),

                        // Auth Section (if not logged in)
                        if (!authProvider.isAuthenticated) ...[
                          const SizedBox(height: 30),
                          _buildAuthSection(isRTL),
                        ],

                        // Logout Button (if logged in)
                        if (authProvider.isAuthenticated) ...[
                          const SizedBox(height: 30),
                          _buildLogoutSection(isRTL),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRTL, dynamic user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo and Title
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.medical_services,
                color: AppTheme.primaryBlue,
                size: 30,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRTL ? 'المنصة الطبية' : 'Medical Platform',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isRTL ? 'صحتك أولويتنا' : 'Your Health is Our Priority',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Language Switcher and Profile
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const LanguageSwitcher(),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const EnhancedProfileScreen(),
                  ),
                );
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeMessage(bool isRTL, dynamic user) {
    final userName = user?.firstName ?? (isRTL ? 'المستخدم' : 'User');
    final timeOfDay = _getTimeOfDay(isRTL);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$timeOfDay $userName! 👋',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isRTL ? 'كيف يمكننا مساعدتك اليوم؟' : 'How can we help you today?',
            style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  String _getTimeOfDay(bool isRTL) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return isRTL ? 'صباح الخير' : 'Good Morning';
    } else if (hour < 17) {
      return isRTL ? 'مساء الخير' : 'Good Afternoon';
    } else {
      return isRTL ? 'مساء الخير' : 'Good Evening';
    }
  }

  Widget _buildQuickActions(bool isRTL) {
    final actions = [
      {
        'title': isRTL ? 'استشارة فورية' : 'Quick Consultation',
        'subtitle': isRTL ? 'تحدث مع طبيب الآن' : 'Talk to a doctor now',
        'icon': Icons.video_call,
        'color': AppTheme.primaryBlue,
        'onTap': () => _navigateToConsultation(),
      },
      {
        'title': isRTL ? 'حجز موعد' : 'Book Appointment',
        'subtitle': isRTL ? 'احجز موعد مع طبيب' : 'Schedule with a doctor',
        'icon': Icons.calendar_today,
        'color': AppTheme.primaryGreen,
        'onTap': () => _navigateToAppointments(),
      },
      {
        'title': isRTL ? 'إنشاء حالة' : 'Create Case',
        'subtitle': isRTL ? 'أضف حالة طبية جديدة' : 'Add a new medical case',
        'icon': Icons.add_circle,
        'color': AppTheme.primaryPurple,
        'onTap': () => _navigateToCreateCase(),
      },
      {
        'title': isRTL ? 'البحث عن أطباء' : 'Find Doctors',
        'subtitle': isRTL ? 'ابحث عن أطباء متخصصين' : 'Search for specialists',
        'icon': Icons.search,
        'color': AppTheme.primaryOrange,
        'onTap': () => _navigateToDoctors(),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'الإجراءات السريعة' : 'Quick Actions',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: ResponsiveHelper.getGridCrossAxisCount(context),
            crossAxisSpacing: ResponsiveHelper.getSpacing(context, 16),
            mainAxisSpacing: ResponsiveHelper.getSpacing(context, 16),
            childAspectRatio: ResponsiveHelper.isMobile(context) ? 1.2 : 1.1,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return _buildActionCard(
              title: action['title'] as String,
              subtitle: action['subtitle'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards(bool isRTL) {
    final stats = [
      {
        'title': isRTL ? 'الاستشارات' : 'Consultations',
        'value': '12',
        'icon': Icons.medical_services,
        'color': AppTheme.primaryBlue,
      },
      {
        'title': isRTL ? 'المواعيد' : 'Appointments',
        'value': '3',
        'icon': Icons.calendar_today,
        'color': AppTheme.primaryGreen,
      },
      {
        'title': isRTL ? 'التقارير' : 'Reports',
        'value': '8',
        'icon': Icons.description,
        'color': AppTheme.primaryPurple,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'الإحصائيات' : 'Statistics',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children:
              stats.map((stat) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          stat['icon'] as IconData,
                          color: stat['color'] as Color,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          stat['value'] as String,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          stat['title'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentActivities(bool isRTL) {
    final activities = [
      {
        'title':
            isRTL ? 'استشارة مع د. أحمد محمد' : 'Consultation with Dr. Ahmed',
        'time': isRTL ? 'منذ ساعتين' : '2 hours ago',
        'icon': Icons.video_call,
        'color': AppTheme.primaryBlue,
      },
      {
        'title': isRTL ? 'تم رفع تقرير طبي' : 'Medical report uploaded',
        'time': isRTL ? 'أمس' : 'Yesterday',
        'icon': Icons.upload_file,
        'color': AppTheme.primaryGreen,
      },
      {
        'title':
            isRTL
                ? 'موعد قادم مع د. سارة'
                : 'Upcoming appointment with Dr. Sara',
        'time': isRTL ? 'غداً الساعة 3:00 م' : 'Tomorrow at 3:00 PM',
        'icon': Icons.schedule,
        'color': AppTheme.primaryOrange,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'الأنشطة الأخيرة' : 'Recent Activities',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children:
                activities.map((activity) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (activity['color'] as Color).withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            activity['icon'] as IconData,
                            color: activity['color'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity['title'] as String,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                activity['time'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHealthTips(bool isRTL) {
    final tips = [
      {
        'title': isRTL ? 'اشرب الماء بانتظام' : 'Stay Hydrated',
        'description':
            isRTL
                ? 'اشرب 8 أكواب من الماء يومياً للحفاظ على صحتك'
                : 'Drink 8 glasses of water daily to maintain good health',
        'icon': Icons.water_drop,
      },
      {
        'title': isRTL ? 'مارس الرياضة' : 'Exercise Regularly',
        'description':
            isRTL
                ? 'مارس الرياضة لمدة 30 دقيقة يومياً'
                : 'Exercise for 30 minutes daily for better health',
        'icon': Icons.fitness_center,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'نصائح صحية' : 'Health Tips',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        ...tips.map((tip) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    tip['icon'] as IconData,
                    color: AppTheme.primaryGreen,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['description'] as String,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _navigateToConsultation() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DoctorListScreen()));
  }

  void _navigateToAppointments() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AppointmentsScreen()));
  }

  void _navigateToCreateCase() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CreateCaseScreen()));
  }

  void _navigateToDoctors() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DoctorListScreen()));
  }

  Widget _buildAuthSection(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'الدخول والتسجيل' : 'Login & Register',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),
        Container(
          padding: ResponsiveHelper.getCardPadding(context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Login Button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getCardHeight(context, 56),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(context, 12),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login,
                        color: Colors.white,
                        size: ResponsiveHelper.getIconSize(context, 24),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context, 12)),
                      Text(
                        isRTL ? 'تسجيل الدخول' : 'Login',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: ResponsiveHelper.getCardHeight(context, 56),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RegisterSelectionScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(context, 12),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_add,
                        color: Colors.white,
                        size: ResponsiveHelper.getIconSize(context, 24),
                      ),
                      SizedBox(width: ResponsiveHelper.getSpacing(context, 12)),
                      Text(
                        isRTL ? 'إنشاء حساب جديد' : 'Create Account',
                        style: TextStyle(
                          fontSize: ResponsiveHelper.getFontSize(context, 16),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: ResponsiveHelper.getSpacing(context, 12)),

              Text(
                isRTL
                    ? 'انضم إلينا للحصول على أفضل الخدمات الطبية'
                    : 'Join us to get the best medical services',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutSection(bool isRTL) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRTL ? 'إعدادات الحساب' : 'Account Settings',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 20),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, 16)),
        Container(
          padding: ResponsiveHelper.getCardPadding(context),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, 16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Profile Button
              ListTile(
                leading: Icon(
                  Icons.person,
                  color: AppTheme.primaryBlue,
                  size: ResponsiveHelper.getIconSize(context, 24),
                ),
                title: Text(
                  isRTL ? 'الملف الشخصي' : 'Profile',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.textSecondary,
                  size: ResponsiveHelper.getIconSize(context, 16),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const EnhancedProfileScreen(),
                    ),
                  );
                },
              ),

              Divider(color: AppTheme.borderColor),

              // Logout Button
              ListTile(
                leading: Icon(
                  Icons.logout,
                  color: AppTheme.dangerRed,
                  size: ResponsiveHelper.getIconSize(context, 24),
                ),
                title: Text(
                  isRTL ? 'تسجيل الخروج' : 'Logout',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.dangerRed,
                  ),
                ),
                onTap: () => _showLogoutDialog(isRTL),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(bool isRTL) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, 16),
            ),
          ),
          title: Text(
            isRTL ? 'تسجيل الخروج' : 'Logout',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 18),
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            isRTL
                ? 'هل أنت متأكد من أنك تريد تسجيل الخروج؟'
                : 'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'إلغاء' : 'Cancel',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/welcome', (route) => false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context, 8),
                  ),
                ),
              ),
              child: Text(
                isRTL ? 'تسجيل الخروج' : 'Logout',
                style: TextStyle(
                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
