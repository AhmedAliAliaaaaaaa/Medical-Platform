
import 'package:flutter/material.dart';
import '../admin_constants.dart';

class SimpleBarChart extends StatelessWidget {
  final List<BarData> data;
  final String title;
  final Color barColor;
  final double? maxValue;

  const SimpleBarChart({
    required this.data,
    required this.title,
    this.barColor = AdminConstants.darkBlue,
    this.maxValue,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // حساب القيمة القصوى إذا لم يتم تحديدها
    final double maxVal = maxValue ?? 
        (data.isEmpty ? 1 : data.map((e) => e.value).reduce((a, b) => a > b ? a : b));

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
          Text(
            title,
            style: AdminConstants.title.copyWith(
              color: AdminConstants.darkBlue,
            ),
          ),
          const SizedBox(height: AdminConstants.spacingMedium),
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // رسم الأعمدة
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: data.map((item) {
                      final height = maxVal == 0 ? 0.0 : item.value / maxVal * 150.0;
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            width: 30,
                            height: height,
                            decoration: BoxDecoration(
                              color: barColor,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(4),
                                topRight: Radius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.label,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AdminConstants.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.value}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BarData {
  final String label;
  final double value;

  BarData({
    required this.label,
    required this.value,
  });
}
