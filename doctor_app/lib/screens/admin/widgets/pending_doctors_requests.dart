
import 'package:flutter/material.dart';
import '../admin_constants.dart';

class PendingDoctorsRequests extends StatelessWidget {
  final int pendingCount;
  final VoidCallback? onViewAll;

  const PendingDoctorsRequests({
    required this.pendingCount,
    this.onViewAll,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pendingCount == 0) {
      return const SizedBox.shrink();
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
              Icon(Icons.warning_amber, color: Colors.orange.shade700),
              const SizedBox(width: AdminConstants.spacingSmall),
              Text(
                'طلبات أطباء معلقة!',
                style: AdminConstants.title.copyWith(
                  color: Colors.orange.shade700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: AdminConstants.borderRadiusSmall,
                ),
                child: Text(
                  '$pendingCount',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          Text(
            'يوجد $pendingCount طلب${pendingCount > 1 ? 'ات' : ''} من الأطباء في انتظار المراجعة والموافقة.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: AdminConstants.spacingMedium),
          ElevatedButton(
            onPressed: onViewAll,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: AdminConstants.borderRadiusSmall,
              ),
            ),
            child: const Text('مراجعة الطلبات'),
          ),
        ],
      ),
    );
  }
}
