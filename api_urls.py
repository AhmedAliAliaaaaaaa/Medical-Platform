from django.urls import path, include
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import (
    TokenObtainPairView,
    TokenRefreshView,
)

# Import API views
from accounts.api_views import (
    CustomTokenObtainPairView,
    DoctorRegistrationView,
    PatientRegistrationView,
    UserProfileView,
    DoctorProfileView,
    doctor_register_with_files,
)
from doctors.api_views import (
    available_doctors,
)
from core.views import api_translate

router = DefaultRouter()

# Simple health check
from django.http import JsonResponse
from django.views.decorators.http import require_GET

@require_GET
def health_view(request):
    return JsonResponse({'status': 'ok'})

urlpatterns = [
    # Health
    path('health/', health_view, name='health'),

    # Authentication
    path('auth/login/', CustomTokenObtainPairView.as_view(), name='token_obtain_pair'),
    path('auth/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('auth/register/doctor/', DoctorRegistrationView.as_view(), name='doctor_register'),
    path('auth/doctor-register/', doctor_register_with_files, name='doctor_register_files'),
    path('auth/patient-register/', PatientRegistrationView.as_view(), name='patient_register'),
    
    # User Profile
    path('profile/', UserProfileView.as_view(), name='user_profile'),
    path('profile/doctor/', DoctorProfileView.as_view(), name='doctor_profile'),
    
    # Available doctors for patients
    path('doctors/available/', available_doctors, name='available_doctors'),

    # Translation API used by the Flutter application
    path('utils/translate/', api_translate, name='translate'),
    
    # Patient APIs
    path('patient/', include('patients.api_urls')),
    
    # Doctor APIs
    path('doctor/', include('doctors.api_urls')),

    # Admin APIs (for admin actions like uploads)
    path('admin/', include('admin_panel.api_urls')),

    # Router URLs
    path('', include(router.urls)),
]