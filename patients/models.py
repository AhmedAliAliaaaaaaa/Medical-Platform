from django.db import models
from django.contrib.auth import get_user_model
from django.utils.translation import gettext as _
from doctors.models import Doctor

User = get_user_model()

class Patient(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    date_of_birth = models.DateField(blank=True, null=True)
    gender = models.CharField(max_length=10, choices=[('male', 'ذكر'), ('female', 'أنثى')], blank=True)
    blood_type = models.CharField(max_length=5, blank=True)
    medical_history = models.TextField(blank=True)
    allergies = models.TextField(blank=True)
    emergency_contact = models.CharField(max_length=15, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.first_name} {self.user.last_name}"

    class Meta:
        verbose_name = 'مريض'
        verbose_name_plural = 'المرضى'


class MedicalCase(models.Model):
    PRIORITY_CHOICES = (
        ('low', 'منخفضة'),
        ('medium', 'متوسطة'),
        ('high', 'عالية'),
        ('urgent', 'عاجلة'),
    )
    
    STATUS_CHOICES = (
        ('pending', 'قيد الانتظار'),
        ('in_progress', 'قيد المراجعة'),
        ('completed', 'تم الرد'),
        ('cancelled', 'ملغية'),
    )
    
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name='medical_cases')
    doctor = models.ForeignKey(Doctor, on_delete=models.SET_NULL, null=True, blank=True, related_name='assigned_cases')
    title = models.CharField(max_length=200, default='حالة طبية جديدة')
    description = models.TextField()
    symptoms = models.TextField(blank=True, verbose_name="الأعراض")
    
    # حقول الترجمة
    title_translated = models.CharField(max_length=200, blank=True, null=True, verbose_name="العنوان المترجم")
    description_translated = models.TextField(blank=True, null=True, verbose_name="الوصف المترجم")
    source_language = models.CharField(max_length=2, choices=[('ar', 'العربية'), ('en', 'English')], default='ar', verbose_name="اللغة الأصلية")
    translation_confidence = models.FloatField(default=0.0, verbose_name="مستوى الثقة في الترجمة")
    
    priority = models.CharField(max_length=10, choices=PRIORITY_CHOICES, default='medium')
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='pending')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    expected_response_time = models.DateTimeField(blank=True, null=True)

    def __str__(self):
        return f"حالة {self.patient.user.first_name} - {self.title}"

    class Meta:
        verbose_name = 'حالة طبية'
        verbose_name_plural = 'الحالات الطبية'
        ordering = ['-created_at']


class CaseAttachment(models.Model):
    case = models.ForeignKey(MedicalCase, on_delete=models.CASCADE, related_name='attachments')
    file = models.FileField(upload_to='case_attachments/')
    file_type = models.CharField(max_length=10, choices=[('image', 'صورة'), ('pdf', 'PDF'), ('other', 'أخرى')])
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"مرفق - {self.case.title}"

    class Meta:
        verbose_name = 'مرفق الحالة'
        verbose_name_plural = 'مرفقات الحالات'


