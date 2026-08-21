import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/language_provider.dart';
import '../../services/admin_api_service.dart';
import '../../utils/app_theme.dart';
import 'admin_constants.dart';
import 'widgets/admin_loading_error_widgets.dart';

class NotificationsManagementScreen extends StatefulWidget {
  const NotificationsManagementScreen({super.key});

  @override
  State<NotificationsManagementScreen> createState() =>
      _NotificationsManagementScreenState();
}

class _NotificationsManagementScreenState
    extends State<NotificationsManagementScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedUserType = 'all';
  String? _selectedUserId;
  bool _isLoading = false;
  bool _isLoadingUsers = false;
  String? _errorMessage;
  String? _successMessage;
  List<Map<String, dynamic>> _availableUsers = [];

  final List<Map<String, String>> _userTypes = [
    {'value': 'all', 'label_ar': 'جميع المستخدمين', 'label_en': 'All Users'},
    {'value': 'patient', 'label_ar': 'المرضى فقط', 'label_en': 'Patients Only'},
    {'value': 'doctor', 'label_ar': 'الأطباء فقط', 'label_en': 'Doctors Only'},
    {
      'value': 'individual_patient',
      'label_ar': 'مريض محدد',
      'label_en': 'Specific Patient'
    },
    {
      'value': 'individual_doctor',
      'label_ar': 'طبيب محدد',
      'label_en': 'Specific Doctor'
    },
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // جلب قائمة المستخدمين حسب النوع
  Future<void> _loadUsers(String userType) async {
    if (!['individual_patient', 'individual_doctor'].contains(userType)) {
      setState(() {
        _availableUsers = [];
        _selectedUserId = null;
      });
      return;
    }

    setState(() {
      _isLoadingUsers = true;
      _availableUsers = [];
      _selectedUserId = null;
    });

    try {
      List<Map<String, dynamic>> users = [];

      if (userType == 'individual_patient') {
        // جلب قائمة المرضى
        final response = await AdminApiService.getPatients();
        users = (response['patients'] as List? ?? [])
            .map((patient) => {
                  'id': patient['id'].toString(),
                  'name': patient['user']['first_name'] +
                      ' ' +
                      (patient['user']['last_name'] ?? ''),
                  'email': patient['user']['email'],
                  'type': 'patient',
                })
            .toList();
      } else if (userType == 'individual_doctor') {
        // جلب قائمة الأطباء
        final response = await AdminApiService.getDoctors();
        users = (response['doctors'] as List? ?? [])
            .map((doctor) => {
                  'id': doctor['id'].toString(),
                  'name': doctor['user']['first_name'] +
                      ' ' +
                      (doctor['user']['last_name'] ?? ''),
                  'email': doctor['user']['email'],
                  'specialization': doctor['specialization'] ?? '',
                  'type': 'doctor',
                })
            .toList();
      }

      setState(() {
        _availableUsers = users;
        _isLoadingUsers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingUsers = false;
        _errorMessage = 'فشل في تحميل قائمة المستخدمين: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isRTL = languageProvider.isRTL;

    return Scaffold(
      backgroundColor: AdminConstants.softBg,
      appBar: AppBar(
        title: Text(isRTL ? 'إدارة الإشعارات' : 'Notifications Management'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: languageProvider.textDirection,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AdminConstants.paddingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSendNotificationCard(isRTL),
                const SizedBox(height: AdminConstants.spacingMedium),
                _buildNotificationHistoryCard(isRTL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendNotificationCard(bool isRTL) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.send, color: AppTheme.primaryBlue, size: 24),
              const SizedBox(width: AdminConstants.spacingSmall),
              Text(
                isRTL ? 'إرسال إشعار جديد' : 'Send New Notification',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AdminConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingMedium),

          // رسائل الحالة
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AdminConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: AdminConstants.borderRadiusSmall,
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: AdminConstants.spacingSmall),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AdminConstants.spacingMedium),
          ],

          if (_successMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AdminConstants.paddingSmall),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: AdminConstants.borderRadiusSmall,
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: AdminConstants.spacingSmall),
                  Expanded(
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green.shade600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AdminConstants.spacingMedium),
          ],

          // اختيار نوع المستخدمين
          Text(
            isRTL ? 'إرسال إلى:' : 'Send to:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AdminConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: AdminConstants.borderRadiusSmall,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedUserType,
                isExpanded: true,
                items: _userTypes.map((type) {
                  return DropdownMenuItem<String>(
                    value: type['value'],
                    child: Text(
                      isRTL ? type['label_ar']! : type['label_en']!,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedUserType = value!;
                    _errorMessage = null;
                    _successMessage = null;
                  });
                  // تحميل قائمة المستخدمين إذا كان الاختيار فردي
                  _loadUsers(value!);
                },
              ),
            ),
          ),
          const SizedBox(height: AdminConstants.spacingMedium),

          // اختيار المستخدم الفردي (يظهر فقط عند اختيار مريض محدد أو طبيب محدد)
          if (['individual_patient', 'individual_doctor']
              .contains(_selectedUserType)) ...[
            Text(
              isRTL
                  ? (_selectedUserType == 'individual_patient'
                      ? 'اختر المريض:'
                      : 'اختر الطبيب:')
                  : (_selectedUserType == 'individual_patient'
                      ? 'Select Patient:'
                      : 'Select Doctor:'),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AdminConstants.textPrimary,
              ),
            ),
            const SizedBox(height: AdminConstants.spacingSmall),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: AdminConstants.borderRadiusSmall,
              ),
              child: _isLoadingUsers
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  : _availableUsers.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            isRTL
                                ? 'لا توجد مستخدمين متاحين'
                                : 'No users available',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        )
                      : DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedUserId,
                            isExpanded: true,
                            hint: Text(
                              isRTL
                                  ? (_selectedUserType == 'individual_patient'
                                      ? 'اختر مريض...'
                                      : 'اختر طبيب...')
                                  : (_selectedUserType == 'individual_patient'
                                      ? 'Select a patient...'
                                      : 'Select a doctor...'),
                            ),
                            items: _availableUsers.map((user) {
                              return DropdownMenuItem<String>(
                                value: user['id'],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      user['name'],
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      user['email'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    if (user['type'] == 'doctor' &&
                                        user['specialization'] != null)
                                      Text(
                                        user['specialization'],
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue.shade600,
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUserId = value;
                                _errorMessage = null;
                                _successMessage = null;
                              });
                            },
                          ),
                        ),
            ),
            const SizedBox(height: AdminConstants.spacingMedium),
          ],

          // عنوان الإشعار
          Text(
            isRTL ? 'عنوان الإشعار:' : 'Notification Title:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AdminConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText:
                  isRTL ? 'أدخل عنوان الإشعار' : 'Enter notification title',
              border: OutlineInputBorder(
                borderRadius: AdminConstants.borderRadiusSmall,
              ),
              prefixIcon: const Icon(Icons.title),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: AdminConstants.spacingMedium),

          // محتوى الإشعار
          Text(
            isRTL ? 'محتوى الإشعار:' : 'Notification Message:',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AdminConstants.textPrimary,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          TextFormField(
            controller: _messageController,
            decoration: InputDecoration(
              hintText:
                  isRTL ? 'أدخل محتوى الإشعار' : 'Enter notification message',
              border: OutlineInputBorder(
                borderRadius: AdminConstants.borderRadiusSmall,
              ),
              prefixIcon: const Icon(Icons.message),
            ),
            maxLines: 4,
            maxLength: 500,
          ),
          const SizedBox(height: AdminConstants.spacingMedium),

          // زر الإرسال
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendNotification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AdminConstants.borderRadiusSmall,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      isRTL ? 'إرسال الإشعار' : 'Send Notification',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationHistoryCard(bool isRTL) {
    // بيانات تجريبية للإشعارات المرسلة مؤخراً
    final recentNotifications = [
      {
        'title': 'تحديث النظام',
        'message': 'تم تحديث النظام بميزات جديدة',
        'sent_to': 'جميع المستخدمين',
        'sent_at': '2024-01-21 14:30',
      },
      {
        'title': 'صيانة مجدولة',
        'message': 'سيتم إجراء صيانة للنظام غداً من الساعة 2-4 صباحاً',
        'sent_to': 'جميع المستخدمين',
        'sent_at': '2024-01-20 10:15',
      },
      {
        'title': 'تذكير للأطباء',
        'message': 'يرجى الرد على الحالات المعلقة في أسرع وقت ممكن',
        'sent_to': 'الأطباء فقط',
        'sent_at': '2024-01-19 16:45',
      },
    ];

    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, color: AppTheme.primaryGreen, size: 24),
              const SizedBox(width: AdminConstants.spacingSmall),
              Text(
                isRTL ? 'سجل الإشعارات' : 'Notification History',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AdminConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingMedium),

          // قائمة الإشعارات المرسلة مؤخراً
          if (recentNotifications.isEmpty)
            const AdminEmptyWidget(
              message: 'لا توجد إشعارات مرسلة',
              icon: Icons.notifications_off,
            )
          else
            Column(
              children: recentNotifications.map((notification) {
                return Card(
                  margin: const EdgeInsets.only(
                      bottom: AdminConstants.spacingSmall),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      child: Icon(
                        Icons.notifications,
                        color: AppTheme.primaryBlue,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      notification['title']!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification['message']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AdminConstants.spacingSmall),
                        Row(
                          children: [
                            Icon(
                              Icons.group,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification['sent_to']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: AdminConstants.spacingSmall),
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              notification['sent_at']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    isThreeLine: true,
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Future<void> _sendNotification() async {
    // التحقق من صحة البيانات
    if (_titleController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال عنوان الإشعار';
        _successMessage = null;
      });
      return;
    }

    if (_messageController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'يرجى إدخال محتوى الإشعار';
        _successMessage = null;
      });
      return;
    }

    // التحقق من اختيار المستخدم في حالة الإرسال الفردي
    if (['individual_patient', 'individual_doctor']
            .contains(_selectedUserType) &&
        _selectedUserId == null) {
      setState(() {
        _errorMessage = 'يرجى اختيار المستخدم المحدد';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      String successMessage = '';

      if (['individual_patient', 'individual_doctor']
          .contains(_selectedUserType)) {
        // إرسال فردي
        print('📤 إرسال إشعار فردي...');
        print('العنوان: ${_titleController.text}');
        print('المحتوى: ${_messageController.text}');
        print('إلى المستخدم: $_selectedUserId');
        print('نوع المستخدم: $_selectedUserType');

        final userType =
            _selectedUserType == 'individual_patient' ? 'patient' : 'doctor';

        await AdminApiService.sendIndividualNotification(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          recipientType: userType,
          recipientId: int.parse(_selectedUserId!),
        );

        final selectedUser =
            _availableUsers.firstWhere((user) => user['id'] == _selectedUserId);
        successMessage = 'تم إرسال الإشعار بنجاح إلى ${selectedUser['name']}';
      } else {
        // إرسال جماعي
        print('📤 إرسال إشعار جماعي...');
        print('العنوان: ${_titleController.text}');
        print('المحتوى: ${_messageController.text}');
        print('إلى: $_selectedUserType');

        await AdminApiService.sendBroadcastNotification(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          userType: _selectedUserType == 'all' ? null : _selectedUserType,
        );

        successMessage = 'تم إرسال الإشعار بنجاح لجميع المستخدمين المحددين';
      }

      print('✅ تم إرسال الإشعار بنجاح');

      setState(() {
        _successMessage = successMessage;
        _titleController.clear();
        _messageController.clear();
        _selectedUserType = 'all';
        _selectedUserId = null;
        _availableUsers = [];
      });

      // إخفاء رسالة النجاح بعد 5 ثوان
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _successMessage = null;
          });
        }
      });
    } catch (e) {
      print('❌ خطأ في إرسال الإشعار: $e');
      setState(() {
        _errorMessage = 'حدث خطأ أثناء إرسال الإشعار: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
