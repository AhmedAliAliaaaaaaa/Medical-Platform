#!/usr/bin/env python
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_platform.settings')
django.setup()

from doctors.models import Doctor

def check_doctor_prices():
    print("=== فحص أسعار الاستشارات في قاعدة البيانات ===\n")
    
    # Get all approved doctors
    doctors = Doctor.objects.filter(status='approved')[:5]  # أول 5 أطباء
    
    if not doctors:
        print("❌ لا يوجد أطباء معتمدون في قاعدة البيانات")
        return
    
    print(f"📊 عدد الأطباء المعتمدين: {Doctor.objects.filter(status='approved').count()}")
    print(f"🔍 فحص أول {len(doctors)} أطباء:\n")
    
    for i, doctor in enumerate(doctors, 1):
        print(f"👨‍⚕️ الطبيب {i}: {doctor.user.get_full_name()} ({doctor.user.username})")
        print(f"   التخصص: {doctor.specialization}")
        
        # فحص جميع الحقول المتعلقة بالأسعار
        price_fields = [
            'consultation_fee',
            'regular_consultation_price', 
            'emergency_consultation_price',
            'follow_up_consultation_price',
            'emergency_fee',
            'follow_up_fee',
            'currency',
            'currency_type',
            'accepts_insurance'
        ]
        
        print("   💰 الأسعار:")
        has_prices = False
        for field in price_fields:
            if hasattr(doctor, field):
                value = getattr(doctor, field, None)
                if value is not None and value != '':
                    print(f"      ✅ {field}: {value}")
                    has_prices = True
                else:
                    print(f"      ❌ {field}: غير محدد")
            else:
                print(f"      ⚠️ {field}: الحقل غير موجود في النموذج")
        
        if not has_prices:
            print("      🚨 لا توجد أسعار محددة لهذا الطبيب")
        
        print("-" * 50)
    
    # فحص نموذج Doctor لمعرفة الحقول المتاحة
    print("\n📋 جميع حقول نموذج Doctor:")
    doctor_sample = doctors.first()
    for field in doctor_sample._meta.fields:
        field_name = field.name
        field_value = getattr(doctor_sample, field_name, None)
        field_type = field.__class__.__name__
        print(f"   {field_name} ({field_type}): {field_value}")

if __name__ == '__main__':
    check_doctor_prices()