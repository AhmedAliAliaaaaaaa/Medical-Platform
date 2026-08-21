import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/responsive_helper.dart';
import '../../widgets/language_switcher.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../auth/doctor_registration_screen.dart';
import '../auth/register_selection_screen.dart';
import '../main_navigation.dart';

class EnhancedWelcomeScreen extends StatefulWidget {
  const EnhancedWelcomeScreen({super.key});

  @override
  State<EnhancedWelcomeScreen> createState() => _EnhancedWelcomeScreenState();
}

class _EnhancedWelcomeScreenState extends State<EnhancedWelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _gradientController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _gradientController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

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
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(
                    AppTheme.primaryBlue,
                    AppTheme.primaryGreen,
                    (_gradientController.value * 2) % 1,
                  )!,
                  Color.lerp(
                    AppTheme.primaryGreen,
                    AppTheme.primaryPurple,
                    (_gradientController.value * 2 + 0.3) % 1,
                  )!,
                  Color.lerp(
                    AppTheme.primaryPurple,
                    AppTheme.primaryBlue,
                    (_gradientController.value * 2 + 0.6) % 1,
                  )!,
                ],
                stops: const [0.0, 0.5, 1.0],
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
                          children: [
                            // Header with Language Switcher
                            _buildHeader(isRTL),

                            SizedBox(
                              height: ResponsiveHelper.getSpacing(context, 40),
                            ),

                            // Hero Section
                            _buildHeroSection(isRTL),

                            SizedBox(
                              height: ResponsiveHelper.getSpacing(context, 60),
                            ),

                            // Features Section
                            _buildFeaturesSection(isRTL),

                            SizedBox(
                              height: ResponsiveHelper.getSpacing(context, 60),
                            ),

                            // Tutorial Section
                            _buildTutorialSection(isRTL),

                            SizedBox(
                              height: ResponsiveHelper.getSpacing(context, 60),
                            ),

                            // Action Buttons (updated)
                            //_buildActionButtons(isRTL),
                            SizedBox(
                              height: ResponsiveHelper.getSpacing(context, 40),
                            ),

                            // Footer
                            _buildFooter(isRTL),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isRTL) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(
              ResponsiveHelper.getBorderRadius(context, 25),
            ),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
          ),
          child: const LanguageSwitcher(),
        ),
      ],
    );
  }

  Widget _buildHeroSection(bool isRTL) {
    return Column(
      children: [
        // App Icon with Animation
        TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (value * 0.2),
              child: Container(
                width: ResponsiveHelper.getIconSize(context, 140),
                height: ResponsiveHelper.getIconSize(context, 140),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(
                    ResponsiveHelper.getBorderRadius(context, 35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 25,
                      offset: const Offset(0, 15),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 3,
                  ),
                ),
                child: Icon(
                  Icons.medical_services_rounded,
                  size: ResponsiveHelper.getIconSize(context, 70),
                  color: AppTheme.primaryBlue,
                ),
              ),
            );
          },
        ),

        SizedBox(height: ResponsiveHelper.getSpacing(context, 40)),

        // Title
        Text(
          isRTL ? 'المنصة الطبية العالمية' : 'Global Medical Platform',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 36),
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1.2,
            shadows: const [
              Shadow(
                color: Colors.black38,
                offset: Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: ResponsiveHelper.getSpacing(context, 8)),

        Container(
          height: 4,
          width: ResponsiveHelper.getSpacing(context, 80),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        SizedBox(height: ResponsiveHelper.getSpacing(context, 30)),

        // Subtitle (match website tagline)
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveHelper.getSpacing(context, 30),
          ),
          child: Text(
            isRTL
                ? 'تواصل مع أفضل الأطباء حول العالم بدون سفر · دفع آمن · خدمة 24/7'
                : 'Connect with top doctors worldwide · Secure payments · 24/7 service',
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 20),
              color: Colors.white.withOpacity(0.95),
              height: 1.6,
              fontWeight: FontWeight.w600,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),

        // Hero Buttons (Start as Patient, Join as Doctor, Login)
        Wrap(
          spacing: ResponsiveHelper.getSpacing(context, 12),
          runSpacing: ResponsiveHelper.getSpacing(context, 12),
          alignment: WrapAlignment.center,
          children: [
            // Start as Patient (outlined white)
            SizedBox(
              height: ResponsiveHelper.getCardHeight(context, 48),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RegisterScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context, 28),
                    ),
                  ),
                ),
                icon: const Icon(Icons.person_add_alt),
                label: Text(
                  isRTL ? 'ابدأ كمريض' : 'Start as Patient',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Join as Doctor (green)
            SizedBox(
              height: ResponsiveHelper.getCardHeight(context, 48),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DoctorRegistrationScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context, 28),
                    ),
                  ),
                  elevation: 6,
                ),
                icon: const Icon(Icons.medical_services),
                label: Text(
                  isRTL ? 'انضم كطبيب' : 'Join as Doctor',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Login (teal)
            SizedBox(
              height: ResponsiveHelper.getCardHeight(context, 48),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF14B8A6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      ResponsiveHelper.getBorderRadius(context, 28),
                    ),
                  ),
                  elevation: 6,
                ),
                icon: const Icon(Icons.login),
                label: Text(
                  isRTL ? 'تسجيل الدخول' : 'Login',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 16),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: ResponsiveHelper.getSpacing(context, 24)),

        // Badges
        Wrap(
          spacing: ResponsiveHelper.getSpacing(context, 12),
          runSpacing: ResponsiveHelper.getSpacing(context, 8),
          children: [
            _buildBadge('🌍', isRTL ? 'عالمي' : 'Global'),
            _buildBadge('🔒', isRTL ? 'آمن' : 'Secure'),
            _buildBadge('⚡', isRTL ? 'سريع' : 'Fast'),
            _buildBadge('🏆', isRTL ? 'موثوق' : 'Trusted'),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(String emoji, String text) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveHelper.getSpacing(context, 16),
        vertical: ResponsiveHelper.getSpacing(context, 8),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context, 20),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(context, 16),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveHelper.getFontSize(context, 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(bool isRTL) {
    final features = [
      {
        'icon': Icons.video_call,
        'title': isRTL ? 'استشارات فورية' : 'Instant Consultations',
        'description':
            isRTL
                ? 'احصل على استشارة طبية فورية من أطباء متخصصين'
                : 'Get instant medical consultation from specialized doctors',
      },
      {
        'icon': Icons.security,
        'title': isRTL ? 'آمن وموثوق' : 'Safe & Trusted',
        'description':
            isRTL
                ? 'جميع الأطباء معتمدين ومرخصين من الجهات المختصة'
                : 'All doctors are certified and licensed by relevant authorities',
      },
      {
        'icon': Icons.language,
        'title': isRTL ? 'متعدد اللغات' : 'Multi-Language',
        'description':
            isRTL
                ? 'تواصل بلغتك المفضلة مع دعم كامل للعربية'
                : 'Communicate in your preferred language with full Arabic support',
      },
    ];

    return Column(
      children: [
        Text(
          isRTL ? 'لماذا تختارنا؟' : 'Why Choose Us?',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, 30)),
        ...features.map(
          (feature) => _buildFeatureCard(
            feature['icon'] as IconData,
            feature['title'] as String,
            feature['description'] as String,
            isRTL,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    bool isRTL,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.getSpacing(context, 20)),
      padding: ResponsiveHelper.getCardPadding(context),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(
          ResponsiveHelper.getBorderRadius(context, 20),
        ),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveHelper.getIconSize(context, 60),
            height: ResponsiveHelper.getIconSize(context, 60),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                ResponsiveHelper.getBorderRadius(context, 15),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: ResponsiveHelper.getIconSize(context, 30),
            ),
          ),
          SizedBox(width: ResponsiveHelper.getSpacing(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 18),
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: ResponsiveHelper.getSpacing(context, 8)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 14),
                    color: Colors.white.withOpacity(0.9),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isRTL) {
    return Column(
      children: [
        // Login Button
        SizedBox(
          width: double.infinity,
          height: ResponsiveHelper.getCardHeight(context, 56),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppTheme.primaryBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context, 28),
                ),
              ),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.login,
                  size: ResponsiveHelper.getIconSize(context, 24),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context, 12)),
                Text(
                  isRTL ? 'تسجيل الدخول' : 'Login',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 18),
                    fontWeight: FontWeight.w600,
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
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  ResponsiveHelper.getBorderRadius(context, 28),
                ),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add,
                  size: ResponsiveHelper.getIconSize(context, 24),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context, 12)),
                Text(
                  isRTL ? 'إنشاء حساب جديد' : 'Create New Account',
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context, 18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: ResponsiveHelper.getSpacing(context, 20)),
      ],
    );
  }

  Widget _buildTutorialSection(bool isRTL) {
    final tutorials = [
      {
        'title': isRTL ? 'إنشاء حساب' : 'Create Account',
        'description': isRTL 
            ? 'سجل ك مريض أو طبيب بسهولة' 
            : 'Sign up as a patient or doctor easily',
        'icon': Icons.person_add,
      },
      {
        'title': isRTL ? 'رفع حالة' : 'Submit Case',
        'description': isRTL 
            ? 'صف أعراضك وارفع التقارير الطبية' 
            : 'Describe your symptoms and upload medical reports',
        'icon': Icons.upload_file,
      },
      {
        'title': isRTL ? 'اختر طبيب' : 'Choose Doctor',
        'description': isRTL 
            ? 'اختر من بين أفضل الأطباء المتخصصين' 
            : 'Choose from the best specialized doctors',
        'icon': Icons.medical_services,
      },
      {
        'title': isRTL ? 'احصل على الاستشارة' : 'Get Consultation',
        'description': isRTL 
            ? 'استلم الرد الطبي خلال 48 ساعة' 
            : 'Receive medical response within 48 hours',
        'icon': Icons.check_circle,
      },
    ];

    return Column(
      children: [
        Text(
          isRTL ? 'كيف يعمل؟' : 'How It Works?',
          style: TextStyle(
            fontSize: ResponsiveHelper.getFontSize(context, 28),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: ResponsiveHelper.getSpacing(context, 30)),
        ...tutorials.asMap().entries.map((entry) {
          final index = entry.key;
          final tutorial = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: ResponsiveHelper.getSpacing(context, 20),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: ResponsiveHelper.getFontSize(context, 18),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: ResponsiveHelper.getSpacing(context, 16)),
                Expanded(
                  child: Container(
                    padding: ResponsiveHelper.getCardPadding(context),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(
                        ResponsiveHelper.getBorderRadius(context, 16),
                      ),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          tutorial['icon'] as IconData,
                          color: Colors.white,
                          size: 28,
                        ),
                        SizedBox(width: ResponsiveHelper.getSpacing(context, 16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tutorial['title'] as String,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, 18),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: ResponsiveHelper.getSpacing(context, 4)),
                              Text(
                                tutorial['description'] as String,
                                style: TextStyle(
                                  fontSize: ResponsiveHelper.getFontSize(context, 14),
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildFooter(bool isRTL) {
    return Text(
      isRTL
          ? '© 2024 المنصة الطبية - جميع الحقوق محفوظة'
          : '© 2024 Medical Platform - All Rights Reserved',
      style: TextStyle(
        color: Colors.white.withOpacity(0.7),
        fontSize: ResponsiveHelper.getFontSize(context, 14),
      ),
      textAlign: TextAlign.center,
    );
  }
}
