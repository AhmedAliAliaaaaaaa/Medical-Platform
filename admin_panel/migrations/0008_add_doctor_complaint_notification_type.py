from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('admin_panel', '0007_delete_systemsettings_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='adminnotification',
            name='notification_type',
            field=models.CharField(
                choices=[
                    ('doctor_registration', 'تسجيل طبيب جديد'),
                    ('doctor_response', 'رد طبيب جديد'),
                    ('doctor_message', 'رسالة من طبيب'),
                    ('patient_complaint', 'شكوى مريض'),
                    ('doctor_complaint', 'شكوى طبيب'),
                    ('system', 'إشعار نظام'),
                    ('general', 'عام'),
                ],
                default='general',
                max_length=20,
            ),
        ),
    ]
