import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_theme.dart';
import '../../services/admin_api_service.dart';
import 'admin_constants.dart';
import 'widgets/admin_loading_error_widgets.dart';

class AdminDoctorResponsesScreen extends StatefulWidget {
  const AdminDoctorResponsesScreen({super.key});

  @override
  State<AdminDoctorResponsesScreen> createState() =>
      _AdminDoctorResponsesScreenState();
}

class _AdminDoctorResponsesScreenState
    extends State<AdminDoctorResponsesScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _responses = [];
  String _query = '';

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
      final data = await AdminApiService.getDoctorResponses();
      setState(() {
        _responses = [];
        for (final e in data) {
          if (e is Map<String, dynamic>) {
            _responses.add(e);
          } else if (e is Map) {
            _responses.add(Map<String, dynamic>.from(e));
          }
        }
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _responses.where((r) {
      final caseTitle = (r['case']?['title'] ?? '').toString();
      final content = (r['content'] ?? '').toString();
      return caseTitle.contains(_query) || content.contains(_query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('ردود الأطباء'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.all(AdminConstants.paddingMedium),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'بحث في الردود والعناوين',
                border: OutlineInputBorder(
                  borderRadius: AdminConstants.borderRadiusSmall,
                ),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const AdminLoadingWidget()
                : _error != null
                    ? AdminErrorWidget(
                        errorMessage: _error,
                        onRetry: _load,
                      )
                    : filtered.isEmpty
                        ? const AdminEmptyWidget(
                            message: 'لا توجد ردود',
                            icon: Icons.forum_outlined,
                          )
                        : RefreshIndicator(
                            onRefresh: _load,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(
                                  AdminConstants.paddingMedium),
                              itemBuilder: (_, i) {
                                final r = filtered[i];
                                final caseTitle =
                                    (r['case']?['title'] ?? 'حالة').toString();
                                final doctor = (r['doctor']?['user']
                                            ?['get_full_name'] ??
                                        r['doctor']?['user']?['username'] ??
                                        'طبيب')
                                    .toString();
                                final createdAt =
                                    (r['created_at'] ?? '').toString();
                                final content = (r['content'] ?? '').toString();
                                return _buildResponseItem(
                                  context,
                                  caseTitle,
                                  doctor,
                                  createdAt,
                                  content,
                                  r,
                                );
                              },
                              separatorBuilder: (_, __) => const SizedBox(
                                  height: AdminConstants.spacingSmall),
                              itemCount: filtered.length,
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseItem(
    BuildContext context,
    String caseTitle,
    String doctor,
    String createdAt,
    String content,
    Map<String, dynamic> response,
  ) {
    return Container(
      padding: const EdgeInsets.all(AdminConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AdminConstants.card,
        borderRadius: AdminConstants.borderRadiusMedium,
        boxShadow: AdminConstants.shadowSoft,
      ),
      child: ListTile(
        leading: const Icon(Icons.forum_outlined),
        title: Text(caseTitle),
        subtitle: Text(
          '$doctor • $createdAt\n$content',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        onTap: () {
          _showResponseDetails(context, response);
        },
      ),
    );
  }

  void _showResponseDetails(
    BuildContext context,
    Map<String, dynamic> response,
  ) {
    final caseTitle = (response['case']?['title'] ?? 'حالة').toString();
    final doctor = (response['doctor']?['user']?['get_full_name'] ??
            response['doctor']?['user']?['username'] ??
            'طبيب')
        .toString();
    final createdAt = (response['created_at'] ?? '').toString();
    final content = (response['content'] ?? '').toString();
    final rec = (response['recommendations'] ?? '').toString();
    final status = (response['status'] ?? '').toString();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (context, scrollController) => Padding(
            padding: const EdgeInsets.all(AdminConstants.paddingMedium),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.forum_outlined),
                      const SizedBox(width: AdminConstants.spacingSmall),
                      Expanded(
                        child: Text(
                          caseTitle,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AdminConstants.spacingSmall),
                  Text('الطبيب: $doctor'),
                  const SizedBox(height: 4),
                  Text('التاريخ: $createdAt'),
                  if (status.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('الحالة: $status'),
                  ],
                  const Divider(height: AdminConstants.spacingMedium),
                  const Text('نص الرد',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AdminConstants.spacingSmall),
                  SelectableText(content),
                  if (rec.isNotEmpty) ...[
                    const SizedBox(height: AdminConstants.spacingMedium),
                    const Text('التوصيات',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: AdminConstants.spacingSmall),
                    SelectableText(rec),
                  ],
                  const SizedBox(height: AdminConstants.spacingMedium),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: content));
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('تم نسخ نص الرد'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.copy),
                        label: const Text('نسخ الرد'),
                      ),
                      const SizedBox(width: AdminConstants.spacingSmall),
                      OutlinedButton.icon(
                        onPressed: () {
                          // Placeholder: الانتقال لتفاصيل الحالة لاحقاً
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('فتح الحالة'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
