from doctors.models import Doctor

def admin_context(request):
    """إضافة متغيرات مشتركة لجميع صفحات الإدارة"""
    context = {}
    
    # التحقق من أن المستخدم مشرف
    if request.user.is_authenticated and request.user.user_type == 'admin':
        # أرقام مختصرة للأيقونات والتنبيهات في القالب العام
        context['pending_doctors_count'] = Doctor.objects.filter(status='pending').count()
        context['pending_cases'] = 0  # يمكن إضافة المزيد لاحقاً
    
    return context