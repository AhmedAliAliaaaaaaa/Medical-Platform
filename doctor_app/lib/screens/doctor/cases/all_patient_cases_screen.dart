import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import 'respond_to_case_screen.dart';

class AllPatientCasesScreen extends StatefulWidget {
  const AllPatientCasesScreen({super.key});

  @override
  State<AllPatientCasesScreen> createState() => _AllPatientCasesScreenState();
}

class _AllPatientCasesScreenState extends State<AllPatientCasesScreen> {
  bool _loading = true;
  String? _error;
  List<dynamic> _cases = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // نجلب بيانات لوحة تحكم الطبيب للحصول على جميع الحالات
      final dashboardData = await ApiService.getDoctorDashboard();
      final List<dynamic> allCases = [];

      if (dashboardData is Map<String, dynamic>) {
        // إضافة الحالات الجديدة
        if (dashboardData.containsKey('new_cases_list') && dashboardData['new_cases_list'] is List) {
          allCases.addAll(dashboardData['new_cases_list']);
        }

        // إضافة الحالات قيد المراجعة
        if (dashboardData.containsKey('pending_cases_list') && dashboardData['pending_cases_list'] is List) {
          allCases.addAll(dashboardData['pending_cases_list']);
        }

        // إضافة الحالات التي تم الرد عليها
        if (dashboardData.containsKey('answered_cases_list') && dashboardData['answered_cases_list'] is List) {
          allCases.addAll(dashboardData['answered_cases_list']);
        }

        // إذا لم توجد القوائم السابقة، نبحث عن قائمة cases عامة
        if (allCases.isEmpty && dashboardData.containsKey('cases') && dashboardData['cases'] is List) {
          allCases.addAll(dashboardData['cases']);
        }
      }

      setState(() {
        _cases = allCases;
      });
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('جميع الحالات')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text(_error!))
                : _cases.isEmpty
                    ? const Center(child: Text('لا توجد حالات مكتملة'))
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        itemCount: _cases.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final item =
                              Map<String, dynamic>.from(_cases[i] as Map);
                          final title = (item['title'] ?? 'حالة').toString();
                          final status = (item['status'] ?? '').toString();
                          final createdAt =
                              (item['created_at'] ?? '').toString();
                          final patientName = (item['patient']?['user']
                                      ?['get_full_name'] ??
                                  item['patient']?['user']?['username'] ??
                                  'مريض')
                              .toString();
                          // تحديد لون الحالة وأيقونتها
                          Color statusColor;
                          IconData statusIcon;

                          switch (status.toLowerCase()) {
                            case 'new':
                            case 'جديد':
                              statusColor = Colors.blue;
                              statusIcon = Icons.new_releases;
                              break;
                            case 'pending':
                            case 'قيد المراجعة':
                              statusColor = Colors.orange;
                              statusIcon = Icons.hourglass_top;
                              break;
                            case 'answered':
                            case 'تم الرد':
                              statusColor = Colors.green;
                              statusIcon = Icons.check_circle;
                              break;
                            case 'completed':
                            case 'مكتمل':
                              statusColor = Colors.purple;
                              statusIcon = Icons.task_alt;
                              break;
                            default:
                              statusColor = Colors.grey;
                              statusIcon = Icons.folder_open;
                          }

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              tileColor: Colors.white,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(statusIcon, color: statusColor),
                              ),
                              title: Text(
                                title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    patientName,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          status,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          createdAt,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // فتح تفاصيل الحالة عند النقر
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RespondToCaseScreen(caseData: item),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
