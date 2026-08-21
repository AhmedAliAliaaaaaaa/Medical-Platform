
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../admin_constants.dart';

class DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doctor;
  final bool isApproved;
  final VoidCallback onViewDetails;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatus;
  final VoidCallback onDelete;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const DoctorCard({
    required this.doctor,
    required this.isApproved,
    required this.onViewDetails,
    required this.onEdit,
    required this.onToggleStatus,
    required this.onDelete,
    required this.onApprove,
    required this.onReject,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = doctor['user'] ?? {};
    final name = doctor['name'] ??
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}';
    final email = doctor['email'] ?? user['email'] ?? '';
    final specialization = doctor['specialization'] ?? 'طبيب عام';
    final status = doctor['status'] ?? 'active';
    final rating = doctor['rating'] ?? 0.0;
    final casesCount = doctor['cases_count'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: AdminConstants.spacingMedium),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: AdminConstants.borderRadiusMedium,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AdminConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // معلومات الطبيب الأساسية
            Row(
              children: [
                // صورة الطبيب
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AdminConstants.darkBlue,
                  backgroundImage: doctor['profile_image'] != null
                      ? CachedNetworkImageProvider(
                          doctor['profile_image'],
                        )
                      : null,
                  child: doctor['profile_image'] == null
                      ? Text(
                          name.isNotEmpty ? name[0] : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AdminConstants.spacingMedium),
                // اسم الطبيب والتخصص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AdminConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialization,
                        style: AdminConstants.subtitle,
                      ),
                    ],
                  ),
                ),
                // حالة الطبيب
                if (isApproved)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: status == 'active'
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      borderRadius: AdminConstants.borderRadiusSmall,
                    ),
                    child: Text(
                      status == 'active' ? 'نشط' : 'معطل',
                      style: TextStyle(
                        color: status == 'active'
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: AdminConstants.borderRadiusSmall,
                    ),
                    child: Text(
                      'قيد المراجعة',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // معلومات الاتصال
            Row(
              children: [
                Icon(Icons.email, color: Colors.grey, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    email,
                    style: AdminConstants.subtitle,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isApproved) ...[
                  Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    rating.toString(),
                    style: AdminConstants.subtitle,
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.medical_services, color: AdminConstants.darkBlue, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$casesCount حالة',
                    style: AdminConstants.subtitle,
                  ),
                ] else ...[
                  Icon(Icons.access_time, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${doctor['experience_years'] ?? 0} سنة',
                    style: AdminConstants.subtitle,
                  ),
                ],
              ],
            ),

            const SizedBox(height: AdminConstants.spacingMedium),

            // أزرار الإجراءات
            Row(
              children: [
                // تفاصيل
                OutlinedButton.icon(
                  onPressed: onViewDetails,
                  icon: const Icon(Icons.visibility),
                  label: const Text('التفاصيل'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminConstants.darkBlue,
                    side: BorderSide(color: AdminConstants.darkBlue),
                  ),
                ),
                const SizedBox(width: AdminConstants.spacingSmall),
                // قائمة منسدلة
                PopupMenuButton<String>(
                  tooltip: 'إجراءات سريعة',
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) async {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'toggle':
                        onToggleStatus();
                        break;
                      case 'approve':
                        onApprove();
                        break;
                      case 'reject':
                        onReject();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) {
                    final items = <PopupMenuEntry<String>>[];
                    if (isApproved) {
                      items.addAll([
                        const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                                leading: Icon(Icons.edit), title: Text('تعديل'))),
                        PopupMenuItem(
                          value: 'toggle',
                          child: ListTile(
                            leading: Icon(status == 'active'
                                ? Icons.block
                                : Icons.check_circle),
                            title: Text(status == 'active' ? 'تعطيل' : 'تفعيل'),
                          ),
                        ),
                        const PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                                leading: Icon(Icons.delete), title: Text('حذف'))),
                      ]);
                    } else {
                      items.addAll([
                        const PopupMenuItem(
                            value: 'approve',
                            child: ListTile(
                                leading: Icon(Icons.check), title: Text('موافقة'))),
                        const PopupMenuItem(
                            value: 'reject',
                            child: ListTile(
                                leading: Icon(Icons.close), title: Text('رفض'))),
                        const PopupMenuItem(
                            value: 'edit',
                            child: ListTile(
                                leading: Icon(Icons.edit), title: Text('تعديل'))),
                      ]);
                    }
                    return items;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
