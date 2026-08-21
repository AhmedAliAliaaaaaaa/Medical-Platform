#!/usr/bin/env python
"""
إنشاء إشعارات تجريبية للطبيب لاختبار النظام
"""
import os
import sys
import django
from datetime import datetime, timedelta

# إعداد Django
sys.path.append(os.path.dirname(os.path.abspath(__file__)))
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'medical_platform.settings')
django.setup()

from doctors.models import Doctor, DoctorNotification
from accounts.models import CustomUser

def create_doctor_notifications():
    """إنشاء إشعارات تجريبية للطبيب"""
    try:
        # البحث عن طبيب
        doctor = Doctor.objects.filter(status='approved').first()
        if not doctor:
            print("❌ لا يوجد أطباء مقبولين في النظام")
            return
        
        print(f"📋 إنشاء إشعارات للطبيب: د. {doctor.user.get_full_name()}")
        
        # حذف الإشعارات القديمة
        DoctorNotification.objects.filter(doctor=doctor).delete()
        print("🗑️ تم حذف الإشعارات القديمة")
        
        # إنشاء إشعارات جديدة
        notifications = [
            {
                'title': 'رسالة من الإدارة',
                'message': 'مرحباً د. {}, نرحب بك في منصتنا الطبية. نتمنى لك تجربة ممتعة ومفيدة.'.format(doctor.user.first_name),
                'notification_type': 'admin',
                'is_read': False,
                'created_at': datetime.now() - timedelta(hours=1)
            },
            {
                'title': 'تحديث في النظام',
                'message': 'تم تحديث النظام بميزات جديدة. يمكنك الآن إرسال إشعارات للمرضى مباشرة من لوحة التحكم.',
                'notification_type': 'admin',
                'is_read': False,
                'created_at': datetime.now() - timedelta(hours=3)
            },
            {
                'title': 'تذكير مهم',
                'message': 'يرجى مراجعة الحالات المعلقة والرد عليها في أقرب وقت ممكن لضمان جودة الخدمة.',
                'notification_type': 'admin',
                'is_read': True,
                'created_at': datetime.now() - timedelta(days=1)
            },
            {
                'title': 'إشعار عام',
                'message': 'سيتم إجراء صيانة دورية للنظام يوم الجمعة من الساعة 2:00 إلى 4:00 صباحاً.',
                'notification_type': 'general',
                'is_read': False,
                'created_at': datetime.now() - timedelta(hours=6)
            },
            {
                'title': 'تهنئة',
                'message': 'تهانينا! لقد حصلت على تقييم 5 نجوم من أحد المرضى. استمر في العمل الممتاز.',
                'notification_type': 'general',
                'is_read': False,
                'created_at': datetime.now() - timedelta(minutes=30)
            }
        ]
        
        # إنشاء الإشعارات
        created_count = 0
        for notif_data in notifications:
            notification = DoctorNotification.objects.create(
                doctor=doctor,
                title=notif_data['title'],
                message=notif_data['message'],
                notification_type=notif_data['notification_type'],
                is_read=notif_data['is_read']
            )
            # تحديث تاريخ الإنشاء
            notification.created_at = notif_data['created_at']
            notification.save()
            created_count += 1
            print(f"✅ تم إنشاء إشعار: {notif_data['title']}")
        
        # إحصائيات
        total_notifications = DoctorNotification.objects.filter(doctor=doctor).count()
        unread_notifications = DoctorNotification.objects.filter(doctor=doctor, is_read=False).count()
        
        print(f"\n📊 الإحصائيات:")
        print(f"   📝 إجمالي الإشعارات: {total_notifications}")
        print(f"   🔔 الإشعارات غير المقروءة: {unread_notifications}")
        print(f"   ✅ الإشعارات المقروءة: {total_notifications - unread_notifications}")
        
        print(f"\n🎉 تم إنشاء {created_count} إشعار بنجاح!")
        
    except Exception as e:
        print(f"❌ خطأ في إنشاء الإشعارات: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    create_doctor_notifications()