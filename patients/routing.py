from django.urls import re_path
from . import ws_consumers

websocket_urlpatterns = [
    re_path(r"^ws/stream/$", ws_consumers.StreamConsumer.as_asgi()),
]