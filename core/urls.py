from django.urls import path
from django.utils.translation import gettext as _
from . import views

app_name = 'core'

urlpatterns = [
    path('', views.HomeView.as_view(), name='home'),
    path('about/', views.AboutView.as_view(), name='about'),
    path('contact/', views.ContactView.as_view(), name='contact'),
    path('faq/', views.FAQView.as_view(), name='faq'),
    path('set-language/', views.set_language, name='set_language'),
    # Translation API endpoint used by mobile app
    path('utils/translate/', views.api_translate, name='translate_api'),
]