#!/usr/bin/env python3
"""
اختبار بسيط لإرسال بيانات تسجيل طبيب مع الأسعار
"""

import requests
import json

# بيانات الاختبار
data = {
    'full_name': 'د. سارة أحمد',
    'username': 'sara_test',
    'email': 'sara@test.com',
    'password': 'testpass123',
    'phone': '+966501234568',
    'specialization': 'cardiology',
    'country': 'السعودية',
    'experience_years': '8',
    'license_number': 'LIC789012',
    'regular_consultation_price': '250.00',
    'emergency_consultation_price': '500.00',
    'follow_up_consultation_price': '125.00',
    'currency': 'ريال سعودي',
    'accepts_insurance': 'true',
    'bio': 'طبيبة قلب بخبرة 8 سنوات'
}

# إنشاء ملف وهمي للترخيص
files = {
    'license_image': ('license.jpg', b'fake image data', 'image/jpeg')
}

try:
    response = requests.post(
        'http://localhost:8000/api/auth/doctor-register/',
        data=data,
        files=files,
        timeout=30
    )
    
    print(f"Status Code: {response.status_code}")
    print(f"Response: {response.text}")
    
    if response.status_code == 201:
        print("✅ تم التسجيل بنجاح!")
    else:
        print("❌ فشل التسجيل")
        
except Exception as e:
    print(f"خطأ في الاتصال: {e}")