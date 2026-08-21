#!/usr/bin/env python
import requests
import json

def get_new_token():
    """الحصول على token جديد للطبيب"""
    
    # بيانات تسجيل الدخول للطبيب (User ID: 9)
    login_data = {
        'username': 'nor',  # اسم المستخدم الصحيح
        'password': '123456789'  # كلمة المرور
    }
    
    try:
        # تسجيل الدخول
        print("🔐 محاولة تسجيل الدخول...")
        response = requests.post(
            'http://127.0.0.1:8000/api/auth/login/',
            data=login_data,
            headers={'Content-Type': 'application/x-www-form-urlencoded'}
        )
        
        print(f"📊 Status Code: {response.status_code}")
        print(f"📊 Response: {response.text}")
        
        if response.status_code == 200:
            data = response.json()
            access_token = data.get('access')
            refresh_token = data.get('refresh')
            
            print(f"✅ تم الحصول على Token جديد!")
            print(f"🔑 Access Token: {access_token}")
            print(f"🔄 Refresh Token: {refresh_token}")
            
            # اختبار Token الجديد
            print("\n🧪 اختبار Token الجديد...")
            test_response = requests.get(
                'http://127.0.0.1:8000/api/doctor/my-patients/',
                headers={'Authorization': f'Bearer {access_token}'}
            )
            
            print(f"📊 Test Status Code: {test_response.status_code}")
            print(f"📊 Test Response: {test_response.text}")
            
            return access_token
        else:
            print(f"❌ فشل تسجيل الدخول: {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ خطأ: {e}")
        return None

if __name__ == "__main__":
    get_new_token()