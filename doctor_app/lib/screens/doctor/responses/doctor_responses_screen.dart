import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../utils/app_theme.dart';

class DoctorResponsesScreen extends StatefulWidget {
  const DoctorResponsesScreen({super.key});

  @override
  State<DoctorResponsesScreen> createState() => _DoctorResponsesScreenState();
}

class _DoctorResponsesScreenState extends State<DoctorResponsesScreen> {
  List<dynamic> _responses = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // استخدام ApiService لجلب بيانات لوحة تحكم الطبيب
      final dashboardData = await ApiService.getDoctorDashboard();

      if (dashboardData != null && dashboardData is Map<String, dynamic>) {
        final List<dynamic> allResponses = [];

        // البحث عن ردود الطبيب في قائمة answered_cases_list أو my_responses
        if (dashboardData.containsKey('my_responses') &&
            dashboardData['my_responses'] is List) {
          // استخدام ردود الطبيب مباشرة إذا كانت موجودة
          allResponses.addAll(dashboardData['my_responses']);
        } else if (dashboardData.containsKey('answered_cases_list') &&
            dashboardData['answered_cases_list'] is List) {
          // استخدام الحالات التي تم الرد عليها
          final answeredCases = dashboardData['answered_cases_list'] as List;

          for (final caseItem in answeredCases) {
            if (caseItem is Map<String, dynamic>) {
              // التحقق من أن الحالة تحتوي على رد
              if (caseItem.containsKey('response') &&
                  caseItem['response'] is Map<String, dynamic>) {
                final response = caseItem['response'] as Map<String, dynamic>;
                // إضافة معلومات الحالة إلى الرد
                response['case_title'] = caseItem['title'] ?? 'حالة';
                response['patient_name'] = caseItem['patient_name'] ?? 'مريض';
                allResponses.add(response);
              }
            }
          }
        }

        setState(() {
          _responses = allResponses;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'فشل تحميل البيانات: تنسيق غير صالح';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في الاتصال: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ردودي'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadResponses,
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
            Text(
              'خطأ في تحميل البيانات',
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
              onPressed: _loadResponses,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_responses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد ردود بعد',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'سيتم عرض ردودك على الحالات هنا',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadResponses,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _responses.length,
        itemBuilder: (context, index) {
          final response = _responses[index];
          return _buildResponseCard(response);
        },
      ),
    );
  }

  Widget _buildResponseCard(Map<String, dynamic> response) {
    // تحديد لون الحالة
    Color statusColor;
    String statusText;
    IconData statusIcon;
    String statusDescription;

    switch (response['status']) {
      case 'approved':
        statusColor = Colors.green;
        statusText = 'معتمد';
        statusIcon = Icons.check_circle;
        statusDescription = 'تم اعتماد ردك من قبل الإدارة';
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusText = 'قيد المراجعة';
        statusIcon = Icons.hourglass_empty;
        statusDescription = 'ردك قيد المراجعة من قبل الإدارة';
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusText = 'مرفوض';
        statusIcon = Icons.cancel;
        statusDescription = 'تم رفض ردك من قبل الإدارة';
        break;
      default:
        statusColor = Colors.grey;
        statusText = response['status'] ?? 'غير معروف';
        statusIcon = Icons.help_outline;
        statusDescription = 'حالة غير معروفة';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان الحالة واسم المريض
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        response['case_title'] ?? 'حالة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            response['patient_name'] ?? 'مريض',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 4),
                          Text(
                            statusText,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      statusDescription,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // محتوى الرد
            const Text(
              'محتوى الرد:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              response['content'] ?? '',
              style: const TextStyle(fontSize: 14),
            ),

            const SizedBox(height: 12),

            // التوصيات
            if (response['recommendations'] != null &&
                response['recommendations'].isNotEmpty) ...[
              const Text(
                'التوصيات:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                response['recommendations'] ?? '',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
            ],

            // سبب الرفض (إذا كان الرد مرفوضاً)
            if (response['status'] == 'rejected' &&
                response['rejection_reason'] != null &&
                response['rejection_reason'].isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: Colors.red.shade600),
                        const SizedBox(width: 4),
                        Text(
                          'سبب الرفض:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      response['rejection_reason'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // تاريخ الإنشاء
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatDate(response['created_at'] ?? ''),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }
}
