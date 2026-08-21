import 'package:flutter/material.dart';
import '../../utils/app_theme.dart';
import 'register_screen.dart';
import 'doctor_registration_screen.dart';

class RegisterSelectionScreen extends StatefulWidget {
  const RegisterSelectionScreen({super.key});

  @override
  State<RegisterSelectionScreen> createState() =>
      _RegisterSelectionScreenState();
}

class _RegisterSelectionScreenState extends State<RegisterSelectionScreen>
    with TickerProviderStateMixin {
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
    final isRTL = Directionality.of(context) == TextDirection.rtl;

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
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(isRTL),

                    const SizedBox(height: 60),

                    // Selection Cards
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildSelectionCard(
                            title:
                                isRTL ? 'تسجيل كمريض' : 'Register as Patient',
                            subtitle:
                                isRTL
                                    ? 'احصل على استشارات طبية من أفضل الأطباء'
                                    : 'Get medical consultations from the best doctors',
                            icon: Icons.person,
                            color: AppTheme.primaryBlue,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          _buildSelectionCard(
                            title: isRTL ? 'تسجيل كطبيب' : 'Register as Doctor',
                            subtitle:
                                isRTL
                                    ? 'انضم إلى شبكة الأطباء وقدم خدماتك الطبية'
                                    : 'Join our network of doctors and provide medical services',
                            icon: Icons.medical_services,
                            color: AppTheme.primaryGreen,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder:
                                      (_) => const DoctorRegistrationScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Login Link
                    _buildLoginLink(isRTL),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isRTL) {
    return Column(
      children: [
        // Back Button
        Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                isRTL ? Icons.arrow_forward : Icons.arrow_back,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.how_to_reg,
            size: 50,
            color: AppTheme.primaryBlue,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        Text(
          isRTL ? 'اختر نوع الحساب' : 'Choose Account Type',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 12),

        Text(
          isRTL
              ? 'حدد نوع الحساب الذي تريد إنشاؤه'
              : 'Select the type of account you want to create',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(24),
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
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 40, color: color),
            ),

            const SizedBox(height: 20),

            // Title
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            // Subtitle
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Arrow
            Icon(Icons.arrow_forward, color: color, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginLink(bool isRTL) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isRTL ? 'لديك حساب بالفعل؟' : 'Already have an account?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              isRTL ? 'تسجيل الدخول' : 'Login',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
