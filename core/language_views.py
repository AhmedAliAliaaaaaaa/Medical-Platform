from django.shortcuts import redirect
from django.utils import translation
from django.http import HttpResponseRedirect
from django.urls import reverse
from django.views.decorators.http import require_POST
from django.views.decorators.csrf import csrf_protect
from django.utils.decorators import method_decorator
from django.views import View
from django.conf import settings
from django.utils.translation import gettext as _

@require_POST
@csrf_protect
def set_language(request):
    """
    Custom language switching view
    """
    language = request.POST.get('language')
    next_url = request.POST.get('next', '/')
    
    # Validate language
    if language and language in ['ar', 'en']:
        # Activate the language
        translation.activate(language)
        
        # Set language in session using the correct key
        request.session['django_language'] = language
        
        # Clean the next URL to remove language prefix if present
        if next_url.startswith('/ar/') or next_url.startswith('/en/'):
            next_url = next_url[3:]  # Remove language prefix
        
        # Ensure next_url starts with /
        if not next_url.startswith('/'):
            next_url = '/' + next_url
            
        # Redirect to the same page with new language
        response = HttpResponseRedirect(next_url)
        
        # Set language cookie
        response.set_cookie(
            'django_language', 
            language,
            max_age=365 * 24 * 60 * 60,  # 1 year
            httponly=True,
            samesite='Lax'
        )
        
        return response
    
    # If invalid language, redirect to home
    return redirect('core:home')