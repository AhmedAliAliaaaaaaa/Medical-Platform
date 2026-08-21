#!/usr/bin/env python
import requests
import json

def create_patient_user():
    print("👤 إنشاء مستخدم مريض جديد...")
    
    base_url = "http://192.168.0.126:8000"
    api_url = f"{base_url}/api"
    
    # بيانات المريض الجديد
    patient_data = {
        "first_name": "أحمد",
        "last_name": "محمد",
        "email": "patient_test_new@example.com",
        "password": "test123456",
        "phone": "1234567890",
        "age": 30,
        "gender": "male"
    }
    
    try:
        # محاولة تسجيل مريض جديد
        register_url = f"{api_url}/auth/patient-register/"
        register_response = requests.post(register_url, json=patient_data)
        
        print(f"Register URL: {register_url}")
        print(f"Register Status: {register_response.status_code}")
        
        if register_response.status_code == 201:
            print("✅ تم إنشاء المريض بنجاح")
            register_data = register_response.json()
            print(f"Patient ID: {register_data.get('user', {}).get('id')}")
            
            # تسجيل الدخول بالمريض الجديد
            print("\n🔐 تسجيل الدخول بالمريض الجديد...")
            login_url = f"{api_url}/auth/login/"
            login_data = {
                "username": patient_data["email"],
                "password": patient_data["password"]
            }
            
            login_response = requests.post(login_url, json=login_data)
            print(f"Login Status: {login_response.status_code}")
            
            if login_response.status_code == 200:
                login_result = login_response.json()
                token = login_result.get('access')
                user_type = login_result.get('user', {}).get('user_type')
                
                print(f"✅ تم تسجيل الدخول بنجاح")
                print(f"User Type: {user_type}")
                print(f"Token: {token[:50]}...")
                
                # اختبار patient dashboard
                print(f"\n📊 اختبار Patient Dashboard...")
                headers = {
                    "Authorization": f"Bearer {token}",
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                }
                
                dashboard_url = f"{api_url}/patient/dashboard/"
                dashboard_response = requests.get(dashboard_url, headers=headers)
                print(f"Dashboard Status: {dashboard_response.status_code}")
                
                if dashboard_response.status_code == 200:
                    dashboard_data = dashboard_response.json()
                    print(f"✅ Patient Dashboard يعمل بشكل مثالي!")
                    print(f"   Total Cases: {dashboard_data.get('total_cases', 0)}")
                    print(f"   Unread Notifications: {dashboard_data.get('unread_notifications', 0)}")
                else:
                    print(f"❌ Dashboard فشل: {dashboard_response.text}")
                
                print(f"\n🎯 استخدم هذه البيانات لتسجيل الدخول:")
                print(f"   Email: {patient_data['email']}")
                print(f"   Password: {patient_data['password']}")
                
            else:
                print(f"❌ فشل تسجيل الدخول: {login_response.text}")
                
        elif register_response.status_code == 400:
            error_data = register_response.json()
            if "already exists" in str(error_data):
                print("⚠️ المستخدم موجود بالفعل، محاولة تسجيل الدخول...")
                
                # تسجيل الدخول بالمستخدم الموجود
                login_url = f"{api_url}/auth/login/"
                login_data = {
                    "username": patient_data["email"],
                    "password": patient_data["password"]
                }
                
                login_response = requests.post(login_url, json=login_data)
                if login_response.status_code == 200:
                    print("✅ تم تسجيل الدخول بالمستخدم الموجود")
                    login_result = login_response.json()
                    user_type = login_result.get('user', {}).get('user_type')
                    print(f"User Type: {user_type}")
                else:
                    print(f"❌ فشل تسجيل الدخول: {login_response.text}")
            else:
                print(f"❌ فشل إنشاء المريض: {error_data}")
        else:
            print(f"❌ فشل إنشاء المريض: Status {register_response.status_code}")
            print(f"Response: {register_response.text}")
            
    except Exception as e:
        print(f"❌ خطأ: {e}")

if __name__ == '__main__':
    create_patient_user()