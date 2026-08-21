import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _locale = const Locale('ar'); // Default to Arabic
  bool _isRTL = true;

  Locale get locale => _locale;
  Locale get currentLocale => _locale;
  bool get isRTL => _isRTL;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  // Initialize language from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code') ?? 'ar';

    _locale = Locale(languageCode);
    _isRTL = languageCode == 'ar';
    notifyListeners();
  }

  // Change language
  Future<void> changeLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;

    _locale = Locale(languageCode);
    _isRTL = languageCode == 'ar';

    // Save to storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', languageCode);

    notifyListeners();
  }

  // Toggle language
  Future<void> toggleLanguage() async {
    final newLanguageCode = _locale.languageCode == 'ar' ? 'en' : 'ar';
    await changeLanguage(newLanguageCode);
  }

  // Set Arabic
  Future<void> setArabic() async {
    await changeLanguage('ar');
  }

  // Set English
  Future<void> setEnglish() async {
    await changeLanguage('en');
  }

  // Get text direction
  TextDirection get textDirection =>
      _isRTL ? TextDirection.rtl : TextDirection.ltr;

  // Get alignment based on language
  Alignment get startAlignment =>
      _isRTL ? Alignment.centerRight : Alignment.centerLeft;
  Alignment get endAlignment =>
      _isRTL ? Alignment.centerLeft : Alignment.centerRight;

  // Get text align based on language
  TextAlign get startTextAlign => _isRTL ? TextAlign.right : TextAlign.left;
  TextAlign get endTextAlign => _isRTL ? TextAlign.left : TextAlign.right;

  // Get edge insets based on language
  EdgeInsets getStartPadding(double value) =>
      _isRTL ? EdgeInsets.only(right: value) : EdgeInsets.only(left: value);

  EdgeInsets getEndPadding(double value) =>
      _isRTL ? EdgeInsets.only(left: value) : EdgeInsets.only(right: value);

  // Get margin based on language
  EdgeInsets getStartMargin(double value) =>
      _isRTL ? EdgeInsets.only(right: value) : EdgeInsets.only(left: value);

  EdgeInsets getEndMargin(double value) =>
      _isRTL ? EdgeInsets.only(left: value) : EdgeInsets.only(right: value);

  // Get icon based on language direction
  IconData getBackIcon() =>
      _isRTL ? Icons.arrow_forward_ios : Icons.arrow_back_ios;
  IconData getForwardIcon() =>
      _isRTL ? Icons.arrow_back_ios : Icons.arrow_forward_ios;

  // Format number based on language
  String formatNumber(int number) {
    if (_isRTL) {
      // Convert to Arabic numerals
      return number.toString().replaceAllMapped(
        RegExp(r'[0-9]'),
        (match) => '٠١٢٣٤٥٦٧٨٩'[int.parse(match.group(0)!)],
      );
    } else {
      return number.toString();
    }
  }

  // Format date based on language
  String formatDate(DateTime date) {
    if (_isRTL) {
      // Arabic date format
      final months = [
        'يناير',
        'فبراير',
        'مارس',
        'أبريل',
        'مايو',
        'يونيو',
        'يوليو',
        'أغسطس',
        'سبتمبر',
        'أكتوبر',
        'نوفمبر',
        'ديسمبر',
      ];
      return '${formatNumber(date.day)} ${months[date.month - 1]} ${formatNumber(date.year)}';
    } else {
      // English date format
      final months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }

  // Format time based on language
  String formatTime(DateTime time) {
    final hour = time.hour;
    final minute = time.minute;

    if (_isRTL) {
      final hourStr = formatNumber(
        hour > 12
            ? hour - 12
            : hour == 0
            ? 12
            : hour,
      );
      final minuteStr = formatNumber(minute).padLeft(2, '٠');
      final period = hour >= 12 ? 'م' : 'ص';
      return '$hourStr:$minuteStr $period';
    } else {
      final hourStr =
          (hour > 12
                  ? hour - 12
                  : hour == 0
                  ? 12
                  : hour)
              .toString();
      final minuteStr = minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      return '$hourStr:$minuteStr $period';
    }
  }

  // Get language name
  String get currentLanguageName => _isRTL ? 'العربية' : 'English';
  String get otherLanguageName => _isRTL ? 'English' : 'العربية';

  // Get supported locales
  static const List<Locale> supportedLocales = [Locale('ar'), Locale('en')];
}
