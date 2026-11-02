from django.db import migrations, models


def unify_service_fees(apps, schema_editor):
    Doctor = apps.get_model('doctors', 'Doctor')
    DoctorEarnings = apps.get_model('payments', 'DoctorEarnings')
    PlatformSettings = apps.get_model('payments', 'PlatformSettings')

    Doctor.objects.all().update(
        consultation_fee=100,
        emergency_fee=200,
        follow_up_fee=75,
    )
    DoctorEarnings.objects.all().update(
        consultation_fee=100,
        emergency_fee=200,
        follow_up_fee=75,
    )
    PlatformSettings.objects.all().update(
        default_consultation_fee=100,
        default_emergency_fee=200,
        default_follow_up_fee=75,
    )


class Migration(migrations.Migration):
    dependencies = [
        ('doctors', '0004_alter_doctor_follow_up_fee'),
        ('payments', '0004_payment_earnings_distributed'),
    ]

    operations = [
        migrations.AlterField(
            model_name='doctorearnings',
            name='follow_up_fee',
            field=models.DecimalField(decimal_places=2, default=75.0, max_digits=8),
        ),
        migrations.AlterField(
            model_name='platformsettings',
            name='default_follow_up_fee',
            field=models.DecimalField(decimal_places=2, default=75.0, max_digits=8),
        ),
        migrations.RunPython(unify_service_fees, migrations.RunPython.noop),
    ]
