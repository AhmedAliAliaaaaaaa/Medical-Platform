from django import forms
from django.utils.translation import gettext_lazy as _
from .models import PaymentMethod, Payment
import re

class PaymentMethodForm(forms.ModelForm):
    """نموذج محسن لإضافة طرق الدفع المتعددة"""
    
    class Meta:
        model = PaymentMethod
        fields = [
            'payment_type', 'card_type', 'card_number', 'card_holder_name',
            'expiry_month', 'expiry_year', 'cvv', 'paypal_email',
            'bank_name', 'account_number', 'iban', 'is_default'
        ]
        widgets = {
            'payment_type': forms.Select(attrs={
                'class': 'form-control',
                'id': 'payment_type',
                'onchange': 'togglePaymentFields()'
            }),
            'card_type': forms.Select(attrs={'class': 'form-control'}),
            'card_number': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': '1234 5678 9012 3456',
                'maxlength': '19',
                'pattern': '[0-9\s]{13,19}',
                'autocomplete': 'cc-number'
            }),
            'card_holder_name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'الاسم كما يظهر على البطاقة',
                'autocomplete': 'cc-name'
            }),
            'expiry_month': forms.Select(attrs={
                'class': 'form-control',
                'autocomplete': 'cc-exp-month'
            }),
            'expiry_year': forms.Select(attrs={
                'class': 'form-control',
                'autocomplete': 'cc-exp-year'
            }),
            'cvv': forms.PasswordInput(attrs={
                'class': 'form-control',
                'placeholder': 'CVV',
                'maxlength': '4',
                'autocomplete': 'cc-csc'
            }),
            'paypal_email': forms.EmailInput(attrs={
                'class': 'form-control',
                'placeholder': 'your-email@paypal.com'
            }),
            'bank_name': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'اسم البنك'
            }),
            'account_number': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'رقم الحساب'
            }),
            'iban': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'SA00 0000 0000 0000 0000 0000'
            }),
            'is_default': forms.CheckboxInput(attrs={
                'class': 'form-check-input'
            })
        }
        
        labels = {
            'payment_type': 'نوع الدفع',
            'card_type': 'نوع البطاقة',
            'card_number': 'رقم البطاقة',
            'card_holder_name': 'اسم حامل البطاقة',
            'expiry_month': 'شهر الانتهاء',
            'expiry_year': 'سنة الانتهاء',
            'cvv': 'رمز الأمان',
            'paypal_email': 'بريد PayPal الإلكتروني',
            'bank_name': 'اسم البنك',
            'account_number': 'رقم الحساب',
            'iban': 'رقم الآيبان',
            'is_default': 'جعل هذه الطريقة افتراضية'
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        
        # إضافة خيارات الشهور
        months = [(i, f'{i:02d}') for i in range(1, 13)]
        self.fields['expiry_month'].choices = [('', 'الشهر')] + months
        
        # إضافة خيارات السنوات
        import datetime
        current_year = datetime.datetime.now().year
        years = [(i, str(i)) for i in range(current_year, current_year + 21)]
        self.fields['expiry_year'].choices = [('', 'السنة')] + years
    
    def clean_card_number(self):
        """تنظيف وتحقق رقم البطاقة"""
        card_number = self.cleaned_data.get('card_number', '')
        if not card_number:
            return card_number
        
        # إزالة المسافات والشرطات
        card_number = re.sub(r'[\s-]', '', card_number)
        
        # التحقق من أن الرقم يحتوي على أرقام فقط
        if not card_number.isdigit():
            raise forms.ValidationError('رقم البطاقة يجب أن يحتوي على أرقام فقط')
        
        # التحقق من طول الرقم
        if len(card_number) < 13 or len(card_number) > 19:
            raise forms.ValidationError('رقم البطاقة غير صحيح')
        
        # إخفاء الرقم وإظهار آخر 4 أرقام فقط
        return '*' * (len(card_number) - 4) + card_number[-4:]
    
    def clean_cvv(self):
        """تحقق رمز الأمان"""
        cvv = self.cleaned_data.get('cvv', '')
        if cvv and not cvv.isdigit():
            raise forms.ValidationError('رمز الأمان يجب أن يحتوي على أرقام فقط')
        if cvv and (len(cvv) < 3 or len(cvv) > 4):
            raise forms.ValidationError('رمز الأمان يجب أن يكون 3 أو 4 أرقام')
        return cvv
    
    def clean_iban(self):
        """تحقق رقم الآيبان السعودي"""
        iban = self.cleaned_data.get('iban', '')
        if iban:
            # إزالة المسافات
            iban = re.sub(r'\s', '', iban)
            # التحقق من تنسيق الآيبان السعودي
            if not re.match(r'^SA\d{22}$', iban):
                raise forms.ValidationError('رقم الآيبان السعودي غير صحيح (يجب أن يبدأ بـ SA ويتبعه 22 رقم)')
        return iban

class ConsultationPaymentForm(forms.Form):
    """Form for consultation payment"""
    
    PAYMENT_METHOD_CHOICES = [
        ('stripe', 'بطاقة ائتمان/خصم'),
        ('paypal', 'PayPal'),
    ]
    
    payment_method = forms.ChoiceField(
        choices=PAYMENT_METHOD_CHOICES,
        widget=forms.RadioSelect(attrs={
            'class': 'form-check-input'
        }),
        label='طريقة الدفع'
    )
    
    saved_payment_method = forms.ModelChoiceField(
        queryset=PaymentMethod.objects.none(),
        required=False,
        widget=forms.Select(attrs={
            'class': 'form-control'
        }),
        label='طريقة دفع محفوظة'
    )
    
    save_payment_method = forms.BooleanField(
        required=False,
        widget=forms.CheckboxInput(attrs={
            'class': 'form-check-input'
        }),
        label='حفظ طريقة الدفع للاستخدام المستقبلي'
    )
    
    def __init__(self, user=None, *args, **kwargs):
        super().__init__(*args, **kwargs)
        if user:
            self.fields['saved_payment_method'].queryset = PaymentMethod.objects.filter(
                user=user, is_active=True
            )

class DoctorSubscriptionForm(forms.Form):
    """Form for doctor subscription to payment methods"""
    
    SUBSCRIPTION_TYPES = [
        ('basic', 'الأساسي - 50 ريال/شهر'),
        ('premium', 'المميز - 100 ريال/شهر'),
        ('professional', 'الاحترافي - 200 ريال/شهر'),
    ]
    
    subscription_type = forms.ChoiceField(
        choices=SUBSCRIPTION_TYPES,
        widget=forms.RadioSelect(attrs={
            'class': 'form-check-input'
        }),
        label='نوع الاشتراك'
    )
    
    payment_method = forms.ChoiceField(
        choices=[
            ('stripe', 'بطاقة ائتمان/خصم'),
            ('paypal', 'PayPal'),
        ],
        widget=forms.RadioSelect(attrs={
            'class': 'form-check-input'
        }),
        label='طريقة الدفع'
    )
    
    card_number = forms.CharField(
        max_length=19,
        required=False,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'رقم البطاقة',
            'pattern': r'[0-9\s]{13,19}'
        }),
        label='رقم البطاقة'
    )
    
    card_holder_name = forms.CharField(
        max_length=100,
        required=False,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'اسم حامل البطاقة'
        }),
        label='اسم حامل البطاقة'
    )
    
    expiry_month = forms.ChoiceField(
        choices=[(i, f'{i:02d}') for i in range(1, 13)],
        required=False,
        widget=forms.Select(attrs={
            'class': 'form-control'
        }),
        label='شهر الانتهاء'
    )
    
    expiry_year = forms.ChoiceField(
        choices=[(i, str(i)) for i in range(2024, 2035)],
        required=False,
        widget=forms.Select(attrs={
            'class': 'form-control'
        }),
        label='سنة الانتهاء'
    )
    
    cvv = forms.CharField(
        max_length=4,
        required=False,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'CVV',
            'pattern': '[0-9]{3,4}'
        }),
        label='رمز الأمان'
    )
    
    def clean(self):
        cleaned_data = super().clean()
        payment_method = cleaned_data.get('payment_method')
        
        if payment_method == 'stripe':
            required_fields = ['card_number', 'card_holder_name', 'expiry_month', 'expiry_year', 'cvv']
            for field in required_fields:
                if not cleaned_data.get(field):
                    self.add_error(field, 'هذا الحقل مطلوب عند الدفع بالبطاقة')
        
        return cleaned_data

class WithdrawalRequestForm(forms.Form):
    """Form for doctor withdrawal requests"""
    
    amount = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        min_value=100,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'placeholder': 'المبلغ المطلوب سحبه',
            'step': '0.01'
        }),
        label='المبلغ (ريال سعودي)'
    )
    
    bank_name = forms.CharField(
        max_length=100,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'اسم البنك'
        }),
        label='اسم البنك'
    )
    
    bank_account = forms.CharField(
        max_length=50,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'رقم الحساب البنكي'
        }),
        label='رقم الحساب البنكي'
    )
    
    account_holder_name = forms.CharField(
        max_length=100,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'اسم صاحب الحساب'
        }),
        label='اسم صاحب الحساب'
    )
    
    def clean_bank_account(self):
        bank_account = self.cleaned_data.get('bank_account')
        if bank_account and not bank_account.replace(' ', '').isdigit():
            raise forms.ValidationError('رقم الحساب البنكي يجب أن يحتوي على أرقام فقط')
        return bank_account