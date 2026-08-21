#!/usr/bin/env python
import os
import sys
import django

# إعداد Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_platform.settings')
django.setup()

from accounts.models import CustomUser
from doctors.models import Doctor

def reset_password():
    try:
        user = CustomUser.objects.get(id=9)
        doctor = Doctor.objects.get(user=user)
        
        print(f"👨‍⚕️ الطبيب: {doctor.user.get_full_name()}")
        print(f"👤 اسم المستخدم: {user.username}")
        
        # تغيير كلمة المرور
        new_password = '123456789'
        user.set_password(new_password)
        user.save()
        
        print(f"✅ تم تغيير كلمة المرور إلى: {new_password}")
        
        # اختبار كلمة المرور الجديدة
        if user.check_password(new_password):
            print(f"✅ تم التأكد من كلمة المرور الجديدة")
        else:
            print(f"❌ فشل في التأكد من كلمة المرور الجديدة")
            
    except Exception as e:
        print(f"❌ خطأ: {e}")

if __name__ == "__main__":
    reset_password()