
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import 'admin_constants.dart';
import 'widgets/admin_loading_error_widgets.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // إعدادات النظام
  bool _allowNewDoctorRegistrations = true;
  bool _requireDoctorApproval = true;
  bool _enableNotifications = true;
  bool _enableEmailNotifications = true;
  int _maxCasesPerDay = 10;
  int _maxDoctorsPerPatient = 3;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // في التطبيق الحقيقي، سيتم جلب الإعدادات من الخادم
      // هنا نستخدم قيم افتراضية للعرض
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // في التطبيق الحقيقي، سيتم حفظ الإعدادات في الخادم
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ الإعدادات بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في حفظ الإعدادات: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AdminConstants.softBg,
        appBar: AppBar(
          title: const Text('إعدادات النظام'),
          backgroundColor: AdminConstants.darkBlue,
          foregroundColor: Colors.white,
        ),
        body: _isLoading
            ? const AdminLoadingWidget()
            : _errorMessage != null
                ? AdminErrorWidget(
                    errorMessage: _errorMessage,
                    onRetry: _loadSettings,
                  )
                : _buildContent(),
        floatingActionButton: FloatingActionButton(
          onPressed: _saveSettings,
          backgroundColor: AdminConstants.orange,
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('إعدادات التسجيل'),
          const SizedBox(height: AdminConstants.spacingSmall),
          _buildSwitchTile(
            'السماح بتسجيل أطباء جدد',
            'السماح للأطباء الجدد بتسجيل حسابات في النظام',
            _allowNewDoctorRegistrations,
            (value) {
              setState(() {
                _allowNewDoctorRegistrations = value;
              });
            },
          ),
          _buildSwitchTile(
            'الموافقة على حسابات الأطباء',
            'يتطلب موافقة المشرف قبل تفعيل حسابات الأطباء',
            _requireDoctorApproval,
            (value) {
              setState(() {
                _requireDoctorApproval = value;
              });
            },
          ),

          const SizedBox(height: AdminConstants.spacingMedium),
          _buildSectionTitle('إعدادات الإشعارات'),
          const SizedBox(height: AdminConstants.spacingSmall),
          _buildSwitchTile(
            'تفعيل الإشعارات',
            'إرسال إشعارات للمستخدمين في التطبيق',
            _enableNotifications,
            (value) {
              setState(() {
                _enableNotifications = value;
              });
            },
          ),
          _buildSwitchTile(
            'إشعارات البريد الإلكتروني',
            'إرسال إشعارات عبر البريد الإلكتروني',
            _enableEmailNotifications,
            (value) {
              setState(() {
                _enableEmailNotifications = value;
              });
            },
          ),

          const SizedBox(height: AdminConstants.spacingMedium),
          _buildSectionTitle('إعدادات النظام'),
          const SizedBox(height: AdminConstants.spacingSmall),
          _buildNumberInputTile(
            'الحد الأقصى للحالات اليومية',
            'الحد الأقصى للحالات التي يمكن للطبيب استقبالها يومياً',
            _maxCasesPerDay,
            (value) {
              setState(() {
                _maxCasesPerDay = value;
              });
            },
          ),
          _buildNumberInputTile(
            'الحد الأقصى للأطباء',
            'الحد الأقصى للأطباء الذين يمكن للمريض استشارتهم',
            _maxDoctorsPerPatient,
            (value) {
              setState(() {
                _maxDoctorsPerPatient = value;
              });
            },
          ),

          const SizedBox(height: AdminConstants.spacingMedium),
          _buildSectionTitle('إدارة النظام'),
          const SizedBox(height: AdminConstants.spacingSmall),
          _buildActionTile(
            'حذف جميع الإشعارات',
            Icons.delete_sweep,
            Colors.red,
            () async {
              final confirmed = await _showConfirmationDialog(
                'حذف جميع الإشعارات',
                'هل أنت متأكد من رغبتك في حذف جميع الإشعارات في النظام؟',
              );

              if (confirmed) {
                // في التطبيق الحقيقي، سيتم حذف الإشعارات من الخادم
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف جميع الإشعارات بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          _buildActionTile(
            'إعادة تعيين كلمات المرور',
            Icons.lock_reset,
            Colors.orange,
            () async {
              final confirmed = await _showConfirmationDialog(
                'إعادة تعيين كلمات المرور',
                'هل أنت متأكد من رغبتك في إعادة تعيين كلمات مرور جميع المستخدمين؟',
              );

              if (confirmed) {
                // في التطبيق الحقيقي، سيتم إعادة تعيين كلمات المرور في الخادم
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إعادة تعيين كلمات المرور بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
          _buildActionTile(
            'حذف البيانات غير النشطة',
            Icons.storage,
            Colors.purple,
            () async {
              final confirmed = await _showConfirmationDialog(
                'حذف البيانات غير النشطة',
                'هل أنت متأكد من رغبتك في حذف البيانات غير النشطة؟',
              );

              if (confirmed) {
                // في التطبيق الحقيقي، سيتم حذف البيانات من الخادم
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم حذف البيانات غير النشطة بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),

          const SizedBox(height: 80), // مساحة آمنة أسفل لتفادي أي تراكب
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AdminConstants.title,
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      margin: const EdgeInsets.only(bottom: AdminConstants.spacingSmall),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AdminConstants.textPrimary,
                  ),
                ),
                const SizedBox(height: AdminConstants.spacingSmall),
                Text(
                  subtitle,
                  style: AdminConstants.subtitle,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AdminConstants.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputTile(
    String title,
    String subtitle,
    int value,
    Function(int) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      margin: const EdgeInsets.only(bottom: AdminConstants.spacingSmall),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AdminConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          Text(
            subtitle,
            style: AdminConstants.subtitle,
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  if (value > 1) {
                    onChanged(value - 1);
                  }
                },
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: AdminConstants.orange.withOpacity(0.1),
                  foregroundColor: AdminConstants.orange,
                ),
              ),
              const SizedBox(width: AdminConstants.spacingMedium),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: AdminConstants.spacingMedium),
              IconButton(
                onPressed: () {
                  onChanged(value + 1);
                },
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: AdminConstants.orange.withOpacity(0.1),
                  foregroundColor: AdminConstants.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AdminConstants.spacingSmall),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AdminConstants.spacingSmall),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AdminConstants.borderRadiusSmall,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Future<bool> _showConfirmationDialog(String title, String message) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
