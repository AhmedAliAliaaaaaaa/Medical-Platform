import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors from Website
  static const Color primaryBlue = Color(0xFF25507B);
  static const Color primaryGreen = Color(0xFF14B892);
  static const Color primaryPurple = Color(0xFF764BA2);
  static const Color lightPurple = Color(0xFFB8C0E4);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF667EEA);
  static const Color gradientEnd = Color(0xFF764BA2);
  static const Color gradientAccent1 = Color(0xFFF093FB);
  static const Color gradientAccent2 = Color(0xFFF5576C);
  static const Color gradientAccent3 = Color(0xFF4FACFE);
  static const Color gradientAccent4 = Color(0xFF00F2FE);

  // Secondary Colors
  static const Color successGreen = Color(0xFF28A745);
  static const Color infoBlue = Color(0xFF17A2B8);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color dangerRed = Color(0xFFDC3545);

  // Neutral Colors
  static const Color darkGray = Color(0xFF4D5257);
  static const Color mediumGray = Color(0xFFE9ECEF);
  static const Color lightGray = Color(0xFFF8F9FA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color white = Color(0xFFFFFFFF);
  static const Color shadowColor = Color(0x1A000000);

  // Text Colors
  static const Color textPrimary = Color(0xFF2C3E50);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textLight = Color(0xFFFFFFFF);

  // Status Colors
  static const Color statusPending = Color(0xFFFFF3CD);
  static const Color statusPendingText = Color(0xFF856404);
  static const Color statusApproved = Color(0xFFD4EDDA);
  static const Color statusApprovedText = Color(0xFF155724);
  static const Color statusRejected = Color(0xFFF8D7DA);
  static const Color statusRejectedText = Color(0xFF721C24);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      gradientStart,
      gradientEnd,
      gradientAccent1,
      gradientAccent2,
      gradientAccent3,
      gradientAccent4,
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lightPurple, primaryPurple],
  );

  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: MaterialColor(primaryBlue.value, <int, Color>{
        50: primaryBlue.withOpacity(0.1),
        100: primaryBlue.withOpacity(0.2),
        200: primaryBlue.withOpacity(0.3),
        300: primaryBlue.withOpacity(0.4),
        400: primaryBlue.withOpacity(0.5),
        500: primaryBlue,
        600: primaryBlue.withOpacity(0.7),
        700: primaryBlue.withOpacity(0.8),
        800: primaryBlue.withOpacity(0.9),
        900: primaryBlue,
      }),
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: lightGray,
      fontFamily: 'Cairo',

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlue,
        foregroundColor: textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textLight,
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: cardBackground,
        elevation: 5,
        shadowColor: shadowColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: textLight,
          elevation: 3,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryBlue,
          textStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryBlue.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dangerRed),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        labelStyle: const TextStyle(fontFamily: 'Cairo', color: textSecondary),
        hintStyle: const TextStyle(fontFamily: 'Cairo', color: textSecondary),
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textSecondary,
        ),
      ),
    );
  }

  // Custom Decorations
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(color: shadowColor, blurRadius: 15, offset: const Offset(0, 5)),
    ],
  );

  static BoxDecoration get gradientCardDecoration => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [
      BoxShadow(color: shadowColor, blurRadius: 15, offset: const Offset(0, 5)),
    ],
  );

  static BoxDecoration get heroDecoration =>
      const BoxDecoration(gradient: heroGradient);

  // Custom Shadows
  static List<BoxShadow> get cardShadow => [
    BoxShadow(color: shadowColor, blurRadius: 15, offset: const Offset(0, 5)),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primaryGreen.withOpacity(0.3),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
  ];
}
