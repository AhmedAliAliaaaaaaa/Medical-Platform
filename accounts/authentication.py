from django.contrib.auth.backends import ModelBackend
from django.contrib.auth import get_user_model
from django.db.models import Q

User = get_user_model()

class CustomAuthenticationBackend(ModelBackend):
    """
    نظام مصادقة مخصص يدعم تسجيل الدخول بـ:
    - اسم المستخدم
    - البريد الإلكتروني
    - الاسم الكامل للأطباء
    """
    
    def authenticate(self, request, username=None, password=None, **kwargs):
        if username is None or password is None:
            return None
        
        user = None
        
        try:
            # أولاً: البحث التقليدي (اسم المستخدم أو البريد الإلكتروني)
            user = User.objects.filter(
                Q(username=username) | Q(email=username)
            ).first()
            
            # ثانياً: إذا لم نجد، ابحث بالاسم الكامل للأطباء المعتمدين فقط
            if not user:
                from doctors.models import Doctor
                
                # تنظيف النص المدخل
                search_name = username.strip()
                name_parts = search_name.split()
                
                # البحث بالاسم الكامل المطابق تماماً
                doctors = Doctor.objects.filter(
                    status='approved'  # فقط الأطباء المعتمدين
                ).select_related('user')
                
                for doctor in doctors:
                    full_name = doctor.user.get_full_name().strip()
                    if full_name.lower() == search_name.lower():
                        user = doctor.user
                        break
                
                # إذا لم نجد مطابقة تامة، جرب البحث بالأجزاء
                if not user and len(name_parts) >= 2:
                    first_name = name_parts[0]
                    last_name = ' '.join(name_parts[1:])
                    
                    doctors = Doctor.objects.filter(
                        status='approved',  # فقط الأطباء المعتمدين
                        user__first_name__iexact=first_name,
                        user__last_name__icontains=last_name
                    ).select_related('user')
                    
                    if doctors.exists():
                        user = doctors.first().user
                elif not user and len(name_parts) == 1:
                    # البحث بالاسم الأول فقط
                    doctors = Doctor.objects.filter(
                        status='approved',  # فقط الأطباء المعتمدين
                        user__first_name__iexact=search_name
                    ).select_related('user')
                    
                    if doctors.exists():
                        user = doctors.first().user
            
            # التحقق من كلمة المرور
            if user and user.check_password(password):
                return user
                
        except Exception as e:
            # في حالة حدوث خطأ، نعود للطريقة التقليدية
            pass
        
        # العودة للطريقة التقليدية
        return super().authenticate(request, username, password, **kwargs)