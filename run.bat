@echo off
echo Starting Medical Platform with Multilingual Support...
echo.
echo Opening browser at http://127.0.0.1:8000
echo.
echo Login credentials:
echo Admin: nory / 123
echo Patient: patient1 / password123
echo Doctor: doctor1 / password123
echo.
echo Language Support:
echo - Arabic (العربية) - Default
echo - English - Available via language switcher
echo - Use the globe icon in navigation to switch languages
echo.
start http://127.0.0.1:8000
python manage.py runserver