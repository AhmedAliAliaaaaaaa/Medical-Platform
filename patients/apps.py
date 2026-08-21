from django.apps import AppConfig
from django.utils.translation import gettext as _


class PatientsConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'patients'

    def ready(self):
        # Import signals to ensure they are registered on startup
        try:
            import patients.signals  # noqa: F401
        except Exception:
            pass
