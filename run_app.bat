@echo off
echo Starting Medical Platform...
echo.

echo Starting Django Server...
start "Django Server" cmd /k "cd /d c:\Users\asus\Desktop\ge && python manage.py runserver"

echo Waiting for Django server to start...
timeout /t 5 /nobreak > nul

echo Starting Flutter Doctor App...
start "Flutter Doctor App" cmd /k "cd /d c:\Users\asus\Desktop\ge\doctor_app && flutter run -d windows"

echo.
echo Both applications are starting...
echo Django Server: http://127.0.0.1:8000/
echo Flutter App: Will open automatically
echo.
pause