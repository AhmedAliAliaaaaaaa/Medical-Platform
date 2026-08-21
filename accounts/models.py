from django.contrib.auth.models import AbstractUser
from django.db import models
from django.utils.translation import gettext as _

class CustomUser(AbstractUser):
    USER_TYPE_CHOICES = (
        ('patient', 'مريض'),
        ('doctor', 'طبيب'),
        ('admin', 'مشرف'),
    )
    
    user_type = models.CharField(max_length=10, choices=USER_TYPE_CHOICES, default='patient')
    phone_number = models.CharField(max_length=15, blank=True, null=True)
    profile_picture = models.ImageField(upload_to='profile_pics/', blank=True, null=True)
    is_verified = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.username} - {self.get_user_type_display()}"
    
    @property
    def password_display(self):
        """عرض كلمة المرور للمشرفين (مشفرة)"""
        return "••••••••"  # Always return masked password for security
