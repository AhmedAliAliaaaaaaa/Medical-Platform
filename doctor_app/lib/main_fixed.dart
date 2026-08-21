import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'utils/app_theme.dart';
import 'providers/language_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  // تأكد من تهيئة Flutter widgets
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting app with minimal initialization...');

  runApp(const FixedDoctorApp());
}

class FixedDoctorApp extends StatelessWidget {
  const FixedDoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            onGenerateTitle: (context) =>
                AppLocalizations.of(context)?.appTitle ?? 'منصة الاستشارات الطبية',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            themeMode: ThemeMode.system,
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
            // استخدام SplashScreen بسيط جداً

          );
        },
      ),
    );
  }
}
