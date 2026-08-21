import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'utils/app_theme.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'screens/splash/unified_splash_screen.dart';

void main() async {
  // تأكد من تهيئة Flutter widgets
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app with minimal initialization...');

  runApp(const DoctorApp());
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => LanguageProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (_) => AuthProvider()..initialize(),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appTitle ??
                'تطبيق الاستشارات الطبية',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.system,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              primaryColor: AppTheme.primaryBlue,
              fontFamily: 'Cairo',
              textTheme: const TextTheme(
                displayLarge: TextStyle(fontFamily: 'Cairo'),
                displayMedium: TextStyle(fontFamily: 'Cairo'),
                displaySmall: TextStyle(fontFamily: 'Cairo'),
                headlineLarge: TextStyle(fontFamily: 'Cairo'),
                headlineMedium: TextStyle(fontFamily: 'Cairo'),
                headlineSmall: TextStyle(fontFamily: 'Cairo'),
                titleLarge: TextStyle(fontFamily: 'Cairo'),
                titleMedium: TextStyle(fontFamily: 'Cairo'),
                titleSmall: TextStyle(fontFamily: 'Cairo'),
                bodyLarge: TextStyle(fontFamily: 'Cairo'),
                bodyMedium: TextStyle(fontFamily: 'Cairo'),
                bodySmall: TextStyle(fontFamily: 'Cairo'),
                labelLarge: TextStyle(fontFamily: 'Cairo'),
                labelMedium: TextStyle(fontFamily: 'Cairo'),
                labelSmall: TextStyle(fontFamily: 'Cairo'),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                  side: const BorderSide(color: AppTheme.primaryBlue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
              ),
              cardTheme: CardTheme(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                centerTitle: true,
              ),
            ),
            locale: languageProvider.currentLocale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            localeResolutionCallback: (deviceLocale, supportedLocales) {
              if (deviceLocale == null) return languageProvider.currentLocale;
              for (final locale in supportedLocales) {
                if (locale.languageCode == deviceLocale.languageCode) {
                  return locale;
                }
              }
              return const Locale('ar');
            },
            home: const UnifiedSplashScreen(),
          );
        },
      ),
    );
  }
}
