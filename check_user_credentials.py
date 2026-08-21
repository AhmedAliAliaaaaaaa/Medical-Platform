#!/usr/bin/env python
import os
import sys
import django

# إعداد Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_platform.settings')
django.setup()

from accounts.models import CustomUser
from doctors.models import Doctor

def check_user_credentials():
    print("🔍 فحص بيانات المستخدمين...")
    print("=" * 50)
    
    # البحث عن الطبيب بـ User ID: 9
    try:
        user = CustomUser.objects.get(id=9)
        doctor = Doctor.objects.get(user=user)
        
        print(f"👨‍⚕️ الطبيب: {doctor.user.get_full_name()}")
        print(f"📧 البريد الإلكتروني: {user.email}")
        print(f"👤 اسم المستخدم: {user.username}")
        print(f"🆔 User ID: {user.id}")
        print(f"🏥 التخصص: {doctor.specialization}")
        print(f"✅ الحالة: {doctor.status}")
        print(f"🔐 هل المستخدم نشط: {user.is_active}")
        
        # محاولة تسجيل الدخول بكلمات مرور مختلفة
        passwords_to_try = ['123456789', '12345678', 'password', 'admin', user.username]
        
        print(f"\n🧪 اختبار كلمات المرور...")
        for password in passwords_to_try:
            if user.check_password(password):
                print(f"✅ كلمة المرور الصحيحة: {password}")
                return user.username, password
            else:
                print(f"❌ كلمة مرور خاطئة: {password}")
        
        print(f"\n⚠️ لم يتم العثور على كلمة المرور الصحيحة")
        print(f"💡 يمكنك تغيير كلمة المرور باستخدام:")
        print(f"   user.set_password('new_password')")
        print(f"   user.save()")
        
    except CustomUser.DoesNotExist:
        print("❌ لم يتم العثور على المستخدم بـ ID: 9")
    except Doctor.DoesNotExist:
        print("❌ لم يتم العثور على الطبيب للمستخدم بـ ID: 9")
    except Exception as e:
        print(f"❌ خطأ: {e}")

if __name__ == "__main__":
    check_user_credentials()