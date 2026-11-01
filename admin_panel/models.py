from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class AdminNotification(models.Model):
    NOTIFICATION_TYPES = (
        ('doctor_registration', 'تسجيل طبيب جديد'),
        ('doctor_response', 'رد طبيب جديد'),
        ('doctor_message', 'رسالة من طبيب'),
        ('patient_complaint', 'شكوى مريض'),
        ('doctor_complaint', 'شكوى طبيب'),
        ('system', 'إشعار نظام'),
        ('general', 'عام'),
    )
    
    title = models.CharField(max_length=200)
    message = models.TextField()
    notification_type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES, default='general')
    is_read = models.BooleanField(default=False)
    
    # علاقات اختيارية
    related_doctor = models.ForeignKey('doctors.Doctor', on_delete=models.CASCADE, null=True, blank=True)
    related_patient = models.ForeignKey('patients.Patient', on_delete=models.CASCADE, null=True, blank=True)
    related_case = models.ForeignKey('patients.MedicalCase', on_delete=models.CASCADE, null=True, blank=True)
    related_response = models.ForeignKey('patients.DoctorResponse', on_delete=models.CASCADE, null=True, blank=True)
    
    created_by = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"إشعار إداري: {self.title}"

    class Meta:
        verbose_name = 'إشعار إداري'
        verbose_name_plural = 'الإشعارات الإدارية'
        ordering = ['-created_at']


class AdminMessage(models.Model):
    sender = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='sent_admin_messages',
    )
    recipient = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='received_admin_messages',
    )
    subject = models.CharField(max_length=200)
    body = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)
    read_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f'{self.subject} ({self.sender} -> {self.recipient})'

    class Meta:
        ordering = ['-created_at']
        verbose_name = 'رسالة إدارية'
        verbose_name_plural = 'الرسائل الإدارية'