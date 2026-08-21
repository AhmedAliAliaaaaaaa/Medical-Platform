
import 'package:flutter/material.dart';
import '../admin_constants.dart';

class AdminStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const AdminStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: AdminConstants.borderRadiusSmall,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AdminConstants.spacingMedium),
            Text(
              title,
              style: AdminConstants.subtitle,
            ),
          ],
        ),
      ),
    );
  }
}
