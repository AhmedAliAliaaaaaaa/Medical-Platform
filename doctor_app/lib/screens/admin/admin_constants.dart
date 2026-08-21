
import 'package:flutter/material.dart';

class AdminConstants {
  // الألوان المستخدمة في صفحات المشرف
  static const Color orange = Color(0xFFF97316); // برتقالي واضح
  static const Color lightOrange = Color(0xFFFFE6D1);
  static const Color darkBlue = Color(0xFF1E3A8A);
  static const Color softBg = Color(0xFFF6F8FB);
  static const Color card = Colors.white;
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF475467);

  // أنماط النصوص
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: textSecondary,
  );

  static const TextStyle btn = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  // الظلال
  static List<BoxShadow> get shadowSoft => [
        BoxShadow(
          color: const Color(0xFF101828).withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  // الحواف
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(16);
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(8);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(20);

  // التباعد
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 12.0;
  static const double spacingLarge = 16.0;
}
