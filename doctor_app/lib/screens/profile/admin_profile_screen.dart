import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/auth_provider.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Directionality(
          textDirection: languageProvider.textDirection,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(
                          Icons.admin_panel_settings,
                          size: 50,
                          color: Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${authProvider.user?.firstName ?? ''} ${authProvider.user?.lastName ?? ''}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isRTL ? 'مشرف النظام' : 'System Administrator',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authProvider.user?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Options
                _buildProfileOption(
                  icon: Icons.person,
                  title: isRTL ? 'المعلومات الشخصية' : 'Personal Information',
                  onTap: () {
                    // Navigate to edit profile
                  },
                ),
                _buildProfileOption(
                  icon: Icons.settings,
                  title: isRTL ? 'إعدادات النظام' : 'System Settings',
                  onTap: () {
                    // Navigate to system settings
                  },
                ),
                _buildProfileOption(
                  icon: Icons.security,
                  title: isRTL ? 'الأمان' : 'Security',
                  onTap: () {
                    // Navigate to security settings
                  },
                ),
                _buildProfileOption(
                  icon: Icons.backup,
                  title: isRTL ? 'النسخ الاحتياطي' : 'Backup & Restore',
                  onTap: () {
                    // Navigate to backup settings
                  },
                ),
                _buildProfileOption(
                  icon: Icons.notifications,
                  title: isRTL ? 'الإشعارات' : 'Notifications',
                  onTap: () {
                    // Navigate to notifications settings
                  },
                ),
                _buildProfileOption(
                  icon: Icons.language,
                  title: isRTL ? 'اللغة' : 'Language',
                  onTap: () {
                    // Show language selection
                  },
                ),
                _buildProfileOption(
                  icon: Icons.help,
                  title: isRTL ? 'المساعدة والدعم' : 'Help & Support',
                  onTap: () {
                    // Navigate to help
                  },
                ),
                _buildProfileOption(
                  icon: Icons.info,
                  title: isRTL ? 'حول التطبيق' : 'About App',
                  onTap: () {
                    // Show about dialog
                  },
                ),
                _buildProfileOption(
                  icon: Icons.logout,
                  title: isRTL ? 'تسجيل الخروج' : 'Logout',
                  onTap: () {
                    _showLogoutDialog();
                  },
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color:
                isDestructive
                    ? const Color(0xFFEF4444).withOpacity(0.1)
                    : const Color(0xFF7C3AED).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color:
                isDestructive
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF7C3AED),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color:
                isDestructive
                    ? const Color(0xFFEF4444)
                    : const Color(0xFF1E293B),
          ),
        ),
        trailing: Icon(
          Provider.of<LanguageProvider>(context).isRTL
              ? Icons.arrow_back_ios
              : Icons.arrow_forward_ios,
          color: const Color(0xFF64748B),
          size: 16,
        ),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showLogoutDialog() {
    final isRTL = Provider.of<LanguageProvider>(context).isRTL;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(isRTL ? 'تسجيل الخروج' : 'Logout'),
            content: Text(
              isRTL
                  ? 'هل أنت متأكد من أنك تريد تسجيل الخروج؟'
                  : 'Are you sure you want to logout?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(isRTL ? 'إلغاء' : 'Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  await Provider.of<AuthProvider>(
                    context,
                    listen: false,
                  ).logout();
                  if (mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  }
                },
                child: Text(
                  isRTL ? 'تسجيل الخروج' : 'Logout',
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
    );
  }
}
