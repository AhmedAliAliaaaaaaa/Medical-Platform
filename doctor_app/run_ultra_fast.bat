@echo off
chcp 65001 >nul
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                  ⚡ تشغيل فائق السرعة                        ║
echo ║                 🚀 حل نهائي لمشكلة التعليق                   ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🔧 التحسينات المطبقة:
echo    ✅ إزالة جميع الخدمات الثقيلة
echo    ✅ SplashScreen بسيط (0.5 ثانية فقط)
echo    ✅ بدء مباشر من صفحة الترحيب
echo    ✅ لا يوجد API calls في البداية
echo.

echo 🚀 تشغيل التطبيق بأقصى سرعة...
flutter run -d windows --release --verbose

echo.
echo 💡 إذا لم يعمل، جرب:
echo    flutter clean
echo    flutter pub get
echo    flutter run -d windows --release
echo.
pause