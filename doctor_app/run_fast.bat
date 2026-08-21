@echo off
chcp 65001 >nul
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    ⚡ تشغيل سريع للتطبيق                     ║
echo ║                  🚀 محسن للأداء والسرعة                      ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🎯 خيارات التشغيل السريع:
echo.
echo [1] Windows Desktop (الأسرع - للتطوير)
echo [2] Android Emulator - Release (سريع - للاختبار)
echo [3] Android Emulator - Profile (متوسط - للتحليل)
echo [4] تنظيف وإعادة بناء
echo [5] إيقاف العمليات الثقيلة
echo.
set /p choice="اختر رقم الخيار (1-5): "

if "%choice%"=="1" goto windows
if "%choice%"=="2" goto android_release
if "%choice%"=="3" goto android_profile
if "%choice%"=="4" goto clean_build
if "%choice%"=="5" goto kill_processes

:windows
echo.
echo 🖥️ تشغيل على Windows Desktop (الأسرع)...
flutter run -d windows --release
goto end

:android_release
echo.
echo 📱 تشغيل على Android - وضع Release...
echo ⏱️ قد يستغرق 1-2 دقيقة للبناء الأول...
flutter run -d emulator-5554 --release
goto end

:android_profile
echo.
echo 📊 تشغيل على Android - وضع Profile...
flutter run -d emulator-5554 --profile
goto end

:clean_build
echo.
echo 🧹 تنظيف وإعادة بناء...
flutter clean
flutter pub get
echo ✅ تم التنظيف بنجاح!
echo.
echo اختر خيار التشغيل:
echo [1] Windows Desktop
echo [2] Android Emulator
set /p run_choice="اختر (1 أو 2): "
if "%run_choice%"=="1" (
    flutter run -d windows --release
) else (
    flutter run -d emulator-5554 --release
)
goto end

:kill_processes
echo.
echo 🔄 إيقاف العمليات الثقيلة...
taskkill /f /im java.exe 2>nul
taskkill /f /im gradle.exe 2>nul
echo ✅ تم إيقاف العمليات الثقيلة!
echo.
echo الآن يمكنك تشغيل التطبيق بسرعة أكبر
pause
goto start

:end
echo.
echo 🎉 انتهى التشغيل!
echo.
echo 💡 نصائح للتطوير السريع:
echo    - استخدم Hot Reload (r) بدلاً من إعادة التشغيل
echo    - استخدم Windows Desktop للتطوير اليومي
echo    - استخدم Android Release للاختبار النهائي
echo.
pause