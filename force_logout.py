#!/usr/bin/env python
import subprocess
import time

def force_logout():
    print("🔄 إجبار تسجيل الخروج ومسح بيانات التطبيق...")
    
    try:
        # إيقاف التطبيق
        print("⏹️ إيقاف التطبيق...")
        subprocess.run(["adb", "shell", "am", "force-stop", "com.example.doctor_app"], 
                      capture_output=True, timeout=10)
        
        # مسح بيانات التطبيق
        print("🗑️ مسح جميع بيانات التطبيق...")
        result = subprocess.run(["adb", "shell", "pm", "clear", "com.example.doctor_app"], 
                               capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            print("✅ تم مسح جميع بيانات التطبيق بنجاح")
        else:
            print(f"⚠️ تحذير: {result.stderr}")
        
        # انتظار قليل
        time.sleep(3)
        
        # إعادة تشغيل التطبيق
        print("🚀 إعادة تشغيل التطبيق...")
        subprocess.run(["adb", "shell", "monkey", "-p", "com.example.doctor_app", "-c", 
                       "android.intent.category.LAUNCHER", "1"], 
                      capture_output=True, timeout=10)
        
        print("\n" + "="*50)
        print("✅ تم مسح بيانات التطبيق بنجاح!")
        print("📱 التطبيق سيفتح الآن بشاشة تسجيل الدخول")
        print("\n🎯 استخدم هذه البيانات لتسجيل الدخول كمريض:")
        print("   Username: patient_test")
        print("   Password: test123456")
        print("="*50)
        
    except subprocess.TimeoutExpired:
        print("❌ انتهت مهلة العملية")
    except Exception as e:
        print(f"❌ خطأ: {e}")

if __name__ == '__main__':
    force_logout()