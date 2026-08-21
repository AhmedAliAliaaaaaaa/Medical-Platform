#!/usr/bin/env python
import requests
import json
import subprocess
import time

def update_app_token():
    """تحديث Token في التطبيق"""
    
    # الحصول على Token جديد
    print("🔐 الحصول على Token جديد...")
    login_data = {
        'username': 'nor',
        'password': '123456789'
    }
    
    try:
        response = requests.post(
            'http://127.0.0.1:8000/api/auth/login/',
            data=login_data,
            headers={'Content-Type': 'application/x-www-form-urlencoded'}
        )
        
        if response.status_code == 200:
            data = response.json()
            access_token = data.get('access')
            refresh_token = data.get('refresh')
            
            print(f"✅ تم الحصول على Token جديد!")
            print(f"🔑 Access Token: {access_token[:50]}...")
            
            # اختبار Token
            test_response = requests.get(
                'http://127.0.0.1:8000/api/doctor/my-patients/',
                headers={'Authorization': f'Bearer {access_token}'}
            )
            
            print(f"📊 Test Status: {test_response.status_code}")
            if test_response.status_code == 200:
                patients_data = test_response.json()
                patients = patients_data.get('patients', [])
                print(f"✅ API يعمل! عدد المرضى: {len(patients)}")
                
                # عرض أسماء المرضى
                for i, patient in enumerate(patients[:5], 1):
                    name = patient.get('name', 'بدون اسم')
                    cases_count = patient.get('cases_count', 0)
                    print(f"   {i}. {name} ({cases_count} حالة)")
                
                if len(patients) > 5:
                    print(f"   ... و {len(patients) - 5} مريض آخر")
                
                print(f"\n💡 يجب تحديث Token في التطبيق:")
                print(f"   - افتح التطبيق")
                print(f"   - اذهب إلى تسجيل الدخول")
                print(f"   - سجل دخول بـ:")
                print(f"     Username: nor")
                print(f"     Password: 123456789")
                
                return access_token
            else:
                print(f"❌ فشل اختبار API: {test_response.text}")
                return None
        else:
            print(f"❌ فشل تسجيل الدخول: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ خطأ: {e}")
        return None

if __name__ == "__main__":
    update_app_token()