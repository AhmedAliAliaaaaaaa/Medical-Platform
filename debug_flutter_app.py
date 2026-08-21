#!/usr/bin/env python
import requests
import json

def simulate_flutter_app():
    print("🔍 محاكاة تطبيق Flutter...")
    
    # خطوة 1: تسجيل الدخول
    print("\n1️⃣ تسجيل الدخول...")
    login_url = "http://192.168.0.126:8000/api/auth/login/"
    login_data = {
        "username": "patient_test",
        "password": "test123456"
    }
    
    try:
        login_response = requests.post(login_url, json=login_data)
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
        
        # خطوة 2: اختبار جميع endpoints التي يستخدمها التطبيق
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }
        
        endpoints_to_test = [
            ("/api/profile/", "Profile"),
            ("/api/patient/dashboard/", "Patient Dashboard"),
            ("/api/patient/notifications/", "Notifications"),
            ("/api/patient/cases/", "Cases"),
        ]
        
        for endpoint, name in endpoints_to_test:
            print(f"\n2️⃣ اختبار {name}...")
            url = f"http://192.168.0.126:8000{endpoint}"
            
            try:
                response = requests.get(url, headers=headers, timeout=10)
                print(f"{name} Status: {response.status_code}")
                
                if response.status_code == 200:
                    data = response.json()
                    print(f"✅ {name} يعمل بشكل صحيح")
                    if endpoint == "/api/patient/dashboard/":
                        print(f"   - Total Cases: {data.get('total_cases', 0)}")
                        print(f"   - Unread Notifications: {data.get('unread_notifications', 0)}")
                elif response.status_code == 401:
                    print(f"❌ {name}: Unauthorized - مشكلة في التوكن")
                elif response.status_code == 404:
                    print(f"❌ {name}: Not Found - الـ endpoint غير موجود")
                else:
                    print(f"❌ {name}: خطأ {response.status_code}")
                    print(f"   Response: {response.text[:200]}")
                    
            except requests.exceptions.Timeout:
                print(f"❌ {name}: Timeout")
            except Exception as e:
                print(f"❌ {name}: خطأ {e}")
        
        print(f"\n3️⃣ اختبار تحديث التوكن...")
        # محاولة تحديث التوكن
        refresh_token = login_data.get('refresh')
        if refresh_token:
            refresh_url = "http://192.168.0.126:8000/api/auth/token/refresh/"
            refresh_data = {"refresh": refresh_token}
            
            refresh_response = requests.post(refresh_url, json=refresh_data)
            print(f"Token Refresh Status: {refresh_response.status_code}")
            
            if refresh_response.status_code == 200:
                print("✅ تحديث التوكن يعمل بشكل صحيح")
            else:
                print(f"❌ فشل تحديث التوكن: {refresh_response.text}")
        
    except Exception as e:
        print(f"❌ خطأ عام: {e}")

if __name__ == '__main__':
    simulate_flutter_app()