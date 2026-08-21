#!/usr/bin/env python
import os
import sys
import django

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_platform.settings')
django.setup()

from doctors.models import Doctor
from patients.models import Patient, MedicalCase

def create_test_data():
    # Get an approved doctor
    doctor = Doctor.objects.filter(status='approved').first()
    if not doctor:
        print("No approved doctor found")
        return
    
    print(f"Using doctor: {doctor.user.get_full_name()} ({doctor.user.username})")
    
    # Get a patient
    patient = Patient.objects.first()
    if not patient:
        print("No patient found")
        return
    
    print(f"Using patient: {patient.user.get_full_name()}")
    
    # Create some test cases
    cases_data = [
        {
            'title': 'صداع مستمر',
            'description': 'أعاني من صداع مستمر منذ أسبوع مع دوخة خفيفة',
            'symptoms': 'صداع، دوخة، تعب',
            'priority': 'medium',
            'status': 'new'
        },
        {
            'title': 'ألم في المعدة',
            'description': 'ألم في المعدة بعد تناول الطعام',
            'symptoms': 'ألم معدة، غثيان',
            'priority': 'high',
            'status': 'new'
        },
        {
            'title': 'حمى وسعال',
            'description': 'حمى مع سعال جاف منذ يومين',
            'symptoms': 'حمى، سعال، تعب',
            'priority': 'high',
            'status': 'new'
        }
    ]
    
    for case_data in cases_data:
        case = MedicalCase.objects.create(
            patient=patient,
            doctor=doctor,
            **case_data
        )
        print(f"Created case: {case.title}")
    
    print(f"Total cases for doctor: {MedicalCase.objects.filter(doctor=doctor).count()}")

if __name__ == '__main__':
    create_test_data()