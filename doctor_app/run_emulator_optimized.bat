@echo off
chcp 65001 >nul
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                  📱 تشغيل محسن للمحاكي                       ║
echo ║                 ⚡ حل مشكلة التعليق والبطء                    ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🔧 التحسينات المطبقة:
echo    ✅ SplashScreen محسن (1 ثانية بدلاً من 2.5)
echo    ✅ Timeout قصير للـ API (2 ثانية)
echo    ✅ Fallback للبيانات التجريبية
echo    ✅ إعدادات Gradle محسنة
echo.

echo 🚀 بدء تشغيل المحاكي...
flutter emulators --launch test_emulator

echo ⏳ انتظار تشغيل المحاكي (15 ثانية)...
timeout /t 15 /nobreak >nul

echo 📱 تشغيل التطبيق المحسن...
flutter run -d emulator-5554 --release --verbose

echo.
echo 💡 نصائح لتجنب التعليق:
echo    - إذا تعلق التطبيق، اضغط Ctrl+C وأعد التشغيل
echo    - استخدم Windows Desktop للتطوير (أسرع)
echo    - تأكد من أن السيرفر يعمل للبيانات الحقيقية
echo.
pause