import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../services/patient_api_service.dart';
import '../../../utils/app_theme.dart';

class ResponsesScreen extends StatefulWidget {
  const ResponsesScreen({super.key});

  @override
  State<ResponsesScreen> createState() => _ResponsesScreenState();
}

class _ResponsesScreenState extends State<ResponsesScreen> {
  late Future<List<Map<String, dynamic>>> _responsesFuture;

  @override
  void initState() {
    super.initState();
    _responsesFuture = _loadResponses();
  }

  Future<List<Map<String, dynamic>>> _loadResponses() async {
    final cases = await PatientApiService.getCaseHistory();

    final List<Map<String, dynamic>> items = [];

    for (final c in cases) {
      if (c is! Map<String, dynamic>) continue;
      final caseId = c['id'] ?? c['case_id'] ?? c['pk'];
      final caseTitle = c['title']?.toString() ?? 'حالة بدون عنوان';

      if (caseId == null) continue;

      try {
        final details = await PatientApiService.getCaseDetails(caseId);
        final caseJson = (details['case'] ?? details) as Map<String, dynamic>;
        final responses = (caseJson['responses'] as List?) ?? const [];
        debugPrint(
            '📦 Case $caseId "$caseTitle" -> responses: ${responses.length}');

        for (final r in responses) {
          if (r is! Map<String, dynamic>) {
            debugPrint('⚠️ Response item is not a map: $r');
            continue;
          }

          final doctor = r['doctor'] as Map<String, dynamic>?;
          final doctorName = doctor != null
              ? (doctor['full_name'] ??
                  doctor['name'] ??
                  doctor['username'] ??
                  'طبيب')
              : (r['doctor_name'] ?? caseJson['doctor_name'] ?? 'طبيب');

          final attachmentsRaw = (r['attachments'] as List?) ?? const [];
          final attachments =
              attachmentsRaw.whereType<Map>().map<Map<String, dynamic>>((a) {
            final m = a.cast<String, dynamic>();
            final url =
                m['file_url']?.toString() ?? m['file']?.toString() ?? '';
            final type = m['file_type']?.toString() ?? '';
            return {'file_url': url, 'file_type': type};
          }).toList();

          items.add({
            // مفاتيح مطلوبة في واجهة العرض
            'created_at': (r['created_at'] ?? r['createdAt'] ?? '').toString(),
            'updated_at': (r['updated_at'] ?? r['updatedAt'] ?? '').toString(),
            'content': (r['content'] ?? r['reply'] ?? '').toString(),
            'recommendations':
                (r['recommendations'] ?? r['advice'] ?? '').toString(),
            'status': (r['status'] ?? '').toString(),
            'diagnosis': (r['diagnosis'] ?? '').toString(),
            'diagnosis_translated':
                (r['diagnosis_translated'] ?? '').toString(),
            'treatment_plan':
                (r['treatment_plan'] ?? r['treatment'] ?? '').toString(),
            'treatment_plan_translated':
                (r['treatment_plan_translated'] ?? '').toString(),
            'notes': (r['notes'] ?? '').toString(),
            'notes_translated': (r['notes_translated'] ?? '').toString(),
            'response_language': (r['response_language'] ?? '').toString(),
            'response_file_url': (r['response_file'] ?? '').toString(),
            'response_video_url': (r['response_video'] ?? '').toString(),
            'attachments': attachments,
            // تعريفات مساعدة
            'doctor_id': doctor?['id'],
            'doctor_name': doctorName?.toString() ?? 'طبيب',
            'case_title': caseTitle,
            'case_id': caseId,
          });
        }
      } catch (e) {
        debugPrint('Error loading case $caseId: $e');
      }
    }

    // ترتيب حسب تاريخ الرد (الأحدث أولاً) عند توفره
    items.sort((a, b) {
      final ad = DateTime.tryParse(a['created_at']?.toString() ?? '');
      final bd = DateTime.tryParse(b['created_at']?.toString() ?? '');
      if (ad == null && bd == null) return 0;
      if (ad == null) return 1;
      if (bd == null) return -1;
      return bd.compareTo(ad);
    });

    return items;
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
    return intl.DateFormat('yyyy/MM/dd - HH:mm').format(dt);
  }

  String _two(int v) => v.toString().padLeft(2, '0');

  // عرض نص كامل داخل شيت قابل للتمرير لتجنب أي Overflow
  void _showFullText({required String title, required String text}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (_, controller) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        )
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: controller,
                        child: SelectableText(
                          text,
                          textAlign: TextAlign.start,
                          style: const TextStyle(fontSize: 15, height: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const Text('ردود الأطباء'),
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
              debugPrint('❌ ResponsesScreen error: ${snapshot.error}');
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
            debugPrint('✅ Responses loaded: ${data.length}');
            if (data.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: const [
                    SizedBox(height: 100),
                    Center(child: Text('لا توجد ردود حتى الآن')),
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
                  final doctorName = item['doctor_name']?.toString() ?? 'طبيب';
                  final caseTitle = item['case_title']?.toString() ?? 'حالة';
                  final createdAt = _formatDate(item['created_at']?.toString());
                  final diagnosis = item['diagnosis']?.toString() ?? '';
                  final plan = item['treatment_plan']?.toString() ?? '';
                  final content = item['content']?.toString() ?? '';
                  final recommendations =
                      item['recommendations']?.toString() ?? '';
                  final notes = item['notes']?.toString() ?? '';
                  final updatedAt = _formatDate(item['updated_at']?.toString());
                  final status = item['status']?.toString() ?? '';
                  final responseLanguage =
                      item['response_language']?.toString() ?? '';
                  final diagnosisTr =
                      item['diagnosis_translated']?.toString() ?? '';
                  final planTr =
                      item['treatment_plan_translated']?.toString() ?? '';
                  final notesTr = item['notes_translated']?.toString() ?? '';
                  final responseFileUrl =
                      item['response_file_url']?.toString() ?? '';
                  final responseVideoUrl =
                      item['response_video_url']?.toString() ?? '';
                  final rating =
                      item['rating']; // قد لا يتوفر، لذلك لم يُستخدم إلزامياً

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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'حالة: $caseTitle',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'طبيب: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF101828),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      doctorName,
                                      style: const TextStyle(fontSize: 14),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.person,
                                      color: AppTheme.primaryBlue),
                                ],
                              ),
                              if (createdAt.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    createdAt,
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              const Divider(height: 24, thickness: 0.6),
                            ],
                          ),

