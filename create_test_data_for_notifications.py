#!/usr/bin/env python
import os
import sys
import django

# إعداد Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_platform.settings')
django.setup()

from django.contrib.auth import get_user_model
from patients.models import Patient, MedicalCase
from doctors.models import Doctor

User = get_user_model()

def create_test_data():
    print("🔍 Creating test data for notifications...")
    
    # البحث عن طبيب موجود
    try:
        doctor_user = User.objects.get(id=9)  # الطبيب المسجل دخول
        doctor = Doctor.objects.get(user=doctor_user)
        print(f"✅ Found doctor: {doctor.user.get_full_name()}")
    except (User.DoesNotExist, Doctor.DoesNotExist):
        print("❌ Doctor not found!")
        return
    
    # إنشاء مرضى تجريبيين
    test_patients_data = [
        {
            'username': 'patient_ahmed',
            'email': 'ahmed@test.com',
            'first_name': 'أحمد',
            'last_name': 'محمد علي',
            'phone': '01234567890',
            'age': 35,
            'gender': 'male'
        },
        {
            'username': 'patient_fatima',
            'email': 'fatima@test.com',
            'first_name': 'فاطمة',
            'last_name': 'أحمد حسن',
            'phone': '01234567891',
            'age': 28,
            'gender': 'female'
        },
        {
            'username': 'patient_mohammed',
            'email': 'mohammed@test.com',
            'first_name': 'محمد',
            'last_name': 'عبدالله سالم',
            'phone': '01234567892',
            'age': 42,
            'gender': 'male'
        },
        {
            'username': 'patient_nour',
            'email': 'nour@test.com',
            'first_name': 'نور الهدى',
            'last_name': 'محمود',
            'phone': '01234567893',
            'age': 25,
            'gender': 'female'
        },
        {
            'username': 'patient_abdulrahman',
            'email': 'abdulrahman@test.com',
            'first_name': 'عبدالرحمن',
            'last_name': 'يوسف',
            'phone': '01234567894',
            'age': 38,
            'gender': 'male'
        }
    ]
    
    created_patients = []
    
    for patient_data in test_patients_data:
        # إنشاء مستخدم للمريض
        user, created = User.objects.get_or_create(
            username=patient_data['username'],
            defaults={
                'email': patient_data['email'],
                'first_name': patient_data['first_name'],
                'last_name': patient_data['last_name'],
                'user_type': 'patient',
                'is_active': True,
            }
        )
        
        if created:
            user.set_password('testpass123')
            user.save()
            print(f"✅ Created user: {user.get_full_name()}")
        else:
            print(f"ℹ️ User already exists: {user.get_full_name()}")
        
        # إنشاء ملف المريض
        from datetime import date
        birth_year = date.today().year - patient_data['age']
        birth_date = date(birth_year, 1, 1)
        
        patient, created = Patient.objects.get_or_create(
            user=user,
            defaults={
                'emergency_contact': patient_data['phone'],
                'date_of_birth': birth_date,
                'gender': patient_data['gender'],
            }
        )
        
        if created:
            print(f"✅ Created patient: {patient.user.get_full_name()}")
        else:
            print(f"ℹ️ Patient already exists: {patient.user.get_full_name()}")
        
        created_patients.append(patient)
    
    # إنشاء حالات طبية للمرضى مع الطبيب
    case_titles = [
        'ألم في الصدر',
        'صداع نصفي مستمر',
        'آلام في المعدة',
        'ضيق في التنفس',
        'آلام في الظهر'
    ]
    
    case_descriptions = [
        'أعاني من ألم في الصدر منذ يومين، يزداد عند التنفس العميق',
        'صداع نصفي شديد يستمر لساعات طويلة مع غثيان',
        'آلام شديدة في المعدة بعد تناول الطعام',
        'أشعر بضيق في التنفس خاصة عند صعود السلالم',
        'آلام مزمنة في أسفل الظهر تؤثر على النوم'
    ]
    
    for i, patient in enumerate(created_patients):
        # إنشاء حالة طبية
        case, created = MedicalCase.objects.get_or_create(
            patient=patient,
            doctor=doctor,
            title=case_titles[i],
            defaults={
                'description': case_descriptions[i],
                'symptoms': f'الأعراض المرتبطة بـ {case_titles[i]}',
                'status': 'new',
                'priority': 'medium',
            }
        )
        
        if created:
            print(f"✅ Created case: {case.title} for {patient.user.get_full_name()}")
        else:
            print(f"ℹ️ Case already exists: {case.title} for {patient.user.get_full_name()}")
    
    print(f"\n🎉 Test data creation completed!")
    print(f"📊 Created {len(created_patients)} patients with medical cases")
    print(f"👨‍⚕️ All cases assigned to doctor: {doctor.user.get_full_name()}")
    
    # عرض ملخص
    total_cases = MedicalCase.objects.filter(doctor=doctor).count()
    print(f"📈 Total cases for this doctor: {total_cases}")

if __name__ == '__main__':
    create_test_data()