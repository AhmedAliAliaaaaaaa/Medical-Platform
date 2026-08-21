from django.urls import path
from . import api_views

urlpatterns = [
    # Dashboard
    path('dashboard/', api_views.patient_dashboard, name='patient_dashboard'),
    
    # Cases Management
    path('cases/', api_views.patient_cases, name='patient_cases'),
    path('cases/<int:case_id>/', api_views.case_details, name='case_details'),
    path('cases/<int:case_id>/rate/', api_views.rate_doctor, name='rate_doctor'),
    
    # Notifications
    path('notifications/', api_views.patient_notifications, name='patient_notifications'),
    path('notifications/<int:notification_id>/mark-read/', api_views.mark_notification_read, name='mark_notification_read'),
    path('notifications/mark-all-read/', api_views.mark_all_notifications_read, name='mark_all_notifications_read'),
    # Attachments upload for cases
    path('cases/<int:case_id>/attachments/', api_views.upload_case_attachments, name='upload_case_attachments'),
]