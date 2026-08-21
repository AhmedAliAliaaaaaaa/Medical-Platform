from django.apps import AppConfig
from django.utils.translation import gettext as _


class PaymentsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'payments'
    verbose_name = 'نظام الدفع'