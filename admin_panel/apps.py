from django.apps import AppConfig
from django.utils.translation import gettext as _


class AdminPanelConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'admin_panel'
