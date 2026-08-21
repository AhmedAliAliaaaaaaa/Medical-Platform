import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/enhanced_card.dart';
import '../../widgets/enhanced_inputs.dart';

class EnhancedProfileScreen extends StatefulWidget {
  const EnhancedProfileScreen({super.key});

  @override
  State<EnhancedProfileScreen> createState() => _EnhancedProfileScreenState();
}

class _EnhancedProfileScreenState extends State<EnhancedProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;
  File? _profileImage;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email;
      _phoneController.text = user.phoneNumber ?? '';
      _bioController.text = user.bio ?? '';
      _addressController.text = user.address ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isRTL = languageProvider.isRTL;
    final user = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // App Bar with Profile Header
                  _buildSliverAppBar(user, isRTL),

                  // Profile Content
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Profile Stats
                          _buildProfileStats(user, isRTL),
                          const SizedBox(height: 24),

                          // Profile Form
                          _buildProfileForm(isRTL),
                          const SizedBox(height: 24),

                          // Account Settings
                          _buildAccountSettings(isRTL),
                          const SizedBox(height: 24),

                          // App Settings
                          _buildAppSettings(isRTL),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(user, bool isRTL) {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryBlue,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryBlue, AppTheme.primaryPurple],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 60),

                // Profile Picture
                Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child:
                            _profileImage != null
                                ? Image.file(
                                  _profileImage!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                )
                                : user?.profilePicture != null
                                ? Image.network(
                                  user!.profilePicture!,
                                  width: 120,
                                  height: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                )
                                : _buildDefaultAvatar(),
                      ),
                    ),

                    // Edit Button
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryGreen,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: AppTheme.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // User Name
                Text(
                  user?.fullName ?? (isRTL ? 'المستخدم' : 'User'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.white,
                  ),
                ),

                const SizedBox(height: 4),

                // User Role
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user?.role == 'doctor'
                        ? (isRTL ? 'طبيب' : 'Doctor')
                        : (isRTL ? 'مريض' : 'Patient'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isEditing ? Icons.save : Icons.edit,
            color: AppTheme.white,
          ),
          onPressed: _toggleEdit,
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlue,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.person, size: 60, color: AppTheme.white),
    );
  }

  Widget _buildProfileStats(user, bool isRTL) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: isRTL ? 'الحالات' : 'Cases',
            value: '12',
            icon: Icons.medical_services,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: isRTL ? 'المواعيد' : 'Appointments',
            value: '8',
            icon: Icons.calendar_today,
            color: AppTheme.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: isRTL ? 'التقييم' : 'Rating',
            value: '4.8',
            icon: Icons.star,
            color: AppTheme.warningYellow,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return EnhancedCard(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm(bool isRTL) {
    return EnhancedCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isRTL ? 'المعلومات الشخصية' : 'Personal Information',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 20),

            // First Name & Last Name
            Row(
              children: [
                Expanded(
                  child: EnhancedTextField(
                    label: isRTL ? 'الاسم الأول' : 'First Name',
                    controller: _firstNameController,
                    prefixIcon: Icons.person,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return isRTL ? 'مطلوب' : 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: EnhancedTextField(
                    label: isRTL ? 'اسم العائلة' : 'Last Name',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline,
                    enabled: _isEditing,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return isRTL ? 'مطلوب' : 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Email
            EnhancedTextField(
              label: isRTL ? 'البريد الإلكتروني' : 'Email',
              controller: _emailController,
              prefixIcon: Icons.email,
              enabled: false, // Email shouldn't be editable
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Phone
            EnhancedTextField(
              label: isRTL ? 'رقم الهاتف' : 'Phone Number',
              controller: _phoneController,
              prefixIcon: Icons.phone,
              enabled: _isEditing,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Bio
            EnhancedTextField(
              label: isRTL ? 'نبذة عني' : 'About Me',
              controller: _bioController,
              prefixIcon: Icons.info,
              enabled: _isEditing,
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Address
            EnhancedTextField(
              label: isRTL ? 'العنوان' : 'Address',
              controller: _addressController,
              prefixIcon: Icons.location_on,
              enabled: _isEditing,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'إعدادات الحساب' : 'Account Settings',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingItem(
            icon: Icons.lock,
            title: isRTL ? 'تغيير كلمة المرور' : 'Change Password',
            subtitle:
                isRTL ? 'تحديث كلمة المرور الخاصة بك' : 'Update your password',
            onTap: _changePassword,
          ),

          _buildSettingItem(
            icon: Icons.security,
            title: isRTL ? 'المصادقة الثنائية' : 'Two-Factor Authentication',
            subtitle:
                isRTL
                    ? 'تأمين إضافي لحسابك'
                    : 'Extra security for your account',
            onTap: _setupTwoFactor,
          ),

          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: isRTL ? 'الخصوصية' : 'Privacy Settings',
            subtitle:
                isRTL ? 'إدارة خصوصية بياناتك' : 'Manage your data privacy',
            onTap: _privacySettings,
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isRTL ? 'إعدادات التطبيق' : 'App Settings',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          _buildSettingItem(
            icon: Icons.notifications,
            title: isRTL ? 'الإشعارات' : 'Notifications',
            subtitle:
                isRTL ? 'إدارة إشعارات التطبيق' : 'Manage app notifications',
            onTap: _notificationSettings,
          ),

          _buildSettingItem(
            icon: Icons.language,
            title: isRTL ? 'اللغة' : 'Language',
            subtitle: isRTL ? 'تغيير لغة التطبيق' : 'Change app language',
            trailing: Consumer<LanguageProvider>(
              builder: (context, languageProvider, child) {
                return Switch(
                  value: languageProvider.isArabic,
                  onChanged: (value) {
                    languageProvider.toggleLanguage();
                  },
                  activeColor: AppTheme.primaryBlue,
                );
              },
            ),
          ),

          _buildSettingItem(
            icon: Icons.help,
            title: isRTL ? 'المساعدة والدعم' : 'Help & Support',
            subtitle: isRTL ? 'احصل على المساعدة' : 'Get help and support',
            onTap: _helpSupport,
          ),

          _buildSettingItem(
            icon: Icons.info,
            title: isRTL ? 'حول التطبيق' : 'About App',
            subtitle:
                isRTL ? 'معلومات التطبيق والإصدار' : 'App info and version',
            onTap: _aboutApp,
          ),

          const SizedBox(height: 16),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: Text(isRTL ? 'تسجيل الخروج' : 'Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.dangerRed,
                side: const BorderSide(color: AppTheme.dangerRed),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
      ),
      trailing:
          trailing ??
          const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: AppTheme.textSecondary,
          ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  void _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
      // TODO: Upload image to server
    }
  }

  void _toggleEdit() {
    if (_isEditing) {
      _saveProfile();
    } else {
      setState(() {
        _isEditing = true;
      });
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Save profile data to server
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      setState(() {
        _isEditing = false;
        _isLoading = false;
      });

      final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? 'تم حفظ البيانات بنجاح' : 'Profile updated successfully',
          ),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isRTL ? 'حدث خطأ في حفظ البيانات' : 'Error updating profile',
          ),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  void _changePassword() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;
    // TODO: Navigate to change password screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL
              ? 'ميزة تغيير كلمة المرور قريباً'
              : 'Change password feature coming soon',
        ),
      ),
    );
  }

  void _setupTwoFactor() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;
    // TODO: Navigate to two-factor setup
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL
              ? 'ميزة المصادقة الثنائية قريباً'
              : 'Two-factor authentication coming soon',
        ),
      ),
    );
  }

  void _privacySettings() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;
    // TODO: Navigate to privacy settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL ? 'إعدادات الخصوصية قريباً' : 'Privacy settings coming soon',
        ),
      ),
    );
  }

  void _notificationSettings() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;
    // TODO: Navigate to notification settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL
              ? 'إعدادات الإشعارات قريباً'
              : 'Notification settings coming soon',
        ),
      ),
    );
  }

  void _helpSupport() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;
    // TODO: Navigate to help & support
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL ? 'صفحة المساعدة قريباً' : 'Help & support page coming soon',
        ),
      ),
    );
  }

  void _aboutApp() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isRTL ? 'حول التطبيق' : 'About App',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isRTL ? 'تطبيق الاستشارات الطبية' : 'Medical Consultation App',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isRTL ? 'الإصدار: 1.1.0' : 'Version: 1.1.0',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isRTL
                    ? 'تطبيق متكامل للاستشارات الطبية عبر الإنترنت مع أفضل الأطباء المختصين.'
                    : 'Complete medical consultation app with the best specialist doctors online.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                isRTL ? 'إغلاق' : 'Close',
                style: const TextStyle(color: AppTheme.primaryBlue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _logout() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isRTL ? 'تسجيل الخروج' : 'Logout',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            isRTL
                ? 'هل أنت متأكد من تسجيل الخروج؟'
                : 'Are you sure you want to logout?',
            style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
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
                Provider.of<AuthProvider>(context, listen: false).logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dangerRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isRTL ? 'تسجيل الخروج' : 'Logout',
                style: const TextStyle(color: AppTheme.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
