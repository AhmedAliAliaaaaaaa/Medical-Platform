from doctors.models import Doctor
from .models import AdminMessage

def admin_context(request):
    """إضافة متغيرات مشتركة لجميع صفحات الإدارة"""
    context = {}
    
    # التحقق من أن المستخدم مشرف
    if request.user.is_authenticated and request.user.user_type == 'admin':
        # أرقام مختصرة للأيقونات والتنبيهات في القالب العام
        context['pending_doctors_count'] = Doctor.objects.filter(status='pending').count()
        context['pending_cases'] = 0  # يمكن إضافة المزيد لاحقاً
        context['unread_admin_messages'] = AdminMessage.objects.filter(
            recipient=request.user,
            is_read=False,
        ).count()
    
    return context