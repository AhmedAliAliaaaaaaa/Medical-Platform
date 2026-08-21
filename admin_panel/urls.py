from django.urls import path
from django.utils.translation import gettext as _
from . import views
from .views import doctor_management_views

app_name = 'admin_panel'

urlpatterns = [
    path('dashboard/', views.AdminDashboardView.as_view(), name='dashboard'),
    
    # Doctors management
    path('doctors/', views.ManageDoctorsView.as_view(), name='manage_doctors'),
    path('doctors/<int:doctor_id>/', views.DoctorDetailView.as_view(), name='doctor_detail'),
    path('doctors/<int:doctor_id>/edit/', views.UpdateDoctorView.as_view(), name='update_doctor'),
    path('doctors/<int:doctor_id>/delete/', views.DeleteDoctorView.as_view(), name='delete_doctor'),
    path('approve-doctor/<int:doctor_id>/', views.ApproveDoctorView.as_view(), name='approve_doctor'),
    path('reject-doctor/<int:doctor_id>/', views.RejectDoctorView.as_view(), name='reject_doctor'),
    
    # Enhanced doctor management
    path('doctors/<int:doctor_id>/get-password/', doctor_management_views.get_doctor_password, name='get_doctor_password'),
    path('doctors/<int:doctor_id>/get-password-new/', doctor_management_views.get_doctor_password, name='get_doctor_password_new'),
    path('doctors/<int:doctor_id>/reset-password/', doctor_management_views.reset_doctor_password, name='reset_doctor_password'),
    path('doctors/<int:doctor_id>/toggle-availability/', doctor_management_views.toggle_doctor_availability, name='toggle_doctor_availability'),
    path('doctors/bulk-actions/', doctor_management_views.bulk_doctor_actions, name='bulk_doctor_actions'),
    
    # Cases management
    path('cases/', views.ManageCasesView.as_view(), name='manage_cases'),
    path('cases/<int:case_id>/', views.CaseDetailView.as_view(), name='case_detail'),
    path('cases/<int:case_id>/edit/', views.UpdateCaseView.as_view(), name='update_case'),
    path('cases/<int:case_id>/delete/', views.DeleteCaseView.as_view(), name='delete_case'),
    path('cases/<int:case_id>/assign-doctor/', views.AssignDoctorView.as_view(), name='assign_doctor'),
    
    # Responses management
    path('responses/', views.ResponsesView.as_view(), name='responses'),
    path('responses/<int:response_id>/', views.ResponseDetailView.as_view(), name='response_detail'),
    
    # Enhanced doctor responses management
    path('doctor-responses/', doctor_management_views.manage_doctor_responses, name='manage_doctor_responses'),
    path('responses/<int:response_id>/approve/', doctor_management_views.approve_doctor_response, name='approve_doctor_response'),
    path('responses/<int:response_id>/reject/', doctor_management_views.reject_doctor_response, name='reject_doctor_response'),
    path('responses/<int:response_id>/delete/', doctor_management_views.delete_doctor_response, name='delete_doctor_response'),
    
    # Other
    path('users/', views.ManageUsersView.as_view(), name='manage_users'),
    path('users/<int:pk>/edit/', views.UpdateUserView.as_view(), name='update_user'),
    path('users/<int:pk>/delete/', views.DeleteUserView.as_view(), name='delete_user'),
    path('notifications/', views.NotificationsView.as_view(), name='notifications'),
    path('send-notification/', views.SendNotificationView.as_view(), name='send_notification'),
    path('statistics/', views.StatisticsView.as_view(), name='statistics'),
    path('export-reports/', views.ExportReportsView.as_view(), name='export_reports'),
    path('test/', views.TestAdminView.as_view(), name='test'),
    path('test-page/', views.TestPageView.as_view(), name='test_page'),
]