from urllib.parse import parse_qs
from channels.auth import AuthMiddlewareStack
from channels.db import database_sync_to_async
from django.contrib.auth import get_user_model
from django.contrib.auth.models import AnonymousUser
from django.conf import settings
from rest_framework_simplejwt.tokens import UntypedToken
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
import jwt

@database_sync_to_async
def get_user(user_id):
    User = get_user_model()
    try:
        return User.objects.get(id=user_id)
    except User.DoesNotExist:
        return AnonymousUser()

class JWTAuthMiddleware:
    def __init__(self, inner):
        self.inner = inner

    def __call__(self, scope):
        return JWTAuthMiddlewareInstance(scope, self.inner)

class JWTAuthMiddlewareInstance:
    def __init__(self, scope, inner):
        self.scope = dict(scope)
        self.inner = inner

    async def __call__(self, receive, send):
        query = parse_qs(self.scope.get("query_string", b"").decode())
        token = query.get("token", [None])[0]
        user = AnonymousUser()
        if token:
            try:
                # Validate shape of token
                UntypedToken(token)
                # Decode to extract user id
                decoded = jwt.decode(
                    token,
                    settings.SIMPLE_JWT.get("SIGNING_KEY", settings.SECRET_KEY),
                    algorithms=[settings.SIMPLE_JWT.get("ALGORITHM", "HS256")],
                    options={"verify_aud": False},
                )
                user_id = decoded.get("user_id")
                if user_id:
                    user = await get_user(user_id)
            except (InvalidToken, TokenError, jwt.PyJWTError):
                user = AnonymousUser()
        self.scope["user"] = user
        inner = self.inner(self.scope)
        return await inner(receive, send)

def JWTAuthMiddlewareStack(inner):
    return JWTAuthMiddleware(AuthMiddlewareStack(inner))