import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class MyResponsesScreen extends StatefulWidget {
  const MyResponsesScreen({super.key});

  @override
  State<MyResponsesScreen> createState() => _MyResponsesScreenState();
}

class _MyResponsesScreenState extends State<MyResponsesScreen> {
  late Future<List<Map<String, dynamic>>> _responsesFuture;

  @override
  void initState() {
    super.initState();
    _responsesFuture = _loadResponses();
  }

  Future<List<Map<String, dynamic>>> _loadResponses() async {
    try {
      // الحصول على جميع حالات الطبيب
      final cases = await ApiService.getDoctorCases();

      final List<Map<String, dynamic>> responses = [];

      // لكل حالة، الحصول على التفاصيل واستخراج الردود
      for (final caseItem in cases) {
        if (caseItem is! Map<String, dynamic>) continue;

        final caseId = caseItem['id'] ?? caseItem['case_id'] ?? caseItem['pk'];
        if (caseId == null) continue;

        try {
          // الحصول على تفاصيل الحالة
          final details = await ApiService.getCaseDetails(caseId);
          final caseJson = (details['case'] ?? details) as Map<String, dynamic>;

          // استخراج الردود من تفاصيل الحالة
          final caseResponses = (caseJson['responses'] as List?) ?? [];

          for (final response in caseResponses) {
            if (response is! Map<String, dynamic>) continue;

            responses.add({
              'case_id': caseId,
              'case_title': caseJson['title'] ?? 'حالة بدون عنوان',
              'patient_name': caseJson['patient']?['user']?['first_name'] ?? 'مريض',
              'created_at': response['created_at'],
              'content': response['content'] ?? '',
              'recommendations': response['recommendations'] ?? '',
              'diagnosis': response['diagnosis'] ?? '',
              'treatment_plan': response['treatment_plan'] ?? '',
              'notes': response['notes'] ?? '',
              'rating': response['rating'],
            });
          }
        } catch (e) {
          print('Error loading case details: $e');
          continue;
        }
      }

      // ترتيب الردود حسب التاريخ (الأحدث أولاً)
      responses.sort((a, b) {
        final ad = DateTime.tryParse(a['created_at']?.toString() ?? '');
        final bd = DateTime.tryParse(b['created_at']?.toString() ?? '');
        if (ad == null && bd == null) return 0;
        if (ad == null) return 1;
        if (bd == null) return -1;
        return bd.compareTo(ad);
      });

      return responses;
    } catch (e) {
      print('Error loading responses: $e');
      return [];
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _responsesFuture = _loadResponses();
    });
    await _responsesFuture;
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} ${_two(dt.hour)}:${_two(dt.minute)}';
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('ردودي'),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
        ),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _responsesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 64, color: Colors.redAccent),
                      const SizedBox(height: 12),
                      Text(
                        'تعذر تحميل الردود: ${snapshot.error}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              );
            }
            final data = snapshot.data ?? const [];
            if (data.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Text('لم تقم بإرسال أي ردود حتى الآن'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: data.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = data[index];
                  final patientName = item['patient_name']?.toString() ?? 'مريض';
                  final caseTitle = item['case_title']?.toString() ?? 'حالة';
                  final createdAt = _formatDate(item['created_at']?.toString());
                  final diagnosis = item['diagnosis']?.toString() ?? '';
                  final plan = item['treatment_plan']?.toString() ?? '';
                  final content = item['content']?.toString() ?? '';
                  final recommendations = item['recommendations']?.toString() ?? '';
                  final notes = item['notes']?.toString() ?? '';
                  final rating = item['rating'];
                  final caseId = item['case_id'];

                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: AppTheme.primaryBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '$patientName — $caseTitle',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (createdAt.isNotEmpty)
                                Text(
                                  createdAt,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (diagnosis.isNotEmpty) ...[
                            const Text('التشخيص:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF101828))),
                            const SizedBox(height: 4),
                            Text(diagnosis),
                            const SizedBox(height: 12),
                          ],
                          if (content.isNotEmpty) ...[
                            const Text('الرد:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF101828))),
                            const SizedBox(height: 4),
                            Text(content),
                            const SizedBox(height: 12),
                          ],
                          if (recommendations.isNotEmpty) ...[
                            const Text('التوصيات:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF101828))),
                            const SizedBox(height: 4),
                            Text(recommendations),
                            const SizedBox(height: 12),
                          ],
                          if (plan.isNotEmpty) ...[
                            const Text('الخطة العلاجية:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF101828))),
                            const SizedBox(height: 4),
                            Text(plan),
                            const SizedBox(height: 12),
                          ],
                          if (notes.isNotEmpty) ...[
                            const Text('ملاحظات:',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF101828))),
                            const SizedBox(height: 4),
                            Text(notes),
                            const SizedBox(height: 12),
                          ],
                          if (rating != null) ...[
                            Row(
                              children: [
                                const Text('تقييم المريض:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF101828))),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < rating ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          // إضافة زر للانتقال إلى تفاصيل الحالة
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/case_details',
                                  arguments: caseId,
                                );
                              },
                              child: const Text('عرض تفاصيل الحالة'),
                            ),
                          ),
                        ],
                      ),
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
