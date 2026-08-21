import re
from django.core.exceptions import ValidationError
from django.utils.translation import gettext_lazy as _

class UnicodeUsernameValidator:
    """
    Validator للسماح بأسماء المستخدمين باللغة العربية والإنجليزية
    يسمح بالأحرف العربية والإنجليزية والأرقام والشرطة السفلية والنقطة
    """
    regex = r'^[\w\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF.@+-]+$'
    message = _(
        'يجب أن يحتوي اسم المستخدم على أحرف عربية أو إنجليزية أو أرقام أو الرموز التالية: @/./+/-/_ فقط.'
    )
    flags = 0

    def __call__(self, value):
        if not re.match(self.regex, value, self.flags):
            raise ValidationError(self.message, code='invalid')

def validate_arabic_english_username(value):
    """
    التحقق من صحة اسم المستخدم - يسمح بالعربية والإنجليزية
    """
    # السماح بالأحرف العربية والإنجليزية والأرقام والرموز الأساسية
    pattern = r'^[\w\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF.@+-]+$'
    
    if not re.match(pattern, value):
        raise ValidationError(
            'اسم المستخدم يجب أن يحتوي على أحرف عربية أو إنجليزية أو أرقام أو الرموز: @/./+/-/_ فقط',
            code='invalid_username'
        )
    
    # التحقق من الطول
    if len(value) < 3:
        raise ValidationError(
            'اسم المستخدم يجب أن يكون 3 أحرف على الأقل',
            code='username_too_short'
        )
    
    if len(value) > 150:
        raise ValidationError(
            'اسم المستخدم يجب أن يكون 150 حرف كحد أقصى',
            code='username_too_long'
        )
    
    # التحقق من عدم البدء برقم أو رمز
    if value[0].isdigit() or value[0] in '@.+-_':
        raise ValidationError(
            'اسم المستخدم يجب أن يبدأ بحرف عربي أو إنجليزي',
            code='invalid_username_start'
        )

def validate_arabic_english_name(value):
    """
    التحقق من صحة الأسماء - يسمح بالعربية والإنجليزية والمسافات
    """
    # السماح بالأحرف العربية والإنجليزية والمسافات
    pattern = r'^[\w\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s]+$'
    
    if not re.match(pattern, value):
        raise ValidationError(
            'الاسم يجب أن يحتوي على أحرف عربية أو إنجليزية فقط',
            code='invalid_name'
        )
    
    # التحقق من الطول
    if len(value.strip()) < 2:
        raise ValidationError(
            'الاسم يجب أن يكون حرفين على الأقل',
            code='name_too_short'
        )