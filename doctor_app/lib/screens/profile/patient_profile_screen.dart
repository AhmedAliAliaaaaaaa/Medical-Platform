import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import '../auth/login_screen.dart';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await ApiService.getUserProfile();
      setState(() {
        _userProfile = profile;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // مسح البيانات المحفوظة
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserProfile,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                onRefresh: _loadUserProfile,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // بطاقة المعلومات الشخصية
                      _buildProfileCard(),
                      const SizedBox(height: 16),

                      // الإحصائيات
                      _buildStatsCard(),
                      const SizedBox(height: 16),

                      // الإعدادات
                      _buildSettingsCard(),
                      const SizedBox(height: 16),

                      // معلومات التطبيق
                      _buildAppInfoCard(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Text(
            'خطأ في تحميل البيانات',
            style: TextStyle(fontSize: 18, color: Colors.red.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserProfile,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = _userProfile?['user'];
    final patient = _userProfile?['patient'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // صورة الملف الشخصي
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primaryBlue,
              backgroundImage:
                  patient?['profile_image'] != null
                      ? NetworkImage(patient['profile_image'])
                      : null,
              child:
                  patient?['profile_image'] == null
                      ? Text(
                        user?['first_name']?[0] ?? 'M',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 16),

            // الاسم
            Text(
              '${user?['first_name'] ?? ''} ${user?['last_name'] ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // البريد الإلكتروني
            Text(
              user?['email'] ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // معلومات إضافية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                  Icons.phone,
                  'الهاتف',
                  patient?['phone'] ?? 'غير محدد',
                ),
                _buildInfoItem(
                  Icons.cake,
                  'العمر',
                  patient?['age']?.toString() ?? 'غير محدد',
                ),
                _buildInfoItem(
                  Icons.wc,
                  'الجنس',
                  patient?['gender'] == 'male' ? 'ذكر' : 'أنثى',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primaryBlue),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    final stats = _userProfile?['stats'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الإحصائيات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'إجمالي الحالات',
                    stats?['total_cases']?.toString() ?? '0',
                    Icons.medical_services,
                    AppTheme.primaryBlue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'تم الرد عليها',
                    stats?['completed_cases']?.toString() ?? '0',
                    Icons.check_circle,
                    AppTheme.primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'قيد الانتظار',
                    stats?['pending_cases']?.toString() ?? '0',
                    Icons.schedule,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'الإشعارات',
                    stats?['unread_notifications']?.toString() ?? '0',
                    Icons.notifications,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
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
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.settings, color: AppTheme.primaryBlue),
                SizedBox(width: 12),
                Text(
                  'الإعدادات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          _buildSettingItem(Icons.edit, 'تعديل الملف الشخصي', () {
            // TODO: Navigate to edit profile screen
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('قريباً...')));
          }),
          _buildSettingItem(Icons.lock, 'تغيير كلمة المرور', () {
            // TODO: Navigate to change password screen
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('قريباً...')));
          }),
          _buildSettingItem(Icons.notifications, 'إعدادات الإشعارات', () {
            // TODO: Navigate to notification settings
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('قريباً...')));
          }),
          _buildSettingItem(Icons.language, 'اللغة', () {
            // TODO: Show language selection
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('قريباً...')));
          }),
          _buildSettingItem(
            Icons.logout,
            'تسجيل الخروج',
            _logout,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : Colors.grey.shade600,
      ),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : Colors.black87),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildAppInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, color: AppTheme.primaryBlue),
                SizedBox(width: 12),
                Text(
                  'معلومات التطبيق',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('اسم التطبيق', 'تطبيق الاستشارات الطبية'),
            _buildInfoRow('الإصدار', '1.0.0'),
            _buildInfoRow('المطور', 'فريق التطوير الطبي'),
            const SizedBox(height: 16),
            const Text(
              'تطبيق للاستشارات الطبية يربط المرضى بالأطباء المختصين لتقديم الاستشارات الطبية عن بُعد.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
