@echo off
echo ===================================
echo إعادة تشغيل تطبيق Flutter بالإعدادات الجديدة
echo ===================================
echo.

set PROJECT_DIR=c:\Users\asus\Desktop\ge\doctor_app

echo 🔄 الانتقال إلى مجلد المشروع...
cd /d "%PROJECT_DIR%"
if errorlevel 1 (
    echo ❌ لم يتم العثور على مجلد المشروع: %PROJECT_DIR%
    pause
    exit /b 1
)

echo.
echo 🧹 تنظيف المشروع...
flutter clean
if errorlevel 1 (
    echo ❌ فشل في تنظيف المشروع
    pause
    exit /b 1
)

echo.
echo 📦 تحديث التبعيات...
flutter pub get
if errorlevel 1 (
    echo ❌ فشل في تحديث التبعيات
    pause
    exit /b 1
)

echo.
echo ✅ تم تحديث الإعدادات بنجاح!
echo.
echo 📍 العنوان الجديد: http://192.168.8.180:8000
echo 🔧 تم إضافة android:usesCleartextTraffic="true"
echo 🌐 تم إضافة صلاحيات الإنترنت
echo.
echo 🚀 الآن يمكنك تشغيل التطبيق:
echo    flutter run
echo.
echo 🔑 بيانات الاختبار:
echo - طبيب: flutter_doctor@test.com / 123456
echo - مريض: flutter_patient@test.com / 123456
echo.

pause