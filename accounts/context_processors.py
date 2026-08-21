from django.conf import settings

def google_oauth_settings(request):
    """
    Context processor لإضافة إعدادات Google OAuth للقوالب
    """
    return {
        'GOOGLE_OAUTH_CLIENT_ID': settings.GOOGLE_OAUTH_CLIENT_ID,
    }