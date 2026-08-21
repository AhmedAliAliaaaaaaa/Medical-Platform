from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.core.exceptions import ValidationError
from django.utils.translation import gettext as _
from .models import CustomUser
from doctors.models import Doctor

class CustomUserCreationForm(UserCreationForm):
    email = forms.EmailField(
        required=True,
        widget=forms.EmailInput(attrs={
            'class': 'form-control',
            'placeholder': 'البريد الإلكتروني'
        })
    )
    phone_number = forms.CharField(
        max_length=15,
        required=False,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'رقم الهاتف (اختياري)'
        })
    )
    
    class Meta:
        model = CustomUser
        fields = ('username', 'email', 'phone_number', 'password1', 'password2')
        
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.fields['username'].widget.attrs.update({
            'class': 'form-control',
            'placeholder': 'اسم المستخدم'
        })
        self.fields['password1'].widget.attrs.update({
            'class': 'form-control',
            'placeholder': 'كلمة المرور'
        })
        self.fields['password2'].widget.attrs.update({
            'class': 'form-control',
            'placeholder': 'تأكيد كلمة المرور'
        })

    def clean_email(self):
        email = self.cleaned_data.get('email')
        if CustomUser.objects.filter(email=email).exists():
            raise ValidationError('هذا البريد الإلكتروني مستخدم بالفعل.')
        return email

class DoctorRegistrationForm(forms.ModelForm):
    # User fields
    username = forms.CharField(
        max_length=150,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'اسم المستخدم'
        })
    )
    full_name = forms.CharField(
        max_length=100,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'الاسم الكامل'
        }),
        label='الاسم الكامل'
    )
    email = forms.EmailField(
        widget=forms.EmailInput(attrs={
            'class': 'form-control',
            'placeholder': 'البريد الإلكتروني'
        })
    )
    password1 = forms.CharField(
        widget=forms.PasswordInput(attrs={
            'class': 'form-control',
            'placeholder': 'كلمة المرور'
        })
    )
    password2 = forms.CharField(
        widget=forms.PasswordInput(attrs={
            'class': 'form-control',
            'placeholder': 'تأكيد كلمة المرور'
        })
    )
    
    # حقول الأسعار
    consultation_fee = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'placeholder': '100.00',
            'step': '0.01',
            'min': '0'
        }),
        label='رسوم الاستشارة العادية'
    )
    
    emergency_fee = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        required=False,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'placeholder': '200.00',
            'step': '0.01',
            'min': '0'
        }),
        label='رسوم استشارة الطوارئ (اختياري)'
    )
    
    follow_up_fee = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        required=False,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'placeholder': '50.00',
            'step': '0.01',
            'min': '0'
        }),
        label='رسوم المتابعة (اختياري)'
    )
    
    currency = forms.ChoiceField(
        choices=[
            ('SAR', 'ريال سعودي'),
            ('USD', 'دولار أمريكي'),
            ('EUR', 'يورو'),
            ('AED', 'درهم إماراتي'),
        ],
        widget=forms.Select(attrs={'class': 'form-control'}),
        label='العملة',
        initial='SAR'
    )
    
    class Meta:
        model = Doctor
        fields = ['specialization', 'license_number', 'license_image', 'country', 'bio', 'experience_years']
        widgets = {
            'specialization': forms.Select(attrs={'class': 'form-control'}),
            'license_number': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'رقم الترخيص'
            }),
            'license_image': forms.FileInput(attrs={'class': 'form-control'}),
            'country': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'الدولة'
            }),
            'bio': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 4,
                'placeholder': 'نبذة عن الطبيب'
            }),
            'experience_years': forms.NumberInput(attrs={
                'class': 'form-control',
                'placeholder': 'سنوات الخبرة'
            }),
        }
    
    def clean_password2(self):
        password1 = self.cleaned_data.get('password1')
        password2 = self.cleaned_data.get('password2')
        if password1 and password2 and password1 != password2:
            raise ValidationError('كلمات المرور غير متطابقة.')
        return password2
    
    def clean_email(self):
        email = self.cleaned_data.get('email')
        if CustomUser.objects.filter(email=email).exists():
            raise ValidationError('هذا البريد الإلكتروني مستخدم بالفعل.')
        return email
    
    def clean_username(self):
        """السماح بأسماء مستخدمين عربية/إنجليزية والتصرف حسب الحالة:
        - إذا كان الاسم موجوداً، نسمح بالمتابعة لصفحة تسجيل الطبيب للمستخدم الحالي (سيتحقق النموذج المتقدم من كلمة المرور)
        - إذا لم يكن موجوداً، يُعتبر صالحاً لإنشاء مستخدم جديد
        """
        username = self.cleaned_data.get('username')
        return username
    
    def clean(self):
        cleaned_data = super().clean()
        consultation_fee = cleaned_data.get('consultation_fee')
        emergency_fee = cleaned_data.get('emergency_fee')
        follow_up_fee = cleaned_data.get('follow_up_fee')
        
        if consultation_fee:
            # التحقق من أن رسوم الطوارئ أعلى من الاستشارة العادية
            if emergency_fee and emergency_fee <= consultation_fee:
                raise ValidationError('رسوم استشارة الطوارئ يجب أن تكون أعلى من رسوم الاستشارة العادية')
            
            # التحقق من أن رسوم المتابعة أقل من الاستشارة العادية
            if follow_up_fee and follow_up_fee >= consultation_fee:
                raise ValidationError('رسوم المتابعة يجب أن تكون أقل من رسوم الاستشارة العادية')
        
        return cleaned_data
    
    def save(self, commit=True):
        # تقسيم الاسم الكامل
        full_name = self.cleaned_data['full_name'].strip()
        name_parts = full_name.split()
        if len(name_parts) >= 2:
            first_name = name_parts[0]
            last_name = ' '.join(name_parts[1:])
        else:
            first_name = full_name
            last_name = ''
        
        # Create user first
        user = CustomUser.objects.create_user(
            username=self.cleaned_data['username'],
            email=self.cleaned_data['email'],
            password=self.cleaned_data['password1'],
            first_name=first_name,
            last_name=last_name,
            user_type='doctor'
        )
        
        # Create doctor profile
        doctor = super().save(commit=False)
        doctor.user = user
        doctor.consultation_fee = self.cleaned_data['consultation_fee']
        doctor.emergency_fee = self.cleaned_data.get('emergency_fee', 0)
        doctor.follow_up_fee = self.cleaned_data.get('follow_up_fee', 0)
        doctor.currency = self.cleaned_data['currency']
        doctor.status = 'pending'
        
        if commit:
            doctor.save()
        return user

