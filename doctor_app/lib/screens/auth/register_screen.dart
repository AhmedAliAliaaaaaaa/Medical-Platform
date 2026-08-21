import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_theme.dart';
import '../../widgets/enhanced_inputs.dart';
import '../../widgets/enhanced_buttons.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

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
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على الشروط والأحكام'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.register(
        firstName: _usernameController.text.trim(),
        lastName: '', // اسم العائلة فارغ
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phoneNumber: _phoneController.text.trim(),
        userType: 'patient',
      );

      if (mounted) {
        // Show success then navigate to login for first sign-in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إنشاء الحساب بنجاح. يرجى تسجيل الدخول.'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        await Future.delayed(const Duration(milliseconds: 600));
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في التسجيل: ${e.toString()}'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
            colors: [AppTheme.primaryGreen, AppTheme.primaryBlue],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Header
                      _buildHeader(isRTL),

                      const SizedBox(height: 30),

                      // Registration Form
                      _buildRegistrationForm(isRTL),

                      const SizedBox(height: 20),

                      // Terms and Conditions
                      _buildTermsCheckbox(isRTL),

                      const SizedBox(height: 20),

                      // Register Button
                      _buildRegisterButton(isRTL),

                      const SizedBox(height: 20),

                      // Login Link
                      _buildLoginLink(isRTL),
                    ],
                  ),
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
              ),
            ),
          ],
        ),

        // Logo
        Container(
          width: 80,
          height: 80,
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
          child: const Icon(
            Icons.person_add,
            size: 40,
            color: AppTheme.primaryGreen,
          ),
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          isRTL ? 'إنشاء حساب جديد' : 'Create New Account',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          isRTL ? 'انضم إلى المنصة الطبية' : 'Join the Medical Platform',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm(bool isRTL) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Username Field
          EnhancedTextField(
            label: isRTL ? 'اسم المستخدم' : 'Username',
            controller: _usernameController,
            prefixIcon: Icons.person,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return isRTL
                    ? 'يرجى إدخال اسم المستخدم'
                    : 'Please enter username';
              }
              if (value!.length < 3) {
                return isRTL
                    ? 'اسم المستخدم قصير جداً (3 أحرف على الأقل)'
                    : 'Username too short (at least 3 characters)';
              }
              if (!RegExp(r'^[a-zA-Z0-9_ ]+$').hasMatch(value)) {
                return isRTL
                    ? 'اسم المستخدم يجب أن يحتوي على أحرف وأرقام ومسافات فقط'
                    : 'Username can only contain letters, numbers, spaces and underscore';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Email Field
          EnhancedTextField(
            label: isRTL ? 'البريد الإلكتروني' : 'Email',
            controller: _emailController,
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return isRTL
                    ? 'يرجى إدخال البريد الإلكتروني'
                    : 'Please enter email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value!)) {
                return isRTL
                    ? 'البريد الإلكتروني غير صحيح'
                    : 'Invalid email format';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Phone Field
          EnhancedTextField(
            label: isRTL ? 'رقم الهاتف' : 'Phone Number',
            controller: _phoneController,
            prefixIcon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return isRTL
                    ? 'يرجى إدخال رقم الهاتف'
                    : 'Please enter phone number';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Password Field
          EnhancedTextField(
            label: isRTL ? 'كلمة المرور' : 'Password',
            controller: _passwordController,
            prefixIcon: Icons.lock,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return isRTL
                    ? 'يرجى إدخال كلمة المرور'
                    : 'Please enter password';
              }
              if (value!.length < 6) {
                return isRTL ? 'كلمة المرور قصيرة جداً' : 'Password too short';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Confirm Password Field
          EnhancedTextField(
            label: isRTL ? 'تأكيد كلمة المرور' : 'Confirm Password',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value?.isEmpty ?? true) {
                return isRTL
                    ? 'يرجى تأكيد كلمة المرور'
                    : 'Please confirm password';
              }
              if (value != _passwordController.text) {
                return isRTL
                    ? 'كلمات المرور غير متطابقة'
                    : 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox(bool isRTL) {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppTheme.primaryGreen,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Text(
              isRTL
                  ? 'أوافق على الشروط والأحكام وسياسة الخصوصية'
                  : 'I agree to the Terms & Conditions and Privacy Policy',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(bool isRTL) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    isRTL ? 'إنشاء الحساب' : 'Create Account',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginLink(bool isRTL) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          isRTL ? 'لديك حساب بالفعل؟' : 'Already have an account?',
          style: TextStyle(color: Colors.white.withOpacity(0.8)),
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
            ),
          ),
        ),
      ],
    );
  }
}
