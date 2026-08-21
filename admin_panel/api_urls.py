from django.urls import path
from . import api_views

urlpatterns = [
    # Admin dashboard and statistics
    path('dashboard/', api_views.admin_dashboard, name='admin_dashboard_api'),
    path('statistics/', api_views.system_statistics, name='admin_system_statistics'),

    # Doctors management
    path('pending-doctors/', api_views.pending_doctor_applications, name='pending_doctor_applications'),
    path('approve-doctor/', api_views.approve_doctor_application, name='approve_doctor_application'),
    path('reject-doctor/', api_views.reject_doctor_application, name='reject_doctor_application'),
    path('doctors/', api_views.list_doctors, name='admin_list_doctors'),
    path('doctors/<int:doctor_id>/', api_views.doctor_details, name='admin_doctor_details'),
    path('doctors/<int:doctor_id>/update/', api_views.update_doctor, name='admin_update_doctor'),
    path('doctors/<int:doctor_id>/status/', api_views.update_doctor_status, name='admin_update_doctor_status'),
    path('doctors/<int:doctor_id>/delete/', api_views.delete_doctor, name='admin_delete_doctor'),

    # Patients management
    path('patients/', api_views.list_patients, name='admin_list_patients'),
    path('patients/<int:patient_id>/', api_views.update_patient, name='admin_update_patient'),
    path('patients/<int:patient_id>/delete/', api_views.delete_patient, name='admin_delete_patient'),
    path('users/<int:user_id>/status/', api_views.update_user_status, name='admin_update_user_status'),

    # Cases and responses
    path('cases/', api_views.list_cases, name='admin_list_cases'),
    path('cases/<int:case_id>/', api_views.case_details, name='admin_case_details'),

    # Notifications
    path('notifications/broadcast/', api_views.send_broadcast_notification, name='admin_broadcast_notification'),
    path('send-individual-notification/', api_views.send_individual_notification, name='admin_individual_notification'),

    # Media uploads
    path('doctors/<int:doctor_id>/upload-profile-image/', api_views.upload_doctor_profile_image, name='upload_doctor_profile_image'),
    path('doctors/<int:doctor_id>/upload-license-image/', api_views.upload_doctor_license_image, name='upload_doctor_license_image'),
]