class ExistingUserDoctorForm(forms.ModelForm):
    """نموذج للمستخدمين الموجودين الذين يريدون التسجيل كأطباء"""
    
    class Meta:
        model = Doctor
        fields = ['specialization', 'country', 'license_number', 'experience_years', 'license_image', 'bio']
        widgets = {
            'specialization': forms.Select(attrs={
                'class': 'form-control',
            }),
            'country': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'الدولة'
            }),
            'license_number': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'رقم الترخيص'
            }),
            'license_image': forms.FileInput(attrs={
                'class': 'form-control',
                'accept': 'image/*'
            }),
            'bio': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 4,
                'placeholder': 'نبذة عن الطبيب'
            }),
            'experience_years': forms.NumberInput(attrs={
                'class': 'form-control',
                'placeholder': 'سنوات الخبرة'
            }),
        }
    
    def save(self, user, commit=True):
        """حفظ ملف الطبيب للمستخدم الموجود"""
        doctor = super().save(commit=False)
        doctor.user = user
        # تحديث نوع المستخدم ليصبح طبيب
        user.user_type = 'doctor'
        user.save()
        
        if commit:
            doctor.save()
        return doctor

class ProfileUpdateForm(forms.ModelForm):
    class Meta:
        model = CustomUser
        fields = ['first_name', 'last_name', 'email', 'phone_number', 'profile_picture']
        widgets = {
            'first_name': forms.TextInput(attrs={'class': 'form-control'}),
            'last_name': forms.TextInput(attrs={'class': 'form-control'}),
            'email': forms.EmailInput(attrs={'class': 'form-control'}),
            'phone_number': forms.TextInput(attrs={'class': 'form-control'}),
            'profile_picture': forms.FileInput(attrs={'class': 'form-control'}),
        }