                          if (diagnosis.isNotEmpty) ...[
                            const Text(
                              'التشخيص:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            Text(diagnosis),
                            const SizedBox(height: 12),
                          ],

                          // محتوى الرد
                          if (content.isNotEmpty) ...[
                            const Text(
                              'الرد:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () => _showFullText(
                                  title: 'الرد الكامل', text: content),
                              child: Text(
                                content,
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => _showFullText(
                                    title: 'الرد الكامل', text: content),
                                icon: const Icon(Icons.open_in_full),
                                label: const Text('عرض الكل'),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // الحقول المترجمة (إن وجدت)
                          if (diagnosisTr.isNotEmpty) ...[
                            const Text(
                              'التشخيص (مترجم):',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            Text(diagnosisTr),
                            const SizedBox(height: 12),
                          ],
                          if (planTr.isNotEmpty) ...[
                            const Text(
                              'الخطة العلاجية (مترجم):',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            Text(planTr),
                            const SizedBox(height: 12),
                          ],
                          if (notesTr.isNotEmpty) ...[
                            const Text(
                              'ملاحظات (مترجم):',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            Text(notesTr),
                            const SizedBox(height: 12),
                          ],

                          if (recommendations.isNotEmpty) ...[
                            const Text(
                              'التوصيات:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            Text(recommendations),
                            const SizedBox(height: 12),
                          ],

                          if (plan.isNotEmpty) ...[
                            const Text(
                              'الخطة العلاجية:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            Text(plan),
                            const SizedBox(height: 12),
                          ],

                          if (notes.isNotEmpty) ...[
                            const Text(
                              'ملاحظات:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            Text(notes),
                            const SizedBox(height: 12),
                          ],

                          // ملف/فيديو الرد (إن وجد)
                          if (responseFileUrl.isNotEmpty) ...[
                            const Text(
                              'ملف الرد:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            _AttachmentTile(attachment: {
                              'file_type': 'other',
                              'file_url': responseFileUrl,
                            }),
                            const SizedBox(height: 12),
                          ],
                          if (responseVideoUrl.isNotEmpty) ...[
                            const Text(
                              'فيديو الرد:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 4),
                            _AttachmentTile(attachment: {
                              'file_type': 'video',
                              'file_url': responseVideoUrl,
                            }),
                            const SizedBox(height: 12),
                          ],

                          // معلومات الحالة العامة للرد - عمود لتجنب Overflow
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (status.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'حالة الرد: ',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    Container(
                                      margin: const EdgeInsetsDirectional.only(
                                          start: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade600,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        status,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              if (responseLanguage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'لغة الرد: ',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                      Text(responseLanguage.toUpperCase()),
                                    ],
                                  ),
                                ),
                              if (updatedAt.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    'آخر تحديث: $updatedAt',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (rating != null) ...[
                            Row(
                              children: [
                                const Text(
                                  'تقييمك:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF101828)),
                                ),
                                const SizedBox(width: 8),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index <
                                              (rating is int
                                                  ? rating
                                                  : int.tryParse(
                                                          rating.toString()) ??
                                                      0)
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.amber,
                                      size: 16,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ],

                          // عرض المرفقات والفيديوهات
                          if (item['attachments'] != null &&
                              (item['attachments'] as List).isNotEmpty) ...[
                            const Text(
                              'المرفقات:',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF101828)),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final attachment
                                    in (item['attachments'] as List))
                                  _AttachmentTile(
                                      attachment: Map<String, dynamic>.from(
                                          attachment)),
                              ],
                            ),
                          ],
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

class _AttachmentTile extends StatelessWidget {
  final Map<String, dynamic> attachment;
  const _AttachmentTile({required this.attachment});

  @override
  Widget build(BuildContext context) {
    final fileType = attachment['file_type']?.toString() ?? '';
    final fileUrl = attachment['file_url']?.toString() ?? '';

    Widget preview;
    if (fileType == 'image') {
      preview = Image.network(
        fileUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 100,
            height: 100,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image, size: 40),
          );
        },
      );
    } else {
      IconData icon;
      switch (fileType) {
        case 'video':
          icon = Icons.videocam;
          break;
        case 'pdf':
          icon = Icons.picture_as_pdf;
          break;
        default:
          icon = Icons.insert_drive_file;
      }
      preview = Container(
        width: 100,
        height: 100,
        color: Colors.grey.shade200,
        child: Icon(icon, size: 40),
      );
    }

    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(child: preview),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: InkWell(
                  onTap: () {
                    // TODO: فتح أو تنزيل الملف (يمكن إضافة url_launcher أو open_file)
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, color: Colors.white, size: 16),
                      SizedBox(width: 4),
                      Text('تحميل',
                          style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
