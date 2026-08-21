from django.db import models
from django.contrib.auth import get_user_model
from django.utils.translation import gettext as _
from patients.models import MedicalCase
from doctors.models import Doctor

User = get_user_model()

class PaymentMethod(models.Model):
    PAYMENT_TYPES = (
        ('visa', 'Visa'),
        ('mastercard', 'Mastercard'),
        ('american_express', 'American Express'),
        ('paypal', 'PayPal'),
        ('apple_pay', 'Apple Pay'),
        ('google_pay', 'Google Pay'),
        ('bank_transfer', 'تحويل بنكي'),
        ('stc_pay', 'STC Pay'),
        ('mada', 'مدى'),
    )
    
    CARD_TYPES = (
        ('credit', 'بطاقة ائتمان'),
        ('debit', 'بطاقة خصم'),
        ('prepaid', 'بطاقة مدفوعة مسبقاً'),
    )
    
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payment_methods')
    payment_type = models.CharField(max_length=20, choices=PAYMENT_TYPES)
    card_type = models.CharField(max_length=10, choices=CARD_TYPES, blank=True, null=True, default='credit')
    card_number = models.CharField(max_length=20, blank=True, default='')  # مشفر - آخر 4 أرقام فقط
    card_holder_name = models.CharField(max_length=100, blank=True, default='')
    expiry_month = models.PositiveIntegerField(blank=True, null=True, default=1)
    expiry_year = models.PositiveIntegerField(blank=True, null=True, default=2025)
    cvv = models.CharField(max_length=4, blank=True, default='')  # مشفر
    
    # معلومات PayPal
    paypal_email = models.EmailField(blank=True, null=True, default='')
    
    # معلومات البنك
    bank_name = models.CharField(max_length=100, blank=True, default='')
    account_number = models.CharField(max_length=50, blank=True, default='')
    iban = models.CharField(max_length=34, blank=True, default='')
    
    # إعدادات البطاقة
    is_default = models.BooleanField(default=False)
    is_active = models.BooleanField(default=True)
    is_verified = models.BooleanField(default=False)
    
    # معلومات الأمان
    billing_address = models.TextField(blank=True, default='')
    billing_city = models.CharField(max_length=100, blank=True, default='')
    billing_country = models.CharField(max_length=100, blank=True, default='')
    billing_postal_code = models.CharField(max_length=20, blank=True, default='')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        if self.card_number:
            return f"{self.get_payment_type_display()} - ****{self.card_number[-4:]}"
        return self.get_payment_type_display()
    
    class Meta:
        verbose_name = 'طريقة الدفع'
        verbose_name_plural = 'طرق الدفع'


class Payment(models.Model):
    PAYMENT_STATUS = (
        ('pending', 'في الانتظار'),
        ('processing', 'قيد المعالجة'),
        ('completed', 'مكتمل'),
        ('failed', 'فشل'),
        ('cancelled', 'ملغي'),
        ('refunded', 'مسترد'),
    )
    
    PAYMENT_PURPOSE = (
        ('consultation', 'استشارة طبية'),
        ('prescription', 'وصفة طبية'),
        ('follow_up', 'متابعة'),
        ('emergency', 'طوارئ'),
        ('subscription', 'اشتراك'),
    )
    
    # معلومات أساسية
    payment_id = models.CharField(max_length=50, unique=True)  # معرف الدفع الفريد
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='payments')
    case = models.ForeignKey(MedicalCase, on_delete=models.CASCADE, related_name='payments', null=True, blank=True)
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name='received_payments', null=True, blank=True)
    
    # تفاصيل الدفع
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    currency = models.CharField(max_length=3, default='SAR')  # ريال سعودي
    payment_method = models.ForeignKey(PaymentMethod, on_delete=models.SET_NULL, null=True, blank=True)
    payment_purpose = models.CharField(max_length=20, choices=PAYMENT_PURPOSE, default='consultation')
    
    # حالة الدفع
    status = models.CharField(max_length=20, choices=PAYMENT_STATUS, default='pending')
    transaction_id = models.CharField(max_length=100, blank=True)  # معرف المعاملة من بوابة الدفع
    
    # معلومات إضافية
    description = models.TextField(blank=True)
    notes = models.TextField(blank=True)
    
    # تواريخ
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    paid_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"دفعة {self.payment_id} - {self.amount} {self.currency}"
    
    def save(self, *args, **kwargs):
        if not self.payment_id:
            import uuid
            self.payment_id = f"PAY-{uuid.uuid4().hex[:8].upper()}"
        super().save(*args, **kwargs)
    
    class Meta:
        verbose_name = 'دفعة'
        verbose_name_plural = 'الدفعات'
        ordering = ['-created_at']


class DoctorEarnings(models.Model):
    doctor = models.OneToOneField(Doctor, on_delete=models.CASCADE, related_name='earnings')
    total_earnings = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    available_balance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    pending_balance = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    withdrawn_amount = models.DecimalField(max_digits=12, decimal_places=2, default=0)
    
    # إعدادات الدفع
    consultation_fee = models.DecimalField(max_digits=8, decimal_places=2, default=100.00)
    follow_up_fee = models.DecimalField(max_digits=8, decimal_places=2, default=50.00)
    emergency_fee = models.DecimalField(max_digits=8, decimal_places=2, default=200.00)
    
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"أرباح د. {self.doctor.user.first_name} - {self.total_earnings} ريال"
    
    class Meta:
        verbose_name = 'أرباح الطبيب'
        verbose_name_plural = 'أرباح الأطباء'


class WithdrawalRequest(models.Model):
    WITHDRAWAL_STATUS = (
        ('pending', 'في الانتظار'),
        ('approved', 'موافق عليه'),
        ('processing', 'قيد المعالجة'),
        ('completed', 'مكتمل'),
        ('rejected', 'مرفوض'),
    )
    
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name='withdrawal_requests')
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    bank_account = models.CharField(max_length=50)
    bank_name = models.CharField(max_length=100)
    account_holder_name = models.CharField(max_length=100)
    
    status = models.CharField(max_length=20, choices=WITHDRAWAL_STATUS, default='pending')
    admin_notes = models.TextField(blank=True)
    
    requested_at = models.DateTimeField(auto_now_add=True)
    processed_at = models.DateTimeField(null=True, blank=True)
    
    def __str__(self):
        return f"طلب سحب د. {self.doctor.user.first_name} - {self.amount} ريال"
    
    class Meta:
        verbose_name = 'طلب سحب'
        verbose_name_plural = 'طلبات السحب'
        ordering = ['-requested_at']


class PlatformSettings(models.Model):
    # رسوم المنصة
    platform_commission_rate = models.DecimalField(max_digits=5, decimal_places=2, default=10.00)  # نسبة عمولة المنصة
    minimum_withdrawal_amount = models.DecimalField(max_digits=8, decimal_places=2, default=100.00)
    
    # أسعار افتراضية
    default_consultation_fee = models.DecimalField(max_digits=8, decimal_places=2, default=100.00)
    default_follow_up_fee = models.DecimalField(max_digits=8, decimal_places=2, default=50.00)
    default_emergency_fee = models.DecimalField(max_digits=8, decimal_places=2, default=200.00)
    
    # إعدادات الدفع
    payment_gateway_enabled = models.BooleanField(default=True)
    auto_approve_payments = models.BooleanField(default=False)
    
    updated_at = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return "إعدادات المنصة"
    
    class Meta:
        verbose_name = 'إعدادات المنصة'
        verbose_name_plural = 'إعدادات المنصة'