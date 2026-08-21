
import 'package:flutter/material.dart';
import '../admin_constants.dart';

class QuickActions extends StatelessWidget {
  final List<QuickActionItem> actions;
  final String title;
  final IconData? titleIcon;

  const QuickActions({
    required this.actions,
    required this.title,
    this.titleIcon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              if (titleIcon != null) ...[
                Icon(titleIcon, color: AdminConstants.orange),
                const SizedBox(width: AdminConstants.spacingSmall),
              ],
              Text(
                title,
                style: AdminConstants.title.copyWith(
                  color: AdminConstants.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AdminConstants.spacingMedium),
          Wrap(
            spacing: AdminConstants.spacingMedium,
            runSpacing: AdminConstants.spacingMedium,
            children: actions.map((action) => _buildActionButton(action)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(QuickActionItem action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AdminConstants.paddingMedium),
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: AdminConstants.borderRadiusSmall,
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: AdminConstants.spacingSmall),
          Text(
            action.label,
            style: AdminConstants.subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class QuickActionItem {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
