import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:doctor_app/screens/patient/cases/create_case_screen.dart';
import '../providers/language_provider.dart';
import '../providers/auth_provider.dart';
import '../core/theme/app_theme.dart';
import '../utils/responsive_helper.dart';
import 'home/home_screen.dart';
import 'patient/doctors/enhanced_doctor_list.dart';
import 'appointments/appointments_screen.dart';
import 'notifications/notifications_screen.dart';
import 'profile/enhanced_profile_screen.dart';
import 'search/advanced_search_screen.dart';
import 'analytics/analytics_screen.dart';
import 'patient/dashboard/professional_patient_dashboard.dart';
import 'doctor/dashboard/doctor_dashboard.dart';
import 'auth/pending_approval_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late PageController _pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isRTL = languageProvider.isRTL;
    final userRole = authProvider.currentUser?.role ?? 'patient';

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: _getScreensForRole(userRole),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: _buildBottomNavigationBar(isRTL, userRole),
      ),
    );
  }

  List<Widget> _getScreensForRole(String role) {
    switch (role) {
      case 'doctor':
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final isApproved = authProvider.isDoctorApproved;
        if (!isApproved) {
          // Block doctor navigation until approved
          return const [
            PendingApprovalScreen(),
            PendingApprovalScreen(),
            PendingApprovalScreen(),
            PendingApprovalScreen(),
            EnhancedProfileScreen(),
          ];
        }
        return [
          const ImprovedDoctorDashboard(),
          const EnhancedDoctorList(),
          const AppointmentsScreen(),
          const AnalyticsScreen(),
          const EnhancedProfileScreen(),
        ];
      case 'admin':
        return const [
          HomeScreen(),
          AnalyticsScreen(),
          EnhancedDoctorList(),
          NotificationsScreen(),
          EnhancedProfileScreen(),
        ];
      default: // patient
        return const [
          ProfessionalPatientDashboard(),
          EnhancedDoctorList(),
          AppointmentsScreen(),
          NotificationsScreen(),
          EnhancedProfileScreen(),
        ];
    }
  }

  Widget _buildBottomNavigationBar(bool isRTL, String userRole) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: AppTheme.darkGray.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomAppBar(
        // تمت إزالة الشق والـ notch الخاصة بالـ FAB لمنع أي تراكب
        color: AppTheme.cardBackground,
        elevation: 0,
        child: Container(
          height: 65,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _buildNavItems(isRTL, userRole),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNavItems(bool isRTL, String userRole) {
    final items = _getNavItemsForRole(userRole, isRTL);
    final leftItems = items.take(2).toList();
    final rightItems = items.skip(2).toList();

    return [
      ...leftItems.asMap().entries.map((entry) {
        return _buildNavItem(entry.value, entry.key, isRTL);
      }),
      // تمت إزالة المسافة الخاصة بالـ FAB
      ...rightItems.asMap().entries.map((entry) {
        return _buildNavItem(entry.value, entry.key + 2, isRTL);
      }),
    ];
  }

  List<NavItem> _getNavItemsForRole(String role, bool isRTL) {
    switch (role) {
      case 'doctor':
        return [
          NavItem(
            icon: Icons.dashboard,
            activeIcon: Icons.dashboard,
            label: isRTL ? 'الرئيسية' : 'Dashboard',
          ),
          NavItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: isRTL ? 'المرضى' : 'Patients',
          ),
          NavItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
            label: isRTL ? 'المواعيد' : 'Appointments',
          ),
          NavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: isRTL ? 'الإحصائيات' : 'Analytics',
          ),
          NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: isRTL ? 'الملف الشخصي' : 'Profile',
          ),
        ];
      case 'admin':
        return [
          NavItem(
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: isRTL ? 'الرئيسية' : 'Dashboard',
          ),
          NavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            label: isRTL ? 'الإحصائيات' : 'Analytics',
          ),
          NavItem(
            icon: Icons.medical_services_outlined,
            activeIcon: Icons.medical_services,
            label: isRTL ? 'الأطباء' : 'Doctors',
          ),
          NavItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: isRTL ? 'الإشعارات' : 'Notifications',
          ),
          NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: isRTL ? 'الملف الشخصي' : 'Profile',
          ),
        ];
      default: // patient
        return [
          NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: isRTL ? 'الرئيسية' : 'Home',
          ),
          NavItem(
            icon: Icons.medical_services_outlined,
            activeIcon: Icons.medical_services,
            label: isRTL ? 'الأطباء' : 'Doctors',
          ),
          NavItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_today,
            label: isRTL ? 'المواعيد' : 'Appointments',
          ),
          NavItem(
            icon: Icons.notifications_outlined,
            activeIcon: Icons.notifications,
            label: isRTL ? 'الإشعارات' : 'Notifications',
          ),
          NavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: isRTL ? 'الملف الشخصي' : 'Profile',
          ),
        ];
    }
  }

  Widget _buildNavItem(NavItem item, int index, bool isRTL) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primaryBlue.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                key: ValueKey(isActive),
                color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton(bool isRTL, String userRole) {
    IconData icon;
    String tooltip;
    VoidCallback onPressed;

    switch (userRole) {
      case 'doctor':
        icon = Icons.add_circle;
        tooltip = isRTL ? 'إضافة ملاحظة' : 'Add Note';
        onPressed = _showAddNoteDialog;
        break;
      case 'admin':
        icon = Icons.add_moderator;
        tooltip = isRTL ? 'إضافة طبيب' : 'Add Doctor';
        onPressed = _showAddDoctorDialog;
        break;
      default: // patient
        icon = Icons.add;
        tooltip = isRTL ? 'إنشاء حالة جديدة' : 'Create New Case';
        onPressed = _navigateToCreateCase;
        break;
    }

    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton(
        onPressed: onPressed,
        tooltip: tooltip,
        backgroundColor: AppTheme.primaryBlue,
        elevation: 8,
        child: Icon(icon, color: AppTheme.white, size: 28),
      ),
    );
  }

  void _navigateToCreateCase() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const CreateCaseScreen()));
  }

  void _showAddNoteDialog() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isRTL ? 'إضافة ملاحظة' : 'Add Note',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  isRTL ? 'اكتب ملاحظتك هنا...' : 'Write your note here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'إلغاء' : 'Cancel',
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isRTL ? 'تم حفظ الملاحظة' : 'Note saved'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isRTL ? 'حفظ' : 'Save',
                style: const TextStyle(color: AppTheme.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddDoctorDialog() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL ? 'ميزة إضافة طبيب قريباً' : 'Add doctor feature coming soon',
        ),
        backgroundColor: AppTheme.primaryBlue,
      ),
    );
  }
}

class NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  NavItem({required this.icon, required this.activeIcon, required this.label});
}
