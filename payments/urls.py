from django.urls import path
from . import views

app_name = 'payments'

urlpatterns = [
    # Payment methods management
    path('methods/', views.payment_methods, name='payment_methods'),
    path('methods/delete/<int:method_id>/', views.delete_payment_method, name='delete_payment_method'),
    
    # Consultation payments
    path('consultation/<int:case_id>/', views.consultation_payment, name='consultation_payment'),
    path('success/<str:payment_id>/', views.payment_success, name='payment_success'),
    path('cancel/', views.payment_cancel, name='payment_cancel'),
    
    # Doctor subscription and earnings
    path('doctor/subscription/', views.doctor_subscription, name='doctor_subscription'),
    path('doctor/earnings/', views.doctor_earnings, name='doctor_earnings'),
    path('doctor/withdrawal/', views.withdrawal_request, name='withdrawal_request'),
    
    # Payment history
    path('history/', views.payment_history, name='payment_history'),
    
    # Webhooks
    path('stripe/webhook/', views.stripe_webhook, name='stripe_webhook'),
]