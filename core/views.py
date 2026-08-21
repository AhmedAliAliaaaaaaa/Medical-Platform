from django.shortcuts import render, redirect
from django.views.generic import TemplateView, CreateView
from django.contrib import messages
from django.db.models import Count
from django.utils import translation
from django.http import HttpResponseRedirect, JsonResponse
from django.conf import settings
from django.utils.translation import gettext as _
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from django.utils.decorators import method_decorator
from django.views import View
import json

from .models import ContactMessage, FAQ
from doctors.models import Doctor
from patients.models import MedicalCase
from accounts.models import CustomUser
from core.translation_service import translation_service
from django.views.decorators.csrf import csrf_exempt

class HomeView(TemplateView):
    def get_template_names(self):
        current_language = translation.get_language()
        if current_language == 'en':
            return ['core/home_en.html']
        return ['core/home_enhanced.html']
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['total_doctors'] = Doctor.objects.filter(status='approved').count()
        context['total_cases'] = MedicalCase.objects.count()
        context['total_patients'] = CustomUser.objects.filter(user_type='patient').count()
        context['featured_doctors'] = Doctor.objects.filter(
            status='approved', 
            is_available=True
        ).order_by('-rating')[:6]
        return context

class AboutView(TemplateView):
    template_name = 'core/about.html'

class ContactView(CreateView):
    model = ContactMessage
    template_name = 'core/contact.html'
    fields = ['name', 'email', 'subject', 'message']
    
    def form_valid(self, form):
        messages.success(self.request, _('تم إرسال رسالتك بنجاح. سنتواصل معك قريباً.'))
        return super().form_valid(form)
    
    def get_success_url(self):
        return self.request.path

class FAQView(TemplateView):
    template_name = 'core/faq.html'
    
    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        context['faqs'] = FAQ.objects.filter(is_active=True)
        return context

@csrf_exempt
@require_http_methods(["GET", "POST"])
def set_language(request):
    """
    تبديل اللغة بين العربية والإنجليزية
    """
    next_url = request.POST.get('next', request.GET.get('next'))
    if not next_url:
        next_url = request.META.get('HTTP_REFERER')
    if not next_url:
        next_url = '/'
    
    # دعم استدعاء API ترجمة فوري (POST JSON) لمسارات i18n القديمة
    if request.path.endswith('/api/translate/') and request.method == 'POST':
        try:
            data = json.loads(request.body)
            text = data.get('text', '')
            target_lang = data.get('target_lang', 'en')
            use_medical_dict = data.get('use_medical_dict', True)
            result = translation_service.translate_text(text, target_lang=target_lang, use_medical_dict=use_medical_dict)
            return JsonResponse(result)
        except Exception as e:
            return JsonResponse({'success': False, 'error': str(e)}, status=400)
    
    response = HttpResponseRedirect(next_url)
    
    language = request.POST.get('language', request.GET.get('language'))
    if language and language in [lang[0] for lang in settings.LANGUAGES]:
        if hasattr(request, 'session'):
            request.session['django_language'] = language
        response.set_cookie(
            settings.LANGUAGE_COOKIE_NAME, 
            language,
            max_age=settings.LANGUAGE_COOKIE_AGE,
            path=settings.LANGUAGE_COOKIE_PATH,
            domain=settings.LANGUAGE_COOKIE_DOMAIN,
            secure=settings.LANGUAGE_COOKIE_SECURE,
            httponly=settings.LANGUAGE_COOKIE_HTTPONLY,
            samesite=settings.LANGUAGE_COOKIE_SAMESITE,
        )
        translation.activate(language)
    
    return response


@csrf_exempt
@require_http_methods(["POST"])
def api_translate(request):
    """نقطة نهاية ترجمة JSON تحت /api/utils/translate/"""
    try:
        data = json.loads(request.body)
        text = data.get('text', '')
        target_lang = data.get('target_lang', 'en')
        use_medical_dict = data.get('use_medical_dict', True)
        result = translation_service.translate_text(text, target_lang=target_lang, use_medical_dict=use_medical_dict)
        return JsonResponse(result)
    except Exception as e:
        return JsonResponse({'success': False, 'error': str(e)}, status=400)
