
from django import forms
from django.utils.translation import gettext as _
from django.contrib.auth.forms import UserCreationForm
from accounts.models import CustomUser as User
from patients.models import DoctorResponse
from .models import Doctor

class DoctorResponseForm(forms.ModelForm):
    class Meta:
        model = DoctorResponse
        fields = ['content', 'recommendations', 'diagnosis', 'treatment_plan', 'notes']
        widgets = {
            'content': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 5,
                'placeholder': 'اكتب ردك الطبي على الحالة...'
            }),
            'recommendations': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 4,
                'placeholder': 'اكتب التوصيات والنصائح الطبية...'
            }),
            'diagnosis': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 3,
                'placeholder': 'التشخيص الطبي (اختياري)...'
            }),
            'treatment_plan': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 4,
                'placeholder': 'خطة العلاج (اختياري)...'
            }),
            'notes': forms.Textarea(attrs={
                'class': 'form-control',
                'rows': 2,
                'placeholder': 'ملاحظات إضافية (اختياري)...'
            }),
        }
        labels = {
            'content': 'محتوى الرد الطبي',
            'recommendations': 'التوصيات',
            'diagnosis': 'التشخيص الطبي (اختياري)',
            'treatment_plan': 'خطة العلاج (اختياري)',
            'notes': 'ملاحظات إضافية (اختياري)',
        }


