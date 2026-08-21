@echo off
echo Setting up Medical Platform...
echo.

echo Installing requirements...
pip install -r requirements.txt

echo.
echo Creating database...
python manage.py makemigrations
python manage.py migrate

echo.
echo Creating admin user...
python manage.py createsuperuser

echo.
echo Updating admin user type...
python update_admin.py

echo.
echo Creating sample data...
python create_sample_data.py

echo.
echo Setup complete! Run 'run.bat' to start the server.
pause