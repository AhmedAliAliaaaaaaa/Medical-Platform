from django.urls import path
from django.utils.translation import gettext as _
from django.views.generic import TemplateView
from . import views

app_name = 'patients'

urlpatterns = [
    path('dashboard/', views.PatientDashboardView.as_view(), name='dashboard'),
    path('new-case/', views.NewCaseView.as_view(), name='new_case'),
    path('select-doctor/<int:case_id>/', views.SelectDoctorView.as_view(), name='select_doctor'),
    path('confirm-case/<int:case_id>/<int:doctor_id>/', views.ConfirmCaseView.as_view(), name='confirm_case'),
    path('case-detail/<int:case_id>/', views.CaseDetailView.as_view(), name='case_detail'),
    path('rate-doctor/<int:case_id>/', views.RateDoctorView.as_view(), name='rate_doctor'),
    path('my-responses/', views.MyResponsesView.as_view(), name='my_responses'),
    path('notifications/', views.NotificationsView.as_view(), name='notifications'),
    path('complaint/', views.SubmitComplaintView.as_view(), name='submit_complaint'),
    path('all-cases/', views.AllCasesView.as_view(), name='all_cases'),
    
    # مميزات جديدة - الدفع والترجمة
    path('payment/<int:case_id>/<int:doctor_id>/', views.PaymentView.as_view(), name='payment'),
    path('api/translate/', views.InstantTranslationView.as_view(), name='instant_translation'),
    path('test-translation/', views.TestTranslationView.as_view(), name='test_translation'),
    path('debug-translation/', TemplateView.as_view(template_name='debug_translation.html'), name='debug_translation'),
    path('simple-test/', TemplateView.as_view(template_name='simple_translator_test.html'), name='simple_test'),
    path('api/medical-suggestions/', views.MedicalSuggestionsView.as_view(), name='medical_suggestions'),
]