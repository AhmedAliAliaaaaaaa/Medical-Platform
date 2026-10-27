from django.urls import path
from django.utils.translation import gettext as _
from . import views

app_name = 'doctors'

urlpatterns = [
    path('dashboard/', views.DoctorDashboardView.as_view(), name='dashboard'),
    path('pending/', views.PendingApprovalView.as_view(), name='pending'),
    path('case/<int:case_id>/', views.CaseDetailView.as_view(), name='case_detail'),
    path('respond/<int:case_id>/', views.RespondToCaseView.as_view(), name='respond_case'),
    path('my-responses/', views.MyResponsesView.as_view(), name='my_responses'),
    path('all-patient-cases/', views.AllPatientCasesView.as_view(), name='all_patient_cases'),
    path('my-ratings/', views.MyRatingsView.as_view(), name='my_ratings'),
    path('send-notification/', views.SendNotificationView.as_view(), name='send_notification'),
    path('notifications/', views.DoctorNotificationsView.as_view(), name='notifications'),
    path('complaint/', views.SubmitComplaintView.as_view(), name='submit_complaint'),
]