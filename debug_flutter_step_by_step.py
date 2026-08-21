#!/usr/bin/env python
import requests
import json

def debug_flutter_app():
    print("🔍 تشخيص مشكلة التطبيق خطوة بخطوة...")
    
    base_url = "http://192.168.0.126:8000"
    api_url = f"{base_url}/api"
    
    # خطوة 1: تسجيل الدخول
    print("\n1️⃣ تسجيل الدخول...")
    login_url = f"{api_url}/auth/login/"
    login_data = {
        "username": "patient_test",
        "password": "test123456"
    }
    
    try:
        login_response = requests.post(login_url, json=login_data)
        print(f"Login URL: {login_url}")
        print(f"Login Status: {login_response.status_code}")
        
        if login_response.status_code != 200:
            print(f"❌ فشل تسجيل الدخول: {login_response.text}")
            return
            
        login_data = login_response.json()
        token = login_data.get('access')
        user_type = login_data.get('user', {}).get('user_type')
        
        print(f"✅ تم تسجيل الدخول بنجاح")
        print(f"User Type: {user_type}")
        print(f"Token: {token[:50]}...")
        
        # خطوة 2: اختبار getUserProfile (كما يفعل SplashScreen)
        print(f"\n2️⃣ اختبار getUserProfile...")
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
            "Accept": "application/json"
        }
        
        profile_url = f"{api_url}/profile/"
        profile_response = requests.get(profile_url, headers=headers)
        print(f"Profile URL: {profile_url}")
        print(f"Profile Status: {profile_response.status_code}")
        
        if profile_response.status_code == 200:
            profile_data = profile_response.json()
            print(f"✅ Profile يعمل بشكل صحيح")
            print(f"   User Type: {profile_data.get('user', {}).get('user_type')}")
        else:
            print(f"❌ Profile فشل: {profile_response.text}")
            return
        
        # خطوة 3: اختبار Patient Dashboard (كما يفعل ProfessionalPatientDashboard)
        print(f"\n3️⃣ اختبار Patient Dashboard...")
        dashboard_url = f"{api_url}/patient/dashboard/"
        dashboard_response = requests.get(dashboard_url, headers=headers)
        print(f"Dashboard URL: {dashboard_url}")
        print(f"Dashboard Status: {dashboard_response.status_code}")
        
        if dashboard_response.status_code == 200:
            dashboard_data = dashboard_response.json()
            print(f"✅ Dashboard يعمل بشكل صحيح")
            print(f"   Total Cases: {dashboard_data.get('total_cases', 0)}")
            print(f"   Pending Cases: {dashboard_data.get('pending_cases', 0)}")
            print(f"   Answered Cases: {dashboard_data.get('answered_cases', 0)}")
            print(f"   Unread Notifications: {dashboard_data.get('unread_notifications', 0)}")
            print(f"   Recent Cases: {len(dashboard_data.get('recent_cases', []))}")
            print(f"   Recent Notifications: {len(dashboard_data.get('recent_notifications', []))}")
        elif dashboard_response.status_code == 401:
            print(f"❌ Dashboard: Unauthorized - مشكلة في التوكن")
            print(f"   Response: {dashboard_response.text}")
        elif dashboard_response.status_code == 404:
            print(f"❌ Dashboard: Not Found - الـ endpoint غير موجود")
            print(f"   Response: {dashboard_response.text}")
        else:
            print(f"❌ Dashboard فشل: Status {dashboard_response.status_code}")
            print(f"   Response: {dashboard_response.text}")
        
        # خطوة 4: اختبار Notifications
        print(f"\n4️⃣ اختبار Notifications...")
        notifications_url = f"{api_url}/patient/notifications/"
        notifications_response = requests.get(notifications_url, headers=headers)
        print(f"Notifications URL: {notifications_url}")
        print(f"Notifications Status: {notifications_response.status_code}")
        
        if notifications_response.status_code == 200:
            notifications_data = notifications_response.json()
            print(f"✅ Notifications يعمل بشكل صحيح")
            print(f"   Count: {notifications_data.get('count', 0)}")
        else:
            print(f"❌ Notifications فشل: {notifications_response.text}")
        
        # خطوة 5: اختبار Cases
        print(f"\n5️⃣ اختبار Cases...")
        cases_url = f"{api_url}/patient/cases/"
        cases_response = requests.get(cases_url, headers=headers)
        print(f"Cases URL: {cases_url}")
        print(f"Cases Status: {cases_response.status_code}")
        
        if cases_response.status_code == 200:
            cases_data = cases_response.json()
            print(f"✅ Cases يعمل بشكل صحيح")
            print(f"   Count: {cases_data.get('count', 0)}")
        else:
            print(f"❌ Cases فشل: {cases_response.text}")
        
        print(f"\n✅ جميع الاختبارات مكتملة!")
        
    except Exception as e:
        print(f"❌ خطأ عام: {e}")

if __name__ == '__main__':
    debug_flutter_app()