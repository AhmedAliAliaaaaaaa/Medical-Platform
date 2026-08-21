import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../doctor/cases/respond_to_case_screen.dart';
import 'response_details_screen.dart';

class MyResponsesScreen extends StatefulWidget {
  const MyResponsesScreen({super.key});

  @override
  State<MyResponsesScreen> createState() => _MyResponsesScreenState();
}

class _MyResponsesScreenState extends State<MyResponsesScreen> {
  bool _isLoading = true;
  String? _error;
  List<dynamic> _responses = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      // جلب بيانات لوحة تحكم الطبيب
      final dashboardData = await ApiService.getDoctorDashboard();
      final List<dynamic> responses = [];

      if (dashboardData is Map<String, dynamic>) {
        // البحث عن ردود الطبيب في قائمة answered_cases_list أو my_responses
        if (dashboardData.containsKey('my_responses') && dashboardData['my_responses'] is List) {
          // استخدام ردود الطبيب مباشرة إذا كانت موجودة
          responses.addAll(dashboardData['my_responses']);
        } 
        else if (dashboardData.containsKey('answered_cases_list') && dashboardData['answered_cases_list'] is List) {
          // استخدام الحالات التي تم الرد عليها
          final answeredCases = dashboardData['answered_cases_list'] as List;

          for (final caseItem in answeredCases) {
            if (caseItem is Map<String, dynamic>) {
              // التحقق من أن الحالة تحتوي على رد
              if (caseItem.containsKey('response') && caseItem['response'] is Map<String, dynamic>) {
                final response = caseItem['response'] as Map<String, dynamic>;
                // إضافة معلومات الحالة إلى الرد
                response['case_title'] = caseItem['title'] ?? 'حالة';
                response['patient_name'] = caseItem['patient_name'] ?? 'مريض';
                responses.add(response);
              }
            }
          }
        }
      }

      setState(() {
        _responses = responses;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ردودي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _responses.isEmpty
                    ? const Center(child: Text('لا توجد ردود حتى الآن'))
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemCount: _responses.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final response =
                              Map<String, dynamic>.from(_responses[i] as Map);
                          final content = (response['content'] ?? '').toString();
                          final recommendations = (response['recommendations'] ?? '').toString();
                          final createdAt =
                              (response['created_at'] ?? '').toString();
                          final caseTitle =
                              (response['case_title'] ?? 'حالة').toString();
                          final patientName =
                              (response['patient_name'] ?? 'مريض').toString();
                          final status =
                              (response['status'] ?? 'unknown').toString();

                          // تحديد لون الحالة
                          Color statusColor;
                          String statusText;

                          switch (status) {
                            case 'approved':
                              statusColor = Colors.green;
                              statusText = 'معتمد';
                              break;
                            case 'pending':
                              statusColor = Colors.orange;
                              statusText = 'قيد المراجعة';
                              break;
                            case 'completed':
                              statusColor = Colors.blue;
                              statusText = 'مكتمل';
                              break;
                            case 'rejected':
                              statusColor = Colors.red;
                              statusText = 'مرفوض';
                              break;
                            default:
                              statusColor = Colors.grey;
                              statusText = status;
                          }

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                                              caseTitle,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.person_outline, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  patientName,
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
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: statusColor),
                                        ),
                                        child: Text(
                                          statusText,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: statusColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 12),

                                  // محتوى الرد
                                  if (content.isNotEmpty) ...[
                                    const Text(
                                      'محتوى الرد:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      content,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  // التوصيات
                                  if (recommendations.isNotEmpty) ...[
                                    const Text(
                                      'التوصيات:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      recommendations,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    const SizedBox(height: 8),
                                  ],

                                  // تاريخ الإنشاء
                                  Row(
                                    children: [
                                      Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                                      const SizedBox(width: 4),
                                      Text(
                                        createdAt,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
