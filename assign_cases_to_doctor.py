#!/usr/bin/env python
"""
Assign some cases to the test doctor
"""
import os
import sys
import django

# Add the project directory to the Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Set up Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_platform.settings')
django.setup()

from patients.models import MedicalCase
from doctors.models import Doctor
from accounts.models import CustomUser

def assign_cases():
    """Assign some unassigned cases to test doctor"""
    
    try:
        # Get test doctor
        test_doctor = Doctor.objects.get(user__email="testdoctor@example.com")
        print(f"✅ وجد الطبيب: {test_doctor.user.first_name} {test_doctor.user.last_name}")
        
        # Get unassigned cases
        unassigned_cases = MedicalCase.objects.filter(doctor__isnull=True)
        print(f"📋 الحالات غير المخصصة: {unassigned_cases.count()}")
        
        if unassigned_cases.exists():
            # Assign first 2 cases to test doctor
            cases_to_assign = unassigned_cases[:2]
            
            for case in cases_to_assign:
                case.doctor = test_doctor
                case.save()
                print(f"   ✅ تم تخصيص الحالة: {case.title} (ID: {case.id})")
            
            print(f"\n🎉 تم تخصيص {len(cases_to_assign)} حالة للطبيب التجريبي")
        else:
            print("❌ لا توجد حالات غير مخصصة")
            
        # Show doctor's cases
        doctor_cases = MedicalCase.objects.filter(doctor=test_doctor)
        print(f"\n📊 إجمالي حالات الطبيب: {doctor_cases.count()}")
        
        for case in doctor_cases:
            print(f"   - {case.title} ({case.get_status_display()})")
            
    except Doctor.DoesNotExist:
        print("❌ الطبيب التجريبي غير موجود")
    except Exception as e:
        print(f"❌ خطأ: {e}")

def assign_to_main_doctor():
    """Also assign some cases to the main doctor"""
    
    try:
        # Get main doctor
        main_doctor = Doctor.objects.get(user__email="doctor@test.com")
        print(f"\n✅ وجد الطبيب الرئيسي: {main_doctor.user.first_name} {main_doctor.user.last_name}")
        
        # Get unassigned cases
        unassigned_cases = MedicalCase.objects.filter(doctor__isnull=True)
        
        if unassigned_cases.exists():
            # Assign remaining cases to main doctor
            cases_to_assign = unassigned_cases[:2]
            
            for case in cases_to_assign:
                case.doctor = main_doctor
                case.save()
                print(f"   ✅ تم تخصيص الحالة: {case.title} (ID: {case.id})")
            
            print(f"\n🎉 تم تخصيص {len(cases_to_assign)} حالة للطبيب الرئيسي")
        
        # Show doctor's cases
        doctor_cases = MedicalCase.objects.filter(doctor=main_doctor)
        print(f"\n📊 إجمالي حالات الطبيب الرئيسي: {doctor_cases.count()}")
        
    except Doctor.DoesNotExist:
        print("❌ الطبيب الرئيسي غير موجود")
    except Exception as e:
        print(f"❌ خطأ: {e}")

if __name__ == "__main__":
    print("🔄 تخصيص الحالات للأطباء التجريبيين")
    print("=" * 50)
    
    assign_cases()
    assign_to_main_doctor()
    
    print(f"\n✅ تم الانتهاء من تخصيص الحالات")
    print(f"🧪 يمكنك الآن اختبار API الحالات")