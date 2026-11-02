from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [
        ('payments', '0003_set_platform_commission_to_sixty'),
    ]

    operations = [
        migrations.AddField(
            model_name='payment',
            name='earnings_distributed',
            field=models.BooleanField(default=False),
        ),
    ]
