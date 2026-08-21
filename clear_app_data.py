#!/usr/bin/env python
import subprocess
import time

def clear_app_data():
    print("🧹 مسح بيانات التطبيق...")
    
    try:
        # مسح بيانات التطبيق
        result = subprocess.run([
            "adb", "shell", "pm", "clear", "com.example.doctor_app"
        ], capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            print("✅ تم مسح بيانات التطبيق بنجاح")
        else:
            print(f"❌ فشل مسح البيانات: {result.stderr}")
            
        # إعادة تشغيل التطبيق
        print("🔄 إعادة تشغيل التطبيق...")
        subprocess.run([
            "adb", "shell", "am", "start", "-n", 
            "com.example.doctor_app/com.example.doctor_app.MainActivity"
        ], timeout=10)
        
        print("✅ تم إعادة تشغيل التطبيق")
        
    except subprocess.TimeoutExpired:
        print("❌ انتهت مهلة العملية")
    except Exception as e:
        print(f"❌ خطأ: {e}")

if __name__ == '__main__':
    clear_app_data()