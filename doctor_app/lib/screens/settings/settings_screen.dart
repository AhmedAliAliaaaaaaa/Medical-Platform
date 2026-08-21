import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'server_settings_screen.dart';

import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/enhanced_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Settings state
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  bool _smsNotifications = false;
  bool _darkModeEnabled = false;
  bool _biometricEnabled = false;
  bool _autoBackup = true;
  double _fontSize = 16.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _loadSettings() {
    // Load settings from SharedPreferences or API
    // This is a placeholder implementation
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: Text(isRTL ? 'الإعدادات' : 'Settings'),
        backgroundColor: AppTheme.cardBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _resetToDefaults,
            tooltip: isRTL ? 'استعادة الافتراضي' : 'Reset to defaults',
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Account Settings
                  _buildAccountSettings(isRTL),
                  const SizedBox(height: 24),

                  // Notification Settings
                  _buildNotificationSettings(isRTL),
                  const SizedBox(height: 24),

                  // Appearance Settings
                  _buildAppearanceSettings(isRTL),
                  const SizedBox(height: 24),

                  // Security Settings
                  _buildSecuritySettings(isRTL),
                  const SizedBox(height: 24),

                  // Data & Privacy
                  _buildDataPrivacySettings(isRTL),
                  const SizedBox(height: 24),

                  // App Settings
                  _buildAppSettings(isRTL),
                  const SizedBox(height: 24),

                  // Support & About
                  _buildSupportSettings(isRTL),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAccountSettings(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            isRTL ? 'إعدادات الحساب' : 'Account Settings',
            Icons.account_circle,
          ),
          const SizedBox(height: 16),

          _buildSettingItem(
            icon: Icons.person,
            title: isRTL ? 'تعديل الملف الشخصي' : 'Edit Profile',
            subtitle:
                isRTL
                    ? 'تحديث معلوماتك الشخصية'
                    : 'Update your personal information',
            onTap: _editProfile,
          ),

          _buildSettingItem(
            icon: Icons.lock,
            title: isRTL ? 'تغيير كلمة المرور' : 'Change Password',
            subtitle:
                isRTL ? 'تحديث كلمة المرور الخاصة بك' : 'Update your password',
            onTap: _changePassword,
          ),

          _buildSettingItem(
            icon: Icons.email,
            title: isRTL ? 'تغيير البريد الإلكتروني' : 'Change Email',
            subtitle:
                isRTL
                    ? 'تحديث عنوان البريد الإلكتروني'
                    : 'Update your email address',
            onTap: _changeEmail,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            isRTL ? 'إعدادات الإشعارات' : 'Notification Settings',
            Icons.notifications,
          ),
          const SizedBox(height: 16),

          _buildSwitchItem(
            title: isRTL ? 'تفعيل الإشعارات' : 'Enable Notifications',
            subtitle:
                isRTL ? 'تلقي جميع الإشعارات' : 'Receive all notifications',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),

          if (_notificationsEnabled) ...[
            _buildSwitchItem(
              title:
                  isRTL ? 'إشعارات البريد الإلكتروني' : 'Email Notifications',
              subtitle:
                  isRTL
                      ? 'تلقي الإشعارات عبر البريد الإلكتروني'
                      : 'Receive notifications via email',
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value;
                });
              },
            ),

            _buildSwitchItem(
              title: isRTL ? 'الإشعارات الفورية' : 'Push Notifications',
              subtitle:
                  isRTL
                      ? 'تلقي الإشعارات الفورية على الجهاز'
                      : 'Receive push notifications on device',
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),

            _buildSwitchItem(
              title: isRTL ? 'إشعارات الرسائل النصية' : 'SMS Notifications',
              subtitle:
                  isRTL
                      ? 'تلقي الإشعارات عبر الرسائل النصية'
                      : 'Receive notifications via SMS',
              value: _smsNotifications,
              onChanged: (value) {
                setState(() {
                  _smsNotifications = value;
                });
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppearanceSettings(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            isRTL ? 'إعدادات المظهر' : 'Appearance Settings',
            Icons.palette,
          ),
          const SizedBox(height: 16),

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

          _buildSwitchItem(
            title: isRTL ? 'الوضع الليلي' : 'Dark Mode',
            subtitle: isRTL ? 'تفعيل الوضع الليلي' : 'Enable dark mode',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
              // TODO: Implement dark mode
            },
          ),

          _buildSliderItem(
            title: isRTL ? 'حجم الخط' : 'Font Size',
            subtitle:
                isRTL
                    ? 'تعديل حجم النص في التطبيق'
                    : 'Adjust text size in the app',
            value: _fontSize,
            min: 12.0,
            max: 24.0,
            divisions: 6,
            onChanged: (value) {
              setState(() {
                _fontSize = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSecuritySettings(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            isRTL ? 'إعدادات الأمان' : 'Security Settings',
            Icons.security,
          ),
          const SizedBox(height: 16),

          _buildSwitchItem(
            title: isRTL ? 'المصادقة البيومترية' : 'Biometric Authentication',
            subtitle:
                isRTL
                    ? 'استخدام بصمة الإصبع أو الوجه'
                    : 'Use fingerprint or face recognition',
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
              // TODO: Implement biometric authentication
            },
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
            icon: Icons.devices,
            title: isRTL ? 'الأجهزة المتصلة' : 'Connected Devices',
            subtitle:
                isRTL
                    ? 'إدارة الأجهزة المتصلة بحسابك'
                    : 'Manage devices connected to your account',
            onTap: _manageDevices,
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacySettings(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            isRTL ? 'البيانات والخصوصية' : 'Data & Privacy',
            Icons.privacy_tip,
          ),
          const SizedBox(height: 16),

          _buildSwitchItem(
            title: isRTL ? 'النسخ الاحتياطي التلقائي' : 'Auto Backup',
            subtitle:
                isRTL
                    ? 'نسخ احتياطي تلقائي للبيانات'
                    : 'Automatic backup of your data',
            value: _autoBackup,
            onChanged: (value) {
              setState(() {
                _autoBackup = value;
              });
            },
          ),

          _buildSettingItem(
            icon: Icons.download,
            title: isRTL ? 'تصدير البيانات' : 'Export Data',
            subtitle:
                isRTL
                    ? 'تحميل نسخة من بياناتك'
                    : 'Download a copy of your data',
            onTap: _exportData,
          ),

          _buildSettingItem(
            icon: Icons.delete_forever,
            title: isRTL ? 'حذف الحساب' : 'Delete Account',
            subtitle:
                isRTL ? 'حذف حسابك نهائياً' : 'Permanently delete your account',
            onTap: _deleteAccount,
            textColor: AppTheme.dangerRed,
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
          _buildSectionHeader(
            isRTL ? 'إعدادات التطبيق' : 'App Settings',
            Icons.settings,
          ),
          const SizedBox(height: 16),

          _buildSettingItem(
            icon: Icons.storage,
            title: isRTL ? 'إدارة التخزين' : 'Storage Management',
            subtitle:
                isRTL
                    ? 'إدارة مساحة التخزين المستخدمة'
                    : 'Manage used storage space',
            onTap: _manageStorage,
          ),

          _buildSettingItem(
            icon: Icons.cached,
            title: isRTL ? 'مسح الذاكرة المؤقتة' : 'Clear Cache',
            subtitle: isRTL ? 'مسح الملفات المؤقتة' : 'Clear temporary files',
            onTap: _clearCache,
          ),

          _buildSettingItem(
            icon: Icons.update,
            title: isRTL ? 'التحديثات' : 'Updates',
            subtitle:
                isRTL
                    ? 'التحقق من التحديثات المتاحة'
                    : 'Check for available updates',
            onTap: _checkUpdates,
          ),

          _buildSettingItem(
            icon: Icons.dns,
            title: isRTL ? 'إعدادات الخادم' : 'Server Settings',
            subtitle:
                isRTL
                    ? 'تغيير عنوان الخادم'
                    : 'Change server address',
            onTap: _openServerSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSettings(bool isRTL) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            isRTL ? 'الدعم والمساعدة' : 'Support & Help',
            Icons.help,
          ),
          const SizedBox(height: 16),

          _buildSettingItem(
            icon: Icons.help_center,
            title: isRTL ? 'مركز المساعدة' : 'Help Center',
            subtitle:
                isRTL ? 'الأسئلة الشائعة والمساعدة' : 'FAQ and help articles',
            onTap: _openHelpCenter,
          ),

          _buildSettingItem(
            icon: Icons.contact_support,
            title: isRTL ? 'اتصل بنا' : 'Contact Us',
            subtitle:
                isRTL
                    ? 'تواصل مع فريق الدعم'
                    : 'Get in touch with support team',
            onTap: _contactSupport,
          ),

          _buildSettingItem(
            icon: Icons.feedback,
            title: isRTL ? 'إرسال ملاحظات' : 'Send Feedback',
            subtitle:
                isRTL
                    ? 'شاركنا رأيك واقتراحاتك'
                    : 'Share your thoughts and suggestions',
            onTap: _sendFeedback,
          ),

          _buildSettingItem(
            icon: Icons.info,
            title: isRTL ? 'حول التطبيق' : 'About App',
            subtitle:
                isRTL
                    ? 'معلومات التطبيق والإصدار'
                    : 'App information and version',
            onTap: _showAbout,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppTheme.primaryBlue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: textColor ?? AppTheme.primaryBlue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppTheme.textPrimary,
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

  Widget _buildSwitchItem({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
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
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryBlue,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  Widget _buildSliderItem({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
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
          trailing: Text(
            value.toInt().toString(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 4,
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.primaryBlue,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Action methods
  void _editProfile() {
    // Navigate to profile edit screen
  }

  void _changePassword() {
    // Navigate to change password screen
  }

  void _changeEmail() {
    // Navigate to change email screen
  }

  void _setupTwoFactor() {
    // Navigate to two-factor setup
  }

  void _manageDevices() {
    // Navigate to device management
  }

  void _exportData() {
    // Export user data
  }

  void _deleteAccount() {
    // Show delete account confirmation
  }

  void _manageStorage() {
    // Show storage management
  }

  void _clearCache() {
    // Clear app cache
  }

  void _checkUpdates() {
    // Check for app updates
  }

  void _openHelpCenter() {
    // Open help center
  }

  void _contactSupport() {
    // Open contact support
  }

  void _sendFeedback() {
    // Open feedback form
  }

  void _showAbout() {
    // Show about dialog
  }

  void _resetToDefaults() {
    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isRTL ? 'استعادة الإعدادات الافتراضية' : 'Reset to Defaults',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            isRTL
                ? 'هل أنت متأكد من استعادة جميع الإعدادات إلى القيم الافتراضية؟'
                : 'Are you sure you want to reset all settings to default values?',
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
                _performReset();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isRTL ? 'استعادة' : 'Reset',
                style: const TextStyle(color: AppTheme.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performReset() {
    setState(() {
      _notificationsEnabled = true;
      _emailNotifications = true;
      _pushNotifications = true;
      _smsNotifications = false;
      _darkModeEnabled = false;
      _biometricEnabled = false;
      _autoBackup = true;
      _fontSize = 16.0;
    });

    final isRTL = Provider.of<LanguageProvider>(context, listen: false).isRTL;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isRTL
              ? 'تم استعادة الإعدادات الافتراضية'
              : 'Settings reset to defaults',
        ),
        backgroundColor: AppTheme.primaryGreen,
      ),
    );
  }

  void _openServerSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ServerSettingsScreen(),
      ),
    );
  }
}