class EnhancedDoctorRegistrationForm(UserCreationForm):
    """نموذج تسجيل الطبيب المحسن مع الأسعار
    يدعم:
    - في حال كان اسم المستخدم موجوداً: التحقق من كلمة المرور واستخدام الحساب الحالي بدون إنشاء مستخدم جديد
    - في حال لم يكن موجوداً: إنشاء مستخدم جديد ثم إنشاء ملف طبيب
    """

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self._existing_user = None  # سيتم ملؤه إذا كان المستخدم موجوداً وتم التحقق من كلمة المرور
        # السماح صراحة بإدخال أسماء مستخدمين بالعربية أو الإنجليزية
        self.fields['username'].widget.attrs.update({
            'placeholder': 'اسم المستخدم (عربي أو إنجليزي)'
        })
    
    # معلومات شخصية
    full_name = forms.CharField(
        max_length=100,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'الاسم الكامل (د. أحمد محمد العلي)'
        }),
        label='الاسم الكامل'
    )
    
    email = forms.EmailField(
        widget=forms.EmailInput(attrs={
            'class': 'form-control',
            'placeholder': 'البريد الإلكتروني'
        }),
        label='البريد الإلكتروني'
    )
    
    phone_number = forms.CharField(
        max_length=15,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': '+966xxxxxxxxx'
        }),
        label='رقم الهاتف'
    )
    
    # معلومات مهنية
    specialization = forms.ChoiceField(
        choices=Doctor.SPECIALIZATION_CHOICES,
        widget=forms.Select(attrs={
            'class': 'form-control'
        }),
        label='التخصص'
    )
    
    license_number = forms.CharField(
        max_length=50,
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'رقم الترخيص الطبي'
        }),
        label='رقم الترخيص الطبي'
    )
    
    license_image = forms.ImageField(
        widget=forms.FileInput(attrs={
            'class': 'form-control',
            'accept': 'image/*'
        }),
        label='صورة الترخيص الطبي'
    )
    
    # صورة الملف الشخصي (اختيارية)
    profile_picture = forms.ImageField(
        required=False,
        widget=forms.FileInput(attrs={
            'class': 'form-control',
            'accept': 'image/*'
        }),
        label='صورة شخصية (اختياري)'
    )

    # قائمة دول جاهزة للاختيار
    COUNTRY_CHOICES = [
        ('SA', 'السعودية'), ('AE', 'الإمارات'), ('KW', 'الكويت'), ('QA', 'قطر'), ('BH', 'البحرين'),
        ('OM', 'عُمان'), ('EG', 'مصر'), ('JO', 'الأردن'), ('LB', 'لبنان'), ('MA', 'المغرب'),
        ('DZ', 'الجزائر'), ('TN', 'تونس'), ('IQ', 'العراق'), ('YE', 'اليمن'), ('SD', 'السودان'),
        ('SY', 'سوريا'), ('PS', 'فلسطين'), ('TR', 'تركيا'), ('US', 'الولايات المتحدة'), ('GB', 'المملكة المتحدة')
    ]

    country = forms.ChoiceField(
        choices=COUNTRY_CHOICES,
        widget=forms.Select(attrs={
            'class': 'form-control'
        }),
        label='البلد'
    )
    
    experience_years = forms.IntegerField(
        min_value=0,
        max_value=50,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'placeholder': 'عدد سنوات الخبرة'
        }),
        label='سنوات الخبرة'
    )
    
    bio = forms.CharField(
        widget=forms.Textarea(attrs={
            'class': 'form-control',
            'rows': 4,
            'placeholder': 'نبذة مختصرة عن خبرتك ومؤهلاتك الطبية...'
        }),
        label='نبذة شخصية'
    )
    
    # معلومات الأسعار والدفع
    consultation_fee = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        min_value=0,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'placeholder': '100.00',
            'step': '0.01'
        }),
        label='رسوم الاستشارة العادية',
        help_text='بالريال السعودي'
    )
    
    emergency_fee = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        min_value=0,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'placeholder': '200.00',
            'step': '0.01'
        }),
        label='رسوم استشارة الطوارئ',
        help_text='بالريال السعودي'
    )
    
    follow_up_fee = forms.DecimalField(
        max_digits=10,
        decimal_places=2,
        min_value=0,
        widget=forms.NumberInput(attrs={
            'class': 'form-control',
            'placeholder': '50.00',
            'step': '0.01'
        }),
        label='رسوم المتابعة',
        help_text='بالريال السعودي'
    )
    
    currency = forms.ChoiceField(
        choices=[
            ('SAR', 'ريال سعودي'),
            ('USD', 'دولار أمريكي'),
            ('EUR', 'يورو'),
            ('AED', 'درهم إماراتي'),
        ],
        widget=forms.Select(attrs={
            'class': 'form-control'
        }),
        label='العملة',
        initial='SAR'
    )
    
    accepts_insurance = forms.BooleanField(
        required=False,
        widget=forms.CheckboxInput(attrs={
            'class': 'form-check-input'
        }),
        label='أقبل التأمين الطبي'
    )
    
    preferred_language = forms.ChoiceField(
        choices=[
            ('ar', 'العربية'),
            ('en', 'English'),
        ],
        widget=forms.Select(attrs={
            'class': 'form-control'
        }),
        label='اللغة المفضلة للتواصل',
        initial='ar'
    )
    
    # شروط الخدمة
    terms_accepted = forms.BooleanField(
        required=True,
        widget=forms.CheckboxInput(attrs={
            'class': 'form-check-input'
        }),
        label='أوافق على شروط الخدمة وسياسة الخصوصية'
    )
    
    class Meta:
        model = User
        fields = [
            'username', 'email', 'password1', 'password2', 'phone_number'
        ]
        
        widgets = {
            'username': forms.TextInput(attrs={
                'class': 'form-control',
                'placeholder': 'اسم المستخدم'
            }),
            'password1': forms.PasswordInput(attrs={
                'class': 'form-control',
                'placeholder': 'كلمة المرور'
            }),
            'password2': forms.PasswordInput(attrs={
                'class': 'form-control',
                'placeholder': 'تأكيد كلمة المرور'
            }),
        }
        
        labels = {
            'username': 'اسم المستخدم',
            'password1': 'كلمة المرور',
            'password2': 'تأكيد كلمة المرور',
        }

    def clean_username(self):
        from django.contrib.auth import get_user_model, authenticate
        UserModel = get_user_model()
        username = self.cleaned_data.get('username')
        if not username:
            return username
        try:
            user = UserModel.objects.get(username=username)
            # موجود بالفعل: تحقق من كلمة المرور المدخلة
            password = self.data.get('password1') or self.cleaned_data.get('password1')
            auth_user = authenticate(username=username, password=password)
            if auth_user is None:
                raise forms.ValidationError('اسم المستخدم موجود. أدخل كلمة المرور الصحيحة للمتابعة باستخدام حسابك.')
            # تم التحقق بنجاح
            self._existing_user = user
            return username
        except UserModel.DoesNotExist:
            # غير موجود: سيكون إنشاء مستخدم جديد
            return username

    def clean_email(self):
        email = self.cleaned_data.get('email')
        # إذا كان هناك مستخدم موجود تم التحقق منه، لا نتحقق من تفرّد البريد (نستخدم بريده)
        if getattr(self, '_existing_user', None):
            return self._existing_user.email
        if User.objects.filter(email=email).exists():
            raise forms.ValidationError('هذا البريد الإلكتروني مستخدم بالفعل')
        return email
    
    def clean_license_number(self):
        license_number = self.cleaned_data.get('license_number')
        if Doctor.objects.filter(license_number=license_number).exists():
            raise forms.ValidationError('رقم الترخيص هذا مستخدم بالفعل')
        return license_number
    
    def clean(self):
        cleaned_data = super().clean()
        consultation_fee = cleaned_data.get('consultation_fee')
        emergency_fee = cleaned_data.get('emergency_fee')
        follow_up_fee = cleaned_data.get('follow_up_fee')
        
        # التحقق من أن رسوم الطوارئ أعلى من الاستشارة العادية
        if consultation_fee and emergency_fee is not None:
            if emergency_fee <= consultation_fee:
                raise forms.ValidationError('رسوم الطوارئ يجب أن تكون أعلى من رسوم الاستشارة العادية')
        
        # التحقق من أن رسوم المتابعة أقل من الاستشارة العادية
        if consultation_fee and follow_up_fee is not None:
            if follow_up_fee >= consultation_fee:
                raise forms.ValidationError('رسوم المتابعة يجب أن تكون أقل من رسوم الاستشارة العادية')
        
        return cleaned_data
    
    def save(self, commit=True):
        # في حال المستخدم موجود مسبقاً وتم التحقق من كلمة المرور
        if getattr(self, '_existing_user', None):
            user = self._existing_user
            # تحديث بعض الحقول الاختيارية
            user.user_type = 'doctor'
            phone = self.cleaned_data.get('phone_number')
            if phone:
                user.phone_number = phone
            # تحديث الاسم من full_name - الحفاظ على المسافات
            full_name = self.cleaned_data['full_name'].strip()
            # البحث عن أول مسافة لتقسيم الاسم
            first_space_index = full_name.find(' ')
            if first_space_index != -1:
                user.first_name = full_name[:first_space_index]
                user.last_name = full_name[first_space_index+1:].strip()
            else:
                user.first_name = full_name
                user.last_name = ''
            if commit:
                user.save()
                Doctor.objects.create(
                    user=user,
                    specialization=self.cleaned_data['specialization'],
                    license_number=self.cleaned_data['license_number'],
                    license_image=self.cleaned_data['license_image'],
                    country=self.cleaned_data['country'],
                    bio=self.cleaned_data['bio'],
                    experience_years=self.cleaned_data['experience_years'],
                    consultation_fee=self.cleaned_data['consultation_fee'],
                    emergency_fee=self.cleaned_data['emergency_fee'],
                    follow_up_fee=self.cleaned_data['follow_up_fee'],
                    currency=self.cleaned_data['currency'],
                    accepts_insurance=self.cleaned_data['accepts_insurance'],
                    preferred_language=self.cleaned_data['preferred_language'],
                    status='pending'
                )
            return user

        # إنشاء مستخدم جديد كالسابق
        user = super().save(commit=False)
        user.user_type = 'doctor'
        user.email = self.cleaned_data['email']
        user.phone_number = self.cleaned_data['phone_number']
        
        # تقسيم الاسم الكامل إلى اسم أول وأخير - الحفاظ على المسافات
        full_name = self.cleaned_data['full_name'].strip()
        # البحث عن أول مسافة لتقسيم الاسم
        first_space_index = full_name.find(' ')
        if first_space_index != -1:
            user.first_name = full_name[:first_space_index]
            user.last_name = full_name[first_space_index+1:].strip()
        else:
            user.first_name = full_name
            user.last_name = ''
        
        if commit:
            user.save()
            # حفظ صورة الملف الشخصي الاختيارية على حساب المستخدم
            profile_pic = self.cleaned_data.get('profile_picture')
            if profile_pic:
                user.profile_picture = profile_pic
                user.save()

            Doctor.objects.create(
                user=user,
                specialization=self.cleaned_data['specialization'],
                license_number=self.cleaned_data['license_number'],
                license_image=self.cleaned_data['license_image'],
                country=dict(self.fields['country'].choices).get(self.cleaned_data['country'], self.cleaned_data['country']),
                bio=self.cleaned_data['bio'],
                experience_years=self.cleaned_data['experience_years'],
                consultation_fee=self.cleaned_data['consultation_fee'],
                emergency_fee=self.cleaned_data['emergency_fee'],
                follow_up_fee=self.cleaned_data['follow_up_fee'],
                currency=self.cleaned_data['currency'],
                accepts_insurance=self.cleaned_data['accepts_insurance'],
                preferred_language=self.cleaned_data['preferred_language'],
                status='pending'
            )
        
        return user


class DoctorPricingForm(forms.ModelForm):
    """نموذج تحديث أسعار الطبيب"""
    
    class Meta:
        model = Doctor
        fields = [
            'consultation_fee', 'emergency_fee', 'follow_up_fee', 
            'currency', 'accepts_insurance'
        ]
        
        widgets = {
            'consultation_fee': forms.NumberInput(attrs={
                'class': 'form-control',
                'step': '0.01',
                'min': '0'
            }),
            'emergency_fee': forms.NumberInput(attrs={
                'class': 'form-control',
                'step': '0.01',
                'min': '0'
            }),
            'follow_up_fee': forms.NumberInput(attrs={
                'class': 'form-control',
                'step': '0.01',
                'min': '0'
            }),
            'currency': forms.Select(attrs={
                'class': 'form-control'
            }),
            'accepts_insurance': forms.CheckboxInput(attrs={
                'class': 'form-check-input'
            })
        }
        
        labels = {
            'consultation_fee': 'رسوم الاستشارة العادية',
            'emergency_fee': 'رسوم استشارة الطوارئ',
            'follow_up_fee': 'رسوم المتابعة',
            'currency': 'العملة',
            'accepts_insurance': 'أقبل التأمين الطبي'
        }