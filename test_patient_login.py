#!/usr/bin/env python
import requests
import json

def test_patient_login():
    print("🔐 اختبار تسجيل دخول المريض...")
    
    base_url = "http://192.168.0.126:8000"
    api_url = f"{base_url}/api"
    
    # تسجيل الدخول بمستخدم المريض
    login_url = f"{api_url}/auth/login/"
    login_data = {
        "username": "patient_test",
        "password": "test123456"
    }
    
    try:
        login_response = requests.post(login_url, json=login_data)
        print(f"Login Status: {login_response.status_code}")
        
        if login_response.status_code == 200:
            login_result = login_response.json()
            token = login_result.get('access')
            user_type = login_result.get('user', {}).get('user_type')
            user_id = login_result.get('user', {}).get('id')
            
            print(f"✅ تم تسجيل الدخول بنجاح")
            print(f"User ID: {user_id}")
            print(f"User Type: {user_type}")
            print(f"Token: {token[:50]}...")
            
            if user_type == 'patient':
                print(f"✅ المستخدم مريض - يمكن اختبار Patient Dashboard")
                
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
                    print(f"   Pending Cases: {dashboard_data.get('pending_cases', 0)}")
                    print(f"   Answered Cases: {dashboard_data.get('answered_cases', 0)}")
                    print(f"   Unread Notifications: {dashboard_data.get('unread_notifications', 0)}")
                    print(f"   Recent Cases: {len(dashboard_data.get('recent_cases', []))}")
                    print(f"   Recent Notifications: {len(dashboard_data.get('recent_notifications', []))}")
                    
                    print(f"\n🎯 استخدم هذه البيانات لتسجيل الدخول في التطبيق:")
                    print(f"   Username: patient_test")
                    print(f"   Password: test123456")
                    
                else:
                    print(f"❌ Dashboard فشل: {dashboard_response.text}")
            else:
                print(f"❌ المستخدم ليس مريض، نوعه: {user_type}")
                
        else:
            print(f"❌ فشل تسجيل الدخول: {login_response.text}")
            
    except Exception as e:
        print(f"❌ خطأ: {e}")

if __name__ == '__main__':
    test_patient_login()