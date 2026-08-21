from django.db import models
from django.contrib.auth import get_user_model
from django.utils.translation import gettext as _

User = get_user_model()

class Doctor(models.Model):
    SPECIALIZATION_CHOICES = (
        ('general', 'طب عام'),
        ('cardiology', 'أمراض القلب'),
        ('dermatology', 'الأمراض الجلدية'),
        ('neurology', 'الأمراض العصبية'),
        ('orthopedics', 'العظام'),
        ('pediatrics', 'طب الأطفال'),
        ('psychiatry', 'الطب النفسي'),
        ('gynecology', 'أمراض النساء'),
        ('urology', 'المسالك البولية'),
        ('ophthalmology', 'طب العيون'),
        ('ent', 'الأنف والأذن والحنجرة'),
        ('dentistry', 'طب الأسنان'),
    )
    
    STATUS_CHOICES = (
        ('pending', 'قيد المراجعة'),
        ('approved', 'مقبول'),
        ('rejected', 'مرفوض'),
    )
    
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    specialization = models.CharField(max_length=20, choices=SPECIALIZATION_CHOICES)
    license_number = models.CharField(max_length=50, unique=True)
    license_image = models.ImageField(upload_to='doctor_licenses/')
    country = models.CharField(max_length=50)
    bio = models.TextField()
    experience_years = models.PositiveIntegerField(default=0)
    consultation_fee = models.DecimalField(max_digits=10, decimal_places=2, default=100.00, verbose_name="رسوم الاستشارة")
    emergency_fee = models.DecimalField(max_digits=10, decimal_places=2, default=200.00, verbose_name="رسوم الطوارئ")
    follow_up_fee = models.DecimalField(max_digits=10, decimal_places=2, default=50.00, verbose_name="رسوم المتابعة")
    currency = models.CharField(max_length=3, default='SAR', verbose_name="العملة")
    accepts_insurance = models.BooleanField(default=False, verbose_name="يقبل التأمين")
    rating = models.DecimalField(max_digits=3, decimal_places=2, default=0.00)
    total_reviews = models.PositiveIntegerField(default=0)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    is_available = models.BooleanField(default=True)
    preferred_language = models.CharField(max_length=2, choices=[('ar', 'العربية'), ('en', 'English')], default='ar', verbose_name="اللغة المفضلة")
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"د. {self.user.first_name} {self.user.last_name} - {self.get_specialization_display()}"

    class Meta:
        verbose_name = 'طبيب'
        verbose_name_plural = 'الأطباء'


class DoctorNotification(models.Model):
    NOTIFICATION_TYPES = (
        ('new_case', 'حالة جديدة'),
        ('admin', 'إشعار إداري'),
        ('patient_message', 'رسالة من مريض'),
        ('response_approved', 'تم اعتماد الرد'),
        ('response_rejected', 'تم رفض الرد'),
        ('general', 'عام'),
    )
    
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=200)
    message = models.TextField()
    notification_type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES, default='general')
    is_read = models.BooleanField(default=False)
    
    # علاقات اختيارية
    related_case = models.ForeignKey('patients.MedicalCase', on_delete=models.CASCADE, null=True, blank=True)
    sender_patient = models.ForeignKey('patients.Patient', on_delete=models.CASCADE, null=True, blank=True)
    sender_admin = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"إشعار لـ د. {self.doctor.user.get_full_name()}: {self.title}"

    class Meta:
        verbose_name = 'إشعار الطبيب'
        verbose_name_plural = 'إشعارات الأطباء'
        ordering = ['-created_at']



