import 'package:flutter/material.dart';
import '../../../services/doctor_api_service.dart';

class ResponseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> caseData;
  const ResponseDetailsScreen({super.key, required this.caseData});

  @override
  State<ResponseDetailsScreen> createState() => _ResponseDetailsScreenState();
}

class _ResponseDetailsScreenState extends State<ResponseDetailsScreen> {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _details; // تفاصيل الحالة الكاملة من API

  int? get _caseId {
    final m = widget.caseData;
    final dynamic id = m['case_id'] ?? m['id'];
    if (id == null) return null;
    return int.tryParse(id.toString());
  }

  @override
  void initState() {
    super.initState();
    _loadDetailsIfPossible();
  }

  Future<void> _loadDetailsIfPossible() async {
    final id = _caseId;
    if (id == null) return; // لا نحمل إن لم يتوفر ID
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final d = await DoctorApiService.getCaseDetails(id);
      setState(() => _details = d);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final caseData = Map<String, dynamic>.from(widget.caseData);
    final details = _details;

    // محاولة استخراج الحقول من caseData أو من details
    final caseMap = Map<String, dynamic>.from(
      (details != null && details['case'] is Map)
          ? Map<String, dynamic>.from(details['case'] as Map)
          : caseData,
    );

    final title = (caseMap['title'] ?? 'تفاصيل الحالة').toString();
    final patientName =
        (caseMap['patient_name'] ?? caseMap['patient']?['name'] ?? '-')
            .toString();
    final status = (caseMap['status'] ?? '').toString();
    final createdAt = (caseMap['created_at'] ??
            caseMap['responded_at'] ??
            caseMap['updated_at'] ??
            '')
        .toString();

    // حقول محتملة لرد الطبيب
    final responseContent = (caseMap['response_content'] ??
            caseMap['content'] ??
            caseMap['doctor_response'] ??
            '')
        .toString();
    final recommendations = (caseMap['recommendations'] ??
            caseMap['doctor_recommendations'] ??
            caseMap['advice'] ??
            '')
        .toString();
    final diagnosis = (caseMap['diagnosis'] ?? '').toString();
    final treatmentPlan = (caseMap['treatment_plan'] ?? '').toString();
    final notes = (caseMap['notes'] ?? '').toString();

    // المرفقات (إن وجدت)
    final List<Map<String, dynamic>> attachments = [];
    if (caseMap['attachments'] is List) {
      final attachmentsList = caseMap['attachments'] as List;
      for (final e in attachmentsList) {
        if (e is Map<String, dynamic>) {
          attachments.add(e);
        } else if (e is Map) {
          attachments.add(Map<String, dynamic>.from(e));
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الرد')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // العنوان والمعلومات الأساسية
                    Text(title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.person, size: 16),
                        const SizedBox(width: 6),
                        Text('المريض: $patientName'),
                        const Spacer(),
                        if (status.isNotEmpty) _chip(status),
                      ],
                    ),
                    if (createdAt.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, size: 16),
                          const SizedBox(width: 6),
                          Text(createdAt),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // محتوى الرد
                    _sectionTitle('محتوى الرد'),
                    _boxedText(responseContent.isEmpty ? '—' : responseContent),

                    const SizedBox(height: 12),

                    // التوصيات
                    _sectionTitle('التوصيات'),
                    _boxedText(recommendations.isEmpty ? '—' : recommendations),

                    if (diagnosis.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _sectionTitle('التشخيص'),
                      _boxedText(diagnosis),
                    ],

                    if (treatmentPlan.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _sectionTitle('خطة العلاج'),
                      _boxedText(treatmentPlan),
                    ],

                    if (notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _sectionTitle('ملاحظات'),
                      _boxedText(notes),
                    ],

                    if (attachments.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _sectionTitle('مرفقات'),
                      const SizedBox(height: 8),
                      ...attachments.map((a) {
                        final name =
                            (a['name'] ?? a['filename'] ?? 'ملف').toString();
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.attach_file),
                            title: Text(name),
                            subtitle: Text((a['type'] ?? '').toString()),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      );

  Widget _boxedText(String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: Text(text),
      );
}
