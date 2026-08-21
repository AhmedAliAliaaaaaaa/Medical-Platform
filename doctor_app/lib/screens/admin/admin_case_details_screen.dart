import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../services/admin_api_service.dart';
import '../../utils/app_theme.dart';

class AdminCaseDetailsScreen extends StatefulWidget {
  final int caseId;

  const AdminCaseDetailsScreen({super.key, required this.caseId});

  @override
  State<AdminCaseDetailsScreen> createState() => _AdminCaseDetailsScreenState();
}

class _AdminCaseDetailsScreenState extends State<AdminCaseDetailsScreen> {
  Map<String, dynamic>? _caseDetails;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCaseDetails();
  }

  Future<void> _loadCaseDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (kDebugMode) {
        print('جاري تحميل تفاصيل الحالة رقم ${widget.caseId}');
      }

      final details = await AdminApiService.getCaseDetails(widget.caseId);

      if (details == null) {
        throw Exception('البيانات المستلمة فارغة');
      }

      // التحقق من وجود البيانات في المفتاحين المحتملين
      final caseData = details['case'] ?? details;

      if (caseData is! Map<String, dynamic>) {
        throw Exception('تنسيق بيانات الحالة غير صحيح');
      }

      if (caseData.isEmpty) {
        throw Exception('تفاصيل الحالة فارغة');
      }

      // التحقق من وجود المعرف الأساسي
      if (!caseData.containsKey('id')) {
        throw Exception('بيانات الحالة غير مكتملة');
      }

      if (kDebugMode) {
        print('تم تحميل تفاصيل الحالة بنجاح');
      }

      setState(() {
        _caseDetails = caseData;
        _isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('خطأ في تحميل تفاصيل الحالة: ${e.toString()}');
      }

      String errorMessage = 'حدث خطأ أثناء تحميل البيانات';

      // معالجة مختلف أنواع الأخطاء
      final errorString = e.toString();

      if (errorString.contains('غير موجودة') || errorString.contains('404')) {
        errorMessage = 'الحالة المطلوبة غير موجودة.';
      } else if (errorString.contains('غير مصرح') || errorString.contains('401')) {
        errorMessage = 'غير مصرح بالوصول إلى بيانات الحالة. يرجى تسجيل الدخول مرة أخرى.';
      } else if (errorString.contains('الاتصال') || errorString.contains('SocketException')) {
        errorMessage = 'خطأ في الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.';
      } else if (errorString.contains('TimeoutException') || errorString.contains('انتهت مهلة')) {
        errorMessage = 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى لاحقاً.';
      } else if (errorString.contains('الخادم') || errorString.contains('500') || errorString.contains('502') || errorString.contains('503')) {
        errorMessage = 'خطأ في الخادم. يرجى المحاولة مرة أخرى لاحقاً.';
      } else if (errorString.contains('فارغة') || errorString.contains('Empty')) {
        errorMessage = 'بيانات الحالة فارغة.';
      } else if (errorString.contains('تنسيق') || errorString.contains('format')) {
        errorMessage = 'تنسيق بيانات الحالة غير صحيح.';
      } else if (errorString.contains('Exception:')) {
        errorMessage = errorString.replaceAll('Exception: ', '');
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('تفاصيل الحالة'),
          backgroundColor: AppTheme.primaryBlue,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Colors.red.shade700,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'خطأ في تحميل البيانات',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade800,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _loadCaseDetails,
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : _caseDetails == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange.shade800,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'لا توجد بيانات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _loadCaseDetails,
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadCaseDetails,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCaseInfoCard(),
                              const SizedBox(height: 16),
                              _buildPatientInfoCard(),
                              const SizedBox(height: 16),
                              if (_hasResponses()) _buildResponsesCard(),
                              if (!_hasResponses())
                                Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(
                                      children: [
                                        Icon(Icons.info, color: Colors.orange.shade800),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'لا توجد ردود من الأطباء على هذه الحالة بعد',
                                            style: TextStyle(color: Colors.orange.shade800),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  Widget _buildCaseInfoCard() {
    final status = _caseDetails!['status'] ?? 'unknown';
    final priority = _caseDetails!['priority'] ?? 'medium';
    final title = _caseDetails!['title'] ?? 'بدون عنوان';
    final description = _caseDetails!['description'] ?? 'لا يوجد وصف';
    final createdAt = _caseDetails!['created_at'] ?? '';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getStatusIcon(status),
                  color: _getStatusColor(status),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: TextStyle(
                      color: _getStatusColor(status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPriorityColor(priority).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPriorityText(priority),
                    style: TextStyle(
                      color: _getPriorityColor(priority),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 4),
                Text(
                  'تاريخ الإنشاء: ${_formatDate(createdAt)}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientInfoCard() {
    final patient = _caseDetails!['patient'] ?? {};
    final patientName = patient['name'] ?? 
        '${patient['first_name'] ?? ''} ${patient['last_name'] ?? ''}';
    final patientEmail = patient['email'] ?? '';
    final patientPhone = patient['phone'] ?? '';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.person, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text(
                  'معلومات المريض',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'الاسم: ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(child: Text(patientName)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    patientEmail,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    patientPhone,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsesCard() {
    final responses = _caseDetails!['responses'] as List;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.medical_services, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text(
                  'ردود الأطباء',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: responses.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final response = responses[index];
                return _buildResponseCard(response);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard(Map<String, dynamic> response) {
    // التحقق من وجود البيانات الأساسية
    if (response == null || 
        response['doctor'] == null || 
        response['doctor']['user'] == null) {
      return Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange.shade800),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'بيانات الرد غير مكتملة',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryGreen,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'د. ${response['doctor']['user']['first_name'] ?? ''} ${response['doctor']['user']['last_name'] ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(response['created_at'] ?? ''),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (response['diagnosis'] != null &&
                response['diagnosis'].toString().isNotEmpty) ...[
              const Text(
                'التشخيص:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(response['diagnosis'].toString()),
              const SizedBox(height: 12),
            ],

            const Text('الرد:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(response['content']?.toString() ?? 'لا يوجد محتوى'),
            const SizedBox(height: 12),

            const Text(
              'التوصيات:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(response['recommendations']?.toString() ?? 'لا توجد توصيات'),

            if (response['treatment_plan'] != null &&
                response['treatment_plan'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'خطة العلاج:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(response['treatment_plan'].toString()),
            ],

            if (response['notes'] != null && response['notes'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'ملاحظات:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(response['notes'].toString()),
            ],
          ],
        ),
      ),
    );
  }

  bool _hasResponses() {
    return _caseDetails!['responses'] != null &&
        (_caseDetails!['responses'] as List).isNotEmpty;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.hourglass_empty;
      case 'completed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد المراجعة';
      case 'completed':
        return 'تم الرد';
      case 'cancelled':
        return 'ملغية';
      default:
        return status;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'urgent':
        return Colors.red.shade800;
      default:
        return Colors.grey;
    }
  }

  String _getPriorityText(String priority) {
    switch (priority) {
      case 'low':
        return 'منخفضة';
      case 'medium':
        return 'متوسطة';
      case 'high':
        return 'عالية';
      case 'urgent':
        return 'عاجلة';
      default:
        return priority;
    }
  }

  String _formatDate(String dateString) {
    if (dateString.isEmpty) return 'تاريخ غير محدد';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
