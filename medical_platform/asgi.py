"""
ASGI config for medical_platform project.

HTTP served by Django ASGI application.
WebSocket served by Channels with JWT auth middleware.
"""
import os

# Configure settings BEFORE importing Django/Channels modules
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_platform.settings')

import django

# Initialize Django first to avoid AppRegistryNotReady when importing auth models
django.setup()

from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter, URLRouter
from medical_platform.jwt_channels_middleware import JWTAuthMiddlewareStack
import patients.routing

django_asgi_app = get_asgi_application()

application = ProtocolTypeRouter({
    "http": django_asgi_app,
    "websocket": JWTAuthMiddlewareStack(
        URLRouter(patients.routing.websocket_urlpatterns)
    ),
})
