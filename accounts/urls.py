from django.urls import path
from django.utils.translation import gettext as _
from django.http import JsonResponse
from django.views.decorators.http import require_GET
from django.contrib.auth import get_user_model
from django.utils.decorators import method_decorator
from . import views

app_name = 'accounts'

User = get_user_model()

@require_GET
def check_username(request):
    username = request.GET.get('username', '').strip()
    if not username:
        return JsonResponse({'available': False, 'message': _('الرجاء إدخال اسم مستخدم')})
    exists = User.objects.filter(username=username).exists()
    return JsonResponse({'available': not exists, 'message': _('الاسم متاح') if not exists else _('الاسم مستخدم بالفعل')})

urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='register'),
    path('login/', views.LoginView.as_view(), name='login'),
    path('logout/', views.LogoutView.as_view(), name='logout'),
    path('profile/', views.ProfileView.as_view(), name='profile'),
    path('change-password/', views.ChangePasswordView.as_view(), name='change_password'),
    path('sessions/', views.SessionsView.as_view(), name='sessions'),
    path('deactivate/', views.DeactivateAccountView.as_view(), name='deactivate'),
    path('delete/', views.DeleteAccountView.as_view(), name='delete_account'),

    path('doctor-register/', views.DoctorRegisterView.as_view(), name='doctor_register'),
    path('enhanced-doctor-register/', views.EnhancedDoctorRegisterView.as_view(), name='enhanced_doctor_register'),
    path('api/check-username/', check_username, name='check_username'),
]