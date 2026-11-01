from django.db import migrations, models


def set_default_commission(apps, schema_editor):
    PlatformSettings = apps.get_model('payments', 'PlatformSettings')
    PlatformSettings.objects.filter(
        platform_commission_rate=10
    ).update(platform_commission_rate=60)


class Migration(migrations.Migration):
    dependencies = [
        ('payments', '0002_paymentmethod_account_number_paymentmethod_bank_name_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='platformsettings',
            name='platform_commission_rate',
            field=models.DecimalField(
                decimal_places=2,
                default=60.0,
                max_digits=5,
            ),
        ),
        migrations.RunPython(
            set_default_commission,
            migrations.RunPython.noop,
        ),
    ]
