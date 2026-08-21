#!/usr/bin/env python
import subprocess
import time

def clear_flutter_data():
    print("🧹 مسح بيانات Flutter...")
    
    try:
        # إيقاف التطبيق
        print("⏹️ إيقاف التطبيق...")
        subprocess.run(["adb", "shell", "am", "force-stop", "com.example.doctor_app"], 
                      capture_output=True, timeout=10)
        
        # مسح بيانات التطبيق
        print("🗑️ مسح بيانات التطبيق...")
        result = subprocess.run(["adb", "shell", "pm", "clear", "com.example.doctor_app"], 
                               capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            print("✅ تم مسح بيانات التطبيق بنجاح")
        else:
            print(f"⚠️ تحذير: {result.stderr}")
        
        # انتظار قليل
        time.sleep(2)
        
        # إعادة تشغيل التطبيق
        print("🚀 إعادة تشغيل التطبيق...")
        subprocess.run(["adb", "shell", "monkey", "-p", "com.example.doctor_app", "-c", 
                       "android.intent.category.LAUNCHER", "1"], 
                      capture_output=True, timeout=10)
        
        print("✅ تم إعادة تشغيل التطبيق")
        print("📱 يرجى فتح التطبيق يدوياً إذا لم يفتح تلقائياً")
        
    except subprocess.TimeoutExpired:
        print("❌ انتهت مهلة العملية")
    except Exception as e:
        print(f"❌ خطأ: {e}")

if __name__ == '__main__':
    clear_flutter_data()