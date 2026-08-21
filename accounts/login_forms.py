from django import forms
from django.contrib.auth.forms import AuthenticationForm
from django.contrib.auth import authenticate
from django.utils.translation import gettext as _

class CustomAuthenticationForm(AuthenticationForm):
    """
    نموذج تسجيل دخول مخصص يدعم:
    - اسم المستخدم
    - البريد الإلكتروني  
    - الاسم الكامل للأطباء المعتمدين
    """
    
    username = forms.CharField(
        widget=forms.TextInput(attrs={
            'class': 'form-control',
            'placeholder': 'اسم المستخدم، البريد الإلكتروني، أو الاسم الكامل',
            'autofocus': True
        }),
        label=_('اسم المستخدم أو البريد الإلكتروني أو الاسم الكامل')
    )
    
    password = forms.CharField(
        widget=forms.PasswordInput(attrs={
            'class': 'form-control',
            'placeholder': 'كلمة المرور'
        }),
        label=_('كلمة المرور')
    )
    
    def clean(self):
        username = self.cleaned_data.get('username')
        password = self.cleaned_data.get('password')

        if username is not None and password:
            self.user_cache = authenticate(
                self.request, 
                username=username, 
                password=password
            )
            if self.user_cache is None:
                raise self.get_invalid_login_error()
            else:
                self.confirm_login_allowed(self.user_cache)

        return self.cleaned_data
    
    def get_invalid_login_error(self):
        return forms.ValidationError(
            _('اسم المستخدم أو كلمة المرور غير صحيحة. تأكد من كتابة اسمك الكامل بشكل صحيح إذا كنت طبيباً معتمداً.'),
            code='invalid_login',
        )