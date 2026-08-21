from django.urls import path
from . import api_views

urlpatterns = [
    path('dashboard/', api_views.doctor_dashboard, name='doctor_dashboard'),
    path('cases/<int:case_id>/', api_views.case_details, name='doctor_case_details'),
    path('cases/<int:case_id>/respond/', api_views.respond_to_case, name='respond_to_case'),
    path('notifications/', api_views.doctor_notifications, name='doctor_notifications'),
    path('notifications/<int:notification_id>/mark-read/', api_views.mark_notification_read, name='doctor_mark_notification_read'),
    path('notifications/clear/<int:case_id>/', api_views.clear_case_notification, name='clear_case_notification'),
    path('notifications/mark-all-read/', api_views.mark_all_notifications_read, name='doctor_mark_all_notifications_read'),
    path('cases/<int:case_id>/update-status/', api_views.update_case_status, name='update_case_status'),
    path('send-notification/', api_views.send_notification, name='send_notification'),
    path('my-patients/', api_views.my_patients, name='my_patients'),
    path('available/', api_views.available_doctors, name='available_doctors'),
    path('earnings/', api_views.doctor_earnings_api, name='doctor_earnings_api'),
]