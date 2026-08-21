import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async

class StreamConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        user = self.scope.get("user")
        if not user or user.is_anonymous:
            await self.close()
            return
        self.user_group = f"user_{user.id}"
        await self.channel_layer.group_add(self.user_group, self.channel_name)
        await self.accept()

    async def disconnect(self, close_code):
        if hasattr(self, "user_group"):
            await self.channel_layer.group_discard(self.user_group, self.channel_name)

    async def receive(self, text_data=None, bytes_data=None):
        # Optional: handle pings or client requests
        try:
            data = json.loads(text_data or "{}")
            # Echo: useful for testing
            if data.get("type") == "ping":
                await self.send(json.dumps({"type": "pong"}))
        except Exception:
            pass

    async def push_event(self, event):
        # Called by group_send
        payload = event.get("payload", {})
        await self.send(text_data=json.dumps(payload))