class DoctorResponse(models.Model):
    STATUS_CHOICES = (
        ('pending', 'قيد المراجعة'),
        ('approved', 'معتمد'),
        ('rejected', 'مرفوض'),
    )
    
    medical_case = models.ForeignKey(MedicalCase, on_delete=models.CASCADE, related_name='responses')
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE)
    content = models.TextField(verbose_name="محتوى الرد")
    recommendations = models.TextField(blank=True, verbose_name="التوصيات")
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='pending')
    rejection_reason = models.TextField(blank=True, null=True, verbose_name="سبب الرفض")
    
    # الحقول القديمة للتوافق
    diagnosis = models.TextField(blank=True)
    treatment_plan = models.TextField(blank=True)
    notes = models.TextField(blank=True)
    
    # حقول الترجمة لرد الطبيب
    diagnosis_translated = models.TextField(blank=True, null=True, verbose_name="التشخيص المترجم")
    treatment_plan_translated = models.TextField(blank=True, null=True, verbose_name="خطة العلاج المترجمة")
    notes_translated = models.TextField(blank=True, null=True, verbose_name="الملاحظات المترجمة")
    response_language = models.CharField(max_length=2, choices=[('ar', 'العربية'), ('en', 'English')], default='en', verbose_name="لغة الرد")
    
    response_file = models.FileField(upload_to='doctor_responses/', blank=True, null=True)
    response_video = models.FileField(upload_to='doctor_videos/', blank=True, null=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"رد د. {self.doctor.user.first_name} على {self.medical_case.title}"

    class Meta:
        verbose_name = 'رد الطبيب'
        verbose_name_plural = 'ردود الأطباء'


class ResponseAttachment(models.Model):
    response = models.ForeignKey(DoctorResponse, on_delete=models.CASCADE, related_name='attachments')
    file = models.FileField(upload_to='response_attachments/')
    file_type = models.CharField(max_length=10, choices=[('image', 'صورة'), ('pdf', 'PDF'), ('video', 'فيديو'), ('other', 'أخرى')])
    uploaded_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"مرفق رد - {self.response.medical_case.title}"

    class Meta:
        verbose_name = 'مرفق الرد'
        verbose_name_plural = 'مرفقات الردود'


class DoctorRating(models.Model):
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE)
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE)
    case = models.OneToOneField(MedicalCase, on_delete=models.CASCADE)
    
    # التقييمات التفصيلية
    diagnosis_accuracy = models.PositiveIntegerField(choices=[(i, i) for i in range(1, 6)], default=5, verbose_name="دقة التشخيص")
    treatment_clarity = models.PositiveIntegerField(choices=[(i, i) for i in range(1, 6)], default=5, verbose_name="وضوح العلاج")
    response_speed = models.PositiveIntegerField(choices=[(i, i) for i in range(1, 6)], default=5, verbose_name="سرعة الرد")
    professionalism = models.PositiveIntegerField(choices=[(i, i) for i in range(1, 6)], default=5, verbose_name="الاحترافية")
    communication = models.PositiveIntegerField(choices=[(i, i) for i in range(1, 6)], default=5, verbose_name="التواصل")
    overall_satisfaction = models.PositiveIntegerField(choices=[(i, i) for i in range(1, 6)], default=5, verbose_name="الرضا العام")
    
    # تقييم عام وتعليق
    rating = models.PositiveIntegerField(choices=[(i, i) for i in range(1, 6)], default=5)
    comment = models.TextField(blank=True, verbose_name="تعليق")
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"تقييم {self.patient.user.get_full_name()} لـ د. {self.doctor.user.get_full_name()}"

    class Meta:
        verbose_name = 'تقييم الطبيب'
        verbose_name_plural = 'تقييمات الأطباء'
        unique_together = ['patient', 'doctor', 'case']


class PatientNotification(models.Model):
    NOTIFICATION_TYPES = (
        ('doctor_response', 'رد طبيب'),
        ('admin', 'إشعار إداري'),
        ('doctor_message', 'رسالة من طبيب'),
        ('appointment', 'موعد'),
        ('general', 'عام'),
    )
    
    patient = models.ForeignKey(Patient, on_delete=models.CASCADE, related_name='notifications')
    title = models.CharField(max_length=200)
    message = models.TextField()
    notification_type = models.CharField(max_length=20, choices=NOTIFICATION_TYPES, default='general')
    is_read = models.BooleanField(default=False)
    
    # علاقات اختيارية
    related_case = models.ForeignKey(MedicalCase, on_delete=models.CASCADE, null=True, blank=True)
    sender_doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, null=True, blank=True)
    sender_admin = models.ForeignKey(User, on_delete=models.CASCADE, null=True, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"إشعار لـ {self.patient.user.get_full_name()}: {self.title}"

    class Meta:
        verbose_name = 'إشعار المريض'
        verbose_name_plural = 'إشعارات المرضى'
        ordering = ['-created_at']
