
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../admin_constants.dart';
import 'admin_loading_error_widgets.dart';

class RecentCases extends StatelessWidget {
  final List<dynamic> cases;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRefresh;
  final Function(Map<String, dynamic>)? onCaseTap;

  const RecentCases({
    required this.cases,
    required this.isLoading,
    this.errorMessage,
    this.onRefresh,
    this.onCaseTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const AdminLoadingWidget(message: 'جاري تحميل الحالات...');
    }

    if (errorMessage != null) {
      return AdminErrorWidget(
        errorMessage: errorMessage,
        onRetry: onRefresh,
      );
    }

    if (cases.isEmpty) {
      return const AdminEmptyWidget(
        message: 'لا توجد حالات حديثة',
        icon: Icons.medical_information,
      );
    }

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
              Icon(Icons.recent_actors, color: AdminConstants.darkBlue),
              const SizedBox(width: AdminConstants.spacingSmall),
              Text(
                'الحالات الأخيرة',
                style: AdminConstants.title,
              ),
              const Spacer(),
              if (onRefresh != null)
                IconButton(
                  onPressed: onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'تحديث',
                ),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingMedium),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cases.length > 5 ? 5 : cases.length,
            separatorBuilder: (context, index) => const Divider(
              height: 1,
              indent: AdminConstants.paddingMedium,
              endIndent: AdminConstants.paddingMedium,
            ),
            itemBuilder: (context, index) {
              final caseItem = cases[index];
              return _buildCaseItem(caseItem);
            },
          ),
          if (cases.length > 5) ...[
            const SizedBox(height: AdminConstants.spacingSmall),
            Center(
              child: TextButton(
                onPressed: () {
                  // الانتقال لصفحة الحالات الكاملة
                },
                child: const Text('عرض المزيد'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCaseItem(Map<String, dynamic> caseItem) {
    final patient = caseItem['patient'] ?? {};
    final user = patient['user'] ?? {};
    final patientName = user['get_full_name'] ?? 
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
    final status = caseItem['status'] ?? 'pending';
    final title = caseItem['title'] ?? 'حالة طبية';
    final description = caseItem['description'] ?? '';
    final createdAt = caseItem['created_at'] ?? '';
    final doctor = caseItem['doctor'] ?? {};
    final doctorName = doctor['user']?['get_full_name'] ?? 
        '${doctor['user']?['first_name'] ?? ''} ${doctor['user']?['last_name'] ?? ''}';

    return InkWell(
      onTap: () => onCaseTap?.call(caseItem),
      borderRadius: AdminConstants.borderRadiusSmall,
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.paddingSmall),
        child: Row(
          children: [
            // رقم الحالة
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AdminConstants.darkBlue.withOpacity(0.1),
                borderRadius: AdminConstants.borderRadiusSmall,
              ),
              child: Center(
                child: Text(
                  '${caseItem['id'] ?? ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AdminConstants.darkBlue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AdminConstants.spacingSmall),
            // تفاصيل الحالة
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        patientName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (doctorName.isNotEmpty) ...[
                        Icon(Icons.medical_services, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          doctorName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AdminConstants.spacingSmall),
            // حالة الحالة
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: _getStatusColor(status).withOpacity(0.1),
                borderRadius: AdminConstants.borderRadiusSmall,
              ),
              child: Text(
                _getStatusText(status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(status),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
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

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'معلّقة';
      case 'in_progress':
        return 'قيد المراجعة';
      case 'completed':
        return 'مكتملة';
      case 'cancelled':
        return 'ملغاة';
      default:
        return 'غير معروفة';
    }
  }
}
