from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import Doctor
from admin_panel.models import AdminNotification

@receiver(post_save, sender=Doctor)
def create_doctor_registration_notification(sender, instance, created, **kwargs):
    """إنشاء إشعار للإدارة عند تسجيل طبيب جديد"""
    if created:
        AdminNotification.objects.create(
            title=f'طلب تسجيل طبيب جديد - د. {instance.user.username}',
            message=f'تم تقديم طلب تسجيل جديد من الطبيب {instance.user.username} في تخصص {instance.get_specialization_display()}. يرجى مراجعة الطلب والموافقة عليه أو رفضه.',
            notification_type='doctor_registration',
            related_doctor=instance,
            is_active=True,
            is_read=False
        )