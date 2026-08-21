import 'package:flutter/material.dart';
import 'package:doctor_app/services/api_service.dart';
import 'package:doctor_app/core/theme/app_theme.dart';
import 'package:doctor_app/screens/auth/login_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  Map<String, dynamic>? _doctorProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDoctorProfile();
  }

  Future<void> _loadDoctorProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profile = await ApiService.getMyDoctorProfile();
      setState(() {
        _doctorProfile = profile;
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
            onPressed: _loadDoctorProfile,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
              ? _buildErrorWidget()
              : RefreshIndicator(
                onRefresh: _loadDoctorProfile,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // بطاقة المعلومات الشخصية
                      _buildProfileCard(),
                      const SizedBox(height: 16),

                      // التقييمات
                      _buildRatingsCard(),
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
            onPressed: _loadDoctorProfile,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final user = _doctorProfile?['user'];
    final doctor = _doctorProfile?['doctor'];

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
                  doctor?['profile_image'] != null
                      ? NetworkImage(doctor['profile_image'])
                      : null,
              child:
                  doctor?['profile_image'] == null
                      ? Text(
                        user?['first_name']?[0] ?? 'D',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                      : null,
            ),
            const SizedBox(height: 16),

            // الاسم والتخصص
            Text(
              'د. ${user?['first_name'] ?? ''} ${user?['last_name'] ?? ''}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              _getSpecializationText(doctor?['specialization']),
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // البريد الإلكتروني
            Text(
              user?['email'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),

            // معلومات إضافية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoItem(
                  Icons.work,
                  'الخبرة',
                  '${doctor?['experience_years'] ?? 0} سنة',
                ),
                _buildInfoItem(
                  Icons.location_on,
                  'البلد',
                  doctor?['country'] ?? 'غير محدد',
                ),
                _buildInfoItem(
                  Icons.verified,
                  'الحالة',
                  doctor?['status'] == 'approved' ? 'معتمد' : 'قيد المراجعة',
                ),
              ],
            ),

            if (doctor?['bio'] != null && doctor['bio'].isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'نبذة شخصية:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                doctor['bio'],
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRatingsCard() {
    final ratings = _doctorProfile?['ratings'];
    final averageRating = ratings?['average_rating'] ?? 0.0;
    final totalReviews = ratings?['total_reviews'] ?? 0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'التقييمات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.star, color: Colors.amber, size: 32),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$totalReviews تقييم',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const Spacer(),
                Column(
                  children: List.generate(5, (index) {
                    final starIndex = 5 - index;
                    final starCount =
                        ratings?['star_counts']?[starIndex.toString()] ?? 0;
                    final percentage =
                        totalReviews > 0
                            ? (starCount / totalReviews) * 100
                            : 0.0;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Text('$starIndex'),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 8),
                          Container(
                            width: 100,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('${percentage.toInt()}%'),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    final stats = _doctorProfile?['stats'];

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
                    'المرضى',
                    stats?['total_patients']?.toString() ?? '0',
                    Icons.people,
                    Colors.purple,
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('قريباً...')));
          }),
          _buildSettingItem(Icons.schedule, 'إدارة المواعيد', () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('قريباً...')));
          }),
          _buildSettingItem(Icons.lock, 'تغيير كلمة المرور', () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('قريباً...')));
          }),
          _buildSettingItem(Icons.notifications, 'إعدادات الإشعارات', () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('قريباً...')));
          }),
          _buildSettingItem(Icons.language, 'اللغة', () {
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
              'منصة طبية متخصصة تمكن الأطباء من تقديم الاستشارات الطبية للمرضى عن بُعد بطريقة آمنة وفعالة.',
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

  String _getSpecializationText(String? specialization) {
    final specializations = {
      'general': 'طب عام',
      'cardiology': 'أمراض القلب',
      'dermatology': 'الأمراض الجلدية',
      'neurology': 'الأمراض العصبية',
      'orthopedics': 'العظام',
      'pediatrics': 'طب الأطفال',
      'psychiatry': 'الطب النفسي',
      'gynecology': 'أمراض النساء',
      'urology': 'المسالك البولية',
      'ophthalmology': 'طب العيون',
      'ent': 'الأنف والأذن والحنجرة',
      'dentistry': 'طب الأسنان',
      'radiology': 'الأشعة',
      'anesthesia': 'التخدير',
      'emergency': 'طب الطوارئ',
      'surgery': 'الجراحة العامة',
      'internal': 'الباطنة',
      'family': 'طب الأسرة',
      'oncology': 'الأورام',
      'endocrinology': 'الغدد الصماء',
    };

    return specializations[specialization] ?? specialization ?? 'طبيب عام';
  }
}
