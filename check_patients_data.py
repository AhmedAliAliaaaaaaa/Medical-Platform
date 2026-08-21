#!/usr/bin/env python
import os
import sys
import django

# إعداد Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_platform.settings')
django.setup()

from doctors.models import Doctor
from patients.models import Patient, MedicalCase
from django.contrib.auth.models import User

def check_patients_data():
    print("🔍 فحص بيانات المرضى والحالات الطبية...")
    print("=" * 50)
    
    # فحص الأطباء
    doctors = Doctor.objects.all()
    print(f"📊 عدد الأطباء في النظام: {doctors.count()}")
    
    for doctor in doctors:
        print(f"👨‍⚕️ الطبيب: {doctor.user.get_full_name()} (ID: {doctor.id})")
        print(f"   - المستخدم ID: {doctor.user.id}")
        print(f"   - التخصص: {doctor.specialization}")
        print(f"   - الحالة: {doctor.status}")
        
        # فحص الحالات الطبية لهذا الطبيب
        cases = MedicalCase.objects.filter(doctor=doctor)
        print(f"   - عدد الحالات الطبية: {cases.count()}")
        
        if cases.exists():
            print("   📋 الحالات الطبية:")
            for case in cases[:5]:  # أول 5 حالات فقط
                print(f"      • {case.title} - المريض: {case.patient.user.get_full_name()}")
                print(f"        الحالة: {case.status} | تاريخ الإنشاء: {case.created_at.strftime('%Y-%m-%d')}")
        
        # فحص المرضى الذين لديهم حالات مع هذا الطبيب
        patients = Patient.objects.filter(medical_cases__doctor=doctor).distinct()
        print(f"   - عدد المرضى المرتبطين: {patients.count()}")
        
        if patients.exists():
            print("   👥 المرضى:")
            for patient in patients[:5]:  # أول 5 مرضى فقط
                cases_count = MedicalCase.objects.filter(doctor=doctor, patient=patient).count()
                print(f"      • {patient.user.get_full_name()} (ID: {patient.id}) - {cases_count} حالة")
        
        print("-" * 30)
    
    # فحص إجمالي الحالات الطبية
    total_cases = MedicalCase.objects.all().count()
    print(f"📊 إجمالي الحالات الطبية في النظام: {total_cases}")
    
    # فحص إجمالي المرضى
    total_patients = Patient.objects.all().count()
    print(f"📊 إجمالي المرضى في النظام: {total_patients}")
    
    print("=" * 50)
    print("✅ انتهى فحص البيانات")

if __name__ == "__main__":
    check_patients_data()