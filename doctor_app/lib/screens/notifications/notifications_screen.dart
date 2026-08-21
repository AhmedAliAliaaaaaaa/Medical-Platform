import 'dart:async';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../services/base_api_service.dart';
import '../../utils/app_theme.dart';
import '../cases/case_details_screen.dart';
import '../patient/rating/rate_doctor_screen.dart';
import 'package:doctor_app/services/doctor_api_service.dart';
import 'package:doctor_app/screens/doctor/cases/respond_to_case_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? userType;
    try {
      // احصل على نوع المستخدم لتحديد مصدر الإشعارات
      userType = await ApiService.getUserType();
      print('🔔 تحميل الإشعارات ($userType)...');
      Map<String, dynamic> response;
      if (userType == 'doctor') {
        // جلب إشعارات الطبيب من الخادم
        try {
          final doctorResponse =
              await BaseApiService.get('/doctor/notifications/');
          final doctorData = BaseApiService.handleResponse(doctorResponse);
          response = {
            'notifications': doctorData['notifications'] ?? [],
            'unread_count': doctorData['unread_count'] ?? 0,
          };
          print('✅ تم جلب ${response['notifications'].length} إشعار للطبيب');
        } catch (e) {
          print('❌ فشل في جلب إشعارات الطبيب: $e');
          // استخدام البيانات التجريبية في حالة الفشل
          throw e;
        }
      } else {
        response = await ApiService.getPatientNotifications(isRead: false);
        // تأكد من تصفية غير المقروء فقط إن لم يقم الخادم بذلك
        final all = response['notifications'] ?? [];
        response['notifications'] =
            all.where((n) => n['is_read'] == false).toList();
        response['unread_count'] = response['notifications'].length;
      }

      setState(() {
        _notifications = response['notifications'] ?? [];
        _unreadCount = response['unread_count'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في تحميل الإشعارات: $e');
      // استخدام بيانات تجريبية في حالة الفشل
      setState(() {
        if (userType == 'doctor') {
          // بيانات تجريبية للطبيب
          _notifications = [
            {
              'id': 1,
              'title': 'حالة جديدة',
              'message': 'تمت إضافة حالة جديدة تحتاج إلى مراجعتك',
              'type': 'new_case',
              'case_id': 125,
              'is_read': false,
              'created_at': DateTime.now()
                  .subtract(const Duration(hours: 1))
                  .toIso8601String(),
            },
            {
              'id': 2,
              'title': 'تقييم جديد',
              'message': 'قيم المريض أحمد ردك الطبي بـ 5 نجوم',
              'type': 'new_rating',
              'case_id': 123,
              'is_read': false,
              'created_at': DateTime.now()
                  .subtract(const Duration(hours: 3))
                  .toIso8601String(),
            },
            {
              'id': 3,
              'title': 'متابعة حالة',
              'message': 'يرجى متابعة حالة المريض سارة التي تحتاج إلى اهتمام',
              'type': 'follow_up',
              'case_id': 124,
              'is_read': true,
              'created_at': DateTime.now()
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
            },
          ];
        } else {
          // بيانات تجريبية للمريض
          _notifications = [
            {
              'id': 1,
              'title': 'وصلك الرد الطبي',
              'message': 'تم الرد على حالتك من قبل د. أحمد محمد',
              'type': 'medical_response',
              'case_id': 123,
              'is_read': false,
              'created_at': DateTime.now()
                  .subtract(const Duration(hours: 2))
                  .toIso8601String(),
            },
            {
              'id': 2,
              'title': 'تم قبول حالتك',
              'message':
                  'تم قبول حالتك من قبل د. فاطمة علي وسيتم الرد خلال 48 ساعة',
              'type': 'case_accepted',
              'case_id': 122,
              'is_read': true,
              'created_at': DateTime.now()
                  .subtract(const Duration(days: 1))
                  .toIso8601String(),
            },
            {
              'id': 3,
              'title': 'تذكير بالتقييم',
              'message': 'لا تنس تقييم الطبيب بعد استلام الرد الطبي',
              'type': 'rating_reminder',
              'case_id': 121,
              'is_read': false,
              'created_at': DateTime.now()
                  .subtract(const Duration(days: 2))
                  .toIso8601String(),
            },
          ];
        }
        _unreadCount = _notifications.where((n) => !n['is_read']).length;
        _isLoading = false;
        _errorMessage = null;
      });
    }
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    try {
      final userType = await ApiService.getUserType();
      if (userType == 'doctor') {
        // استخدام endpoint الطبيب
        await BaseApiService.post(
            '/doctor/notifications/$notificationId/mark-read/', {});
      } else {
        await ApiService.markNotificationRead(notificationId);
      }
      setState(() {
        _notifications[index]['is_read'] = true;
        if (_unreadCount > 0) _unreadCount--;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث الإشعار: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await ApiService.markAllNotificationsRead();
      setState(() {
        for (var notification in _notifications) {
          notification['is_read'] = true;
        }
        _unreadCount = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديد جميع الإشعارات كمقروءة'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تحديث الإشعارات: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleNotificationTap(
    Map<String, dynamic> notification,
    int index,
  ) async {
    // تحديد الإشعار كمقروء
    if (!notification['is_read']) {
      await _markAsRead(notification['id'], index);
    }

    // التعامل مع أنواع الإشعارات المختلفة
    final notificationType = notification['type'];
    final caseId = notification['case_id'];

    switch (notificationType) {
      case 'medical_response':
        // فتح تفاصيل الحالة لعرض الرد الطبي (للمريض) أو شاشة الرد (للطبيب)
        if (caseId != null) {
          final userType = await ApiService.getUserType();
          if (userType == 'doctor') {
            // جلب تفاصيل الحالة وتمريرها إلى شاشة الرد
            final details = await DoctorApiService.getCaseDetails(caseId);
            final caseMap = Map<String, dynamic>.from(
              details['case'] is Map ? details['case'] as Map : details,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RespondToCaseScreen(caseData: caseMap),
              ),
            ).then((_) => _loadNotifications());
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaseDetailsScreen(caseId: caseId),
              ),
            ).then((_) => _loadNotifications());
          }
        }
        break;

      case 'case_accepted':
        // فتح تفاصيل الحالة
        if (caseId != null) {
          final userType = await ApiService.getUserType();
          if (userType == 'doctor') {
            final details = await DoctorApiService.getCaseDetails(caseId);
            final caseMap = Map<String, dynamic>.from(
              details['case'] is Map ? details['case'] as Map : details,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RespondToCaseScreen(caseData: caseMap),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaseDetailsScreen(caseId: caseId),
              ),
            );
          }
        }
        break;

      // إشعارات خاصة بالطبيب لفتح شاشة الرد مباشرة
      case 'new_case':
      case 'follow_up':
      case 'case_assigned':
        if (caseId != null) {
          final userType = await ApiService.getUserType();
          if (userType == 'doctor') {
            final details = await DoctorApiService.getCaseDetails(caseId);
            final caseMap = Map<String, dynamic>.from(
              details['case'] is Map ? details['case'] as Map : details,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RespondToCaseScreen(caseData: caseMap),
              ),
            ).then((_) => _loadNotifications());
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CaseDetailsScreen(caseId: caseId),
              ),
            );
          }
        }
        break;

      case 'rating_reminder':
        // فتح صفحة التقييم
        if (caseId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RateDoctorScreen(caseId: caseId),
            ),
          ).then((_) {
            _loadNotifications();
          });
        }
        break;

      default:
        // إشعار عام - عرض رسالة
        _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(Map<String, dynamic> notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification['title'] ?? 'إشعار'),
        content: Text(notification['message'] ?? ''),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            const Text('الإشعارات'),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          if (_unreadCount > 0)
            IconButton(
              onPressed: _markAllAsRead,
              icon: const Icon(Icons.done_all),
              tooltip: 'تحديد الكل كمقروء',
            ),
          IconButton(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'خطأ في تحميل الإشعارات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadNotifications,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد إشعارات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'ستظهر الإشعارات هنا عند وصولها',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          return _buildNotificationCard(_notifications[index], index);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    final isUnread = notification['is_read'] == false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isUnread
            ? Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.3),
                width: 2,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _handleNotificationTap(notification, index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnread
                      ? AppTheme.primaryBlue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getNotificationIcon(notification['notification_type']),
                  color: isUnread ? AppTheme.primaryBlue : Colors.grey,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.w600,
                              color: isUnread
                                  ? Colors.black
                                  : Colors.grey.shade700,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification['message'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(notification['created_at']),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        const Spacer(),
                        if (isUnread)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'جديد',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'new_case':
        return Icons.medical_services;
      case 'case_response':
        return Icons.chat_bubble;
      case 'appointment':
        return Icons.event;
      case 'reminder':
        return Icons.alarm;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return 'منذ ${difference.inDays} يوم';
      } else if (difference.inHours > 0) {
        return 'منذ ${difference.inHours} ساعة';
      } else if (difference.inMinutes > 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else {
        return 'الآن';
      }
    } catch (e) {
      return dateString;
    }
  }
}
